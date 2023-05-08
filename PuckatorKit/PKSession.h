//
//  PKSession.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 21/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DOSingleton/DOSingleton.h>
#import "PKProductsViewController.h"

#import "PKFeedConfig.h"
#import "PKCustomer.h"

@class PKFeedConfig;
@class PKCustomer;
@class PKCustomCategoryBar;

// PK Session is used for storing temporary variables, or anything session related.
// For example, the current active feed config.
@interface PKSession : DOSingleton

#pragma mark - Properties

@property (strong) PKCustomCategoryBar *customCategoryBar;

@property (nonatomic, strong) NSString *currentCurrencyCode;

// The ID of the currently selected category, or nil
@property (nonatomic, strong) NSString *selectedCategoryId;

// Used to determine if the user has decided to hide out of stock products:
@property (assign, nonatomic) BOOL hideOutOfStockProducts;

// Used to determine if the user has decided to hide bespoke products:
@property (assign, nonatomic) BOOL hideBespokeProducts;

// Used to determine if the user has decided to hide bespoke products:
@property (assign, nonatomic) BOOL showSampleProducts;

// Used to determine if the user has decided to hide bespoke products:
@property (assign, nonatomic) BOOL hideTBDProducts;

// Used to determine if the user has decided to hide bespoke products:
@property (assign, nonatomic) BOOL hideProductsInOrderView;

// Used to determine if the user has decided to hide bespoke products:
@property (assign, nonatomic) BOOL showAvailableProducts;

// Used to apply a global discount to products:
@property (strong, nonatomic) NSNumber *discountAmount;

// Used to display the purchase history of the customer:
@property (strong, nonatomic) NSDictionary *purchaseHistory;

// Used to display the back order quantity of the customer:
@property (strong, nonatomic) NSDictionary *backOrderProducts;

// Used to display the price history of a product:
@property (strong, nonatomic) NSDictionary *priceHistory;

@property (strong, nonatomic) PKBasket *basket;

@property (assign, nonatomic) PKProductsDisplayMode productsDisplayMode;

@property (assign, nonatomic) BOOL isShowOrder;

#pragma mark - Methods

// Gets the active feed config, or nil if one has not been set
- (PKFeedConfig *)currentFeedConfig;

// Gets the active customer, or nil if one has not been set:
- (PKCustomer *)currentCustomer;

// Sets the current feed.  When changed, a kNotificationFeedDidChange notification is dispatched
- (void)setCurrentFeedConfig:(PKFeedConfig*)feedConfig;

// Sets the current customer and currency code:
- (void)setCurrentCustomer:(PKCustomer *)customer andCurrencyCode:(NSString*)currencyCode;

- (NSNumber *)lastQuantityForProduct:(PKProduct *)product;
- (void)setLastQuantity:(NSNumber *)quanity forProduct:(PKProduct *)product;
- (void)clearProductQuantityHistory;

- (void)clear;

@end
