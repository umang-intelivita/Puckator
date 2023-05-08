//
//  PKSession.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 21/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKSession.h"
#import "PKConstant.h"
#import "PKRecentCustomer+Operations.h"
#import "PKBasket+Operations.h"

@interface PKSession()

@property (nonatomic, strong) PKFeedConfig *config;
@property (strong, nonatomic) PKCustomer *customer;

// Used to display the last quantity used for a product:
@property (strong, nonatomic) NSMutableDictionary *productQuantityHistory;

@end

@implementation PKSession
@synthesize priceHistory = _priceHistory;

- (void)clear {
    [self setCurrentCustomer:nil andCurrencyCode:nil];
    [self setConfig:nil];
    [self setCustomer:nil];
    [self setPriceHistory:nil];
    [self setCurrentCurrencyCode:nil];
    [self setBackOrderProducts:nil];
    [self setPurchaseHistory:nil];
    [self setBasket:nil];
    [self setDiscountAmount:0];
    [self setSelectedCategoryId:nil];
    [self setProductQuantityHistory:nil];
    [self setIsShowOrder:NO];
}

- (void)clearProductQuantityHistory {
    [self setProductQuantityHistory:nil];
}

#pragma mark - Getters

- (NSString *)currentCurrencyCode {
    if (_currentCurrencyCode) {
        return _currentCurrencyCode;
    } else {
        return [[[PKSession sharedInstance] currentFeedConfig] defaultCurrencyIsoCode];
    }
}

// Gets the active feed config, or nil if one has not been set
- (PKFeedConfig *)currentFeedConfig {
    // If there is no current config and there is only one feed, automatically switch to it
    if (![self config] && [[PKFeedConfig feeds] count] == 1) {
        for (int i = 0; i < [PKFeedConfig feeds].count; i++) {
            PKFeedConfig * feed = [[PKFeedConfig feeds] objectAtIndex:i];
            if ([[feed isWiped] boolValue] == NO){
                [self setCurrentFeedConfig:[[PKFeedConfig feeds] firstObject]];
                break;
            }
        }
    }
    
    // Look in the user default for the last selected feed:
    if (![self config]) {
        NSArray *feeds = [PKFeedConfig feeds];
        __block PKFeedConfig *config = nil;
        
        if ([feeds count] != 0) {
            NSString *feedNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kNSUserDefaultsFeedNumberKey];
            if (feedNumber) {
                [[PKFeedConfig feeds] enumerateObjectsUsingBlock:^(PKFeedConfig *feedConfig, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([[feedConfig number] isEqualToString:feedNumber]) {
                        config = feedConfig;
                        *stop = YES;
                    }
                }];
            }
            
            // If a matching config isn't found default to the first one in the array:
            if (!config) {
                config = [feeds firstObject];
            }
            
            // Make sure a config is found and then set it up:
            if (config) {
                [self setCurrentFeedConfig:config];
            }
        }
    }
    
    // Remove the config (might be nil):
    return [self config];
}

- (PKCustomer *)currentCustomer {
    return [self customer];
}

#pragma mark - Setters

// Sets the current feed
- (void) setCurrentFeedConfig:(PKFeedConfig*)feedConfig {
    // Don't do anything if the feed config is nil:
    if (feedConfig == nil) {
        return;
    }
    
    BOOL didHavePreviousConfig = NO;
    if ([self config]) {
        didHavePreviousConfig = YES;
    }
    
    // Set the current config
    if (![[feedConfig number] isEqualToString:[[self config] number]]) {
        [self setConfig:feedConfig];
            
        if ([self config]) {
            // Save the feed in the user defaults:
            [[NSUserDefaults standardUserDefaults] setObject:[[self config] number] forKey:kNSUserDefaultsFeedNumberKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Dispatch notification to inform the app to make any changes
            if (didHavePreviousConfig) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedDidChange object:feedConfig];
            }
        }
    }
    
    // Setup the customer and currency code:
    [self setCurrentCustomer:[self customer] andCurrencyCode:[[self config] defaultCurrencyIsoCode]];
}

- (void)setCurrentCustomer:(PKCustomer *)customer andCurrencyCode:(NSString*)currencyCode {
    // Clear session properties:
    [self setCustomer:nil];
    [self setCurrentCurrencyCode:nil];
    [[PKSession sharedInstance] setPriceHistory:nil];
    [[PKSession sharedInstance] setPurchaseHistory:nil];
    [[PKSession sharedInstance] setBackOrderProducts:nil];
    
    // Set the customer:
    if (customer) {
        [self setCustomer:customer];
    }
    
    // Set the currency code:
    if (currencyCode) {
        [self setCurrentCurrencyCode:currencyCode];
    }
    
    if ([self customer]) {
        // Setup the purchase history:
        [[PKSession sharedInstance] setPurchaseHistory:[PKInvoiceLine previousPricesForCustomer:[self customer]]];
        
        // Setup back orders:
        [[PKSession sharedInstance] setBackOrderProducts:[PKInvoiceLine backOrderProductsForCustomer:[self customer]]];
        
        // Save recent customer:
        [PKRecentCustomer addCustomer:[self customer] context:nil];
    } else {
        // There is no customer therefore clear the basket:
        [self setBasket:nil];
        [self setDiscountAmount:@(0.0f)];
        [self setCurrentCurrencyCode:nil];
    }
    
    // Setup the price history:
    if ([self currentCurrencyCode]) {
        [[PKSession sharedInstance] setPriceHistory:[PKProduct priceHistoryWithCurrencyCode:[[self currentCurrencyCode] uppercaseString]]];
    }
}

#pragma mark - Price History 

- (void)setPriceHistory:(NSDictionary *)priceHistory {
    _priceHistory = priceHistory;
    //NSLog(@"[%@] - Price History: %@", self, _priceHistory);
}

- (NSDictionary *)priceHistory {
    // Return nil
    if (![self currentCurrencyCode]) {
        return nil;
    }
    
    if (!_priceHistory) {
        // Setup pricing history:
        if ([self currentCurrencyCode]) {
            [self setPriceHistory:[PKProduct priceHistoryWithCurrencyCode:[self currentCurrencyCode]]];
        }
    }
    
    return _priceHistory;
}

#pragma mark - Quantity History

- (void)setLastQuantity:(NSNumber *)quanity forProduct:(PKProduct *)product {
    if (![self productQuantityHistory]) {
        [self setProductQuantityHistory:[NSMutableDictionary dictionary]];
    }
    
    if (product) {
        [[self productQuantityHistory] setObject:quanity forKey:[product model]];
    }
}

- (NSNumber *)lastQuantityForProduct:(PKProduct *)product {
    if ([[self productQuantityHistory] objectForKey:[product model]]) {
        return [[self productQuantityHistory] objectForKey:[product model]];
    }
    
    if ([[product minOrderQuantity] intValue] <= 0) {
        return @(1);
    }
    
    return [product minOrderQuantity];
}

#pragma mark -

@end
