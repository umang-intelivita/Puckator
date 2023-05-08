//
//  PKProductPrice+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductPrice.h"
#import "PKFeedConfig.h"

@interface PKProductPrice (Operations)

// Creates a new price associated with a product
+ (PKProductPrice*) createWithForProduct:(PKProduct *)product
                           forFeedConfig:(PKFeedConfig *)feedConfig
                               inContext:(NSManagedObjectContext *)context;

- (NSNumber *)priceWithCurrentFxRate; // Returns the price taking into account the selected FX rate on the PKBasket, or the default currency for this feed
- (NSNumber *)priceWithCurrentFxRate:(NSNumber *)price;
- (NSNumber *)fxRate;
+ (NSNumber *)priceWithGBP:(NSNumber *)gbp fxRate:(NSNumber *)fxRate;

- (NSString *)formattedPrice;
- (NSString *)formattedPriceWithAtPrefix;

+ (NSString *)formattedPrice:(NSNumber *)price;
+ (NSString *)formattedPrice:(NSNumber *)price withIsoCode:(NSString*)isoCode;
+ (NSString *)formattedPriceWithAtPrefix:(NSNumber *)price;

- (NSNumber *)priceWithWholesaleDiscount;
- (NSNumber *)priceWithDiscountRate:(NSNumber *)discountRate;

+ (BOOL)deleteProductPricesforFeedConfig:(PKFeedConfig*)feedConfig
                               inContext:(NSManagedObjectContext*)context;

#pragma mark - Currency Rate

+ (NSNumber *)fxRateForProductPriceObject:(PKProductPrice*)productPrice forCurrencyIsoCode:(NSString*)currencyIsoCode;

@end
