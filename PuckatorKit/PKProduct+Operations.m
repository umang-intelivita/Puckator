 //
//  PKProduct+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProduct+Operations.h"
#import <MagicalRecord/MagicalRecord.h>
#import "RXMLElement+Utilities.h"
#import "PKImage+Operations.h"
#import "PKSession.h"
#import "PKProductSaleHistory+Operations.h"
#import <FileMD5Hash/FileHash.h>
#import "PKSearchParameters.h"
#import "PKTranslate.h"
#import "PKProductPrice.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import "PKCategory.h"
#import "PKConstant.h"
#import <MKFoundationKit/MKFoundationKit.h>
#import "PKProductPrice+Operations.h"
#import "PKInvoice.h"
#import "PKInvoiceLine.h"
#import "PKSession.h""

@implementation PKProduct (Operations)

#pragma mark - Find Methods

#pragma mark -

+ (BOOL)deleteProductsforFeedConfig:(PKFeedConfig*)feedConfig inContext:(NSManagedObjectContext*)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber = %@", [feedConfig number]];
    return [PKProduct MR_deleteAllMatchingPredicate:predicate inContext:context];
}

+ (PKProduct*) findOrCreateWithProductId:(NSString*)productId
                           forFeedConfig:(PKFeedConfig*)feedConfig
                               inContext:(NSManagedObjectContext*)context {
    // Create a predicate to find the product within a given feed
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId = %@ AND feedNumber = %@", productId, [feedConfig number]];
    
    // Execute the search for the product
    PKProduct *product = [PKProduct MR_findFirstWithPredicate:predicate inContext:context];
    if (!product) {
        // Product not found, create a new one
        product = [PKProduct MR_createEntityInContext:context];
        [product setProductId:productId];
        [product setFeedNumber:[feedConfig number]];
    }
    
    // Returns either a new or existing product entity
    return product;
}

+ (NSArray *)newProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    // Ghanshyam
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isNew == %@ && feedNumber == %@", @(1), [feedConfig number]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isNewStar == %@ && feedNumber == %@", @(1), [feedConfig number]];
    
    NSFetchRequest *request = [PKProduct MR_requestAllWithPredicate:predicate inContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSSortDescriptor *sortCode = [[NSSortDescriptor alloc] initWithKey:@"model" ascending:YES];
    [request setSortDescriptors:@[sort, sortCode]];
    
    return [PKProduct removeBespokeProducts:[PKProduct MR_executeFetchRequest:request inContext:context]];
}

+ (NSArray *)newEDCProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isNewEDC == %@ && feedNumber == %@", @(1), [feedConfig number]];
    
    NSFetchRequest *request = [PKProduct MR_requestAllWithPredicate:predicate inContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSSortDescriptor *sortCode = [[NSSortDescriptor alloc] initWithKey:@"model" ascending:YES];
    [request setSortDescriptors:@[sort, sortCode]];
    
    return [PKProduct removeBespokeProducts:[PKProduct MR_executeFetchRequest:request inContext:context]];
}

+ (NSArray *)newAvailableProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    PKProductWarehouse warehouse = [feedConfig warehouse];
    
    NSPredicate *predicate = nil;
    switch (warehouse) {
        default:
        case PKProductWarehouseUK:
            //ghanshyam
//            predicate = [NSPredicate predicateWithFormat:@"isNew == %@ && feedNumber == %@ && (availableStock > 0 || availableStockEDC > 0)", @(1), [feedConfig number]];
            predicate = [NSPredicate predicateWithFormat:@"isNewStar == %@ && feedNumber == %@ && (availableStock > 0 || availableStockEDC > 0)", @(1), [feedConfig number]];
            break;
        case PKProductWarehouseEDC:
            predicate = [NSPredicate predicateWithFormat:@"isNewEDC == %@ && feedNumber == %@ && (availableStock > 0 || availableStockEDC > 0)", @(1), [feedConfig number]];
            break;
    }
    
    NSFetchRequest *request = [PKProduct MR_requestAllWithPredicate:predicate inContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSSortDescriptor *sortCode = [[NSSortDescriptor alloc] initWithKey:@"model" ascending:YES];
    [request setSortDescriptors:@[sort, sortCode]];
    
    return [PKProduct removeBespokeProducts:[PKProduct MR_executeFetchRequest:request inContext:context]];
}

+ (NSArray *)inStockProductsByDate:(NSDate *)date forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    return [PKProduct inStockProductsByDate:date
                                 inCategory:nil
                              forFeedConfig:feedConfig
                                  inContext:context];
}

+ (NSArray *)inStockProductsByDate:(NSDate *)date inCategory:(PKCategory *)category forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    if (!date) {
        date = [NSDate date];
    }
    
    // Add a day to catch all of the day requested:
    date = [date mk_dateByAddingDays:1];
    PKProductWarehouse warehouse = [feedConfig warehouse];
    
    NSPredicate *predicate = nil;
    if (category) {
        switch (warehouse) {
            default:
            case PKProductWarehouseUK:
                predicate = [NSPredicate predicateWithFormat:@"ANY categories.categoryId == %@ && feedNumber == %@ && ((stockLevel > 0) || (stockLevel <= 0 && dateDue >= %@ && dateDue <= %@ && dateDue != null))", [category categoryId], [feedConfig number], [NSDate date], date];
                break;
            case PKProductWarehouseEDC:
                predicate = [NSPredicate predicateWithFormat:@"ANY categories.categoryId == %@ && feedNumber == %@ && ((stockLevelEDC > 0) || (stockLevelEDC <= 0 && dateDueEDC >= %@ && dateDueEDC <= %@ && dateDueEDC != null))", [category categoryId], [feedConfig number], [NSDate date], date];
                break;
        }
    } else {
        switch (warehouse) {
            default:
            case PKProductWarehouseUK:
                predicate = [NSPredicate predicateWithFormat:@"feedNumber == %@ && ((stockLevel > 0) || (stockLevel <= 0 && dateDue >= %@ && dateDue <= %@ && dateDue != null))", [feedConfig number], [NSDate date], date];

                break;
            case PKProductWarehouseEDC:
                predicate = [NSPredicate predicateWithFormat:@"feedNumber == %@ && ((stockLevelEDC > 0) || (stockLevelEDC <= 0 && dateDueEDC >= %@ && dateDueEDC <= %@ && dateDueEDC != null))", [feedConfig number], [NSDate date], date];
                break;
        }
    }
        
    NSFetchRequest *request = [PKProduct MR_requestAllWithPredicate:predicate inContext:context];
    return [PKProduct removeBespokeProducts:[PKProduct MR_executeFetchRequest:request inContext:context]];
}

+ (NSArray *)customerProductsForCustomer:(PKCustomer *)customer forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    // Loop all customer orders:
    NSArray *invoices = [customer invoices];
    NSMutableArray *products = [NSMutableArray array];
    [invoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PKInvoice class]]) {
            PKInvoice *invoice = (PKInvoice *)obj;
            [[invoice invoiceLines] enumerateObjectsUsingBlock:^(PKInvoiceLine *invoiceLine, NSUInteger idx, BOOL * _Nonnull stop) {
                PKProduct *product = [invoiceLine product];
                if (product && ![products containsObject:product]) {
                    [products addObject:product];
                }
            }];
        } else if ([obj isKindOfClass:[PKBasket class]]) {
            PKBasket *basket = (PKBasket *)obj;
            [[basket items] enumerateObjectsUsingBlock:^(PKBasketItem *item, BOOL * _Nonnull stop) {
                PKProduct *product = [PKProduct findWithProductId:[item productUuid] forFeedConfig:nil inContext:nil];
                if (product && ![products containsObject:product]) {
                    [products addObject:product];
                }
            }];
        }
    }];
    
    return products;
}

+ (NSArray *)customerPastOrderProductsForCustomer:(PKCustomer *)customer forFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    // Loop all customer orders:
    NSArray *invoices = [customer invoices];
    NSMutableArray *products = [NSMutableArray array];
    [invoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PKInvoice class]]) {
            PKInvoice *invoice = (PKInvoice *)obj;
            if(([invoice statusCode] == PKInvoiceStatusComplete) || ([invoice statusCode] == PKInvoiceStatusOutstanding) || ([invoice statusCode] == PKInvoiceStatusInWarehouse)) {
                [[invoice invoiceLines] enumerateObjectsUsingBlock:^(PKInvoiceLine *invoiceLine, NSUInteger idx, BOOL * _Nonnull stop) {
                    PKProduct *product = [invoiceLine product];
                    if (product && ![products containsObject:product]) {
                        [products addObject:product];
                    }
                }];
            }
        }
    }];
    
    return products;
}

+ (NSArray *)topSellingProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    NSString *key = @"position";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"position > 0 && feedNumber == %@", [feedConfig number]];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kPKUserDefaultsGlobalRanks] boolValue]) {
        key = @"positionGlobal";
        predicate = [NSPredicate predicateWithFormat:@"positionGlobal > 0 && feedNumber == %@", [feedConfig number]];
    }
    
    NSFetchRequest *request = [PKProduct MR_requestAllSortedBy:key
                                                     ascending:YES
                                                 withPredicate:predicate
                                                     inContext:context];
    [request setFetchLimit:250];
    return [PKProduct MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *)topGrossingProductsForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    NSFetchRequest *request = [PKProduct MR_requestAllSortedBy:@"valuePosition"
                                                     ascending:YES
                                                 withPredicate:[NSPredicate predicateWithFormat:@"valuePosition > 0 && stockLevel > 0 && feedNumber == %@", [feedConfig number]]
                                                     inContext:context];
    [request setFetchLimit:250];
    return [PKProduct MR_executeFetchRequest:request inContext:context];
}

+ (PKProduct*) findWithProductId:(NSString*)productId
                   forFeedConfig:(PKFeedConfig*)feedConfig
                       inContext:(NSManagedObjectContext*)context {
    // Provide a context if one isn't available
    if(!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if(!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    // Create a predicate to find the product within a given feed
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId = %@ AND feedNumber = %@", productId, [feedConfig number]];
    
    // Execute the search for the product
    return [PKProduct MR_findFirstWithPredicate:predicate inContext:context];
}

+ (PKProduct *)findWithProductCode:(NSString *)productCode
                     forFeedConfig:(PKFeedConfig *)feedConfig
                         inContext:(NSManagedObjectContext *)context {
    // Provide a context if one isn't available
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    // Create a predicate to find the product within a given feed
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"model = %@ AND feedNumber = %@", productCode, [feedConfig number]];
    
    // Execute the search for the product
    return [PKProduct MR_findFirstWithPredicate:predicate inContext:context];
}

+ (PKProduct*) findOrCreateWithProductId:(NSString*)productId
                           forFeedConfig:(PKFeedConfig*)feedConfig
                         inProductsArray:(NSArray*)products
                               inContext:(NSManagedObjectContext*)context
                               predicate:(NSPredicate *)predicate {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    if ([products count] != 0) {
        for (PKProduct *p in products) {
            if ([[p productId] isEqualToString:productId] && [[p feedNumber] isEqualToString:[feedConfig number]]) {
                return p;
            }
        }
    }
    
    PKProduct *product = [PKProduct MR_createEntityInContext:context];
    [product setProductId:productId];
    [product setFeedNumber:[feedConfig number]];
    return product;
}

+ (NSArray*) allProductsForFeedConfig:(PKFeedConfig*)feedConfig
                            inContext:(NSManagedObjectContext*)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber == %@", [feedConfig number]];
    return [PKProduct MR_findAllWithPredicate:predicate inContext:context];
}

- (UIImage *)image {
    UIImage *image = nil;
    PKImage *pkImage = nil;
    
    if ([self mainImage]) {
        pkImage = [self mainImage];
    } else {
        NSLog(@"[%@] - Main image missing for product code: %@", [self class], [self model]);
    }
    
    if (!pkImage) {
        pkImage = [[self sortedImages] firstObject];
    }
    
    if (pkImage) {
        image = [pkImage image];
    }
    
    if (!image) {
        NSLog(@"[%@] - No images missing for product code: %@", [self class], [self model]);
        image = [UIImage imageNamed:kPuckatorNoImageName];
    }
    
    return image;
}

- (UIImage *)thumb {
    return [self image];
//    UIImage *thumb = [[self mainImage] thumb];
//    if (thumb) {
//        return thumb;
//    } else {
//        return [self image];
//    }
}


- (NSArray *)sortedUIImages {
    NSMutableArray *images = [NSMutableArray array];
    
    [[self sortedImages] enumerateObjectsUsingBlock:^(PKImage *pkImage, NSUInteger idx, BOOL *stop) {
        UIImage *image = [pkImage image];
        if (image) {
            [images addObject:image];
        }
    }];
    
    return images;
}

- (NSArray *)sortedImages {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *images = [[self images] sortedArrayUsingDescriptors:@[sort]];
    return images;    
}

- (NSArray *)sortedPrices {
    return [self sortedPricesAscending:YES];
}

- (NSNumber *)wholesalePrice {
    PKProductPrice *price = [[self sortedPricesAscending:YES] firstObject];
    
    if (price) {
        return [NSDecimalNumber multiply:[price value] by:kPuckatorWholesaleDiscountPercentage];
    } else {
        return @(0.0f);
    }
}

- (NSNumber *)cartonPrice {
    PKProductPrice *productPrice = [[self sortedPricesAscending:NO] firstObject];
    NSNumber *price = @(0.0f);
    
    // Convert the price using the fx rate:
    if (productPrice) {
        price = [productPrice priceWithCurrentFxRate];
    }
    
    // Round the price to 2 demical places:
    return [NSDecimalNumber roundNumber:price];
}

- (NSNumber *)midPrice {
    NSNumber *price = @(0.0f);
    
    NSArray *prices = [self sortedPricesAscending:YES];
    
    if ([prices count] > 2) {
        PKProductPrice *productPrice = [prices objectAtIndex:1];
        
        // Convert the price using the fx rate:
        if (productPrice) {
            price = [productPrice priceWithCurrentFxRate];
        }
        
        // Round the price to 2 demical places:
        return [NSDecimalNumber roundNumber:price];
    }
    
    return price;
}

- (NSNumber *)midQuantity {
    NSNumber *quantity = @(0.0f);
    
    NSArray *prices = [self sortedPricesAscending:YES];
    
    if ([prices count] > 2) {
        PKProductPrice *productPrice = [prices objectAtIndex:1];
        
        // Convert the price using the fx rate:
        if (productPrice) {
            quantity = [productPrice quantity];
        }
    }
    
    return quantity;
}

- (NSArray *)sortedPricesAscending:(BOOL)ascending {
    if (![self prices]) {
        return nil;
    } else {    
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayIndex" ascending:ascending];
        NSArray *prices = [[self prices] sortedArrayUsingDescriptors:@[sort]];
        return prices;
    }
}

- (PKProductPrice *)price {
    return [[self sortedPrices] firstObject];
}

- (NSString *)purchaseUnitFormatted {
    return [NSString stringWithFormat:@"%i", [[self purchaseUnit] intValue]];
}

- (NSNumber *)purchaseUnitQuantityForRequestedQuantity:(NSNumber *)requestedQuantity {
    // Make sure the request quantity is at least 1:
    if ([requestedQuantity doubleValue] <= 0) {
        requestedQuantity = @(1);
    }
    
    //int purchaseUnit = [[self purchaseUnit] intValue];
    
    // Calculate both the normal multiple and the ceiled multiple in order
    // to determine if they are equal to one another:
    //float multiple = (float)requestedQuantity/(float)purchaseUnit;
    
    
    NSNumber *multiple = [NSDecimalNumber divide:requestedQuantity by:[self purchaseUnit]];
    float multipleCeil = ceilf([multiple floatValue]);
    
    // Only change the value if it isn't already a multiple of the purchase unit:
    if ([multiple floatValue] != multipleCeil) {
        // The requested quantity isn't a multiple of the purchase unit, therefore
        // return a multiple of the purchase unit:
        requestedQuantity = [NSDecimalNumber multiply:[self purchaseUnit] by:@(multipleCeil)];
    }
    
    // Return either the original quantity or the new quantity:
    return requestedQuantity;
}

- (NSString *)formattedPurchaseUnitQuantityForRequestedQuantity:(NSNumber *)requestedQuantity {
    return [NSString stringWithFormat:@"%i", [[self purchaseUnitQuantityForRequestedQuantity:requestedQuantity] intValue]];
}

- (PKProductPrice *)priceForQuantity:(NSNumber *)quantity {
    __block PKProductPrice *foundPrice = nil;
    NSArray *prices = [self sortedPricesAscending:NO];
    
    [prices enumerateObjectsUsingBlock:^(PKProductPrice *price, NSUInteger idx, BOOL *stop) {
        if ([quantity intValue] >= [[price quantity] intValue]) {
            foundPrice = price;
            *stop = YES;
        }
    }];
    
    // Default to the last price if required:
    if (!foundPrice) {
        foundPrice = [prices lastObject];
    }
    
    return foundPrice;
}

- (NSNumber *)roundedQuantity:(NSNumber *)quantity {
    float fraction = [quantity floatValue]/[[self purchaseUnit] floatValue];
    fraction = ceilf(fraction);
    
    int result = (int)(fraction * [[self purchaseUnit] floatValue]);
    return [NSNumber numberWithInt:result];    
}

- (NSArray*)salesHistoryForType:(PKSaleHistoryType)type warehouse:(PKProductWarehouse)warehouse {
    // If no sales history object attached, return empty array.
    if (![self saleHistory]) {
        return @[];
    }
    
    // Create handy PKSaleHistory objects based on the history...
    NSMutableArray *results = [NSMutableArray array];
    for(int i=1; i <= 12; i++) {
        PKProductSaleHistory *saleHistory = nil;
        switch (warehouse) {
            case PKProductWarehouseUK:
                saleHistory = [self saleHistory];
                break;
            case PKProductWarehouseEDC:
                saleHistory = [self saleHistoryEDC];
                break;
            default:
                break;
        }
        id history = [[PKSaleHistory alloc] initWithSaleHistory:saleHistory forType:type andMonthIndex:i];
        if (history) {
            [results addObject:history];
        }
    }
    return results;
}

- (int)salesHistoryTotalForHistory:(NSArray *)history {
    __block int total = 0;
    [history enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PKSaleHistory class]]) {
            PKSaleHistory *saleHistory = (PKSaleHistory *)obj;
            total += [saleHistory value];
        }
    }];
    return total;
}

- (int)salesHistoryTotalForType:(PKSaleHistoryType)type warehouse:(PKProductWarehouse)warehouse {
    return [self salesHistoryTotalForHistory:[self salesHistoryForType:type warehouse:warehouse]];
}

- (NSString *)yearNameForHistoryType:(PKSaleHistoryType)type {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    
    switch (type) {
        case PKSaleHistoryTypeYearToDate:
            return [formatter stringFromDate:[NSDate date]];
            break;
        case PKSaleHistoryTypePriorTwoYear: {
            int secondsInAYear = 31556926*2;
            return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-secondsInAYear]];
            break;
        }
        case PKSaleHistoryTypePriorYear:
        default: {
            int secondsInAYear = 31556926;
            return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-secondsInAYear]];
            break;
        }
    }
}

- (BOOL)isNewProduct {
    return [[self isNew] boolValue];
    //return [[self dateAdded] mk_isLaterThanDate:[[NSDate date] mk_dateByAddingDays:-[[[PKSession sharedInstance] currentFeedConfig] newProductDays]]];
}

- (BOOL)isNewStarProduct {
    return [[self isNewStar] boolValue];
    //return [[self dateAdded] mk_isLaterThanDate:[[NSDate date] mk_dateByAddingDays:-[[[PKSession sharedInstance] currentFeedConfig] newProductDays]]];
}


- (BOOL)isLOCK_TO_CARTON_QTY {
    
    return [[self lock_to_carton_qty] boolValue];
}

- (BOOL)isLOCK_TO_CARTON_PRICE {
    
    return [[self lock_to_carton_price] boolValue];
}

- (BOOL)isNewEDCProduct {
    NSLog(@"Document Path: %d", [[self isNewEDC] boolValue]);
    return [[self isNewEDC] boolValue];
}

- (NSAttributedString *)attributedBackOrderString {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    int qty = [self backOrderQty];
    
    if (qty != 0) {
        NSDictionary *attributes = @{NSBackgroundColorAttributeName : [UIColor redColor],
                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSFontAttributeName : [UIFont puckatorFontMediumWithSize:14]};
        NSDictionary *attributesHacks = @{NSForegroundColorAttributeName : [UIColor clearColor],
                                          NSBackgroundColorAttributeName : [UIColor redColor]};
        
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"%d on back order", @"Displays the number of products that are currently on back order. E.g. 1,000 on back order"), qty];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"xx" attributes:attributesHacks]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", text] attributes:attributes]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"xx" attributes:attributesHacks]];
    }
    
    return attributedString;
}

- (int)backOrderQty {
    return [[[[PKSession sharedInstance] backOrderProducts] objectForKey:[self model]] intValue];
}

- (NSAttributedString *)attributedTitleIncludeModel:(BOOL)includeModel includeCategories:(BOOL)includeCategories {
    NSString *title = [self title];
    
    if (!includeCategories) {
        if ([title length] > 40) {
            title = [[[title substringToIndex:40] mk_trimmedString] stringByAppendingString:@"..."];
        }
    }
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title
                                                                                        attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:20] color:[UIColor puckatorProductTitle]]];
    
    if (includeModel) {
        if (!includeCategories) {
            [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        } else {
            [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"   "]];
        }
        
        //ghanshyam change
        
        if ([self isNewStarProduct] || [self isNewEDCProduct]) {
            [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"★ "
                                                                                    attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:16] color:[UIColor puckatorRankMid]]]];
        }
        
        [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self model]]
                                                                                attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:16] color:[UIColor puckatorProductTitle]]]];
        
        if ([[self toBeDiscontinued] boolValue]) {
            [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[@" ⛔ " suffixFlagUK]
                                                                                    attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:16] color:[UIColor puckatorRankMid]]]];
        }
        
        if ([[self toBeDiscontinuedEDC] boolValue]) {
            [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[@" ⛔ " suffixFlagEDC]
                                                                                    attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:16] color:[UIColor puckatorRankMid]]]];
        }
    }
    
    if (includeCategories) {
        NSMutableString *categories = [NSMutableString string];
        [[self categories] enumerateObjectsUsingBlock:^(PKCategory *category, BOOL *stop) {
            [categories appendFormat:@"%@ / ", [category title]];
        }];
        
        if([categories length] >= 2) {
            categories = [[categories substringToIndex:([categories length] - 2)] mutableCopy];
        } 
        
        [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", categories]
                                                                                attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:16] color:[UIColor puckatorProductSubtitle]]]];
    }
    
    return attributedTitle;
}

#pragma mark - Supplier Methods

+ (NSArray *)supplierList {
    NSFetchRequest *request = [PKProduct MR_requestAll];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[@"manufacturer"]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"manufacturer" ascending:YES]]];
    [request setReturnsDistinctResults:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"manufacturer != '' && feedNumber == %@", [[[PKSession sharedInstance] currentFeedConfig] number]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *suppliers = [[NSManagedObjectContext MR_context] executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"[%@] - Error: %@", [self class], [error localizedDescription]);
    }
    
    return [suppliers valueForKey:@"manufacturer"];
}

+ (NSArray *)buyerList {
    NSFetchRequest *request = [PKProduct MR_requestAll];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[@"buyer"]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"buyer" ascending:YES]]];
    [request setReturnsDistinctResults:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buyer != '' && feedNumber == %@", [[[PKSession sharedInstance] currentFeedConfig] number]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *suppliers = [[NSManagedObjectContext MR_context] executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"[%@] - Error: %@", [self class], [error localizedDescription]);
    }
    
    return [suppliers valueForKey:@"buyer"];
}

+ (NSArray *)productsForSupplier:(NSString *)supplier {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"manufacturer == %@ && feedNumber == %@", supplier, [feedConfig number]];
    
    NSFetchRequest *request = [PKProduct MR_requestAllWithPredicate:predicate inContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSSortDescriptor *sortCode = [[NSSortDescriptor alloc] initWithKey:@"model" ascending:YES];
    [request setSortDescriptors:@[sort, sortCode]];
    
    return [PKProduct MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *)productsForBuyer:(NSString *)buyer {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buyer == %@ && feedNumber == %@", buyer, [feedConfig number]];
    
    NSFetchRequest *request = [PKProduct MR_requestAllWithPredicate:predicate inContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSSortDescriptor *sortCode = [[NSSortDescriptor alloc] initWithKey:@"model" ascending:YES];
    [request setSortDescriptors:@[sort, sortCode]];
    
    return [PKProduct MR_executeFetchRequest:request inContext:context];
}

#pragma mark - Search

+ (NSArray*)resultsForSearchParameters:(PKSearchParameters*)searchParameters {
    NSArray *keywords = nil;
    if ([[searchParameters searchText] length] != 0) {
        keywords = [[searchParameters searchText] componentsSeparatedByString:@" "];
    }
    
    NSMutableArray *keywordPredicates = [NSMutableArray array];
    
    // Create an array of predicates for each keyword in the title
    for (NSString *keyword in keywords) {
        if ([keyword length] != 0) {
            NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", keyword];
            if (titlePredicate) {
                [keywordPredicates addObject:titlePredicate];
            }
        }
    }
    
    // Product code predicates
    NSMutableArray *productCodePredicates = [NSMutableArray array];
    
    // Create an array of predicates for each keyword in the title
    for (NSString *keyword in keywords) {
        if ([keyword length] != 0) {
            NSPredicate *productCodePredicate = [NSPredicate predicateWithFormat:@"model contains[cd] %@", keyword];
            if (productCodePredicate) {
                [productCodePredicates addObject:productCodePredicate];
            }
        }
    }
    
//    // Product code predicates
//    NSMutableArray *barcodePredicates = [NSMutableArray array];
//
//    // Create an array of predicates for each keyword in the title
//    for (NSString *keyword in keywords) {
//        if ([keyword length] != 0) {
//            NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barcode contains[cd] %@", keyword];
//            if (barcodePredicate) {
//                [barcodePredicates addObject:barcodePredicate];
//            }
//        }
//    }
    
    NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barcode endswith[cd] %@", [searchParameters searchText]];
    
    // Create a predicate to search the product titles
    NSCompoundPredicate *predicateTitle = [NSCompoundPredicate andPredicateWithSubpredicates:keywordPredicates];
    
    // Then another predicate for product codes
    NSCompoundPredicate *predicateProductCodes = [NSCompoundPredicate andPredicateWithSubpredicates:productCodePredicates];
    
    // Then, create a prdicate to search the descriptions
    NSPredicate *descPredicate = [NSPredicate predicateWithValue:YES];
    if ([[searchParameters searchText] length] != 0) {
        descPredicate = [NSPredicate predicateWithFormat:@"descText contains[cd] %@", [searchParameters searchText]];
    }
    
    // Create a compound predicate from the first
    NSCompoundPredicate *compoundPredicateMetaData = nil;
    if ([searchParameters scope] == PKSearchParameterTypeSearchByAll) {
        compoundPredicateMetaData = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicateTitle, descPredicate, predicateProductCodes, barcodePredicate]];
    } else if ([searchParameters scope] == PKSearchParameterTypeSearchByCodeOnly) {
        compoundPredicateMetaData = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicateProductCodes]];
    } else if ([searchParameters scope] == PKSearchParameterTypeSearchByTitleAndDesc) {
        compoundPredicateMetaData = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicateTitle, descPredicate]];
    } else if ([searchParameters scope] == PKSearchParameterTypeSearchByTitleOnly) {
        compoundPredicateMetaData = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicateTitle]];
    }
    
    // Filter by specific categories
    NSMutableArray *categoryPredicates = [NSMutableArray array];
    if ([[searchParameters filterCategoryIds] count] >= 1) {
        for (NSString *categoryId in [searchParameters filterCategoryIds]) {
            NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"ANY categories.categoryId = %@", categoryId];
            if (categoryPredicate) {
                [categoryPredicates addObject:categoryPredicate];
            }
        }
    }
    
    // Create compound predicate from the above
    NSCompoundPredicate *compoundPredicateCagegories = [NSCompoundPredicate orPredicateWithSubpredicates:categoryPredicates];
    
    
    // Create the final compound predicate
    NSCompoundPredicate *predicate = nil;
    if (compoundPredicateMetaData != nil) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[compoundPredicateMetaData, compoundPredicateCagegories]];
    } else {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[compoundPredicateCagegories]];
    }
    
    // If no categories, override the predicate
    if ([[searchParameters filterCategoryIds] count] == 0) {
        predicate = compoundPredicateMetaData;
    }
    
    NSPredicate *pricePredicate = nil;
    if ([[searchParameters priceMin] floatValue] > 0 && [[searchParameters priceMax] floatValue] > 0) {
        pricePredicate = [NSPredicate predicateWithFormat:@"firstPrice >= %@ && firstPrice <= %@", [searchParameters priceMin], [searchParameters priceMax]];
    } else if ([[searchParameters priceMin] floatValue] > 0) {
        pricePredicate = [NSPredicate predicateWithFormat:@"firstPrice >= %@", [searchParameters priceMin]];
    } else if ([[searchParameters priceMax] floatValue] > 0) {
        pricePredicate = [NSPredicate predicateWithFormat:@"firstPrice <= %@", [searchParameters priceMax]];
    }
    
    if (predicate && pricePredicate) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, pricePredicate]];
    }
    
    NSPredicate *feedNumberPredicate = [NSPredicate predicateWithFormat:@"feedNumber == %@", [[[PKSession sharedInstance] currentFeedConfig] number]];
    if (predicate) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, feedNumberPredicate]];
    }
    
    //NSLog(@"Predicate for search is %@", predicate);
    
    // Perform the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PKProduct"];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setRelationshipKeyPathsForPrefetching:[self prefetchingNames]];
    
    // Execute
    NSArray *results = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:fetchRequest error:nil];
    //NSLog(@"Results: %@", results);
    //NSLog(@"Total %d", (int)[results count]);
    
    return results;
    
    return [PKProduct filterProducts:results stockFilterEnabled:NO bespokeFilterEnabled:NO];
}

#pragma mark - Utils

+ (NSArray *)filterProducts:(NSArray *)products {
    return [PKProduct filterProducts:products stockFilterEnabled:YES bespokeFilterEnabled:YES];
}

+ (NSArray *)filterProducts:(NSArray *)products stockFilterEnabled:(BOOL)stockFilterEnabled bespokeFilterEnabled:(BOOL)bespokeFilterEnabled {
    if ([products count] != 0) {
        // Filter the out of stock products:
        NSString *predicate = nil;
        PKProductWarehouse warehouse = [[[PKSession sharedInstance] currentFeedConfig] warehouse];
        
        if (stockFilterEnabled) {
            if ([[PKSession sharedInstance] showAvailableProducts]) {
                switch (warehouse) {
                    default:
                    case PKProductWarehouseUK:
                        predicate = @"availableStock > 0";
                        break;
                    case PKProductWarehouseEDC:
                        predicate = @"availableStockEDC > 0";
                        break;
                }
            } else if ([[PKSession sharedInstance] hideOutOfStockProducts]) {
                switch (warehouse) {
                    default:
                    case PKProductWarehouseUK:
                        predicate = @"stockLevel > 0";
                        break;
                    case PKProductWarehouseEDC:
                        predicate = @"stockLevelEDC > 0";
                        break;
                }
            }
        }
        
        if ([predicate length] != 0) {
            products = [products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicate]];
        }
        
        if (![[PKSession sharedInstance] showSampleProducts]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT model beginswith[cd] %@", @"S_"];
            products = [products filteredArrayUsingPredicate:predicate];
        }
        
        if ([[PKSession sharedInstance] hideTBDProducts]) {
            NSPredicate *predicate = nil;
            switch (warehouse) {
                default:
                case PKProductWarehouseUK:
                    predicate = [NSPredicate predicateWithFormat:@"toBeDiscontinued == 0" arguments:nil];
                    break;
                case PKProductWarehouseEDC:
                    predicate = [NSPredicate predicateWithFormat:@"toBeDiscontinuedEDC == 0" arguments:nil];
                    break;
            }
            
            if (predicate) {
                products = [products filteredArrayUsingPredicate:predicate];
            }
        }
        
        if ([[PKSession sharedInstance] hideBespokeProducts] && bespokeFilterEnabled) {
            // Get the bespoke categories:
            NSArray *bespokeCategories = [PKCategory bespokeCategoryIds];
            
            // Filter out the bespoke products:
            NSMutableArray *filteredProducts = [products mutableCopy];
            [products enumerateObjectsUsingBlock:^(PKProduct *product, NSUInteger idx, BOOL *stop) {
                [bespokeCategories enumerateObjectsUsingBlock:^(NSString *categoryId, NSUInteger idx, BOOL *stop) {
                    if ([[product categoryIds] containsString:[NSString stringWithFormat:@"-%@-", categoryId]]) {
                        [filteredProducts removeObject:product];
                        *stop = YES;
                    }
                }];
            }];
            
            // Update the products array:
            products = filteredProducts;
        }
    }
    
    return products;
}

+ (NSArray *)removeBespokeProducts:(NSArray *)products {
    if ([products count] == 0) {
        return products;
    }
    
    // Get the bespoke categories:
    NSArray *bespokeCategories = [PKCategory bespokeCategoryIds];
    
    // Filter out the bespoke products:
    NSMutableArray *filteredProducts = [products mutableCopy];
    [products enumerateObjectsUsingBlock:^(PKProduct *product, NSUInteger idx, BOOL *stop) {
        [bespokeCategories enumerateObjectsUsingBlock:^(NSString *categoryId, NSUInteger idx, BOOL *stop) {
            if ([[product categoryIds] containsString:[NSString stringWithFormat:@"-%@-", categoryId]]) {
                [filteredProducts removeObject:product];
                *stop = YES;
            }
        }];
    }];
    
    // Update the products array:
    return filteredProducts;
}

+ (NSArray *)sortProducts:(NSArray *)products {
    int selectedSortFilter = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PKSortOption"] intValue];
    
    BOOL isAscending = YES;
    NSString *key = @"title";
    
    if (selectedSortFilter <= 0) {
        isAscending = NO;
    }
    
    int sortFilter = abs(selectedSortFilter);
    switch (sortFilter) {
        case PKSearchParameterTypeProductCode: {
            key = @"model";
            break;
        }
        case PKSearchParameterTypePrice: {
            key = @"firstPrice";
            break;
        }
        case PKSearchParameterTypeTotalSold: {
            key = @"totalSold";
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kPKUserDefaultsGlobalRanks]) {
                key = @"totalSoldGlobal";
            }
            break;
        }
        case PKSearchParameterTypeTotalValue: {
            key = @"totalValue";
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kPKUserDefaultsGlobalRanks]) {
                key = @"totalValueGlobal";
            }
            break;
        }
        case PKSearchParameterTypeStockAvailable: {
            key = @"stockLevel";
            if ([[[[PKSession sharedInstance] currentFeedConfig] name] isEqualToString:@"EU"]) {
                key = @"stockLevelEDC";
            }
            break;
        }
        case PKSearchParameterTypeDateAdded: {
            key = @"dateAdded";
            break;
        }
        default: {
            key = @"model";
            break;
        }
    }
    
    products = [products sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:key ascending:isAscending]]];
    
    return products;
}

+ (NSArray *)prefetchingNames {
    return [NSArray arrayWithObjects:@"categories", @"images", @"prices", nil];
}

- (NSString *)formattedStockAvaliableDate {
    NSDictionary *stockAvaliableDate = [self stockDateAvaliableData];
    return [NSString stringWithFormat:@"%@: %@", [stockAvaliableDate valueForKey:@"title"], [stockAvaliableDate valueForKey:@"value"]];
}

- (NSDictionary *)stockDateAvaliableData {
    NSString *formattedQty = [NSString string];
    if ([[self ordered] intValue] > 0) {
        formattedQty = [NSString stringWithFormat:@"(%d)", [[self ordered] intValue]];
    }
    
    // Add the due date:
    NSString *dateTitle = nil;
    NSString *dateValue = nil;
    NSString *formattedDate = nil;
    
    if ([[self dateDueEDC] mk_isEarlierThanDate:[NSDate date]]) {
        dateTitle = NSLocalizedString(@"Last received", nil);
        formattedDate = [[self dateAvailable] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]];
    } else {
        dateTitle = NSLocalizedString(@"Due in", nil);
        formattedDate = [[self dateDueEDC] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]];
    }
    
    // Check the formatted date is valid:
    if ([formattedDate length] == 0 || [formattedDate containsString:@"null"]) {
        formattedDate = NSLocalizedString(@"-", nil);
    }
    
    if ([dateValue length] == 0) {
        if ([formattedQty length] != 0) {
            dateValue = [NSString stringWithFormat:@"%@ %@", formattedDate, formattedQty];
        } else {
            dateValue = [NSString stringWithFormat:@"%@", formattedDate];
        }
    }
    
    // Check strings are valid:
    if ([dateTitle length] == 0 || [dateTitle containsString:@"null"]) {
        dateTitle = NSLocalizedString(@"Due/Received", nil);
    }
    if ([dateValue length] == 0 || [dateValue containsString:@"null"]) {
        dateValue = NSLocalizedString(@"-", nil);
    }
    
    PKFeedConfig *activeFeed = [[PKSession sharedInstance] currentFeedConfig];
    
    if([activeFeed.name isEqualToString:@"EU" ]) {
        return @{@"title" : [dateTitle suffixFlagEDC], @"value" : dateValue};
    }
    
    return @{@"title" : [dateTitle suffixFlagUK], @"value" : dateValue};
}

- (NSDate *)dateDueEDC {
    return [self dateAvailableEDC];
}

- (NSDictionary *)stockDateAvaliableDataEDC {
    NSString *formattedQty = [NSString string];
    if ([[self orderedEDC] intValue] > 0) {
        formattedQty = [NSString stringWithFormat:@"(%d)", [[self orderedEDC] intValue]];
    }
    
    // Add the due date:
    NSString *dateTitle = nil;
    NSString *dateValue = nil;
    NSString *formattedDate = nil;
    
    if ([[self dateDueEDC] mk_isEarlierThanDate:[NSDate date]]) {
        dateTitle = NSLocalizedString(@"Last received", nil);
        formattedDate = [[self dateAvailableEDC] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]];
    } else {
        dateTitle = NSLocalizedString(@"Due in", nil);
        formattedDate = [[self dateDueEDC] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]];
    }
    
    // Check the formatted date is valid:
    if ([formattedDate length] == 0 || [formattedDate containsString:@"null"]) {
        formattedDate = NSLocalizedString(@"-", nil);
    }
    
    if ([dateValue length] == 0) {
        if ([formattedQty length] != 0) {
            dateValue = [NSString stringWithFormat:@"%@ %@", formattedDate, formattedQty];
        } else {
            dateValue = [NSString stringWithFormat:@"%@", formattedDate];
        }
    }
    
    // Check strings are valid:
    if ([dateTitle length] == 0 || [dateTitle containsString:@"null"]) {
        dateTitle = NSLocalizedString(@"Due/Received", nil);
    }
    if ([dateValue length] == 0 || [dateValue containsString:@"null"]) {
        dateValue = NSLocalizedString(@"-", nil);
    }
    
    return @{@"title" : [dateTitle suffixFlagEDC], @"value" : dateValue};
}

- (PKDisplayData *)displayData {
    PKDisplayData *displayData = [PKDisplayData create];
    [displayData openSection];
    [displayData addTitle:NSLocalizedString(@"Product code", nil) data:[self model]];
    [displayData addTitle:NSLocalizedString(@"Barcode", nil) data:[self barcode]];
    
    // -------------
    // -- UK DATA --
    // -------------
    //[displayData addTitle:[@"" prefixFlagUK] data:NSLocalizedString(@"UK Warehouse Data", nil)];
    [displayData addTitle:[NSLocalizedString(@"Total YTD sold", nil) suffixFlagUK] data:[NSString stringWithFormat:@"%i", [self salesHistoryTotalForType:PKSaleHistoryTypeYearToDate warehouse:PKProductWarehouseUK]]];
    if ([[self availableStock] intValue] >= 0) {
        [displayData addTitle:[NSLocalizedString(@"In stock", nil) suffixFlagUK] data:[NSString stringWithFormat:@"%i (%@: %i)", [[self stockLevel] intValue], NSLocalizedString(@"Available", nil), [[self availableStock] intValue]]];
    } else {
        [displayData addTitle:[NSLocalizedString(@"In stock", nil) suffixFlagUK] data:[NSString stringWithFormat:@"%i (%@: %i)", [[self stockLevel] intValue], NSLocalizedString(@"Available", nil), [[self availableStock] intValue]] foregroundRight:[UIColor redColor] backgroundRight:nil];
    }
    
    NSDictionary *stockDateData = nil;
    if ([[self purchaseOrders] count] == 0) {
        // Display stock date data:
        stockDateData = [self stockDateAvaliableData];
        [displayData addTitle:[stockDateData valueForKey:@"title"] data:[stockDateData valueForKey:@"value"]];
    } else {
        // Add the purchase orders:
        [[self purchaseOrders] enumerateObjectsUsingBlock:^(PKPurchaseOrder *purchaseOrder, NSUInteger idx, BOOL *stop) {
            // Don't show any purchase orders that have the same date as the due in date:
            //if ([[purchaseOrder date] mk_isLaterThanDate:[self dateDue]]) {
            if (idx == 0) {
                [displayData addTitle:[NSLocalizedString(@"Due in", nil) suffixFlagUK] data:[purchaseOrder formattedDescription]];
            } else {
                [displayData addTitle:@"" data:[purchaseOrder formattedDescription]];
            }
        }];
    }
    
    [displayData addTitle:[NSLocalizedString(@"On back order", nil) suffixFlagUK] data:[NSString stringWithFormat:@"%i", [[self backOrders] intValue]]];
    
    // --------------
    // -- EDC DATA --
    // --------------
    //[displayData addTitle:[@"" prefixFlagEDC] data:NSLocalizedString(@"EDC Warehouse Data", nil)];
    [displayData addTitle:[NSLocalizedString(@"Total YTD sold", nil) suffixFlagEDC] data:[NSString stringWithFormat:@"%i", [self salesHistoryTotalForType:PKSaleHistoryTypeYearToDate warehouse:PKProductWarehouseEDC]]];
    
    if ([[self availableStockEDC] intValue] >= 0) {
        [displayData addTitle:[NSLocalizedString(@"In stock", nil) suffixFlagEDC] data:[NSString stringWithFormat:@"%i (%@: %i)", [[self stockLevelEDC] intValue], NSLocalizedString(@"Available", nil), [[self availableStockEDC] intValue]]];
    } else {
        [displayData addTitle:[NSLocalizedString(@"In stock", nil) suffixFlagEDC] data:[NSString stringWithFormat:@"%i (%@: %i)", [[self stockLevelEDC] intValue], NSLocalizedString(@"Available", nil), [[self availableStockEDC] intValue]] foregroundRight:[UIColor redColor] backgroundRight:nil];
    }
    
    // Display stock date data:
    if ([[self purchaseOrdersEDC] count] == 0) {
        stockDateData = [self stockDateAvaliableDataEDC];
        [displayData addTitle:[stockDateData valueForKey:@"title"] data:[stockDateData valueForKey:@"value"]];
    } else {
        // Add the purchase orders:
        [[self purchaseOrdersEDC] enumerateObjectsUsingBlock:^(PKPurchaseOrder *purchaseOrder, NSUInteger idx, BOOL *stop) {
            // Don't show any purchase orders that have the same date as the due in date:
//            if ([[purchaseOrder date] mk_isLaterThanDate:[self dateDueEDC]]) {
//                [displayData addTitle:@"" data:[purchaseOrder formattedDescription]];
//            }
            
            if (idx == 0) {
                [displayData addTitle:[NSLocalizedString(@"Due in", nil) suffixFlagEDC] data:[purchaseOrder formattedDescription]];
            } else {
                [displayData addTitle:@"" data:[purchaseOrder formattedDescription]];
            }
        }];
    }
    
    [displayData addTitle:[NSLocalizedString(@"On back order", nil) suffixFlagEDC] data:[NSString stringWithFormat:@"%i", [[self backOrdersEDC] intValue]]];
    
    // --------------
    
    //[displayData addTitle:@"-" data:@"-"];
    [displayData addTitle:NSLocalizedString(@"Purchase Unit", nil) data:[NSString stringWithFormat:@"%i", [[self purchaseUnit] intValue]]];
    [displayData addTitle:NSLocalizedString(@"Inner", nil) data:[NSString stringWithFormat:@"%i", [[self inner] intValue]]];
    [displayData addTitle:NSLocalizedString(@"Carton", nil) data:[NSString stringWithFormat:@"%i", [[self carton] intValue]]];
    [displayData addTitle:NSLocalizedString(@"Supplier", nil) data:[self manufacturer]];
    [displayData addTitle:NSLocalizedString(@"Buyer", nil) data:[self buyer]];
    
    [displayData addTitle:[NSLocalizedString(@"MTS", nil) suffixFlagUK] data:[NSString stringWithFormat:@"%d", [[self monthsToSell] intValue]]];
    
    // Check for the admin password:
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kPKUserDefaultsPasswordKey] isEqualToString:kPKUserDefaultsPasswordValue]) {
        [displayData addTitle:[NSLocalizedString(@"FOB", nil) suffixFlagUK] data:[NSString stringWithFormat:@"$%.2f", [[self fobPrice] doubleValue]]];
        [displayData addTitle:[NSLocalizedString(@"LCP", nil) suffixFlagUK] data:[NSString stringWithFormat:@"£%.2f", [[self landedCostPrice] doubleValue]]];
    }
    
    [displayData addTitle:[NSLocalizedString(@"MTS", nil) suffixFlagEDC] data:[NSString stringWithFormat:@"%d", [[self monthsToSellEDC] intValue]]];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kPKUserDefaultsPasswordKey] isEqualToString:kPKUserDefaultsPasswordValue]) {
        [displayData addTitle:[NSLocalizedString(@"FOB", nil) suffixFlagEDC] data:[NSString stringWithFormat:@"$%.2f", [[self fobPriceEDC] doubleValue]]];
        [displayData addTitle:[NSLocalizedString(@"LCP", nil) suffixFlagEDC] data:[NSString stringWithFormat:@"€%.2f", [[self landedCostPriceEDC] doubleValue]]];
    }
    
    [displayData closeSection];
    
    return displayData;
}

#pragma mark - Price History

+ (NSDictionary *)priceHistoryWithCurrencyCode:(NSString *)currencyCode {
    // Only do execute the SQL query if the currency code is valid:
    if ([currencyCode length] == 0) {
        return nil;
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT PRODUCT_ID, PRICE, TIER1, TIER2 FROM PriceHistory WHERE CURRENCY = '%@'", [currencyCode uppercaseString]];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            NSString *productId = [resultSet stringForColumnIfExists:@"PRODUCT_ID"];
            double tier0 = [resultSet doubleForColumnIfExists:@"PRICE"];
            double tier1 = [resultSet doubleForColumnIfExists:@"TIER1"];
            double tier2 = [resultSet doubleForColumnIfExists:@"TIER2"];
            
            NSArray *prices = @[@(tier0), @(tier1), @(tier2)];
            
            [dictionary setObject:prices forKey:productId];
        }
    }];
    
    return dictionary;
}

#pragma mark - Purchase Order Methods

- (NSArray *)purchaseOrders {
    NSMutableArray *purchaseOrders = [NSMutableArray array];
    
    if ([[self purchaseOrdersCSV] length] != 0) {
        NSArray *pos = [[self purchaseOrdersCSV] componentsSeparatedByString:@","];
        
        [pos enumerateObjectsUsingBlock:^(NSString *po, NSUInteger idx, BOOL *stop) {
            NSArray *properties = [po componentsSeparatedByString:@"|"];
            
            if ([properties count] == 3) {
                PKPurchaseOrder *purchaseOrder = [PKPurchaseOrder createWithNumber:[properties objectAtIndex:0]
                                                                        dateString:[properties objectAtIndex:1]
                                                                    quantityString:[properties objectAtIndex:2]];
                [purchaseOrder setShipmentStatus:PKShipmentStatusNotShipped];
                if (purchaseOrder) {
                    [purchaseOrders addObject:purchaseOrder];
                }
            } else if ([properties count] == 4) {
                PKPurchaseOrder *purchaseOrder = [PKPurchaseOrder createWithNumber:[properties objectAtIndex:0]
                                                                        dateString:[properties objectAtIndex:1]
                                                                    quantityString:[properties objectAtIndex:2]];
                if ([[properties objectAtIndex:3] intValue] == 0) {
                    [purchaseOrder setShipmentStatus:PKShipmentStatusNotShipped];
                } else if ([[properties objectAtIndex:3] intValue] >= 1) {
                    [purchaseOrder setShipmentStatus:PKShipmentStatusShipped];
                }
                if (purchaseOrder) {
                    [purchaseOrders addObject:purchaseOrder];
                }
            }
        }];
    }
    
    return purchaseOrders;
}

- (NSArray *)purchaseOrdersEDC {
    NSMutableArray *purchaseOrders = [NSMutableArray array];
    
    if ([[self purchaseOrdersCSVEDC] length] != 0) {
        NSArray *pos = [[self purchaseOrdersCSVEDC] componentsSeparatedByString:@","];
        
        [pos enumerateObjectsUsingBlock:^(NSString *po, NSUInteger idx, BOOL *stop) {
            NSArray *properties = [po componentsSeparatedByString:@"|"];
            
            if ([properties count] == 3) {
                PKPurchaseOrder *purchaseOrder = [PKPurchaseOrder createWithNumber:[properties objectAtIndex:0]
                                                                        dateString:[properties objectAtIndex:1]
                                                                    quantityString:[properties objectAtIndex:2]];
                [purchaseOrder setShipmentStatus:PKShipmentStatusNotShipped];
                if (purchaseOrder) {
                    [purchaseOrders addObject:purchaseOrder];
                }
            } else if ([properties count] == 4) {
                PKPurchaseOrder *purchaseOrder = [PKPurchaseOrder createWithNumber:[properties objectAtIndex:0]
                                                                        dateString:[properties objectAtIndex:1]
                                                                    quantityString:[properties objectAtIndex:2]];
                if ([[properties objectAtIndex:3] intValue] == 0) {
                    [purchaseOrder setShipmentStatus:PKShipmentStatusNotShipped];
                } else if ([[properties objectAtIndex:3] intValue] >= 1) {
                    [purchaseOrder setShipmentStatus:PKShipmentStatusShipped];
                }
                if (purchaseOrder) {
                    [purchaseOrders addObject:purchaseOrder];
                }
            }
        }];
    }
    
    return purchaseOrders;
}

#pragma mark - Sound Methods

- (NSArray<NSString *> *)soundFilenames {
    if ([[self model] isEqualToString:@"KEY79"]) {
        return @[@"KEY79_Crying With Laughter.m4a",
                 @"KEY79_Grin 1.m4a",
                 @"KEY79_Grin 2.m4a",
                 @"KEY79_Grin 3.m4a",
                 @"KEY79_Grin 4.m4a",
                 @"KEY79_Grin 5.m4a",
                 @"KEY79_Heart Eyes.m4a",
                 @"KEY79_Poop.m4a",
                 @"KEY79_Sunglasses.m4a",
                 @"KEY79_Tongue Out.m4a"];
    }
    return nil;
}

- (NSString *)cleanSoundFilename:(NSString *)filename {
    filename = [filename stringByReplacingOccurrencesOfString:[[self model] stringByAppendingString:@"_"] withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@".m4a" withString:@""];
    return filename;
}

#pragma mark -

@end
