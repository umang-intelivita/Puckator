//
//  PKBasketItemTableViewCell.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasketItemTableViewCell.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"
#import "PKBasketItem+Operations.h"     // Huh?  Why is this a warning..?
#import "PKImage+Operations.h"
#import "NSString+Utils.h"
#import "PKProductPrice+Operations.h"
#import "PKInvoice.h"

@interface PKBasketItemTableViewCell ()

@property (strong, nonatomic) NSNumberFormatter *formatter;
@property (strong, nonatomic) NSMutableAttributedString *attributedMetaData;
@property (strong, nonatomic) NSDictionary *boldAttributes;
@property (strong, nonatomic) NSDictionary *standardAttributes;

@end

@implementation PKBasketItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) updateStyleWithBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor {
    int radius = 4;
    //if ([[[self btnPrice] layer] cornerRadius] != radius) {
        // Update button color
        [[self btnPrice] setBackgroundColor:backgroundColor];
        [[self btnQuantity] setBackgroundColor:backgroundColor];
        
        // Update button text
        [[self btnPrice] setTitleColor:textColor forState:UIControlStateNormal];
        [[self btnQuantity] setTitleColor:textColor forState:UIControlStateNormal];
        
        // Update corner radius
        [[[self btnPrice] layer] setCornerRadius:radius];
        [[self btnPrice] setClipsToBounds:YES];
        [[[self btnQuantity] layer] setCornerRadius:radius];
        [[self btnQuantity] setClipsToBounds:YES];
    //}
}

- (void) setupInteractions {
    // Add tap gesture to the image:
    if ([[[self imageViewProduct] gestureRecognizers] count] == 0) {
        [[self imageViewProduct] setUserInteractionEnabled:YES];
        
        // Setup the tap gesture:
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
        [[self imageViewProduct] addGestureRecognizer:tapGestureRecognizer];
        
        // Configure events for buttons:
        [[self btnPrice] addTarget:self action:@selector(didTapPrice:) forControlEvents:UIControlEventTouchUpInside];
        [[self btnQuantity] addTarget:self action:@selector(didTapQuanity:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) updateWithBasketItem:(PKBasketItem*)basketItem atIndexPath:(NSIndexPath*)indexPath {
    [self updateWithBasketItem:basketItem atIndexPath:indexPath editable:YES];
}

- (void)updateWithInvoice:(PKInvoice *)invoice invoiceLine:(PKInvoiceLine *)invoiceLine atIndexPath:(NSIndexPath *)indexPath {
    PKProduct *product = [PKProduct findWithProductCode:[invoiceLine productCode] forFeedConfig:nil inContext:nil];
    
    NSString *currencyCode = [[PKCurrency currencyInfoForCurrencyCode:[invoice currencyType]] objectForKey:@"iso"];
    NSNumber *price = [NSDecimalNumber divide:[invoiceLine itemNetAmount] by:[invoiceLine orderQty]];
    
    NSString *formattedPrice = [PKProductPrice formattedPrice:price withIsoCode:currencyCode];
    NSString *formattedTotal = [PKProductPrice formattedPrice:[invoiceLine itemNetAmount] withIsoCode:currencyCode];
    
    [self updateWithProduct:product
                productCode:[invoiceLine productCode]
             formattedPrice:formattedPrice
                   quantity:[invoiceLine orderQty]
             formattedTotal:formattedTotal
                atIndexPath:indexPath
                   editable:NO];
}

- (void) updateWithBasketItem:(PKBasketItem*)basketItem atIndexPath:(NSIndexPath*)indexPath editable:(BOOL)editable {
    [self updateWithProduct:[basketItem product]
                productCode:[[basketItem product] model]
             formattedPrice:[basketItem unitPriceForFxRateFormatted]
                   quantity:[basketItem quantity]
             formattedTotal:[basketItem totalFormatted]
                atIndexPath:indexPath
                   editable:editable];
}

- (void)updateWithProduct:(PKProduct *)product
              productCode:(NSString *)productCode
           formattedPrice:(NSString *)formattedPrice
                 quantity:(NSNumber *)quantity
           formattedTotal:(NSString *)formattedTotal
              atIndexPath:(NSIndexPath *)indexPath
                 editable:(BOOL)editable {
    // Update the cell style
    if (editable) {
        [self updateStyleWithBackgroundColor:[UIColor puckatorPrimaryColor] textColor:[UIColor whiteColor]];
    } else {
        [self updateStyleWithBackgroundColor:[UIColor clearColor] textColor:[UIColor puckatorProductTitle]];
    }
    
    // Get the product from Core Data:
    if (product) {
        // Update the product title
        if ([[product title] length] >= 1) {
            [[self labelProductTitle] setText:[product title]];
        } else {
            [[self labelProductTitle] setText:@"?"];
        }
        
        // Update the image:
        [[product mainImage] setThumbAsyncToImageView:[self imageViewProduct]];
        
        // Update meta
        if (![self attributedMetaData]) {
            [self setAttributedMetaData:[[NSMutableAttributedString alloc] init]];
        }
        
        // Clear the clear attributed meta data:
        [[[self attributedMetaData] mutableString] setString:@""];
        
        // Setup the bold attributes:
        if (![self boldAttributes]) {
            [self setBoldAttributes:@{NSFontAttributeName:[UIFont puckatorContentTextBold]}];
        }
        NSDictionary *boldAttributes = [self boldAttributes];
        
        // Setup the standard attributes:
        if (![self standardAttributes]) {
            [self setStandardAttributes:@{NSFontAttributeName:[UIFont puckatorContentText]}];
        }
        NSDictionary *regularAttributes = [self standardAttributes];
        
        PKFeedConfig *activeFeed = [[PKSession sharedInstance] currentFeedConfig];

        
        // Setup the meta data for this product:
        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", NSLocalizedString(@"Stock", nil)] attributes:regularAttributes]];
        
        if ([activeFeed.name isEqualToString:@"EU"]) {
            [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%i", [[product stockLevelEDC] intValue]] padWithTrailingWhitespace:0] attributes:boldAttributes]];

        } else {
            [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%i", [[product stockLevel] intValue]] padWithTrailingWhitespace:0] attributes:boldAttributes]];
        }

        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t" attributes:regularAttributes]];
  
        if ([activeFeed.name isEqualToString:@"EU"]) {
            [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@: %i)", NSLocalizedString(@"Available", nil), [[product availableStockEDC] intValue]] attributes:regularAttributes]];
        } else {
            [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@: %i)", NSLocalizedString(@"Available", nil), [[product availableStock] intValue]] attributes:regularAttributes]];
        }
        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t\t" attributes:regularAttributes]];
        
        NSDictionary *stockData = [product stockDateAvaliableData];
        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", [stockData valueForKey:@"title"]] attributes:regularAttributes]];
        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%@", [stockData valueForKey:@"value"]] padWithTrailingWhitespace:10] attributes:boldAttributes]];
        
        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:regularAttributes]];
        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", NSLocalizedString(@"Code", nil)] attributes:regularAttributes]];
        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:[[product model] padWithTrailingWhitespace:10] attributes:boldAttributes]];
        [[self attributedMetaData] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t\t" attributes:regularAttributes]];
        
        //formattedStockAvaliableDate
        [[self labelMetaData] setNumberOfLines:0];
        [[self labelMetaData] setAttributedText:[self attributedMetaData]];
    } else {
        // Update cell with error info
        [[self labelProductTitle] setText:@"Product not found"];
        [[self imageViewProduct] setImage:[UIImage imageNamed:@"PKNoImage.png"]];
        [[self labelMetaData] setText:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Code", nil), productCode]];
    }
    
    [[self btnPrice] setTitle:formattedPrice forState:UIControlStateNormal];
    
    // Create a number formatter
    if (![self formatter]) {
        [self setFormatter:[[NSNumberFormatter alloc] init]];
        [[self formatter] setLocale:[NSLocale currentLocale]];
    }
    
    // Update the price
    [[self formatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[self labelRowTotal] setText:formattedTotal];
    
    // Update the quantity
    [[self formatter] setNumberStyle:NSNumberFormatterNoStyle];
    [[self btnQuantity] setTitle:[[self formatter] stringFromNumber:quantity] forState:UIControlStateNormal];
    
    // Enable or disable the edit buttons:
    if (!editable) {
        [[self btnQuantity] setEnabled:NO];
        [[self btnPrice] setEnabled:NO];
    } else {
        [[self btnQuantity] setEnabled:YES];
        [[self btnPrice] setEnabled:YES];
    }
    
    // Update the index number
    [[self labelIndex] setText:[NSString stringWithFormat:@"#%d", (int)indexPath.row+1]];
    
    // Update interactions
    [self setupInteractions];
}

#pragma mark - Integrations

- (void) didTapImage:(id)sender {
    NSLog(@"Tapped Image");
    if([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkBasketItemTableViewCell:didSelectInteractionElement:)]) {
        [[self selectionDelegate] pkBasketItemTableViewCell:self didSelectInteractionElement:@"image"];
    }
}

- (void) didTapQuanity:(id)sender {
    NSLog(@"Tapped Qty");
//    if([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkBasketItemTableViewCell:didSelectInteractionElement:)]) {
//        [[self selectionDelegate] pkBasketItemTableViewCell:self didSelectInteractionElement:@"quantity"];
//    }
    
    if ([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkBasketItemTableViewCell:didSelectInteractionElement:name:)]) {
        [[self selectionDelegate] pkBasketItemTableViewCell:self didSelectInteractionElement:sender name:@"quantity"];
    }
}

- (void) didTapPrice:(id)sender {
    NSLog(@"Tapped Price");
    if ([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkBasketItemTableViewCell:didSelectInteractionElement:name:)]) {
        [[self selectionDelegate] pkBasketItemTableViewCell:self didSelectInteractionElement:sender name:@"price"];
    }
}

@end
