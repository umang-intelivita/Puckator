//
//  PKCurrency.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKCurrency : NSObject

#pragma mark - Properties
@property (nonatomic, strong) NSString *currentId;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong) NSNumber *deliveryCharge;
@property (nonatomic, strong) NSNumber *deliveryFreeAfter;

#pragma mark - Factories

/**
 *  Creates a new PKCurrency object from a dictionary
 *
 *  @param dictionaryRepresentation The dict
 *
 *  @return The PKCurrency object
 */
+ (PKCurrency*) createWithDictionary:(NSDictionary*)dictionaryRepresentation;

+ (PKCurrency *)createWithCurrencyCode:(int)currencyCode;

#pragma mark - Class Methods

/**
 *  Creates an array of PKCurrency object from an array of dictionaries
 *
 *  @param arrayOfDictionaries An array of dictionaries
 *
 *  @return An array of PKCurrency objects
 */
+ (NSArray*) currenciesWithArray:(NSArray*)arrayOfDictionaries;
+ (NSArray*) currenciesWithArray:(NSArray*)arrayOfDictionaries uniqueOnly:(BOOL)uniqueOnly;

#pragma mark - Utilities

+ (int) currencyCodeForIsoCode:(NSString*)isoCode;
+ (NSDictionary*) currencyInfoForCurrencyCode:(int)currencyCode;
+ (NSDictionary*) currencyInfoForIsoCode:(NSString*)isoCode;
+ (NSString*) symbolForCurrencyIsoCode:(NSString*)isoCode;

@end
