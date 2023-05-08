//
//  PKBasketItem+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 11/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PuckatorKit.h"
#import "PKBasketItem.h"

@interface PKBasketItem (Operations)

/**
 *  Gets the PKProduct from Core Data
 *
 *  @return A PKProduct instance or nil if product not found
 */
- (PKProduct *)product;

- (NSNumber *)total;
- (NSNumber *)unitPriceForFxRate;

- (NSString *)totalFormatted;
- (NSString *)unitPriceForFxRateFormatted;

- (void)updateQuantity:(NSNumber *)quantity;

- (void)applyCartonPrice;
- (void)applyWholeDiscount;
- (void)applyMidPrice;
- (void)applyZeroPrice;
- (void)applyDiscountRate:(NSNumber *)discount;

#pragma mark - Calculations

- (NSNumber *)lineTotalExVat;
- (NSNumber *)lineTotalIncVat:(NSNumber *)vatRate;
- (NSNumber *)singleUnitVat:(NSNumber *)vatRate;

@end
