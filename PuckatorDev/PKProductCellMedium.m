//
//  PKProductCell.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKProductCellMedium.h"
#import "PKRankIndicator.h"
#import "UIView+Extended.h"
#import "PKBasket+Operations.h"
#import "PKBasketItem+Operations.h"
#import "PKBasketItem+UI.h"
#import "UIView+FrameHelper.h"
#import "PKCustomersViewController.h"
#import "PKProductPrice.h"
#import "PKProductPrice+Operations.h"
#import "UIFont+Puckator.h"
#import "UIView+Animate.h"

@interface PKProductCellMedium ()

@property (weak, nonatomic) PKProduct *product;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIView *viewQuantityContainer;
@property (weak, nonatomic) IBOutlet UIView *viewQuickQuantityContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewMain;
@property (weak, nonatomic) IBOutlet PKRankIndicator *rankIndicatorSales;
@property (weak, nonatomic) IBOutlet PKRankIndicator *rankIndicatorGrossing;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderAmount;
@property (weak, nonatomic) IBOutlet PKQuantityView *quantityView;

// Styling:
@property (strong, nonatomic) NSDictionary *attributeStandard;
@property (strong, nonatomic) NSDictionary *attributeStandardRed;
@property (strong, nonatomic) NSDictionary *attributeBold;
@property (strong, nonatomic) NSMutableAttributedString *attributedString;

// Data labels:
@property (weak, nonatomic) IBOutlet UILabel *labelPriceOne;
@property (weak, nonatomic) IBOutlet UILabel *labelPriceTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelPriceThree;
@property (weak, nonatomic) IBOutlet UILabel *labelPurchaseUnit;
@property (weak, nonatomic) IBOutlet UILabel *labelInner;
@property (weak, nonatomic) IBOutlet UILabel *labelCarton;
@property (weak, nonatomic) IBOutlet UILabel *labelStock;
@property (weak, nonatomic) IBOutlet UILabel *labelPreviousPrice;

// Low stock:
@property (strong, nonatomic) UIView *viewLowStock;

@end

@implementation PKProductCellMedium

- (void)awakeFromNib {
    // Initialization code
    [self setupView];
}

#pragma mark - Private Methods

- (void)setupView {
    [[[self viewQuantityContainer] layer] setCornerRadius:5];
    [[[self viewQuickQuantityContainer] layer] setCornerRadius:5];
    
    [[self labelOrderAmount] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelOrderAmountTapped:)]];
    [[self labelOrderAmount] setUserInteractionEnabled:YES];
}

- (void)loadProductImage:(PKProduct *)product {
    [[self imageViewMain] setImage:[product thumb]];
    //[[product mainImage] setThumbAsyncToImageView:[self imageViewMain]];
}

#pragma mark - Public Methods

- (void)setupWithProduct:(PKProduct *)product {
    [self setupWithProduct:product image:[product thumb]];
}

- (void)setupWithProduct:(PKProduct *)product image:(UIImage *)image {
    [self setProduct:product];
    [[self quantityView] setProduct:[self product] andDelegate:self];
    
    [[self labelTitle] setAttributedText:[product attributedTitleIncludeModel:YES includeCategories:NO]];
    [[self labelStock] setText:[NSString stringWithFormat:@"%@: %i (%i)", NSLocalizedString(@"Stock", nil), [[product stockLevel] intValue], [[product availableStock] intValue]]];
    [[self labelStock] setTextColor:[UIColor redColor]];
    
    [self loadProductImage:product];
    [self updateOrderAmountUI:nil];
    
    [[self rankIndicatorSales] setRankValue:[[product position] intValue]];
    [[self rankIndicatorGrossing] setRankValue:[[product valuePosition] intValue]];
        
    [self setupDataLabels];
}

- (void)setupWithProduct:(PKProduct *)product image:(UIImage *)image indexPath:(NSIndexPath *)indexPath {
    [[self labelTitle] setText:[NSString stringWithFormat:@"%i - %i", (int)[indexPath section], (int)[indexPath row]]];
}

- (void)setupDataLabels {
    if (![self attributedString]) {
        // Create an attributed string:
        [self setAttributedString:[[NSMutableAttributedString alloc] init]];
    } else {
        // Clear the current attributed string:
        [[[self attributedString] mutableString] setString:@""];
    }
    
    // Setup the bold attribute:
    if (![self attributeBold]) {
        [self setAttributeBold:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:14]]];
    }
    
    // Setup the standard attribute:
    if (![self attributeStandard]) {
        [self setAttributeStandard:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:12]]];
    }
    
    // Setup the standard attribute:
    if (![self attributeStandardRed]) {
        [self setAttributeStandardRed:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:12] color:[UIColor redColor]]];
    }
 
    // Setup the label text:
    NSArray *prices = [[self product] sortedPrices];
    
    NSArray *priceHistory = [[[PKSession sharedInstance] priceHistory] objectForKey:[[[self product] model] uppercaseString]];
    NSArray *labels = @[[self labelPriceOne], [self labelPriceTwo], [self labelPriceThree], [self labelPreviousPrice]];
    __block BOOL oldPricesFound = NO;
    
    [prices enumerateObjectsUsingBlock:^(PKProductPrice *productPrice, NSUInteger idx, BOOL *stop) {
        NSNumber *currentPrice = [productPrice priceWithCurrentFxRate];
        
        UILabel *label = nil;
        
        if (idx < [labels count]) {
            label = [labels objectAtIndex:idx];
        }
        
        // Clear the current attributed string:
        [[[self attributedString] mutableString] setString:@""];
        
        // Setup the label:
        if (label) {
            [label setNumberOfLines:0];
            
            [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i+ ", [[productPrice quantity] intValue]]
                                                                                            attributes:[self attributeStandard]]];
            [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[productPrice formattedPrice]
                                                                                            attributes:[self attributeBold]]];
            
            NSNumber *oldPrice = @(0.f);
            if (idx < [priceHistory count]) {
                oldPrice = [priceHistory objectAtIndex:idx];
            } else if ([productPrice oldPrice] > 0) {
                oldPrice = [productPrice oldPrice];
            }
            
            if ([oldPrice floatValue] > 0) {
                oldPricesFound = YES;
                oldPrice = [PKProductPrice priceWithGBP:oldPrice fxRate:[productPrice fxRate]];
                NSDictionary *strikethrough = @{NSStrikethroughStyleAttributeName : [NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle]};
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", [PKProductPrice formattedPrice:oldPrice]]
                                                                                       attributes:strikethrough];
                
                if ([oldPrice floatValue] <= [currentPrice floatValue]) {
                    attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", @"🏷️"]                     attributes:nil];
                }
                
                [[self attributedString] appendAttributedString:attributedString];
            }
    
            [label setAttributedText:[self attributedString]];
            
            CGSize size = [label sizeThatFits:CGSizeMake([label width], INT_MAX)];
            //[label setSize:CGSizeMake([label width], size.height)];
            
            [label setTag:idx];
            [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelPriceTapped:)]];
            [label setUserInteractionEnabled:YES];
        }
    }];
    
    NSDictionary *previousPrice = [[[PKSession sharedInstance] purchaseHistory] objectForKey:[[self product] model]];
    if ([previousPrice count] != 0) {
        NSNumber *unitAmount = [previousPrice objectForKey:@"unit_amount"];
        int qty = [[previousPrice objectForKey:@"qty"] intValue];
        
        [[[self attributedString] mutableString] setString:@""];
        [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d+ ", qty]
                                                                                        attributes:[self attributeStandard]]];
        [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[PKProductPrice formattedPrice:unitAmount]
                                                                                        attributes:[self attributeBold]]];
        [[self labelPreviousPrice] setAttributedText:[self attributedString]];
        [[self labelPreviousPrice] setHidden:NO];
        
        [[self labelPreviousPrice] setTextColor:[UIColor redColor]];
        [[self labelPreviousPrice] setUserInteractionEnabled:YES];
        [[self labelPreviousPrice] setTag:kPKProductCellPreviousPriceTag];
        [[self labelPreviousPrice] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelPriceTapped:)]];
    } else {
        [[self labelPreviousPrice] setHidden:YES];
    }
    
    // Layout the labels:
    int padding = 0;
    if (oldPricesFound) {
        padding = 0;
    }
    __block UILabel *previousLabel = nil;
    [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        if (previousLabel) {
            [label setY:CGRectGetMaxY([previousLabel frame]) + padding];
        }
        
        previousLabel = label;
    }];
    
    // Setup the purchase unit label:
    [[[self attributedString] mutableString] setString:@""];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"P / Unit", @"Purchase Unit")
                                                                                    attributes:[self attributeStandard]]];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@", [[self product] purchaseUnitFormatted]]
                                                                                    attributes:[self attributeBold]]];
    [[self labelPurchaseUnit] setAttributedText:[self attributedString]];
    [[self labelPurchaseUnit] setUserInteractionEnabled:YES];
    [[self labelPurchaseUnit] setTag:[[[self product] purchaseUnit] intValue]];
    [[self labelPurchaseUnit] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelQuantityTapped:)]];
    
    // Setup the inner label:
    [[[self attributedString] mutableString] setString:@""];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Inner", nil)
                                                                                    attributes:[self attributeStandard]]];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %i", [[[self product] inner] intValue]]
                                                                                    attributes:[self attributeBold]]];
    [[self labelInner] setAttributedText:[self attributedString]];
    [[self labelInner] setUserInteractionEnabled:YES];
    [[self labelInner] setTag:[[[self product] inner] intValue]];
    [[self labelInner] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelQuantityTapped:)]];
    
    // Setup the carton label:
    [[[self attributedString] mutableString] setString:@""];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Carton", nil)
                                                                                    attributes:[self attributeStandard]]];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %i", [[[self product] carton] intValue]]
                                                                                    attributes:[self attributeBold]]];
    [[self labelCarton] setAttributedText:[self attributedString]];
    [[self labelCarton] setUserInteractionEnabled:YES];
    [[self labelCarton] setTag:[[[self product] carton] intValue]];
    [[self labelCarton] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelQuantityTapped:)]];
    
    // Setup the stock label:
    [[[self attributedString] mutableString] setString:@""];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stock", nil)
                                                                                    attributes:[self attributeStandard]]];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": 🇬🇧 %i", [[[self product] stockLevel] intValue]]
                                                                                    attributes:[self attributeBold]]];
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" 🇪🇺 %i", [[[self product] stockLevelEDC] intValue]]
                                                                                    attributes:[self attributeBold]]];
    
    [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n(%@: 🇬🇧 %i 🇪🇺 %i)", NSLocalizedString(@"Available", nil), [[[self product] availableStock] intValue], [[[self product] availableStockEDC] intValue]]
                                                                                    attributes:([[[self product] availableStock] intValue] >= 0) ? [self attributeStandard] : [self attributeStandardRed]]];
    
    NSString *dueDateString = [[self product] nextDueDateFormatted];
    if (dueDateString) {
        [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n🇬🇧 %@", dueDateString]
                                                                                        attributes:[self attributeStandard]]];
    }
    
    dueDateString = [[self product] nextDueDateFormattedEDC];
    if (dueDateString) {
        [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n🇪🇺 %@", dueDateString]
                                                                                        attributes:[self attributeStandard]]];
    }
    
//    int backOrderQty = [[[[PKSession sharedInstance] backOrderProducts] objectForKey:[[self product] model]] intValue];
//    if (backOrderQty != 0) {
//        [[self attributedString] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"
//                                                                                        attributes:[self attributeStandard]]];
//        [[self attributedString] appendAttributedString:[[self product] attributedBackOrderString]];
//    }
    
    [[self labelStock] setNumberOfLines:0];
    [[self labelStock] setAttributedText:[self attributedString]];
    //[[self labelStock] sizeToFit];
}

#pragma mark - Event Methods

- (void)labelOrderAmountTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    if ([[[self labelOrderAmount] text] length] != 0) {
        [[[self viewController] tabBarController] setSelectedIndex:2];
    }
}

- (void)labelPriceTapped:(UITapGestureRecognizer *)tapGesture {
    [[tapGesture view] pop];
    int index = (int)[[tapGesture view] tag];
    
    if (index == kPKProductCellPreviousPriceTag) {
        NSDictionary *previousPrice = [[[PKSession sharedInstance] purchaseHistory] objectForKey:[[self product] model]];
        NSNumber *unitAmount = [previousPrice objectForKey:@"unit_amount"];
        NSNumber *qty = [previousPrice objectForKey:@"qty"];
        [[self quantityView] updatePrice:unitAmount quantity:qty];
    } else {
        PKProductPrice *productPrice = [[[self product] sortedPrices] objectAtIndex:index];
        [[self quantityView] updateWithProductPrice:productPrice];
    }
}

- (void)labelQuantityTapped:(UITapGestureRecognizer *)tapGesture {
    [[tapGesture view] pop];
    int quantity = (int)[[tapGesture view] tag];
    [[self quantityView] updateWithQuantity:@(quantity)];
}

#pragma mark - PKQuantityViewDelegate Methods

- (void)pkQuantityView:(PKQuantityView *)quantityView addedBasketItem:(PKBasketItem *)basketItem {
    [self updateOrderAmountUI:basketItem];
}

- (void)updateOrderAmountUI:(PKBasketItem *)basketItem {
    // Make sure we are running on the main thread:
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateOrderAmountUI:) withObject:basketItem waitUntilDone:NO];
        return;
    }
    
    // Added try catch as this method seems to be causing repeated issues:
    @try {
        // Attempt to load the basket item if one hasn't been passed:
        if (!basketItem) {
            basketItem = [[PKBasket sessionBasket] basketItemForProduct:[self product] context:nil];
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        
        // Add the basket item amount:
        if (basketItem) {
            NSAttributedString *orderAmountAttributedString = [basketItem orderAmountAttributedString];
            if ([orderAmountAttributedString length] != 0) {
                [attributedString appendAttributedString:orderAmountAttributedString];
            }
        }
        
        // Add the back order amount:
        if ([[self product] backOrderQty] != 0) {
            NSAttributedString *backOrderAttributedString = [[self product] attributedBackOrderString];
            
            if ([backOrderAttributedString length] != 0) {
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
                [attributedString appendAttributedString:[[self product] attributedBackOrderString]];
            }
        }
        
        if ([attributedString length] != 0) {
            [[self labelOrderAmount] setAttributedText:attributedString];
        } else {
            [[self labelOrderAmount] setAttributedText:nil];
            [[self labelOrderAmount] setText:nil];
        }
    } @catch (NSException *exception) {
        [[self labelOrderAmount] setAttributedText:nil];
        [[self labelOrderAmount] setText:nil];
    } @finally {
        
    }
}

#pragma mark -

@end
