//
//  PKProductPrice+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductPrice+Operations.h"
#import "PKSession.h"
#import <MagicalRecord/MagicalRecord.h>
#import "PKFeedConfig.h"
#import "PKCurrency.h"
#import "PKBasket+Operations.h"
#import "PKConstant.h"

@implementation PKProductPrice (Operations)

+ (PKProductPrice *)createWithForProduct:(PKProduct *)product forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    // Create a new price entity
    PKProductPrice *priceEntity = [PKProductPrice MR_createEntityInContext:context];
    [priceEntity setProduct:product];
    [priceEntity setFeedNumber:[feedConfig number]];
    return priceEntity;
}

+ (BOOL)deleteProductPricesforFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber = %@", [feedConfig number]];
    return [PKProductPrice MR_deleteAllMatchingPredicate:predicate inContext:context];
}

+ (NSNumber *)priceWithGBP:(NSNumber *)gbp fxRate:(NSNumber *)fxRate {
    // Apply the FXRate to the GBP price:
    NSNumber *price = [NSDecimalNumber multiply:gbp by:fxRate];
    
    // Round to 2 decimal places:
    return [NSDecimalNumber roundNumber:price];
}

- (NSNumber *)priceWithCurrentFxRate:(NSNumber *)price {
    // Get the FXRate for the current currency code:
    NSString *currencyCode = [[PKSession sharedInstance] currentCurrencyCode];
    NSNumber *fxRate = [PKProductPrice fxRateForProductPriceObject:self forCurrencyIsoCode:currencyCode];
    
    NSDecimalNumber *numberPrice = [NSDecimalNumber decimalNumberWithNumber:price];
    NSDecimalNumber *numberDiscount = [NSDecimalNumber decimalNumberWithNumber:fxRate];
    
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

- (NSNumber *)fxRate {
    NSString *currencyCode = nil;
    if ([[[PKSession sharedInstance] currentCurrencyCode] length] != 0) {
        currencyCode = [[PKSession sharedInstance] currentCurrencyCode];
    } else {
        currencyCode = [[[PKSession sharedInstance] currentFeedConfig] defaultCurrencyIsoCode];
    }
    
    return [PKProductPrice fxRateForProductPriceObject:self forCurrencyIsoCode:currencyCode];
}

- (NSNumber *)priceWithCurrentFxRate {
    //NSLog(@"[%@] - Price: %@", [self class], [self value]);
    return [self priceWithCurrentFxRate:[self value]];
}

- (NSString *)formattedPrice {
    return [PKProductPrice formattedPrice:[self priceWithCurrentFxRate]];
}

- (NSString *)formattedPriceWithAtPrefix {
    return [PKProductPrice formattedPriceWithAtPrefix:[self priceWithCurrentFxRate]];
}

+ (NSString *)formattedPrice:(NSNumber *)price {
    NSString *currencyCode = [[[PKSession sharedInstance] currentFeedConfig] defaultCurrencyIsoCode];
    if ([PKBasket sessionBasket]) {
        currencyCode = [[PKBasket sessionBasket] currencyCode];
    }
    return [PKProductPrice formattedPrice:price withIsoCode:currencyCode];
//    return [PKProductPrice formattedPrice:price withIsoCode:[[PKBasket sessionBasket] currencyCode]];
}

+ (NSString *)formattedPrice:(NSNumber *)price withIsoCode:(NSString *)isoCode {
    if ([isoCode length] == 0) {
        isoCode = [[PKSession sharedInstance] currentCurrencyCode];
    }
    
    price = [NSDecimalNumber roundNumber:price];
    return [NSString stringWithFormat:@"%@%.2f", [PKCurrency symbolForCurrencyIsoCode:isoCode], [price floatValue]];
}

+ (NSString *)formattedPriceWithAtPrefix:(NSNumber *)price {
    return [NSString stringWithFormat:@"x %@", [PKProductPrice formattedPrice:price]];
}

- (NSNumber *)priceWithWholesaleDiscount {
    return [self priceWithDiscountRate:kPuckatorWholesaleDiscountPercentage];
}

- (NSNumber *)priceWithDiscountRate:(NSNumber *)discountRate {
    // Work out the price:
    NSDecimalNumber *numberPrice = [NSDecimalNumber decimalNumberWithString:[[self priceWithCurrentFxRate] stringValue]];
    
    // Calculate the discount from the rate:
    NSDecimalNumber *numberDiscountRate = [NSDecimalNumber decimalNumberWithString:[discountRate stringValue]];
    NSDecimalNumber *numberOne = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSDecimalNumber *numberDiscount = [numberOne decimalNumberBySubtracting:numberDiscountRate];
    
    // Work out the new price:
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

#pragma mark - Currency Rate

+ (NSNumber *)fxRateForProductPriceObject:(PKProductPrice *)productPrice forCurrencyIsoCode:(NSString *)currencyIsoCode {
    NSNumber *fxRate = [NSNumber numberWithFloat:1.0f];
    
    if ([[currencyIsoCode lowercaseString] isEqualToString:@"gbp"] || [[currencyIsoCode lowercaseString] isEqualToString:@"usd"]) {
        fxRate = [productPrice rateGBP];
    }
    
    if ([[currencyIsoCode lowercaseString] isEqualToString:@"eur"]) {
        fxRate = [productPrice rateEUR];
    }
    
    if ([[currencyIsoCode lowercaseString] isEqualToString:@"pln"]) {
        fxRate = [productPrice ratePLN];
    }
    
    if ([[currencyIsoCode lowercaseString] isEqualToString:@"sek"]) {
        fxRate = [productPrice rateSEK];
    }
    
    if ([[currencyIsoCode lowercaseString] isEqualToString:@"dkk"]) {
        fxRate = [productPrice rateDKK];
    }
    
    if ([[currencyIsoCode lowercaseString] isEqualToString:@"rmb"]) {
        fxRate = [productPrice rateRMB];
    }
    
    if ([[currencyIsoCode lowercaseString] isEqualToString:@"czk"]) {
        fxRate = [productPrice rateCZK];
    }
    
    // Return a default of 1.0 is the same as no FX rate:
    return fxRate;
}

@end
