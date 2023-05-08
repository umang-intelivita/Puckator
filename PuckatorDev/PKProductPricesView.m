//
//  PKProductPricesView.m
//  PuckatorDev
//
//  Created by Luke Dixon on 09/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductPricesView.h"
#import "UIView+Extended.h"
#import "UIColor+Puckator.h"
#import "NSArray+Extended.h"
#import "PKProductPrice.h"
#import "PKProductPrice+Operations.h"

@interface PKProductPricesView ()

@property (weak, nonatomic) PKProduct *product;
@property (strong, nonatomic) NSArray *prices;
@property (weak, nonatomic) id<PKProductPriceViewDelegate>delegate;

@end

@implementation PKProductPricesView

#pragma mark - Constructor Methods

+ (instancetype)createWithProduct:(PKProduct *)product delegate:(id<PKProductPriceViewDelegate>)delegate frame:(CGRect)frame {
    PKProductPricesView *productPricesView = [[PKProductPricesView alloc] initWithFrame:frame];
    [productPricesView setProduct:product];
    [productPricesView setDelegate:delegate];
    [productPricesView setPrices:[product sortedPrices]];
    [productPricesView setupUI];
    return productPricesView;
}

#pragma mark - Private Methods

- (void)setupUI {
    // Remove all subviews:
    [self removeAllSubviews];
    
    float pricesCount = [[self prices] count] == 0 ? 1.f : (float)[[self prices] count];
    
    // Get the price last paid:
    NSDictionary *previousPrice = [[[PKSession sharedInstance] purchaseHistory] objectForKey:[[self product] model]];
    if ([previousPrice count] != 0) {
        pricesCount += 1.0f;
    }
    
    NSArray *priceHistory = [[[PKSession sharedInstance] priceHistory] objectForKey:[[[self product] model] uppercaseString]];
    
    // Determine the width of each price view:
    float viewWidth = (float)[self frame].size.width;
    float width = floorf(viewWidth / pricesCount);
    
    int padding = 5;
    
    // Setup the UI for prices:
    for (int i = 0; i < pricesCount; i++) {
        CGRect frame = CGRectMake(i * width, padding, width, [self bounds].size.height - (padding * 2));
        
        PKProductPriceView *productPriceView = nil;
        
        if (i < [[self prices] count]) {
            PKProductPrice *productPrice = [[self prices] objectAtIndex:i];
            
            NSNumber *oldPrice = @(0.0f);
            if (i < [priceHistory count]) {
                oldPrice = [priceHistory objectAtIndex:i];
            } else if ([[productPrice oldPrice] doubleValue] > 0) {
                oldPrice = [productPrice oldPrice];
            }
            
            if (oldPrice > 0) {
                oldPrice = [PKProductPrice priceWithGBP:oldPrice fxRate:[productPrice fxRate]];
            }
            
            productPriceView = [PKProductPriceView createWithProductPrice:productPrice oldPrice:oldPrice frame:frame];
        } else {
            NSNumber *unitAmount = [previousPrice objectForKey:@"unit_amount"];
            int qty = [[previousPrice objectForKey:@"qty"] intValue];
            productPriceView = [PKProductPriceView createWithPrice:unitAmount quantity:@(qty) frame:frame];
            [productPriceView setTintColor:[UIColor redColor]];
        }
        
        if ((i + 1) < pricesCount) {
            UIView *viewBorder = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(frame),
                                                                          0,
                                                                          1,
                                                                          CGRectGetHeight([self bounds]))];
            [viewBorder setBackgroundColor:[UIColor puckatorDarkGray]];
            [self addSubview:viewBorder];
        }
        
        [productPriceView setDelegate:[self delegate]];
        [self addSubview:productPriceView];
    }
    
//    [[self prices] enumerateObjectsUsingBlockWithFirstAndLast:^(PKProductPrice *productPrice, NSUInteger idx, BOOL isFirst, BOOL isLast, BOOL *stop) {
//        
//        PKProductPriceView *productPriceView = [PKProductPriceView createWithProductPrice:productPrice frame:frame];
//        [productPriceView setDelegate:[self delegate]];
//        [self addSubview:productPriceView];
//        
//        if (!isLast) {
//            UIView *viewBorder = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(frame),
//                                                                          0,
//                                                                          1,
//                                                                          CGRectGetHeight([self bounds]))];
//            [viewBorder setBackgroundColor:[UIColor puckatorDarkGray]];
//            [self addSubview:viewBorder];
//        }
//    }];
//    
//    if ([previousPrice count] != 0) {
//        
//        
//        
//    }
}

#pragma mark - Public Methods

- (void)updateProduct:(PKProduct *)product {
    [self setProduct:product];
    [self setPrices:[product sortedPrices]];
    [self setupUI];
}

#pragma mark -

@end
