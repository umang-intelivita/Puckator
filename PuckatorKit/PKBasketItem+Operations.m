//
//  PKBasketItem+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 11/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasketItem+Operations.h"
#import "PKBasket+Operations.h"
#import "PKProductPrice+Operations.h"
#import "PKSession.h"
#import "PKConstant.h"
#import <objc/runtime.h>

NSString const *pkBasketItemCacheProductKey = @"PKBasketItem.operations.key.product";

@implementation PKBasketItem (Operations)

- (PKProduct *)product {
    PKProduct *product = [self cachedProduct];
    
    if (!product) {
        product = [PKProduct findWithProductId:[self productUuid]
                                 forFeedConfig:[[PKSession sharedInstance] currentFeedConfig]
                                     inContext:nil];
        [self cacheProduct:product];
    }
    
    return product;
}

- (void)cacheProduct:(PKProduct *)product {
    objc_setAssociatedObject(self, &pkBasketItemCacheProductKey, product, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PKProduct *)cachedProduct {
    return objc_getAssociatedObject(self, &pkBasketItemCacheProductKey);
}

- (NSNumber *)total {
    NSNumber *price = [self unitPriceForFxRate];
    if ([[self isCustomPriceSet] boolValue]) {
        price = [self unitPrice];
    }
    
    return [NSDecimalNumber multiply:[self quantity] by:price];
}

- (NSNumber *)unitPriceForFxRate {
    return [NSDecimalNumber multiply:[self unitPrice] by:[self fxRate]];
}

- (NSString *)unitPriceForFxRateFormatted {
    NSNumber *price = [self unitPriceForFxRate];
    if ([[self isCustomPriceSet] boolValue]) {
        price = [self unitPrice];
    }
    
    return [PKProductPrice formattedPrice:price withIsoCode:[self fxIsoCode]];
}

- (NSString *)totalFormatted {

    // Warning - this may need changing for viewing past orders...
    return [PKProductPrice formattedPrice:[self total] withIsoCode:[self fxIsoCode]];
    
    //return [NSString stringWithFormat:@"£%.2f", [self total]];
}

- (void)updateQuantity:(NSNumber *)quantity {
    // Only round if unrestricted qty is not activated (in settings bundle)
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"unrestrict_quantity"]) {
        quantity = [[self product] roundedQuantity:quantity];
    }
    
    PKProductPrice *productPrice = [[self product] priceForQuantity:quantity];
    NSNumber *price = [productPrice priceWithCurrentFxRate];
    
    // If custom price set, do not auto update the qty
    if ([[self isCustomPriceSet] boolValue] == YES) {
        price = [NSNumber numberWithInt:-1];
    }
    
    [[self basket] addOrUpdateProduct:[self product]
                             quantity:quantity
                                price:price
                       customPriceSet:[[self isCustomPriceSet] boolValue]
                   productPriceObject:productPrice
                          incremental:NO
                              context:nil];
}

- (void)applyCartonPrice {
    PKProduct *product = [PKProduct findWithProductId:[self productUuid] forFeedConfig:nil inContext:nil];
    if (product) {
        [self setUnitPrice:[product cartonPrice]];
    }
}

- (void)applyMidPrice {
    PKProduct *product = [PKProduct findWithProductId:[self productUuid] forFeedConfig:nil inContext:nil];
    if (product) {
        [self setUnitPrice:[product midPrice]];
    }
}

- (void)applyZeroPrice {
    PKProduct *product = [PKProduct findWithProductId:[self productUuid] forFeedConfig:nil inContext:nil];
    if (product) {
        [self setUnitPrice:@(0)];
    }
}

- (void)applyWholeDiscount {
    PKProduct *product = [PKProduct findWithProductId:[self productUuid] forFeedConfig:nil inContext:nil];
    
    NSLog(@"CateogryID %@ ", [product categoryIds]);
    
//    if [product ]

        PKProductPrice *productPrice = [[product sortedPrices] firstObject];
        
        if (productPrice) {
            [self setUnitPrice:[productPrice priceWithWholesaleDiscount]];
        }
    
    
}

- (void)applyDiscountRate:(NSNumber *)discount {
    PKProduct *product = [PKProduct findWithProductId:[self productUuid] forFeedConfig:nil inContext:nil];
    PKProductPrice *productPrice = [product price];
    
    if (productPrice) {
        [self setUnitPrice:[productPrice priceWithDiscountRate:discount]];
    }
}

#pragma mark - Calculations

/*
 PKProduct *product = [item product];
 double totalPriceExVat = ([[item unitPrice] doubleValue] * [[item quantity] doubleValue]);
 double totalItemsVat = (totalPriceExVat / 100.f) * vat;
 //float totalPriceIncVat = totalPriceExVat + totalItemsVat;
 double singleProductVat = ([[item unitPrice] doubleValue] / 100.f) * vat;
 */

- (NSNumber *)lineTotalExVat {
    return [NSDecimalNumber multiply:[self unitPrice] by:[self quantity]];
}

- (NSNumber *)lineTotalIncVat:(NSNumber *)vatRate {
    NSNumber *lineTotalExVat = [self lineTotalExVat];
    NSNumber *number100 = @(100.0f);
    
    NSNumber *lineTotalIncVat = [NSDecimalNumber divide:lineTotalExVat by:number100];
    lineTotalExVat = [NSDecimalNumber multiply:lineTotalIncVat by:vatRate];
    
    return lineTotalExVat;
}

- (NSNumber *)singleUnitVat:(NSNumber *)vatRate {
    NSNumber *unitPrice = [self unitPrice];
    NSNumber *number100 = @(100.0f);
    
    NSNumber *singleUnitVat = [NSDecimalNumber divide:unitPrice by:number100];
    singleUnitVat = [NSDecimalNumber multiply:singleUnitVat by:vatRate];
    
    return singleUnitVat;
}

#pragma mark -

@end
