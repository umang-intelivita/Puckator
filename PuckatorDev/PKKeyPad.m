//
//  PKNumericPad.m
//  PuckatorDev
//
//  Created by Luke Dixon on 21/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKKeyPad.h"
#import "UIButton+AllStates.h"
#import "UIColor+Puckator.h"
#import "PKBasketItem+Operations.h"
#import "PKProductPrice+Operations.h"
#import <AFSoundManager/AFSoundManager.h>
#import "UIFont+Puckator.h"
#import "UIView+Animate.h"
#import "PKConstant.h"

@interface PKKeyPad ()

@property (weak, nonatomic) IBOutlet UIView *viewKeypadContainer;
@property (weak, nonatomic) IBOutlet UILabel *labelValue;
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UIButton *buttonConfirm;
@property (weak, nonatomic) IBOutlet UILabel *labelPurchaseUnit;
@property (weak, nonatomic) IBOutlet UILabel *labelInner;
@property (weak, nonatomic) IBOutlet UILabel *labelCarton;
@property (weak, nonatomic) IBOutlet UILabel *labelPrices;
@property (weak, nonatomic) IBOutlet UILabel *labelCPCQ;
@property (weak, nonatomic) PKProduct *product;
@property (weak, nonatomic) PKBasketItem *basketItem;

@property (weak, nonatomic) IBOutlet UIButton *buttonWholesale;
@property (weak, nonatomic) IBOutlet UIButton *buttonMidPrice;
@property (weak, nonatomic) IBOutlet UIButton *buttonCarton;
@property (weak, nonatomic) IBOutlet UIButton *buttonDiscount;

@property (strong, nonatomic) NSNumber *functionValue;
@property (assign, nonatomic) PKKeyPadFunction function;
@property (nonatomic, assign) PKKeyPadMode mode;

@property (weak, nonatomic) IBOutlet UIView *viewDiscountContainer;
@property (weak, nonatomic) IBOutlet UIButton *buttonClearDiscount;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *discountButtons;
@property (assign, nonatomic) BOOL isShowingDiscounts;
@property (assign, nonatomic) CGRect discountContainerFrame;
@property (weak, nonatomic) IBOutlet UIButton *buttonDecimal;


@end

@implementation PKKeyPad

#pragma mark -

+ (instancetype)createWithProduct:(PKProduct *)product delegate:(id<PKKeyPadDelegate>)delegate {
    PKKeyPad *keyPad = [[PKKeyPad alloc] initWithNibName:@"PKKeyPad" bundle:nil];
    [keyPad setProduct:product];
    [keyPad setDelegate:delegate];
    return keyPad;
}

+ (instancetype)createWithProduct:(PKProduct *)product mode:(PKKeyPadMode)mode delegate:(id<PKKeyPadDelegate>)delegate {
    PKKeyPad *keyPad = [[PKKeyPad alloc] initWithNibName:@"PKKeyPad" bundle:nil];
    [keyPad setMode:mode];
    [keyPad setProduct:product];
    [keyPad setDelegate:delegate];
    return keyPad;
}

+ (instancetype)createWithBasketItem:(PKBasketItem *)basketItem delegate:(id<PKKeyPadDelegate>)delegate {
    return [PKKeyPad createWithBasketItem:basketItem mode:PKKeyPadModeQuantity delegate:delegate];
}

+ (instancetype)createWithBasketItem:(PKBasketItem *)basketItem mode:(PKKeyPadMode)mode delegate:(id<PKKeyPadDelegate>)delegate {
    PKKeyPad *keyPad = [[PKKeyPad alloc] initWithNibName:@"PKKeyPad" bundle:nil];
    [keyPad setBasketItem:basketItem];
    [keyPad setProduct:[basketItem product]];
    [keyPad setDelegate:delegate];
    [keyPad setMode:mode];
    return keyPad;
}

+ (instancetype)createWithIdentifier:(NSString *)identifier mode:(PKKeyPadMode)mode delegate:(id<PKKeyPadDelegate>)delegate {
    PKKeyPad *keyPad = [[PKKeyPad alloc] initWithNibName:@"PKKeyPad" bundle:nil];
    [keyPad setDelegate:delegate];
    [keyPad setIdentifier:identifier];
    [keyPad setMode:mode];
    return keyPad;
}

- (void)setMode:(PKKeyPadMode)mode {
    _mode = mode;
    
    if (_mode == PKKeyPadModeDecimal) {
        [[self viewDiscountContainer] setHidden:YES];
        [[self viewDiscountContainer] setUserInteractionEnabled:NO];
    }
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGSize)preferredContentSize {
    if ([self mode] == PKKeyPadModeDecimal || [self mode] == PKKeyPadModeQuantity) {
        return CGSizeMake([[self viewKeypadContainer] size].width + ([[self viewKeypadContainer] x] * 2), 450);
    } else {
        return CGSizeMake(450, 450);
    }
}

#pragma mark - Private Methods

- (NSNumber *)inputValue {
    // Get the input text from the label:
    NSString *inputText = [[self labelValue] text];
    
    // Replace any commas:
    inputText = [inputText stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    // Cast the input text into a float value:
    //float value = [inputText floatValue];
    return (NSNumber *)[NSDecimalNumber decimalNumberWithString:inputText];
}

- (void)clearInputValue {
    [[self labelValue] setText:@"0"];
}

- (void)setInputValue:(NSNumber *)inputValue {
    // Always round up the input value:
    if ([self mode] == PKKeyPadModeQuantity) {
        inputValue = @(ceilf([inputValue floatValue]));
    }
    
    // Update the UI:
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
    [fmt setPositiveFormat:@"0.##"];
    [[self labelValue] setText:[fmt stringFromNumber:inputValue]];
    //[[self labelValue] setText:[NSString stringWithFormat:@"%.2f", inputValue]];
}

- (void)buttonConfirmEnabled:(BOOL)enabled {
    [[self buttonConfirm] setEnabled:enabled];
    [[self buttonConfirm] setAlpha:enabled ? 1.0f : 0.25f];
}

- (void)setupView {
    [[self viewDiscountContainer] setBackgroundColor:[UIColor clearColor]];
    if ([self mode] == PKKeyPadModeQuantity) {
        [[self view] setBackgroundColor:[UIColor puckatorDarkGreen]];
        [[self view] setTintColor:[UIColor puckatorDarkGreen]];
    } else {
        [[self view] setBackgroundColor:[UIColor puckatorPrimaryColor]];
    }
  
    
    // Update the confirm enabled:
    [self buttonConfirmEnabled:NO];
    
    // Hide the clear button:
    [[self buttonClear] setHidden:YES];
    
    // Style the buttons:
    [[self labelValue] setTextColor:[UIColor puckatorPrimaryColor]];
    [[[self viewKeypadContainer] layer] setCornerRadius:5];
    [[self viewKeypadContainer] setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:1.0f]];
    
    UIColor *buttonColor = [UIColor puckatorPrimaryColor];
    [[[self viewKeypadContainer] subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            if (button != [self buttonClear]) {
                [button setBackgroundColor:[UIColor clearColor]];
                [[button layer] setCornerRadius:[button frame].size.height * 0.5f];
                [[button layer] setBorderWidth:1.2];
                [[button layer] setBorderColor:[buttonColor CGColor]];
                [button setTitleColorForAllStates:buttonColor];
            }
        }
    }];
    
   
    
    if ([self mode] == PKKeyPadModeQuantity) {
        [[self buttonDecimal] setEnabled:NO];
        [[self buttonDecimal] setAlpha:0.25f];
        [[self viewDiscountContainer] setHidden:YES];
        [[self viewDiscountContainer] setUserInteractionEnabled:NO];
    } else if ([self mode] == PKKeyPadModeDecimal) {
        [[self viewDiscountContainer] setHidden:YES];
        [[self viewDiscountContainer] setUserInteractionEnabled:NO];
    }
        
    [[self buttonClear] setImageRenderingModeForAllStates:UIImageRenderingModeAlwaysTemplate];
    [[self buttonClear] setTintColor:[UIColor puckatorPrimaryColor]];
    
    // Setup the carton label:
    [[self labelCarton] setAttributedText:[UIFont puckatorAttributedStringWithStandardText:NSLocalizedString(@"Carton: ", nil)
                                                                                  boldText:[NSString stringWithFormat:@"%i", [[[self product] carton] intValue]]
                                                                                  fontSize:14]];
    [[self labelCarton] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelQuantityTapped:)]];
    [[self labelCarton] setUserInteractionEnabled:YES];
    [[self labelCarton] setTag:[[[self product] carton] intValue]];
    
    // Setup the purchase unit label:
    [[self labelPurchaseUnit] setAttributedText:[UIFont puckatorAttributedStringWithStandardText:NSLocalizedString(@"Purchase Unit: ", nil)
                                                                                        boldText:[NSString stringWithFormat:@"%i", [[[self product] purchaseUnit] intValue]]
                                                                                        fontSize:14]];
    [[self labelPurchaseUnit] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelQuantityTapped:)]];
    [[self labelPurchaseUnit] setUserInteractionEnabled:YES];
    [[self labelPurchaseUnit] setTag:[[[self product] purchaseUnit] intValue]];
    
    // Setup the inner label:
    [[self labelInner] setAttributedText:[UIFont puckatorAttributedStringWithStandardText:NSLocalizedString(@"Inner: ", nil)
                                                                                 boldText:[NSString stringWithFormat:@"%i",
                                                                                       [[[self product] inner] intValue]]
                                                                                 fontSize:14]];
    [[self labelInner] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelQuantityTapped:)]];
    [[self labelInner] setUserInteractionEnabled:YES];
    [[self labelInner] setTag:[[[self product] inner] intValue]];
    
    // Setup the prices UI:
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [[self labelPrices] setTextAlignment:NSTextAlignmentRight];
    
    if ([[self product] cartonPrice])  {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@"Prices(CP)"]
                                                                                 attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor whiteColor]]]];
    } else {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Prices", nil) attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:18] color:[UIColor whiteColor]]]];
    }
    
    
    if ([[self product] isLOCK_TO_CARTON_QTY] == true || [[self product] isLOCK_TO_CARTON_PRICE] == true) {
        
        [[self labelCPCQ] setText:@"CPCQ"];
    }else if ([[self product] isLOCK_TO_CARTON_QTY] == false || [[self product] isLOCK_TO_CARTON_PRICE] == true) {
        
        [[self labelCPCQ] setText:@"CP"];
    }else if ([[self product] isLOCK_TO_CARTON_QTY] == true || [[self product] isLOCK_TO_CARTON_PRICE] == false) {
        
        [[self labelCPCQ] setText:@"CQ"];
    }else{
        
        [[self labelCPCQ] setText:@""];
    }

    
    
    

    [[[self product] sortedPrices] enumerateObjectsUsingBlock:^(PKProductPrice *productPrice, NSUInteger idx , BOOL *stop) {
        
      
       
//        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [productPrice formattedPrice]]
//                                                                                 attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor whiteColor]]]];
        
//        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n CPCQ"]
//                                                                                 attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor whiteColor]]]];
        
        
        if (idx == 2) {
            
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%i+", [[productPrice quantity] intValue]]
                                                                                     attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:16] color:[UIColor whiteColor]]]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [productPrice formattedPrice]]
                                                                                     attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor whiteColor]]]];

        }else{
            
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%i+ ", [[productPrice quantity] intValue]]
                                                                                     attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:16] color:[UIColor whiteColor]]]];
            
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [productPrice formattedPrice]]
                                                                                     attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor whiteColor]]]];
        }
    }];
//    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] init];
//    [attributedString1 appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n CPCQ"]
//                                                                                  attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor whiteColor]]]];
//
//    [attributedString appendAttributedString:attributedString1];
   
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineHeightMultiple:1.3f];
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    [attributedString addAttributes:@{NSParagraphStyleAttributeName : paragraphStyle} range:NSMakeRange(0, [attributedString length])];
    [[self labelPrices] setAttributedText:attributedString];
    
    float labelPricesWidth = [[self labelPrices] bounds].size.width;
    [[self labelPrices] sizeToFit];
    [[self labelPrices] setWidth:labelPricesWidth];

    [self styleButton:[self buttonCarton]];
    [self styleButton:[self buttonWholesale]];
    [self styleButton:[self buttonMidPrice]];
    [self styleButton:[self buttonDiscount]];
    
    if ([self basketItem]) {
        [[self buttonCarton] setHidden:YES];
        [[self buttonWholesale] setHidden:YES];
        [[self buttonDiscount] setHidden:YES];
        [[self buttonMidPrice] setHidden:YES];
    }
    
    if ([self mode] == PKKeyPadModeDecimal || [self mode] == PKKeyPadModeQuantity) {
        [[self buttonCarton] setHidden:YES];
        [[self buttonWholesale] setHidden:YES];
        [[self buttonMidPrice] setHidden:YES];
        [[self buttonDiscount] setHidden:YES];
        [[self labelPrices] setHidden:YES];
        [[self labelCarton] setHidden:YES];
        [[self labelInner] setHidden:YES];
        [[self labelPurchaseUnit] setHidden:YES];
    }
}

- (void)styleButton:(UIButton *)button {
    [self styleButton:button useBackgroundColor:NO];
}

- (void)styleButton:(UIButton *)button useBackgroundColor:(BOOL)useBackgroundColor {
    UIColor *backgroundColor = [button backgroundColor];
    
    if (!useBackgroundColor) {
        backgroundColor = [UIColor whiteColor];
    }
    
    if (!useBackgroundColor) {
        [button setBackgroundColor:[UIColor clearColor]];
    }
    [[button layer] setBorderColor:[backgroundColor CGColor]];
    [[button layer] setBorderWidth:1.2];
    [[button layer] setCornerRadius:[button bounds].size.width * 0.5f];
    [button setTitleColorForAllStates:[UIColor whiteColor]];
}

- (void)setupFunction:(PKKeyPadFunction)function {
    // Set the current function:
    [self setFunction:function];
    
    // Update the confirm enabled:
    [self buttonConfirmEnabled:YES];
    
    if ([self function] != PKKeyPadFunctionNone) {
        // Save the current value as the function value:
        [self setFunctionValue:[self inputValue]];

        // Clear the current value:
        [self clearInputValue];
        
        // Change the confirm button:
        [[self buttonConfirm] setTitleForAllStates:@"="];
        
        // Change color back to normal
        [[[self buttonConfirm] layer] setBorderColor:[[UIColor puckatorPrimaryColor] CGColor]];
        [[self buttonConfirm] setBackgroundColor:[UIColor clearColor]];
        [[self buttonConfirm] setTitleColor:[UIColor puckatorPrimaryColor] forState:UIControlStateNormal];
    } else {
        // Clear the function value:
        [self setFunctionValue:0];
        
        // Change the confirm button:
        [[self buttonConfirm] setTitleForAllStates:@"⏎"];
        
        // Highlight with pink to confirm the action
        [[[self buttonConfirm] layer] setBorderColor:[[UIColor puckatorGreen] CGColor]];
        [[self buttonConfirm] setBackgroundColor:[UIColor puckatorGreen]];
        [[self buttonConfirm] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)performFunction {
    // Create an output value (set to current input in case the function fails):
    NSNumber *outputValue = [self inputValue];
    
    // Perform the function:
    switch ([self function]) {
        default:
        case PKKeyPadFunctionNone:
            break;
        case PKKeyPadFunctionAdd:
            outputValue = [NSDecimalNumber add:[self functionValue] to:[self inputValue]];
            break;
        case PKKeyPadFunctionSubtract:
            outputValue = [NSDecimalNumber subtract:[self inputValue] from:[self functionValue]];
            break;
        case PKKeyPadFunctionMultiply:
            outputValue = [NSDecimalNumber multiply:[self functionValue] by:[self inputValue]];
            break;
        case PKKeyPadFunctionDivide:
            outputValue = [NSDecimalNumber divide:[self functionValue] by:[self inputValue]];
            break;
    }
    
    if ([outputValue floatValue] < 0) {
        outputValue = @(0.f);
    }
    
    // Set the output value:
    [self setInputValue:outputValue];
    
    // Clear the function:
    [self setupFunction:PKKeyPadFunctionNone];
}

#pragma mark - Event Methods

- (void)buttonDiscountValuePressed:(id)sender {
    [sender pop];

    if ([[self delegate] respondsToSelector:@selector(pkKeyPad:didSelectDiscount:quantity:)]) {
        int discount = (int)[(UIButton *)sender tag];
    
        for(UIButton *button in self.discountButtons) {
            if (button.tag == discount) {
                [[button layer] setBorderColor:[[UIColor blackColor] CGColor]];
                [[button layer] setBorderWidth:3.2];
            } else {
                [[button layer] setBorderColor:[[UIColor clearColor] CGColor]];
                [[button layer] setBorderWidth:3.2];
            }
            
            if (button.tag == 11111) {
                if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkKeyPad:didSelectPrice:quantity:)]) {
                    // Convert the product price:
                    
                    [[button layer] setBorderColor:[[UIColor blackColor] CGColor]];
                    [[button layer] setBorderWidth:3.2];
                    
                    //[[self delegate] pkKeyPad:self didSelectPrice:[[self product] cartonPrice] quantity:[self inputValue]];
                    [[self delegate] pkKeyPad:self didSelectPrice:[[self product] cartonPrice] quantity:[[self product] carton]];
                    
                    // Setup the prices UI:
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
                    [[self labelPrices] setTextAlignment:NSTextAlignmentRight];
                    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Prices", nil) attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:18] color:[UIColor whiteColor]]]];
                    [[[self product] sortedPrices] enumerateObjectsUsingBlock:^(PKProductPrice *productPrice, NSUInteger idx, BOOL *stop) {
                        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%i+ ", [[productPrice quantity] intValue]]
                                                                                                 attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:16] color:[UIColor whiteColor]]]];
                        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [productPrice formattedPrice]]
                                                                                                 attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor whiteColor]]]];
                        if ([[self product] cartonPrice])  {
                            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",@"CP"]
                                                                                                     attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor whiteColor]]]];
                        }
                    }];
                    
                    return;
                }
            }
        }
        
//        switch (discount) {
//            case 5:
//
//
//                break;
//            case 10:
//                if (btn.tag == discount) {
//                    [[btn layer] setBorderColor:[[UIColor blackColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                } else {
//                    [[btn layer] setBorderColor:[[UIColor clearColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                }
//                break;
//
//            case 15:
//                if (btn.tag == discount) {
//                    [[btn layer] setBorderColor:[[UIColor blackColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                } else {
//                    [[btn layer] setBorderColor:[[UIColor clearColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                }
//                break;
//
//            case 20:
//                if (btn.tag == discount) {
//                    [[btn layer] setBorderColor:[[UIColor blackColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                } else {
//                    [[btn layer] setBorderColor:[[UIColor clearColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                }
//                break;
//
//            case 35:
//                if (btn.tag == discount) {
//                    [[btn layer] setBorderColor:[[UIColor blackColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                } else {
//                    [[btn layer] setBorderColor:[[UIColor clearColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                }
//                break;
//
//            case 37:
//                if (btn.tag == discount) {
//                    [[btn layer] setBorderColor:[[UIColor blackColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                } else {
//                    [[btn layer] setBorderColor:[[UIColor clearColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                }
//                break;
//
//            case 40:
//                if (btn.tag == discount) {
//                    [[btn layer] setBorderColor:[[UIColor blackColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                } else {
//                    [[btn layer] setBorderColor:[[UIColor clearColor] CGColor]];
//                    [[btn layer] setBorderWidth:1.2];
//                }
//                break;
//            default:
//                [[btn layer] setBorderColor:[[UIColor clearColor] CGColor]];
//                [[btn layer] setBorderWidth:1.2];
//                break;
//        }
       
       
        [[self delegate] pkKeyPad:self didSelectDiscount:@(discount) quantity:[self inputValue]];
    }
}

- (IBAction)buttonDiscountPressed:(UIButton *)button {
    [button pop];
        
    [[self viewDiscountContainer] setBackgroundColor:[UIColor clearColor]];
    [[self discountButtons] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self styleButton:obj useBackgroundColor:YES];
        [(UIButton *)obj addTarget:self action:@selector(buttonDiscountValuePressed:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    if (CGRectEqualToRect([self discountContainerFrame], CGRectZero)) {
        [self setDiscountContainerFrame:[[self viewDiscountContainer] frame]];
    }
    
    [UIView animateWithDuration:0.35f usingSpringWithDamping:0.75f initialSpringVelocity:0.25f animations:^{
        if ([self isShowingDiscounts]) {
            [[self labelPrices] setAlpha:1.0f];
            [[self labelCPCQ] setAlpha:1.0f];
            [[self viewDiscountContainer] setFrame:[self discountContainerFrame]];
        } else {
            [[self labelPrices] setAlpha:0.0f];
            [[self labelCPCQ] setAlpha:0.0f];
            [[self viewDiscountContainer] setFrame:CGRectMake([[self viewDiscountContainer] frame].origin.x,
                                                              [[self view] bounds].size.height - [[self viewDiscountContainer] bounds].size.height,
                                                              [[self viewDiscountContainer] frame].size.width,
                                                              [[self viewDiscountContainer] frame].size.height)];
        }
    } completion:^(BOOL finished) {
        
        for(UIButton *button in self.discountButtons) {
            if ([[self product] isLOCK_TO_CARTON_QTY] == false || [[self product] isLOCK_TO_CARTON_PRICE] == true) {
                
                
                
            }
            
            if ([[self product] isLOCK_TO_CARTON_QTY] == false || [[self product] isLOCK_TO_CARTON_PRICE] == true) {
                
                if (button.tag == 11111) {
                    [[button layer] setBorderColor:[[UIColor blackColor] CGColor]];
                    [[button layer] setBorderWidth:3.2];
                } else {
                    [[button layer] setBorderColor:[[UIColor clearColor] CGColor]];
                    [[button layer] setBorderWidth:3.2];
                }
                
            }else{
                
                if (button.tag == 40) {
                    [[button layer] setBorderColor:[[UIColor blackColor] CGColor]];
                    [[button layer] setBorderWidth:3.2];
                } else {
                    [[button layer] setBorderColor:[[UIColor clearColor] CGColor]];
                    [[button layer] setBorderWidth:3.2];
                }
            }
            
            
        }
        
        [self setIsShowingDiscounts:![self isShowingDiscounts]];
    }];
}

- (IBAction)buttonClearPressed:(id)sender {
    [sender pop];
    
    [[self labelValue] setText:@"0"];
    [[self buttonClear] setHidden:YES];
}

- (IBAction)buttonNumberPressed:(id)sender {
    [sender pop];
    
    // Update the confirm enabled:
    [self buttonConfirmEnabled:YES];
    
    int tag = (int)[(UIButton *)sender tag];
    NSString *enteredValue = nil;
    
    if (tag < 0) {
        enteredValue = @".";
    } else {
        enteredValue = [NSString stringWithFormat:@"%i", tag];
    }
    
    NSString *currentValue = nil;
    //if ([[[self labelValue] text] intValue] != 0) {
        currentValue = [[self labelValue] text];
    //}
    
    if (currentValue) {
        if ([enteredValue isEqualToString:@"."] && [currentValue containsString:@"."]) {
            
        } else if ([enteredValue isEqualToString:@"0"] && [currentValue isEqualToString:@"0"]) {
            [[self labelValue] setText:@"0"];
            
        } else if ([currentValue isEqualToString:@"0"]) {
            [[self labelValue] setText:enteredValue];
        }else {
            [[self labelValue] setText:[NSString stringWithFormat:@"%@%@", currentValue, enteredValue]];
        }
    } else {
        [[self labelValue] setText:enteredValue];
    }
    
    if ([[[self labelValue] text] length] != 0 && ![[[self labelValue] text] isEqualToString:@"0"]) {
        [[self buttonClear] setHidden:NO];
    } else {
        [[self buttonClear] setHidden:YES];
    }
}

- (IBAction)buttonConfirmPressed:(id)sender {
    [sender pop];
    
    // Preform price check to see if the value entered is greater
    // than the top tier price:
    if (sender && [self mode] == PKKeyPadModePrice) {
        if ([self product]) {
            NSArray *prices = [[self product] sortedPrices];
            PKProductPrice *productPrice = [prices firstObject];
            if (productPrice) {
                if ([[productPrice priceWithCurrentFxRate] floatValue] < [[self inputValue] floatValue]) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Price Check", nil)
                                                                                             message:NSLocalizedString(@"You have entered a price greater than the top tier price.\n\nAre you sure you want to apply this price?", nil)
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"Apply Price", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self buttonConfirmPressed:nil];
                    }];
                    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertController addAction:actionConfirm];
                    [alertController addAction:actionCancel];
                    [self presentViewController:alertController animated:YES completion:^{
                    }];
                    return;
                }
            }
        }
    }
    
    // Check for a function:
    if ([self function] == PKKeyPadFunctionNone) {
        if ([self basketItem]) {
            // If price change mode
            if ([self mode] == PKKeyPadModePrice) {
                [[self basketItem] setUnitPrice:[self inputValue]];  // ...?
                [[self basketItem] setIsCustomPriceSet:@(YES)];
            } else {
                if ([self mode] == PKKeyPadModeQuantity && [[self inputValue] floatValue] < 1.0f) {
                    [[self basketItem] updateQuantity:@(1.0f)];
                } else {
                    [[self basketItem] updateQuantity:[self inputValue]];
                }
            }
        }
        
        // No function therefore update the delegate:
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkKeyPad:didEnterValue:)]) {
            if ([self mode] == PKKeyPadModeQuantity && [[self inputValue] floatValue] < 1.0f) {
                [[self delegate] pkKeyPad:self didEnterValue:@(1.0f)];
            } else {
                [[self delegate] pkKeyPad:self didEnterValue:[self inputValue]];
            }
        }
    } else {
        // There is a function therefore perform the function:
        [self performFunction];
    }
}

- (IBAction)buttonAddPressed:(id)sender {
    [sender pop];
    [self setupFunction:PKKeyPadFunctionAdd];
}

- (IBAction)buttonSubtractPressed:(id)sender {
    [sender pop];
    [self setupFunction:PKKeyPadFunctionSubtract];
}

- (IBAction)buttonMultiplyPressed:(id)sender {
    [sender pop];
    [self setupFunction:PKKeyPadFunctionMultiply];
}

- (IBAction)buttonDividePressed:(id)sender {
    [sender pop];
    [self setupFunction:PKKeyPadFunctionDivide];
}

- (IBAction)buttonMidPricePressed:(id)sender {
    [sender pop];
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkKeyPad:didSelectPrice:quantity:)]) {
        // Convert the product price:
        [[self delegate] pkKeyPad:self didSelectPrice:[[self product] midPrice] quantity:[[self product] midQuantity]];
    }
}

- (IBAction)buttonWholesalePressed:(id)sender {
    [sender pop];
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkKeyPad:didSelectDiscount:quantity:)]) {
        NSNumber *discount = [NSDecimalNumber multiply:kPuckatorWholesaleDiscountPercentage by:@(100)];
        [[self delegate] pkKeyPad:self didSelectDiscount:discount quantity:[[self product] carton]];
    }
}

- (IBAction)buttonCartonPressed:(id)sender {
    [sender pop];
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkKeyPad:didSelectPrice:quantity:)]) {
        // Convert the product price:
                
        //[[self delegate] pkKeyPad:self didSelectPrice:[[self product] cartonPrice] quantity:[self inputValue]];
        [[self delegate] pkKeyPad:self didSelectPrice:[[self product] cartonPrice] quantity:[[self product] carton]];
    }
}

- (void)labelQuantityTapped:(UITapGestureRecognizer *)tapGesture {
    int quantity = (int)[[tapGesture view] tag];
    
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkKeyPad:didSelectQuantity:)]) {
        [[self delegate] pkKeyPad:self didSelectQuantity:@(quantity)];
    }
}

- (IBAction)buttonClearDiscountPressed:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(pkKeyPad:didSelectDiscount:quantity:)]) {
        [[self delegate] pkKeyPad:self didSelectDiscount:0 quantity:[self inputValue]];
    }
}

#pragma mark -

@end
