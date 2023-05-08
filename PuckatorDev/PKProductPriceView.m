//
//  PKProductPriceView.m
//  PuckatorDev
//
//  Created by Luke Dixon on 09/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductPriceView.h"
#import "PKProductPrice.h"
#import "PKProductPrice+Operations.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import "UIView+Animate.h"

@interface PKProductPriceView ()

// Properties:
@property (weak, nonatomic) PKProductPrice *productPrice;

// UI:
@property (strong, nonatomic) UILabel *labelQuantity;
@property (strong, nonatomic) UILabel *labelPrice;

@property (strong, nonatomic) NSNumber *oldPrice;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *quantity;

@end

@implementation PKProductPriceView

#pragma mark - Constructor Methods

+ (instancetype)createWithProductPrice:(PKProductPrice *)productPrice oldPrice:(NSNumber *)oldPrice frame:(CGRect)frame {
    PKProductPriceView *productPriceView = [[PKProductPriceView alloc] initWithFrame:frame];
    [productPriceView setProductPrice:productPrice];
    [productPriceView setOldPrice:oldPrice];
    [productPriceView setPrice:[productPrice value]];
    [productPriceView setQuantity:[productPrice quantity]];
    [productPriceView setupUI];
    return productPriceView;
}

+ (instancetype)createWithPrice:(NSNumber *)price quantity:(NSNumber *)quantity frame:(CGRect)frame {
    PKProductPriceView *productPriceView = [[PKProductPriceView alloc] initWithFrame:frame];
    [productPriceView setQuantity:quantity];
    [productPriceView setPrice:price];
    [productPriceView setupUI];
    return productPriceView;
}

#pragma mark - Private Methods

- (void)setupUI {
    // Setup the labels:
    CGRect labelQuantityFrame = CGRectMake(0, 0, [self bounds].size.width, [self bounds].size.height * 0.5f);
    [self setLabelQuantity:[[UILabel alloc] initWithFrame:labelQuantityFrame]];
    CGRect labelPriceFrame = CGRectMake(0, [self bounds].size.height * 0.5f, [self bounds].size.width, [self bounds].size.height * 0.5f);
    [self setLabelPrice:[[UILabel alloc] initWithFrame:labelPriceFrame]];
    
    [[self labelQuantity] setPuckatorBoldFont];
    [[self labelPrice] setPuckatorStandardFont];
    [[self labelQuantity] setTextColor:[UIColor whiteColor]];
    [[self labelPrice] setTextColor:[UIColor whiteColor]];
    [[self labelQuantity] setTextAlignment:NSTextAlignmentCenter];
    [[self labelPrice] setTextAlignment:NSTextAlignmentCenter];
    
    [[self labelQuantity] setText:[NSString stringWithFormat:@"%i+", [[[self productPrice] quantity] intValue]]];
    [[self labelQuantity] setText:[NSString stringWithFormat:@"%d+", [[self quantity] intValue]]];
    
    NSString *formattedPrice = nil;
    if ([self productPrice]) {
        formattedPrice = [PKProductPrice formattedPrice:[[self productPrice] priceWithCurrentFxRate:[self price]]];
    } else {
        formattedPrice = [PKProductPrice formattedPrice:[self price]];
    }
    
    if ([[self oldPrice] doubleValue] != 0.0) {
        UIFont *font = [UIFont fontWithName:[[[self labelPrice] font] fontName] size:12];
        NSDictionary *strikethrough = @{NSStrikethroughStyleAttributeName : [NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle],
                                        NSFontAttributeName : font};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        //[attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[PKProductPrice formattedPrice:[self price]] attributes:nil]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:formattedPrice attributes:nil]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        NSNumber *currentPrice = [[self productPrice] priceWithCurrentFxRate];
        if ([[self oldPrice] floatValue] <= [currentPrice floatValue]) {            
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"🏷️" attributes:nil]];
        } else {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[PKProductPrice formattedPrice:[self oldPrice]] attributes:strikethrough]];
        }
        
        [[self labelPrice] setAttributedText:attributedString];
    } else {
        [[self labelPrice] setText:formattedPrice];
        
//        if ([self productPrice]) {
//            [[self labelPrice] setText:[PKProductPrice formattedPrice:[[self productPrice] priceWithCurrentFxRate:[self price]]]];
//        } else {
//            [[self labelPrice] setText:[PKProductPrice formattedPrice:[self price]]];
//        }
    }
    
    [self addSubview:[self labelQuantity]];
    [self addSubview:[self labelPrice]];
    
    // Setup the gestures:
    [self setupGestureRecognizers];
}

- (void)setupGestureRecognizers {
    // Setup the tap gesture recognizer:
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [tapGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - Event Methods

- (void)viewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    switch ([tapGestureRecognizer state]) {
        case UIGestureRecognizerStateRecognized: {
            [[tapGestureRecognizer view] pop];
            if ([self productPrice]) {
                if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkProductPriceView:wasTappedWithProductPrice:)]) {
                    [[self delegate] pkProductPriceView:self wasTappedWithProductPrice:[self productPrice]];
                }
            } else {
                if ([[self delegate] respondsToSelector:@selector(pkProductPriceView:wasTappedWithPrice:quantity:)]) {
                    [[self delegate] pkProductPriceView:self wasTappedWithPrice:[self price] quantity:[self quantity]];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Public Methods

- (void)setTintColor:(UIColor *)tintColor {
    [[self labelQuantity] setTextColor:tintColor];
    [[self labelPrice] setTextColor:tintColor];
}

#pragma mark -

@end
