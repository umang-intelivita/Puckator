//
//  PKBasket+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 11/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PuckatorKit.h"
#import "PKBasket.h"
#import "PKInvoice.h"

@class PKCustomer;

typedef enum : NSUInteger {
    PKBasketStatusError = 0,
    PKBasketStatusOpen = 100,
    PKBasketStatusSaved = 1,
    PKBasketStatusQuote = 2,
    PKBasketStatusComplete = 3,
    PKBasketStatusOutstanding = 4,
    PKBasketStatusCancelled = 5
} PKBasketStatus;

@interface PKBasket (Operations)

#pragma mark - Basket Operations

/**
 *  Creates a new basket for a customer.  If an existing basket already exists for the customer, this is returned.
 *
 *  @param customerId The ID of the customer
 *  @param feedNumber The feed number the user is currently using
 *  @param context The CoreData context
 *  @param context The CoreData context
 *  @return A PKBasket or nil if failed
 */
+ (PKBasket *)basketWithOrderRef:(NSString *)orderRef feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context;
+ (BOOL)deleteOpenBasketsForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context;
+ (NSArray *)openBasketsForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber includeErrored:(BOOL)includeErrored context:(NSManagedObjectContext *)context;
+ (NSArray *)openBasketsForFeedNumber:(NSString *)feedNumber includeErrored:(BOOL)includeErrored context:(NSManagedObjectContext *)context;
+ (NSArray *)openBasketsIncludeErrored:(BOOL)includeErrored context:(NSManagedObjectContext *)context;
- (NSDate *)date;

/**
 *  Adds or updates a product within the basket
 *
 *  @param product  The product to add
 *  @param quantity The quanity
 *  @param price    The price
 *  @param context  The CoreData context
 *  @return A PKBasketItem (if found) or nil
 */
- (PKBasketItem*) addOrUpdateProduct:(PKProduct *)product
                            quantity:(NSNumber *)quantity
                               price:(NSNumber *)price
                      customPriceSet:(BOOL)customPriceSet
                  productPriceObject:(PKProductPrice*)priceObject
                         incremental:(BOOL)incremental
                             context:(NSManagedObjectContext*)context;

- (PKBasketItem*) addOrUpdateProduct:(PKProduct *)product
                            quantity:(NSNumber *)quantity
                               price:(NSNumber *)price
                      customPriceSet:(BOOL)customPriceSet
                  productPriceObject:(PKProductPrice*)priceObject
                         incremental:(BOOL)incremental
                             context:(NSManagedObjectContext*)context
                            skipSave:(BOOL)skipSave;

/**
 *  Finds a PKBasketItem entity within the PKBasketItem.  If no item found, returns nil.
 *
 *  @param product The product ID to find
 *  @param context The CoreData context
 *
 *  @return A PKBasketItem (if found) or nil
 */
- (PKBasketItem*) basketItemForProduct:(PKProduct*)product
                               context:(NSManagedObjectContext*)context;


/**
 *  Deletes a PKBasketItem from the PKBasket
 *
 *  @param product The product to delete
 *  @param context The CoreData context
 *
 *  @return YES if deletion succeeded, or NO otherwise
 */
- (BOOL) deleteProduct:(PKProduct*)product
               context:(NSManagedObjectContext*)context;

- (BOOL) deleteBasketItem:(PKBasketItem*)item
                  context:(NSManagedObjectContext*)context;

#pragma mark - Getter Methods
+ (NSArray *)basketsForFeedNumber:(NSString *)feedNumber
                           status:(PKBasketStatus)status
                          context:(NSManagedObjectContext *)context;

+ (NSArray *)recentBasketsForFeedNumber:(NSString *)feedNumber
                                context:(NSManagedObjectContext *)context;

+ (NSArray *)basketsForCustomer:(PKCustomer *)customer
                     feedNumber:(NSString *)feedNumber
                         status:(PKBasketStatus)status
                        context:(NSManagedObjectContext *)context;
+ (NSArray *)ordersAndQuotesForCustomer:(PKCustomer *)customer
                             feedNumber:(NSString *)feedNumber
                                context:(NSManagedObjectContext *)context;

+ (NSArray *)archivedOrdersAndQuotesForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context;

#pragma mark - Helper Methods
- (NSArray *)itemsOrdered;
- (NSNumber *)total __deprecated_msg("Use totalExShipping instead for improved accuracy of language.");
- (NSNumber *)totalExShipping;
- (NSNumber *)totalVat;
- (NSNumber *)grandTotal;
- (NSString *)totalFormatted;
- (NSString *)formattedPrice:(NSNumber *)value;
- (void)outputItems;

- (NSArray *)basketItems;
- (NSArray *)products;
- (void)removeAllBasketItems;

// This method flags the order as complete:
- (PKBasket *)copyBasket;
- (PKBasket *)copyBasketToCustomer:(PKCustomer *)customer currencyCode:(NSString *)currencyCode;

- (void)save;

- (NSString *)statusName;
+ (NSString *)nameForStatus:(PKBasketStatus)status wasSent:(BOOL)isSent;
+ (NSArray *)statusItems;

#pragma mark - Order transformation

- (NSString *)transformToOrderXmlStringIsQuote:(BOOL)isQuote;
- (void)saveOrderXml:(NSString*)orderXml;

#pragma mark - Status Methods
- (BOOL)cancelOrder;
- (NSNumber *)wasSent;
- (PKBasketStatus)status;
- (void)setStatus:(PKBasketStatus)status shouldSave:(BOOL)shouldSave;

- (NSString *)formattedCreatedAt;
+ (BOOL)cancelAllOpenBasketsForCustomer:(PKCustomer *)customer;

#pragma mark - Invoice Methods
+ (PKBasket *)createWithInvoice:(PKInvoice *)invoice;
+ (PKBasket *)createWithInvoice:(PKInvoice *)invoice customer:(PKCustomer *)customer currencyCode:(NSString *)currencyCode;

#pragma mark - New Methods
+ (PKBasket *)sessionBasket;
+ (BOOL)setSessionBasket:(PKBasket *)basket;
+ (BOOL)clearSessionBasket;
+ (PKBasket *)createSessionBasketForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context;

@end
