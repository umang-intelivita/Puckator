//
//  PKCurrency.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCurrency.h"

@implementation PKCurrency

/*
 "APP_ID" = 0;
 CODE = GBP;
 "COUNTRY_CODE" = GB;
 "DELIVERY_CHARGE" = "9.95";
 "DELIVERY_FREE_AFTER" = "300.00";
 LOCALE = "en-gb";
 "SERVER_ID" = 1;
 */

+ (PKCurrency*) createWithDictionary:(NSDictionary*)dictionaryRepresentation {
    PKCurrency *instance = [[PKCurrency alloc] init];
    if([dictionaryRepresentation objectForKey:@"APP_ID"]) {        
        id currencyId = [dictionaryRepresentation objectForKey:@"APP_ID"];
        if ([currencyId isKindOfClass:[NSString class]]) {
            [instance setCurrentId:currencyId];
        } else if ([currencyId isKindOfClass:[NSNumber class]]) {
            [instance setCurrentId:[NSString stringWithFormat:@"%d", [(NSNumber *)currencyId intValue]]];
        } else {
            [instance setCurrentId:@""];
        }
    }
    if([dictionaryRepresentation objectForKey:@"LOCALE"]) {
        [instance setLocale:[NSLocale localeWithLocaleIdentifier:[dictionaryRepresentation objectForKey:@"LOCALE"]]];
    }
    if([dictionaryRepresentation objectForKey:@"CODE"]) {
        [instance setCode:[dictionaryRepresentation objectForKey:@"CODE"]];
    }
    if([dictionaryRepresentation objectForKey:@"COUNTRY_CODE"]) {
        [instance setCountryCode:[dictionaryRepresentation objectForKey:@"COUNTRY_CODE"]];
    }
    if([dictionaryRepresentation objectForKey:@"DELIVERY_CHARGE"]) {
        [instance setDeliveryCharge:[dictionaryRepresentation objectForKey:@"DELIVERY_CHARGE"]];
    }
    if([dictionaryRepresentation objectForKey:@"DELIVERY_FREE_AFTER"]) {
        [instance setDeliveryFreeAfter:[dictionaryRepresentation objectForKey:@"DELIVERY_FREE_AFTER"]];
    }
    return instance;
}

+ (PKCurrency *)createWithCurrencyCode:(int)currencyCode {
    NSDictionary *dictionaryRep = [PKCurrency dictionaryRepresentationForCurrencyCode:currencyCode];
    return [PKCurrency createWithDictionary:dictionaryRep];
}

+ (NSArray*) currenciesWithArray:(NSArray*)arrayOfDictionaries {
    return [PKCurrency currenciesWithArray:arrayOfDictionaries uniqueOnly:NO];
}

+ (NSArray*) currenciesWithArray:(NSArray*)arrayOfDictionaries uniqueOnly:(BOOL)uniqueOnly {
    NSMutableArray *currencies = [[NSMutableArray alloc] init];
    for(NSDictionary *dictionary in arrayOfDictionaries) {
        __block BOOL currencyFound = NO;
        
        PKCurrency *currency = [PKCurrency createWithDictionary:dictionary];
        
        if (uniqueOnly) {
            [currencies enumerateObjectsUsingBlock:^(PKCurrency *existingCurrency, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[existingCurrency code] isEqualToString:[currency code]]) {
                    currencyFound = YES;
                    *stop = YES;
                }
            }];
        }
        
        // Only add the currency if it wasn't found:
        if (!currencyFound) {
            if (currency) {
                [currencies addObject:currency];
            }
        }
    }
    return (NSArray*)currencies;
}

#pragma mark - Utilities

+ (int) currencyCodeForIsoCode:(NSString*)isoCode {
    // Load a dictionary of currencies
    NSDictionary *currencies = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CurrencyList" ofType:@"plist"]];

    for(NSString *key in currencies) {
        NSArray *currency = [currencies objectForKey:key];
        if([currency count] == 2) {
            NSString *code = [currency firstObject];
            if([[code uppercaseString] isEqualToString:[isoCode uppercaseString]]) {
                return [key intValue];
            }
        }
    }
    
    return -1;
}

+ (NSDictionary*) dictionaryRepresentationForCurrencyCode:(int)currencyCode {
    // Load a dictionary of currencies
    NSDictionary *currencies = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CurrencyList" ofType:@"plist"]];
    
    for(NSString *key in currencies) {
        NSArray *currency = [currencies objectForKey:key];
        if([currency count] == 2) {
            NSString *code = [currency firstObject];
            NSString *symbol = [currency lastObject];
            if([key intValue] == currencyCode) {
                return @{@"code": @(currencyCode), @"iso": code, @"symbol": symbol};
            }
        }
    }
    
    return nil;
}

+ (NSDictionary*) currencyInfoForCurrencyCode:(int)currencyCode {    
    // Load a dictionary of currencies
    NSDictionary *currencies = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CurrencyList" ofType:@"plist"]];
    
    for(NSString *key in currencies) {
        NSArray *currency = [currencies objectForKey:key];
        if([currency count] == 2) {
            NSString *code = [currency firstObject];
            NSString *symbol = [currency lastObject];
            if([key intValue] == currencyCode) {
                return @{@"code": @(currencyCode), @"iso": code, @"symbol": symbol};
            }
        }
    }
    
    return nil;
}

+ (NSDictionary*) currencyInfoForIsoCode:(NSString*)isoCode {
    int code = [PKCurrency currencyCodeForIsoCode:isoCode];
    if(code != -1) {
        return [PKCurrency currencyInfoForCurrencyCode:code];
    }
    return nil;
}

+ (NSString*) symbolForCurrencyIsoCode:(NSString*)isoCode {
    NSDictionary *currencyInfo = [PKCurrency currencyInfoForIsoCode:isoCode];
    if(currencyInfo) {
        if([currencyInfo objectForKey:@"symbol"]) {
            return [currencyInfo objectForKey:@"symbol"];
        }
    }
    return @"?";
}

@end
