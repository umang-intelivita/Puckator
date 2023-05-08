//
//  PKProduct+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProduct.h"
#import "PKFeedConfig.h"
#import <RXMLElement.h>
#import "NSManagedObject+Operations.h"
#import "PKSaleHistory.h"
#import "PKDisplayData.h"
#import "PKPurchaseOrder.h"

@class PKSearchParameters;
@class PKCustomer;

typedef enum {
    PKProductWarehouseUK = 0,
    PKProductWarehouseEDC = 1
} PKProductWarehouse;

@interface PKProduct (Operations) <PKDisplayData>

+ (BOOL)deleteProductsforFeedConfig:(PKFeedConfig*)feedConfig inContext:(NSManagedObjectContext*)context;

// Fetches or creates a Product entity with a specific product ID
+ (PKProduct*) findOrCreateWithProductId:(NSString*)productId
                           forFeedConfig:(PKFeedConfig*)feedConfig
                               inContext:(NSManagedObjectContext*)context;

// Gets a product, but never creates it.  Used by basket.
+ (PKProduct*) findWithProductId:(NSString*)productId
                   forFeedConfig:(PKFeedConfig*)feedConfig
                       inContext:(NSManagedObjectContext*)context;

+ (PKProduct *)findWithProductCode:(NSString *)productCode
                     forFeedConfig:(PKFeedConfig *)feedConfig
                         inContext:(NSManagedObjectContext *)context;

+ (PKProduct*) findOrCreateWithProductId:(NSString*)productId
                           forFeedConfig:(PKFeedConfig*)feedConfig
                         inProductsArray:(NSArray*)products
                               inContext:(NSManagedObjectContext*)context
                               predicate:(NSPredicate *)predicate;

// Fetches all the products for a particular feed.  This is used during sync to prevent excessive core data queries being used (for upserting)
+ (NSArray *)allProductsForFeedConfig:(PKFeedConfig*)feedConfig inContext:(NSManagedObjectContext*)context;
+ (NSArray *)newProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (NSArray *)newEDCProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (NSArray *)topSellingProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (NSArray *)topGrossingProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (NSArray *)newAvailableProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (NSArray *)inStockProductsByDate:(NSDate *)date forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (NSArray *)inStockProductsByDate:(NSDate *)date inCategory:(PKCategory *)category forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (NSArray *)customerProductsForCustomer:(PKCustomer *)customer forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (NSArray *)customerPastOrderProductsForCustomer:(PKCustomer *)customer forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;

#pragma mark - Utilities

+ (NSArray *)filterProducts:(NSArray *)products;
+ (NSArray *)filterProducts:(NSArray *)products stockFilterEnabled:(BOOL)stockFilterEnabled bespokeFilterEnabled:(BOOL)bespokeFilterEnabled;
+ (NSArray *)sortProducts:(NSArray *)products;

- (NSAttributedString *)attributedTitleIncludeModel:(BOOL)includeModel includeCategories:(BOOL)includeCategories;

+ (NSArray *)supplierList;
+ (NSArray *)buyerList;
+ (NSArray *)productsForSupplier:(NSString *)supplier;
+ (NSArray *)productsForBuyer:(NSString *)buyer;

// Returns an array of images:
- (NSArray *)sortedImages;

// Returns an array of UIImages:
- (NSArray *)sortedUIImages;

// Returns the UIImage for the main PKImage:
- (UIImage *)image;

// Returns the UIImage for the thumb PKImage:
- (UIImage *)thumb;

// Returns an array of sorted prices:
- (NSArray *)sortedPrices;

// Returns the price for quantity of zero:
- (PKProductPrice *)price;

// Returns the purchase unit formatted as a string:
- (NSString *)purchaseUnitFormatted;

// Returns the multiple of the purchase unit for the given requested quantity:
- (NSNumber *)purchaseUnitQuantityForRequestedQuantity:(NSNumber *)requestedQuantity;

// Returns the multiple of the purchase unit for the given requested quantity as a string:
- (NSString *)formattedPurchaseUnitQuantityForRequestedQuantity:(NSNumber *)requestedQuantity;

// Returns the price for the given quantity:
- (PKProductPrice *)priceForQuantity:(NSNumber *)quantity;

// Returns the wholesale price for the product:
- (NSNumber *)wholesalePrice;

// Return the carton price for the product:
- (NSNumber *)cartonPrice;

// Returns the price price for the product:
- (NSNumber *)midPrice;
- (NSNumber *)midQuantity;

// Gets array of PKSaleHistory objects for a given type (i.e. ytd / prior). Ordered by date.
- (NSArray*)salesHistoryForType:(PKSaleHistoryType)type warehouse:(PKProductWarehouse)warehouse;

// Returns the total of the history for a given type:
- (int)salesHistoryTotalForType:(PKSaleHistoryType)type warehouse:(PKProductWarehouse)warehouse;

// Returns the total of the history in the given array:
- (int)salesHistoryTotalForHistory:(NSArray *)history;

// Returns the year name the history type:
- (NSString *)yearNameForHistoryType:(PKSaleHistoryType)type;

// Returns the rounded quantity based on the purchase unit:
- (NSNumber *)roundedQuantity:(NSNumber *)quantity;

// Return YES if this product is new:
- (BOOL)isNewProduct;

// Return YES if this product is new:
- (BOOL)isNewStarProduct;

// Return YES if this product is new EDC:
- (BOOL)isNewEDCProduct;


- (BOOL)isLOCK_TO_CARTON_QTY;

- (BOOL)isLOCK_TO_CARTON_PRICE;
// Returns the number on back order for the current customer:
- (int)backOrderQty;
- (NSAttributedString *)attributedBackOrderString;

#pragma mark - Search

+ (NSArray*)resultsForSearchParameters:(PKSearchParameters*)searchParameters;

#pragma mark - Price History

+ (NSDictionary *)priceHistoryWithCurrencyCode:(NSString *)currencyCode;

#pragma mark - Purchase Orders Methods

- (NSArray *)purchaseOrders;
- (NSArray *)purchaseOrdersEDC;

#pragma mark - UI Methods

- (NSDate *)dateDueEDC;
- (NSString *)formattedStockAvaliableDate;
- (NSDictionary *)stockDateAvaliableData;
- (NSDictionary *)stockDateAvaliableDataEDC;

#pragma mark - Sound Methods

- (NSArray<NSString *> *)soundFilenames;
- (NSString *)cleanSoundFilename:(NSString *)filename;

@end
