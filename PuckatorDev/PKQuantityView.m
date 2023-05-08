//
//  PKQuantityView.m
//  PuckatorDev
//
//  Created by Luke Dixon on 15/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKQuantityView.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"
#import "UIButton+AllStates.h"
#import "PKProductPrice+Operations.h"
#import "PKBasket+Operations.h"
#import "PKCustomerSelectionDelegate.h"
#import "PKCustomersViewController.h"
#import "UIView+Extended.h"
#import "UIView+Animate.h"
#import "PKConstant.h"

typedef enum : NSUInteger {
    BasketActionAdd,
    BasketActionChangeQuantity,
    BasketActionRemove,
} BasketAction;

@interface PKQuantityView ()

@property (weak, nonatomic) PKProduct *product;
@property (strong, nonatomic) UITextField *textFieldQuantity;
@property (strong, nonatomic) UILabel *labelPrice;
@property (strong, nonatomic) UIButton *buttonAdd;
@property (strong, nonatomic) UIButton *buttonOptions;
@property (strong, nonatomic) UIView *viewLine;
@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) UIButton *buttonClear;
@property (assign, nonatomic) BOOL isEditingQuantity;

// Pricing:
@property (assign, nonatomic) BOOL customPriceSet;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *discount;
@property (strong, nonatomic) NSNumber *quantity;

@end

@implementation PKQuantityView

@synthesize price = _price;

#pragma mark - View Lifecycle 

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Public Methods

- (void)setProduct:(PKProduct *)product andDelegate:(id<PKQuantityViewDelegate>)delegate {
    if ([[[PKSession sharedInstance] discountAmount] doubleValue] > 0.f) {
        [self setDiscount:[[PKSession sharedInstance] discountAmount]];
    } else {
        [self setDiscount:[NSNumber numberWithFloat:0.0f]];
    }
    
    [self setProduct:product];
    [self setDelegate:delegate];
}

- (void)updatePrice:(NSNumber *)price quantity:(NSNumber *)quantity {
    [self setDiscount:@(0)];
    [self setQuantity:quantity];
    [self setPrice:price];
    [self setCustomPriceSet:YES];
}

- (void)updateWithProductPrice:(PKProductPrice *)productPrice {
    [self setPrice:[productPrice priceWithCurrentFxRate]];
    [self setQuantity:[productPrice quantity]];
    [self setCustomPriceSet:NO];
}

- (void)updateWithQuantity:(NSNumber *)quantity {
    [self setQuantity:quantity];
}

#pragma mark - Overidden Methods

- (void)setProduct:(PKProduct *)product {
    _product = product;
    
    // Attempt to set the quantity to 1, this method will round the value to the closest purchase unit:
    NSNumber *lastQuantity = [[PKSession sharedInstance] lastQuantityForProduct:_product];
    [self setQuantity:lastQuantity];
}

- (NSNumber *)price {
    // Default the current price:
    NSNumber *price = _price;
    
    // Always get the most expensive price when appling discounts:
    if ([[self discount] doubleValue] > 0.f) {
        PKProductPrice *productPrice = [[[self product] sortedPrices] firstObject];
        if (productPrice) {
            return [productPrice priceWithCurrentFxRate];
        }
    }
    
    // Make sure to round the price to 2 decimal places:
    return price;
}

- (void)setDiscount:(NSNumber *)discount {
    _discount = discount;
    [self setPrice:[self price]];
}

- (NSNumber *)priceWithDiscount {
    return [self priceWithDiscount:[self price]];
}

- (NSNumber *)priceWithDiscount:(NSNumber *)price {
    //NSNumber *discount = (100.0 - [self discount]) / 100.0;
    
    NSDecimalNumber *number100 = [NSDecimalNumber decimalNumberWithString:@"100.0"];
    NSDecimalNumber *numberDiscount = [NSDecimalNumber decimalNumberWithNumber:[self discount]];
    numberDiscount = [number100 decimalNumberBySubtracting:numberDiscount];
    numberDiscount = [numberDiscount decimalNumberByDividingBy:number100];
    
    NSDecimalNumber *numberPrice = [NSDecimalNumber decimalNumberWithNumber:price];
    //NSDecimalNumber *numberDiscount = [NSDecimalNumber decimalNumberWithString:[@(discount) stringValue]];
    
    
    
    NSDecimalNumber *numberResult = [numberPrice decimalNumberByMultiplyingBy:numberDiscount];
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                              scale:2
                                                                                   raiseOnExactness:NO
                                                                                    raiseOnOverflow:NO
                                                                                   raiseOnUnderflow:NO
                                                                                raiseOnDivideByZero:NO];
    NSDecimalNumber *numberRounded = [numberResult decimalNumberByRoundingAccordingToBehavior:behavior];
    return (NSNumber *)numberRounded;
}

- (NSNumber *)priceWithDiscountWithoutFxRateForProductPrice:(PKProductPrice *)productPrice {
    return [self priceWithDiscount:[self price]];
}

- (void)setPrice:(NSNumber *)price {
    _price = price;
    
    // Refresh the UI:
    NSString *priceStr = [PKProductPrice formattedPriceWithAtPrefix:[self priceWithDiscount:[self price]]];
    [[self labelPrice] setText:priceStr];
    [[self labelPrice] sizeToFit];
    [[self labelPrice] setHeight:[[self textFieldQuantity] height]];
    [[self labelPrice] setCenter:CGPointMake([[self labelPrice] center].x, [[self textFieldQuantity] center].y)];
    [[self buttonClear] setFrame:CGRectMake(CGRectGetMaxX([[self labelPrice] frame]) + 10,
                                            0,
                                            [[self buttonClear] frame].size.width,
                                            [[self buttonClear] frame].size.height)];
    [[self buttonClear] setCenter:CGPointMake([[self buttonClear] center].x, [[self labelPrice] center].y)];
    
    // Determine if the label needs to be resized to fit the price in:
    int buttonClearWidth = [self smallMode] ? 0 : [[self buttonClear] width];
    int labelWidth = [self width] - [[self labelPrice] x] - [[self buttonAdd] width] - buttonClearWidth;
    if ([[self labelPrice] width] > labelWidth) {
        [[self labelPrice] setWidth:labelWidth];
        [[self buttonClear] setX:CGRectGetMaxX([[self labelPrice] frame])];
    }
}

- (void)setQuantity:(NSNumber *)quantity {
    // Clamp the quantity to a purchase unit:
    _quantity = [[self product] purchaseUnitQuantityForRequestedQuantity:quantity];
    
    // Update the price:
    PKProductPrice *productPrice = [[self product] priceForQuantity:_quantity];
    [self setPrice:[productPrice priceWithCurrentFxRate]];
    [self setCustomPriceSet:NO];
    
    // Update the text field for quantity:
    [[self textFieldQuantity] setText:[[self product] formattedPurchaseUnitQuantityForRequestedQuantity:[self quantity]]];
    if ([[[self textFieldQuantity] text] intValue] == [[[self product] purchaseUnit] intValue] || [self smallMode]) {
        [[self buttonClear] setHidden:YES];
    } else {
        [[self buttonClear] setHidden:NO];
    }
}

#pragma mark - Interface Methods

- (void)prepareForInterfaceBuilder {
    [self setupUI];
}

#pragma mark - Private Methods

- (BOOL)smallMode {
    if ([self frame].size.width < 300) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setupUI {
    [[self layer] setCornerRadius:10];
    [self setBackgroundColor:[UIColor puckatorDarkBlue]];
    
    int padding = 10;
    int viewHeight = [self bounds].size.height;
    int elementHeight = viewHeight - (padding * 2);
    
    int viewWidth = [self bounds].size.width;
    int remainingWidth = viewWidth - (padding * 4);
    int textFieldWidth = remainingWidth * 0.2f;
    int labelWidth = remainingWidth * 0.4f;
    int buttonWidth = remainingWidth * 0.4f;
    
    if ([self smallMode]) {
        textFieldWidth = remainingWidth * 0.3f;
        labelWidth = remainingWidth * 0.4f;
        buttonWidth = remainingWidth * 0.3f;
    }
    
    // Setup gesture recognizers:
    if ([[self gestureRecognizers] count] == 0) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayKeyPad:)]];
    }
    
    if (![self textFieldQuantity]) {
        [self setTextFieldQuantity:[[UITextField alloc] initWithFrame:CGRectMake(padding, padding, textFieldWidth, elementHeight)]];
        [[self textFieldQuantity] setBackgroundColor:[UIColor whiteColor]];
        [[[self textFieldQuantity] layer] setCornerRadius:5];
        [[self textFieldQuantity] setFont:[UIFont puckatorFontBoldWithSize:23]];
        [[self textFieldQuantity] setTextColor:[UIColor puckatorDarkGreen]];
        [[self textFieldQuantity] setDelegate:self];
        [[self textFieldQuantity] setTextAlignment:NSTextAlignmentCenter];
        [[self textFieldQuantity] setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin];
        [[self textFieldQuantity] setMinimumFontSize:0.5f];
        [self addSubview:[self textFieldQuantity]];
    }
    
    if (![self labelPrice]) {
        [self setLabelPrice:[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX([[self textFieldQuantity] frame]) + padding,
                                                                      0,
                                                                      labelWidth,
                                                                      viewHeight)]];
        [[self labelPrice] setText:@"@ £0.29"];
        [[self labelPrice] setFont:[UIFont puckatorFontBoldWithSize:23]];
        [[self labelPrice] setTextColor:[UIColor whiteColor]];
        [[self labelPrice] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self labelPrice] setMinimumScaleFactor:0.25f];
        [[self labelPrice] setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:[self labelPrice]];
    }
    
    if (![self buttonAdd]) {
        [self setButtonAdd:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[[self buttonAdd] titleLabel] setFont:[UIFont puckatorFontBoldWithSize:18]];
        [[self buttonAdd] setTitleColorForAllStates:[UIColor puckatorLightBlue]];
        
        int width = [self smallMode] == YES ? buttonWidth : (buttonWidth * 0.5f);
        [[self buttonAdd] setFrame:CGRectMake(viewWidth - buttonWidth, 0, width, viewHeight)];
        [[self buttonAdd] setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [[self buttonAdd] addTarget:self action:@selector(buttonAddPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonAdd] setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15f]];
        [self addSubview:[self buttonAdd]];
        [self refreshAddButton];
    }
    
    if (![self buttonOptions] && [self smallMode] == NO) {
        [self setButtonOptions:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[[self buttonOptions] titleLabel] setFont:[UIFont puckatorFontBoldWithSize:18]];
        [[self buttonOptions] setTitleColorForAllStates:[UIColor puckatorLightBlue]];
        [[self buttonOptions] setFrame:CGRectMake(viewWidth - (buttonWidth * 0.5f), 0, (buttonWidth * 0.5f), viewHeight)];
        [[self buttonOptions] setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [[self buttonOptions] addTarget:self action:@selector(buttonOptionsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonOptions] setImageForAllStates:[UIImage imageNamed:@"TabOptions"]];
        [[self buttonOptions] setTintColor:[UIColor whiteColor]];
        //[[self buttonOptions] setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15f]];
        [self addSubview:[self buttonOptions]];
    }
    
    if (![self viewLine]) {
        [self setViewLine:[[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX([[self buttonAdd] frame]), 0, 1, viewHeight)]];
        [[self viewLine] setBackgroundColor:[UIColor puckatorSeparatorLight]];
        [[self viewLine] setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self addSubview:[self viewLine]];
    }
    
    if (![self buttonClear]) {
        [self setButtonClear:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[self buttonClear] setImageForAllStates:[[UIImage imageNamed:@"31-circle-x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [[self buttonClear] setTintColor:[UIColor whiteColor]];
        [[self buttonClear] sizeToFit];
        [[self buttonClear] addTarget:self action:@selector(buttonClearPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:[self buttonClear]];
    }
    
    // Setup notifications:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBasketStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAddButton) name:kNotificationBasketStatusChanged object:nil];
}

- (void)refreshAddButton {
    [[self buttonAdd] setTintColor:[UIColor whiteColor]];
    [[self buttonAdd] setTitleForAllStates:nil];
    
    if ([PKBasket sessionBasket]) {
        [[self buttonAdd] setImageForAllStates:[UIImage imageNamed:@"IconBasketAdd"]];
    } else {
        [[self buttonAdd] setImageForAllStates:[UIImage imageNamed:@"IconCustomerSelect"]];
    }
}

- (void)displayKeyPad:(UIGestureRecognizer *)gestureRecognizer {
    PKKeyPad *numericPad = nil;
    
    // Setup a PKNumericPad:
    if ([self isEditingQuantity]) {
        [self setIsEditingQuantity:NO];
        numericPad = [PKKeyPad createWithProduct:[self product] mode:PKKeyPadModeQuantity delegate:self];
        [numericPad setIdentifier:@"quantity"];
    } else {
        if (gestureRecognizer) {
            CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
            int padding = 20;
            if (location.x > (CGRectGetMaxX([[self textFieldQuantity] frame]) + padding)) {
                numericPad = [PKKeyPad createWithProduct:[self product] mode:PKKeyPadModePrice delegate:self];
                [numericPad setIdentifier:@"price"];
            } else {
                numericPad = [PKKeyPad createWithProduct:[self product] mode:PKKeyPadModeQuantity delegate:self];
                [numericPad setIdentifier:@"quantity"];
            }
        }
    }
    
    // Setup a UIPopoverController:
    [self setPopoverController:[[UIPopoverController alloc] initWithContentViewController:numericPad]];
    [[self popoverController] presentPopoverFromRect:[self frame]
                                              inView:[self superview]
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
}

- (void)dismissKeyPad {
    if ([self popoverController]) {
        [[self popoverController] dismissPopoverAnimated:NO];
        [self setPopoverController:nil];
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self setIsEditingQuantity:YES];
    [self dismissKeyPad];
    [self displayKeyPad:nil];
    return NO;
}

#pragma mark - Event Methods

- (void)buttonOptionsPressed:(id)sender {
    // Check for main thread:
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(buttonOptionsPressed:) withObject:sender waitUntilDone:NO];
        return;
    }
    
    if (sender == [self buttonOptions]) {
        //[sender pop];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Basket Options", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Add option:
    UIAlertAction *actionAdd = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self buttonAddPressed:nil];
    }];
    
    // Remove option:
    UIAlertAction *actionRemove = [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self runBasketAction:BasketActionRemove];
    }];
    
    // Change quantity:
    UIAlertAction *actionQuantity = [UIAlertAction actionWithTitle:NSLocalizedString(@"Change Quantity", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self runBasketAction:BasketActionChangeQuantity];
    }];
    
    // Cancel:
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    if (![PKBasket sessionBasket]) {
        [actionAdd setValue:NSLocalizedString(@"Create Order", nil) forKeyPath:@"title"];
        [alertController addAction:actionAdd];
        [alertController addAction:actionCancel];
    } else {
        [alertController addAction:actionAdd];
        [alertController addAction:actionQuantity];
        [alertController addAction:actionRemove];
        [alertController addAction:actionCancel];
    }
    
    [[alertController popoverPresentationController] setSourceView:sender];
    [[alertController popoverPresentationController] setSourceRect:[sender bounds]];
    [[alertController popoverPresentationController] setPermittedArrowDirections:UIPopoverArrowDirectionUp];
    [[self viewController] presentViewController:alertController animated:NO completion:^{
    }];
    [self layoutIfNeeded];
    [[self viewController] view];
    [[[self viewController] view] layoutIfNeeded];
}

- (void)buttonAddPressed:(id)sender {
    if (sender == [self buttonAdd]) {
        [sender pop];
    }
    
    [self runBasketAction:BasketActionAdd];
}

- (void)runBasketAction:(BasketAction)action {
    // Check for current customer session:
    if (![[PKSession sharedInstance] currentCustomer]) {
        PKCustomersViewController *customers = [PKCustomersViewController createWithMode:PKCustomersViewControllerModeSelect delegate:self];
        UINavigationController *navigationController = [customers withNavigationController];
        [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        [[self viewController] presentViewController:navigationController animated:YES completion:^{
        }];
        return;
    }
    
    // Get the current basket:
    PKBasket *basket = [PKBasket sessionBasket];
    if (basket) {
        // Get PKProductPrice depending on QTY
        
        NSNumber *quantity = [NSNumber numberWithInt:[[[self textFieldQuantity] text] intValue]];
        [[PKSession sharedInstance] setLastQuantity:quantity forProduct:[self product]];
        PKProductPrice *priceObject = [[self product] priceForQuantity:quantity];
        
        NSLog(@"Matched! %@", [[self product] cartonPrice]);
        NSLog(@"Matched! %@", [self price]);
        NSLog(@"Matched! %@", [[self product] midPrice]);
        NSLog(@"Matched! %@", [[self product] wholesalePrice]);
        NSLog(@"Matched! %@", [[self product] midQuantity]);
        NSLog(@"Matched! %@", [[self product] carton]);
        NSLog(@"Matched! %@", [[self product] minOrderQuantity]);
        NSLog(@"totalproductInCard %@", [self quantity]);
        NSNumber *minprice = [[self product] minOrderQuantity];
        PKProductPrice *pricessss = [[self product] priceForQuantity:minprice];
        
        NSNumber *finalfirstprice = [self priceWithDiscountWithoutFxRateForProductPrice:pricessss];
        NSLog(@"Matched! %@", finalfirstprice);
//        NSLog(@"Matched! %@", BasketActionRemove);
        
        
        if ([self quantity] >= [[self product] carton] ) {
            
            // Add or change quantity:
            PKBasketItem *basketItem = [basket addOrUpdateProduct:[self product]
                                                         quantity:(action == BasketActionRemove ? @(-1) : quantity)
                                                            price:[[self product] cartonPrice]
                                                   customPriceSet:[self customPriceSet]
                                               productPriceObject:priceObject
                                                      incremental:(action == BasketActionAdd)
                                                          context:nil];
            
            if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkQuantityView:addedBasketItem:)]) {
                [[self delegate] pkQuantityView:self addedBasketItem:basketItem];
            }
            
        }
        
        if ([self quantity] >= [[self product] midQuantity] && [self quantity] < [[self product] carton] ) {
            
            
            // Add or change quantity:
            PKBasketItem *basketItem = [basket addOrUpdateProduct:[self product]
                                                         quantity:(action == BasketActionRemove ? @(-1) : quantity)
                                                            price:[[self product] midPrice]
                                                   customPriceSet:[self customPriceSet]
                                               productPriceObject:priceObject
                                                      incremental:(action == BasketActionAdd)
                                                          context:nil];
            
            if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkQuantityView:addedBasketItem:)]) {
                [[self delegate] pkQuantityView:self addedBasketItem:basketItem];
            }
        }
        
        
        if ([[self product] isLOCK_TO_CARTON_QTY] == true || [[self product] isLOCK_TO_CARTON_PRICE] == true) {
            

            NSLog(@"Matched! %@", [[self product] cartonPrice]);
            
            NSNumber *midtier = [[self product] midQuantity];
            NSNumber *lasttier = [[self product] carton];
            
            if (quantity > midtier) {
                
                
                priceObject = [[self product] midPrice];
            }
            
          
//            [[self delegate] pkKeyPad:self didSelectPrice:[[self product] midPrice] quantity:[[self product] midQuantity]];
            
        }else{
            
           
        }
        
        
       
        
        
//        // Add or change quantity:
//        PKBasketItem *basketItem = [basket addOrUpdateProduct:[self product]
//                                                     quantity:(action == BasketActionRemove ? @(-1) : quantity)
//                                                        price:[self priceWithDiscountWithoutFxRateForProductPrice:priceObject]
//                                               customPriceSet:[self customPriceSet]
//                                           productPriceObject:priceObject
//                                                  incremental:(action == BasketActionAdd)
//                                                      context:nil];
        
      
    }
    
    // Refresh the add button title:
    [self refreshAddButton];
}

- (void)buttonClearPressed:(id)sender {
    if (sender == [self buttonClear]) {
        [sender pop];
    }
    
    [self setQuantity:[[[self product] price] quantity]];
}

#pragma mark - PKKeyPadDelegate Methods

- (void)pkKeyPad:(PKKeyPad *)keyPad didEnterValue:(NSNumber *)value {
    if ([[keyPad identifier] isEqualToString:@"price"]) {
        [self setDiscount:@(0)];
        [self setPrice:value];
        [self setCustomPriceSet:YES];
    } else {
        [self setQuantity:value];
    }
    [self dismissKeyPad];
}

- (void)pkKeyPad:(PKKeyPad *)keyPad didSelectPrice:(NSNumber *)price quantity:(NSNumber *)quantity {
    if (quantity > 0) {
        [self setQuantity:quantity];
    }
    
    [self setDiscount:@(0.0f)];
    [self setPrice:price];
    [self dismissKeyPad];
}

- (void)pkKeyPad:(PKKeyPad *)keyPad didSelectDiscount:(NSNumber *)discount quantity:(NSNumber *)quantity {
    if (quantity > 0) {
        [self setQuantity:quantity];
    }
    
    [self setDiscount:discount];
   // [self dismissKeyPad];
}

- (void)pkKeyPad:(PKKeyPad *)keyPad didSelectQuantity:(NSNumber *)quantity {
    [self setQuantity:quantity];
    [self dismissKeyPad];
}

#pragma mark - PKCustomersViewControllerDelegate Methods

- (void)pkCustomerSelectionDelegateSelectedCustomer:(PKCustomer *)customer andCreatedBasket:(PKBasket *)basket {
    [self buttonAddPressed:nil];
    [[self viewController] dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Memory Management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

@end
