//
//  PKBasket+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 11/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasket+Operations.h"
#import "PKCustomer.h"
#import "PKBasketItem+Operations.h"
#import "PKOrder.h"
#import <FCFileManager/FCFileManager.h>
#import <AFNetworking/AFNetworking.h>
#import "PKConstant.h"
#import "PKCurrency.h"
#import "PKProductPrice+Operations.h"
#import "PKCustomerMeta+Operations.h"
#import "PKInvoiceLine.h"
#import <FXKeychain/FXKeychain.h>
#import "PKCountry.h"
#import "PKAddress.h"
#import <MKFoundationKit/MKFoundationKit.h>

@implementation PKBasket (Operations)

+ (NSArray *)archivedOrdersAndQuotesForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if ([feedNumber length] == 0) {
        feedNumber = [[[PKSession sharedInstance] currentFeedConfig] number];
    }
    
    NSString *customerId = [NSString stringWithFormat:@"%i", [customer objectId]];
    return [PKBasket MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"customerId = %@ && feedNumber = %@ AND (basketStatus == %@ OR basketStatus == %@ OR basketStatus == %@)", customerId, feedNumber, @(PKBasketStatusOpen), @(PKBasketStatusError), @(PKBasketStatusCancelled)] inContext:context];
}

+ (NSArray *)ordersAndQuotesForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if ([feedNumber length] == 0) {
        feedNumber = [[[PKSession sharedInstance] currentFeedConfig] number];
    }
    
    NSString *customerId = [NSString stringWithFormat:@"%i", [customer objectId]];
    return [PKBasket MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"customerId = %@ && feedNumber = %@ AND basketStatus != %@ AND basketStatus != %@ AND basketStatus != %@", customerId, feedNumber, @(PKBasketStatusOpen), @(PKBasketStatusCancelled), @(PKBasketStatusError)] inContext:context];
}

+ (NSArray *)recentBasketsForFeedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if ([feedNumber length] == 0) {
        feedNumber = [[[PKSession sharedInstance] currentFeedConfig] number];
    }
    
    NSDate *date = [[NSDate date] mk_dateByAddingWeeks:-2];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber = %@ AND basketStatus != %@ && (createdAt >= %@)", feedNumber, @(PKBasketStatusOpen), date];
    return [PKBasket MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:predicate inContext:context];
}

+ (NSArray *)basketsForFeedNumber:(NSString *)feedNumber status:(PKBasketStatus)status context:(NSManagedObjectContext *)context {
    // Provide a context if one isn't available:
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Validate the variables:
    if ([feedNumber length] != 0) {
        //return [PKBasket MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"customerId = %@ AND feedNumber = %@", customerId, feedNumber] inContext:context];
        return [PKBasket MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"feedNumber = %@ AND basketStatus = %@", feedNumber, @(status)] inContext:context];
    }
    
    return nil;
}

+ (NSArray *)basketsForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber status:(PKBasketStatus)status context:(NSManagedObjectContext *)context {
    // Provide a context if one isn't available:
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Validate the variables:
    if (customer && [feedNumber length] != 0) {
        NSString *customerId = [NSString stringWithFormat:@"%i", [customer objectId]];
        //return [PKBasket MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"customerId = %@ AND feedNumber = %@", customerId, feedNumber] inContext:context];
        return [PKBasket MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"customerId = %@ AND feedNumber = %@ AND basketStatus = %@", customerId, feedNumber, @(status)] inContext:context];
    }
    
    return nil;
}

#pragma mark - New Basket Methods

+ (PKBasket *)createSessionBasketForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context {
    // TODO: Clear down open baskets:
    
    if (!customer) {
        return nil;
    }
    
    if (!feedNumber) {
        return nil;
    }
    
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Get the customerId:
    NSString *customerId = [NSString stringWithFormat:@"%i", [customer objectId]];
    
    // Create a new basket
    PKBasket *basket = [PKBasket MR_createEntityInContext:context];
    [basket setCreatedAt:[NSDate date]];
    [basket setCustomerId:customerId];
    [basket setFeedNumber:feedNumber];
    [basket setNotes:@""];
    [basket setCurrencyCode:[[PKSession sharedInstance] currentCurrencyCode]];        // This will be overwritten by the client
    [basket setBasketStatus:@(PKBasketStatusOpen)];
    
    // Insert empty order object
    PKOrder *order = [PKOrder MR_createEntityInContext:context];
    [order setAddressBillingCompanyName:[customer companyName]];
    [order setAddressBillingContactName:[customer contactName]];
    [order setTradeShowOrder:@([[PKSession sharedInstance] isShowOrder])];
    [order setDraft:@(YES)];    // This will mean the default customer details will get loaded when about to complete order
    [order setPaymentMethodId:@(3)]; // Payment not agreed
    [basket setOrder:order];
    
    // Inject default values:
    PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    [basket setVatRate:@([feedConfig defaultVatRate])];
    [basket setDeliveryPrice:@([feedConfig defaultDeliveryCostForISO:[basket currencyCode]])];
    
    // Save the PKBasket to database:
    [context MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronouslyExceptRootContext completion:^(BOOL contextDidSave, NSError *error) {
        if (error) {
            NSLog(@"Error saving PKBasket: %@", [error localizedDescription]);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBasketStatusChanged object:basket];
        }
    }];
    
    // Set the session basket:
    if ([PKBasket setSessionBasket:basket]) {
        // Return the basket:
        return basket;
    }
    
    // Return nil:
    return nil;
}

+ (PKBasket *)sessionBasket {
    return [[PKSession sharedInstance] basket];
}

+ (BOOL)setSessionBasket:(PKBasket *)basket {
    [[PKSession sharedInstance] setBasket:basket];
    return (basket == [PKBasket sessionBasket]);
}

+ (BOOL)clearSessionBasket {
    [[PKSession sharedInstance] setBasket:nil];
    [[PKSession sharedInstance] clearProductQuantityHistory];
    return ([PKBasket sessionBasket] == nil);
}

#pragma mark - Open Basket Methods

+ (NSArray *)openBasketsForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber includeErrored:(BOOL)includeErrored context:(NSManagedObjectContext *)context {
    if ([feedNumber length] == 0) {
        feedNumber = [[[PKSession sharedInstance] currentFeedConfig] number];
    }
    
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Find all open baskets for the customer (latest first):
    NSString *customerId = [NSString stringWithFormat:@"%i", [customer objectId]];
    
    NSPredicate *predicate = nil;
    if (includeErrored) {
        predicate = [NSPredicate predicateWithFormat:@"customerId = %@ AND feedNumber = %@ AND (basketStatus = %@ || basketStatus = %@)", customerId, feedNumber, @(PKBasketStatusOpen), @(PKBasketStatusError)];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"customerId = %@ AND feedNumber = %@ AND basketStatus = %@", customerId, feedNumber, @(PKBasketStatusOpen)];
    }
    
    NSArray *openBaskets = [PKBasket MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:predicate inContext:context];
    
    // Cancel the open baskets excepted the first order:
    if ([openBaskets count] > 1) {
        [openBaskets enumerateObjectsUsingBlock:^(PKBasket * _Nonnull basket, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != 0) {
                [basket setStatus:PKBasketStatusCancelled shouldSave:NO];
            }
        }];
        
        // Save the context:
        [context MR_saveToPersistentStoreAndWait];
    }
    
    // Only return the first open basket (as the other have now been cancelled):
    if ([openBaskets firstObject]) {
        return @[[openBaskets firstObject]];
    }
    
    return nil;
}

+ (NSArray *)openBasketsForFeedNumber:(NSString *)feedNumber includeErrored:(BOOL)includeErrored context:(NSManagedObjectContext *)context {
    if ([feedNumber length] == 0) {
        feedNumber = [[[PKSession sharedInstance] currentFeedConfig] number];
    }
    
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Find all open baskets for the customer (latest first):
    NSPredicate *predicate = nil;
    if (includeErrored) {
        predicate = [NSPredicate predicateWithFormat:@"feedNumber = %@ AND (basketStatus = %@ OR basketStatus = %@)", feedNumber, @(PKBasketStatusOpen), @(PKBasketStatusError)];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"feedNumber = %@ AND basketStatus = %@", feedNumber, @(PKBasketStatusOpen)];
    }
    
    NSMutableArray *openBaskets = [[PKBasket MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:predicate inContext:context] mutableCopy];
    
    // Remove the current basket:
    PKBasket *currentBasket = [PKBasket sessionBasket];
    if ([openBaskets containsObject:currentBasket]) {
        [openBaskets removeObject:currentBasket];
    }
    
    return openBaskets;
}

+ (NSArray *)openBasketsIncludeErrored:(BOOL)includeErrored context:(NSManagedObjectContext *)context {
   if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Find all open baskets for the customer (latest first):
    NSPredicate *predicate = nil;
    if (includeErrored) {
        predicate = [NSPredicate predicateWithFormat:@"(basketStatus = %@ OR basketStatus = %@)", @(PKBasketStatusOpen), @(PKBasketStatusError)];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"basketStatus = %@", @(PKBasketStatusOpen)];
    }
    
    NSMutableArray *openBaskets = [[PKBasket MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:predicate inContext:context] mutableCopy];
    
    // Remove the current basket:
    PKBasket *currentBasket = [PKBasket sessionBasket];
    if ([openBaskets containsObject:currentBasket]) {
        [openBaskets removeObject:currentBasket];
    }
    
    return openBaskets;
}

+ (BOOL)deleteOpenBasketsForCustomer:(PKCustomer *)customer feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context {
    if ([feedNumber length] == 0) {
        feedNumber = [[[PKSession sharedInstance] currentFeedConfig] number];
    }
    
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    NSString *customerId = [NSString stringWithFormat:@"%i", [customer objectId]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId = %@ AND feedNumber = %@ AND basketStatus = %@", customerId, feedNumber, @(PKBasketStatusOpen)];
    NSArray *openBaskets = [PKBasket MR_findAllWithPredicate:predicate inContext:context];
    
    [context MR_deleteObjects:openBaskets];
    [context MR_saveOnlySelfAndWait];
    
    return YES;
}

#pragma mark -

+ (PKBasket *)basketWithOrderRef:(NSString *)orderRef feedNumber:(NSString *)feedNumber context:(NSManagedObjectContext *)context {
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if ([feedNumber length] == 0) {
        feedNumber = [[[PKSession sharedInstance] currentFeedConfig] number];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order.orderRef = %@ && feedNumber = %@", orderRef, feedNumber];
    return [PKBasket MR_findFirstWithPredicate:predicate inContext:context];
}

//+ (BOOL) hasCurrentBasket {
//    PKBasket *basket = [PKBasket currentBasketAndCreateIfNone:NO];
//    return (basket ? YES : NO);
//}

- (PKBasketItem*) addOrUpdateProduct:(PKProduct *)product
                            quantity:(NSNumber *)quantity
                               price:(NSNumber *)price
                      customPriceSet:(BOOL)customPriceSet
                  productPriceObject:(PKProductPrice*)priceObject
                         incremental:(BOOL)incremental
                             context:(NSManagedObjectContext*)context
                            skipSave:(BOOL)skipSave {
    // Provide a context if one isn't available
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Get the existing basket item
    PKBasketItem *item = [self basketItemForProduct:product context:context];
    if (item) {
        // Update the item
        if (incremental) {
            [item setQuantity:[NSDecimalNumber add:[item quantity] to:quantity]];
        } else {
            [item setQuantity:quantity];
        }
        
        // Only update price if not fixed
        if ([price intValue] != -1) {
            [item setUnitPrice:price];
        }
    } else {
        item = [PKBasketItem MR_createEntityInContext:context];
        [item setCreatedAt:[NSDate date]];
        [item setQuantity:quantity];
        [item setUnitPrice:price];
        [self addItemsObject:item];
    }
    
    [item setProductUuid:[product productId]];
    [item setProductModel:[[product model] sanitize]];
    [item setProductTitle:[[product title] sanitize]];
    [item setFxRate:@(1.0)];
    [item setFxIsoCode:[self currencyCode]];
    [item setIsCustomPriceSet:@(customPriceSet)];
    
    // Check if the item should be removed:
    if ([quantity intValue] == -1) {
        [self removeItemsObject:item];
    }
    
    // Save the PKBasketItem to database:
    if (!skipSave) {
        [self triggerDeliveryChargeCheck];
        [self save];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBasketDidUpdateItem object:item];
    
    return item;
}

- (PKBasketItem*) addOrUpdateProduct:(PKProduct*)product
                            quantity:(NSNumber *)quantity
                               price:(NSNumber *)price
                      customPriceSet:(BOOL)customPriceSet
                  productPriceObject:(PKProductPrice *)priceObject
                         incremental:(BOOL)incremental
                             context:(NSManagedObjectContext*)context {
    return [self addOrUpdateProduct:product
                           quantity:quantity
                              price:price
                     customPriceSet:customPriceSet
                 productPriceObject:priceObject
                        incremental:incremental
                            context:context
                           skipSave:NO];
}

- (void) triggerDeliveryChargeCheck {
    if ([[self deliveryPriceOverride] boolValue] == NO) {
        // Get the delivery free after value:
        float deliveryFreeAfter = [[[PKSession sharedInstance] currentFeedConfig] defaultDeliveryFreeAfterForISO:[self currencyCode]];
        
//        NSLog(@"[%@] - Performing shipping discount calculation [free after: %.2f]", [self class], deliveryFreeAfter);
        NSNumber *totalExShipping = [self totalExShipping];
        if ([totalExShipping floatValue] > deliveryFreeAfter) {
            [self setDeliveryPrice:@(0)];
            //NSLog(@"[%@] - Delivery is now free: %.2f > %.2f", [self class], totalExShipping, deliveryFreeAfter);
        } else {
            float defaultDeliveryPrice = [[[PKSession sharedInstance] currentFeedConfig] defaultDeliveryCostForISO:[self currencyCode]];
            [self setDeliveryPrice:@(defaultDeliveryPrice)];
        }
    }
}

- (PKBasketItem*) basketItemForProduct:(PKProduct*)product context:(NSManagedObjectContext*)context {
    // If no product specified, return NO
    if (!product) {
        return nil;
    }
    
    // Find existing basket item
    NSSet *itemsFound = [[self items] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"productUuid = %@", [product productId]]];
    if ([itemsFound count]) {
        return (PKBasketItem *)[itemsFound anyObject];
    } else {
        return nil;
    }
}

- (NSArray *)itemsOrdered {
    // Don't bother attempting to sort the items array if there is 1 or less objects:
    if ([[self items] count] <= 1) {
        // Just return the object as sorting it won't make a difference:
        return [[self items] allObjects];
    }
    
    int selectedSortFilter = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PKSortOptionBasket"] intValue];
    
    BOOL isAscending = YES;
    NSString *key = @"productTitle";
    
    if (selectedSortFilter <= 0) {
        isAscending = NO;
    }
    
    int sortFilter = abs(selectedSortFilter);
    switch (sortFilter) {
        case PKSearchParameterTypeProductCode: {
            key = @"productModel";
            break;
        }
        case PKSearchParameterTypeDateAdded: {
            key = @"createdAt";
            break;
        }
        default:
            key = @"productTitle";
            break;
    }
    
    return [[self items] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:key ascending:isAscending]]];
}

- (NSArray *)itemsOrderedByModel {
    return [[self items] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"productModel" ascending:YES]]];
}

- (BOOL) deleteProduct:(PKProduct*)product
               context:(NSManagedObjectContext*)context {
    
    // Provide a context if one isn't available
    if(!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Get the existing basket item
    PKBasketItem *item = [self basketItemForProduct:product
                                            context:context];
    
    // If we found something delete it!
    if(item) {
        BOOL deleted = [item MR_deleteEntity];
        if(deleted) {
            [self removeItemsObject:item];
        }
        
        [self save];
        return YES;
        
//        NSError *error = nil;
//        if([context save:&error]) {
//            if(deleted) {
//                return YES;
//            } else {
//                NSLog(@"Something went wrong, MR_deleteEntity returned YES, but saving the context failed! %@", [error localizedDescription]);
//                return NO;
//            }
//        }
//        return NO;
    } else {
        return NO;
    }
}

- (BOOL)deleteBasketItem:(PKBasketItem*)item context:(NSManagedObjectContext*)context {
    // If we found something delete it:
    if (item) {
        BOOL deleted = [item MR_deleteEntity];
        if (deleted) {
            [self removeItemsObject:item];
        }
        [self save];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBasketDidUpdateItem object:item];
        return YES;
    } else {
        return NO;
    }
}

- (NSNumber *)total {
    return [self totalExShipping];
}

- (NSNumber *)totalExShipping {
    __block NSNumber *total = @(0.f);
    
    [[self items] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, BOOL * _Nonnull stop) {
        total = [NSDecimalNumber add:total to:[basketItem total]];
    }];
    
    return total;
}

- (NSNumber *)totalVat {
    NSNumber *vat = [NSDecimalNumber divide:[self vatRate] by:@(100.f)];
    NSNumber *total = [NSDecimalNumber multiply:[self totalExShipping] by:vat];
    total = [NSDecimalNumber add:total to:[self shippingTax]];
    return total;
}

- (PKCustomer *)customer {
    return [PKCustomer findCustomerWithId:[self customerId]];
}

- (NSNumber *)vatRate {
    // Set VAT to the default value (set by feed meta data):
    double vat = [[[PKSession sharedInstance] currentFeedConfig] defaultVatRate];
    
    // Attempt to find the delivery country being used for this order:
    PKCountry *country = nil;
    
    // First, look in the order, every basket will have an order, however, not all orders
    // have been filled in by the user, so still attempted to get the country:
    if ([self order]) {
        country = [PKCountry countryWithExactName:[[self order] addressDeliveryCountry]];
    }
    
    // If the order wasn't able to return a valid country then look to the customer that
    // is attached to the basket:
    if (!country) {
        country = [[[self customer] deliveryAddress] pkCountry];
    }
    
    // If a country has been found and is flagged as NOT to charge VAT then
    // set the VAT rate to zero:
    if (country && ![country chargeVAT]) {
        vat = 0.0f;
    }
    
    // Worst case, a country hasn't been found and the VAT rate is returned
    // at the default value:
    return @(vat);
}

- (NSNumber *)vatRateDecimal {
    return [NSDecimalNumber divide:[self vatRate] by:@(100.f)];
}

- (NSNumber *)grandTotal {
    NSNumber *total = [NSDecimalNumber add:[self totalExShipping] to:[self totalVat]];
    total = [NSDecimalNumber add:total to:[self deliveryPrice]];
    return total;
}

-(NSNumber *)shippingTax {
    return [NSDecimalNumber multiply:[self deliveryPrice] by:[self vatRateDecimal]];
}

- (NSString *)formattedPrice:(NSNumber *)value {
    return [NSString stringWithFormat:@"%@%.2f", [PKCurrency symbolForCurrencyIsoCode:[self currencyCode]], [value floatValue]];
}

- (NSString *)totalFormatted {
    return [self formattedPrice:[self totalExShipping]];
}

- (NSString *)formattedCreatedAt {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    return [dateFormatter stringFromDate:[self createdAt]];
}

- (void)outputItems {    
    NSMutableString *items = [NSMutableString string];
    [items appendString:@"\n*** BASKET ITEMS ***\n"];
    __block float orderTotal = 0.f;
    __block int orderQuantity = 0;
    [[self itemsOrdered] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, NSUInteger idx, BOOL *stop) {
        float total = [[basketItem quantity] doubleValue] * [[basketItem unitPrice] doubleValue];
        orderQuantity += [[basketItem quantity] intValue];
        orderTotal += total;
        [items appendFormat:@"\n    - %@ %i x %.2f = %.2f", [basketItem productUuid], [[basketItem quantity] intValue], [[basketItem unitPrice] doubleValue], total];
    }];
    [items appendFormat:@"\n    Total: %i items with total of %.2f", orderQuantity, orderTotal];
    [items appendString:@"\n\n********************\n"];
    NSLog(@"\n%@", items);
}

- (NSArray *)basketItems {
    return [self itemsOrdered];
}

- (void) removeAllBasketItems {
    for(PKBasketItem *item in [self basketItems]) {
        [item MR_deleteEntity];
    }
    [self setItems:[[NSSet alloc] init]];
    
    // Save to core data
    NSError *error = nil;
    [[NSManagedObjectContext MR_defaultContext] save:&error];
    if (!error) {
        NSLog(@"Cleared basket!");
    } else {
        NSLog(@"Error saving to context! %@", [error localizedDescription]);
    }
}

- (NSArray *)products {
    NSMutableArray *products = [NSMutableArray array];
    
    [[self itemsOrdered] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, NSUInteger idx, BOOL *stop) {
        PKProduct *product = [basketItem product];
        if (product) {
            [products addObject:product];
        }
    }];
    
    return products;
}

#pragma mark - Order Ref Methods

+ (NSString *)generateOrderRef {
    // Default the next order number to -1 so we can check for this later:
    int nextNumber = -1;
    
    // Create the device identifier key:
    NSNumber *deviceIdentifier = [[[PKSession sharedInstance] currentFeedConfig] allocatedDeviceIdentifier];
    NSString *orderRefKey = [NSString stringWithFormat:@"%@_order_ref", deviceIdentifier];
    
    // Create the user default object:
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Attempt to get the order ref from the keychain first:
    FXKeychain *keychain = [FXKeychain defaultKeychain];
    [keychain setAccessibility:FXKeychainAccessibleAlways];
    //[keychain setObject:configurations forKey:@"feeds"];
    
    if ([keychain objectForKey:orderRefKey]) {
        nextNumber = [[keychain objectForKey:orderRefKey] intValue];
    }
    
    // If the next number still equals -1 then attempt to get the order ref
    // from the user defaults instead:
    if (nextNumber < 0) {
        if ([userDefaults objectForKey:orderRefKey]) {
            nextNumber = [[userDefaults objectForKey:orderRefKey] intValue];
        }
    }
    
    // If the next number is still equals -1 then it wasn't found in either the
    // key chain or user defaults therefore default to 10000:
    if (nextNumber < 0) {
        nextNumber = 10000;
    }
    
    // Increment the next number value:
    nextNumber += 1;
    
    // Save the next number object to the keychain:
    [keychain setObject:@(nextNumber) forKey:orderRefKey];
    
    // Save the next number object to the user default:
    [userDefaults setObject:@(nextNumber) forKey:orderRefKey];
    [userDefaults synchronize];
    
    // Create the order ref and return the value:
    NSString *orderRef = [NSString stringWithFormat:@"%@_%d", deviceIdentifier, nextNumber];
    return orderRef;
}

#pragma mark - Order transformation

- (NSString *)transformToOrderXmlStringIsQuote:(BOOL)isQuote {
    // Generate order date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    // Create XML string
    NSMutableString *data = [[NSMutableString alloc] initWithString:@""];
    
    [data setString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
    [data appendString:@"<ORDER>\n"];
    
    if (isQuote) {
        [data appendString: [NSString stringWithFormat:@"<ORDER_TYPE>%@</ORDER_TYPE>\n", @"QUOTE"]];
    } else {
        [data appendString: [NSString stringWithFormat:@"<ORDER_TYPE>%@</ORDER_TYPE>\n", @"ORDER"]];
    }
    
    [data appendFormat:@"<QUOTE_FORMAT>%@</QUOTE_FORMAT>", [[self order] pdfType]];
    
//    if ([self status] == PKBasketStatusComplete) {
//        [data appendString: [NSString stringWithFormat:@"<ORDER_TYPE>%@</ORDER_TYPE>\n", @"ORDER"]];
//    } else if ([self status] == PKBasketStatusQuote) {
//        [data appendString: [NSString stringWithFormat:@"<ORDER_TYPE>%@</ORDER_TYPE>\n", @"QUOTE"]];
//    } else {
//        [data appendString: [NSString stringWithFormat:@"<ORDER_TYPE>%@</ORDER_TYPE>\n", @"UNKNOWN"]];
//    }
    
    // Get the customer
    PKOrder *order = [self order];
    PKCustomer *customer = [PKCustomer findCustomerWithId:[self customerId]];
    
    // Calculate the account_ref
    NSString *accountRef = [customer accountRef];
    if (!accountRef || [accountRef length] == 0 || [accountRef isEqualToString:@"0"]) {
        // There is no account_ref for this customer, check Core Data to see if we have already made one for this customer
        NSDictionary *customerKeyValue = [PKCustomerMeta keyValueForCustomerId:[self customerId] feedNumber:[self feedNumber] key:@"ACCOUNT_REF"];
        if (customerKeyValue) {
            accountRef = [customerKeyValue objectForKey:@"value"];
        } else {
            accountRef = [NSString stringWithFormat:@"%@%d", [[[PKSession sharedInstance] currentFeedConfig] allocatedDeviceIdentifier], arc4random()%99999];
            [PKCustomerMeta setKey:@"ACCOUNT_REF" value:accountRef customerId:[self customerId] feedNumber:[self feedNumber]];
        }
    }
    
    [data appendString:@"<CUSTOMER>\n"];
    [data appendString:[NSString stringWithFormat:@"<CUSTOMER_ID>%@</CUSTOMER_ID>\n", [self customerId]]];
    [data appendString:[NSString stringWithFormat:@"<SAGE_ID><![CDATA[%@]]></SAGE_ID>\n", [customer sageId]]];
    [data appendString:[NSString stringWithFormat:@"<ACCOUNT_REF><![CDATA[%@]]></ACCOUNT_REF>\n", accountRef]];
    [data appendString:[NSString stringWithFormat:@"<CONTACT_NAME><![CDATA[%@]]></CONTACT_NAME>\n", [[customer contactName] sanitize]]];
    [data appendString:[NSString stringWithFormat:@"<TELEPHONE><![CDATA[%@]]></TELEPHONE>\n", [[customer telephone] sanitize]]];
    
    PKAgent *agent = [PKAgent currentAgent];
    NSMutableString *emailAddresses = [NSMutableString stringWithString:[order emailAddresses]];
    
    // Add the agent's email:
    if ([[agent email] length] != 0 && ![emailAddresses containsString:[agent email]]) {
        if ([emailAddresses length] != 0) {
            [emailAddresses appendFormat:@";"];
        }
        [emailAddresses appendFormat:@"%@", [agent email]];
    }
    
    // Remove any double ;; in the email string:
    [emailAddresses replaceOccurrencesOfString:@";;" withString:@";" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [emailAddresses length])];
    
    // Remove the last ;
    if ([emailAddresses length] != 0 && [emailAddresses containsString:@";"]) {
        if ([[emailAddresses substringFromIndex:[emailAddresses length] - 1] isEqualToString:@";"]) {
            emailAddresses = [[emailAddresses substringToIndex:[emailAddresses length] - 1] mutableCopy];
        }
    }
    
    // Add the emails to the XML:
    [data appendString: [NSString stringWithFormat:@"<EMAIL><![CDATA[%@]]></EMAIL>\n", [emailAddresses sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<MOBILE><![CDATA[%@]]></MOBILE>\n", [[customer mobile] sanitize]]];
    
    // This is only used for italian orders...
    if ([[[order fiscalCode] sanitize] length] >= 1) {
        [data appendString: [NSString stringWithFormat:@"<FISCAL_CODE><![CDATA[%@]]></FISCAL_CODE>\n", [[order fiscalCode] sanitize]]];
    }
    if ([[[order pecEmail] sanitize] length] >= 1) {
        [data appendString: [NSString stringWithFormat:@"<PEC_EMAIL><![CDATA[%@]]></PEC_EMAIL>\n", [[order pecEmail] sanitize]]];
    }
    
    [data appendString:@"</CUSTOMER>\n"];
    
    // Inject currency info into the xml file
    if([[[[PKSession sharedInstance] currentCurrencyCode] sanitize] length] >= 1) {
        NSString *currencySymbol = [PKCurrency symbolForCurrencyIsoCode:[[[PKSession sharedInstance] currentCurrencyCode] sanitize]];
        [data appendString: [NSString stringWithFormat:@"<ORDER_CURRENCY>%@</ORDER_CURRENCY>\n", currencySymbol]];
        
        // Get the currency information from the CurrencyList.plist file
        int currencyCode = [PKCurrency currencyCodeForIsoCode:[[[PKSession sharedInstance] currentCurrencyCode] sanitize]];
        if(currencyCode != -1) {
            [data appendString: [NSString stringWithFormat:@"<ORDER_CURRENCY_ID>%d</ORDER_CURRENCY_ID>\n", currencyCode]];
        } else {
            [data appendString: [NSString stringWithFormat:@"<ORDER_CURRENCY_ID>%@</ORDER_CURRENCY_ID>\n", @"UNSUPPORTED_CURRENCY"]];
        }
    } else {
        [data appendString: [NSString stringWithFormat:@"<ORDER_CURRENCY>%@</ORDER_CURRENCY>\n", @"UNKNOWN_CURRENCY"]];
        [data appendString: [NSString stringWithFormat:@"<ORDER_CURRENCY_ID>%@</ORDER_CURRENCY_ID>\n", @"UNKNOWN_CURRENCY"]];
    }
    
    // Generate a new order ref if required:
    if ([[[self order] orderRef] length] == 0) {
        [[self order] setOrderRef:[PKBasket generateOrderRef]];
        [self save];
    }
    
    NSArray *countries = nil;
    
    [data appendString: [NSString stringWithFormat:@"<ORDER_REF>%@</ORDER_REF>\n", [[self order] orderRef]]];
    [data appendString: [NSString stringWithFormat:@"<ORDER_DATE>%@</ORDER_DATE>\n", [formatter stringFromDate:[NSDate date]]]];
    [data appendString: [NSString stringWithFormat:@"<ORDER_BY><![CDATA[%@]]></ORDER_BY>\n", [NSString stringWithFormat:@"%@ %@", [agent firstName], [agent lastName]]]];
    
    [data appendString: [NSString stringWithFormat:@"<INVOICE_COMPANY><![CDATA[%@]]></INVOICE_COMPANY>\n", [[order addressBillingCompanyName] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<INVOICE_NAME><![CDATA[%@]]></INVOICE_NAME>\n", [[order addressBillingContactName] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<INVOICE_ONE><![CDATA[%@]]></INVOICE_ONE>\n", [[order addressBillingAddressLine1] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<INVOICE_TWO><![CDATA[%@]]></INVOICE_TWO>\n", [[order addressBillingAddressLine2] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<INVOICE_CITY><![CDATA[%@]]></INVOICE_CITY>\n", [[order addressBillingCity] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<INVOICE_STATE><![CDATA[%@]]></INVOICE_STATE>\n", [[order addressBillingState] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<INVOICE_COUNTRY><![CDATA[%@]]></INVOICE_COUNTRY>\n", [[order addressBillingCountry] sanitize]]];
    
    // Make sure the ISO code is valid:
    __block NSString *billingISO = [order addressBillingISO];
    if ([billingISO length] == 0) {
        // Load the countries:
        if ([countries count] == 0) {
            countries = [PKCountry allCountries];
        }
        
        // Find the country that matches the country name:
        [countries enumerateObjectsUsingBlock:^(PKCountry *country, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[country name] lowercaseString] containsString:[[order addressBillingCountry] lowercaseString]]) {
                billingISO = [country isoCode];
                *stop = YES;
            }
        }];
    }
    [data appendString: [NSString stringWithFormat:@"<INVOICE_ISO><![CDATA[%@]]></INVOICE_ISO>\n", billingISO]];
    // -----
    
    [data appendString: [NSString stringWithFormat:@"<INVOICE_POSTCODE><![CDATA[%@]]></INVOICE_POSTCODE>\n", [[order addressBillingPostcode] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<INVOICE_VAT><![CDATA[%@]]></INVOICE_VAT>\n", [order vatNumber]]];
    [data appendString: [NSString stringWithFormat:@"<PAYMENT_TERMS><![CDATA[%@]]></PAYMENT_TERMS>\n", [order paymentMethod]]];
    [data appendString: [NSString stringWithFormat:@"<PAYMENT_TERMS_REF><![CDATA[%d]]></PAYMENT_TERMS_REF>\n", [[order paymentMethodId] intValue]]];
    
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_COMPANY><![CDATA[%@]]></DELIVERY_COMPANY>\n", [[order addressDeliveryCompanyName] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_NAME><![CDATA[%@]]></DELIVERY_NAME>\n", [[order addressDeliveryContactName] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_ONE><![CDATA[%@]]></DELIVERY_ONE>\n", [[order addressDeliveryAddressLine1] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_TWO><![CDATA[%@]]></DELIVERY_TWO>\n", [[order addressDeliveryAddressLine2] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_CITY><![CDATA[%@]]></DELIVERY_CITY>\n", [[order addressDeliveryCity] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_STATE><![CDATA[%@]]></DELIVERY_STATE>\n", [[order addressDeliveryState] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_COUNTRY><![CDATA[%@]]></DELIVERY_COUNTRY>\n", [[order addressDeliveryCountry] sanitize]]];
    
    // Make sure the ISO code is valid:
    __block NSString *deliveryISO = [order addressDeliveryISO];
    if ([deliveryISO length] == 0) {
        // Load the countries:
        if ([countries count] == 0) {
            countries = [PKCountry allCountries];
        }
        
        // Find the country that matches the country name:
        [countries enumerateObjectsUsingBlock:^(PKCountry *country, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[country name] lowercaseString] containsString:[[order addressDeliveryCountry] lowercaseString]]) {
                deliveryISO = [country isoCode];
                *stop = YES;
            }
        }];
    }
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_ISO><![CDATA[%@]]></DELIVERY_ISO>\n", [deliveryISO sanitize]]];
    // -----
    
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_POSTCODE><![CDATA[%@]]></DELIVERY_POSTCODE>\n", [[order addressDeliveryPostcode] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<DELIVERY_DATE><![CDATA[%@]]></DELIVERY_DATE>\n", [formatter stringFromDate:[order dateRequired]]]];
    [data appendString: [NSString stringWithFormat:@"<ORDER_NOTES><![CDATA[%@]]></ORDER_NOTES>\n", [[order notes] sanitize]]];
    
    [data appendString:@"<LINES>\n"];
    
    NSNumber *vat = [self vatRate];
    
    NSNumber *combinedTotalUnitPrice = @(0.0f);
    NSNumber *combinedTotalVat = @(0.0f);
    for (PKBasketItem *item in [self itemsOrdered]) {
        // Get the product from the basket item:
        PKProduct *product = [item product];
        
        //NSLog(@"[%@] - UUID: %@ PID: %@ MID: %@", [self class], [item productUuid], [product productId], [[product model] sanitize]);
        
        // Calculate the line total with and without vat:
        NSNumber *lineTotalExVat = [item lineTotalExVat];
        NSNumber *lineTotalIncVat = [item lineTotalIncVat:vat];
        NSNumber *singleUnitVat = [item singleUnitVat:vat];
        
        // Attempt to fix the (null) product id and model in XML:
        NSString *productId = [product productId];
        NSString *productModel = [[product model] sanitize];
        NSString *productTitle = [[product title] sanitize];
        if ([productId length] == 0) { productId = [item productUuid]; }
        if ([productModel length] == 0) { productModel = [[item productModel] sanitize]; }
        if ([productTitle length] == 0) { productTitle = [[item productTitle] sanitize]; }
        
        // Add these values to the totals:
        combinedTotalUnitPrice = [NSDecimalNumber add:combinedTotalUnitPrice to:lineTotalExVat];
        combinedTotalVat = [NSDecimalNumber add:combinedTotalVat to:lineTotalIncVat];
        
        [data appendString:@"\t<LINE>\n"];
        [data appendString: [NSString stringWithFormat:@"\t\t<PRODUCT_ID>%@</PRODUCT_ID>\n", productId]];
        [data appendString: [NSString stringWithFormat:@"\t\t<PRODUCT_CODE>%@</PRODUCT_CODE>\n", productModel]];
        [data appendString: [NSString stringWithFormat:@"\t\t<PRICE>%0.2f</PRICE>\n", [[item unitPrice] doubleValue]]];
        [data appendString: [NSString stringWithFormat:@"\t\t<VAT>%0.2f</VAT>\n", [[NSDecimalNumber roundNumber:singleUnitVat] floatValue]]];
        [data appendString: [NSString stringWithFormat:@"\t\t<QTY>%d</QTY>\n", [[item quantity] intValue]]];
        [data appendString: [NSString stringWithFormat:@"\t\t<LINE_TOTAL>%0.2f</LINE_TOTAL>\n", [[NSDecimalNumber roundNumber:lineTotalExVat] floatValue]]];
        [data appendString: [NSString stringWithFormat:@"\t\t<LINE_VAT>%0.2f</LINE_VAT>\n", [[NSDecimalNumber roundNumber:lineTotalIncVat] floatValue]]];
        [data appendString: [NSString stringWithFormat:@"\t\t<PRODUCT_TITLE><![CDATA[%@]]></PRODUCT_TITLE>\n", productTitle]];
        [data appendString: [NSString stringWithFormat:@"\t\t<VAT_RATE>%0.2f</VAT_RATE>\n", [[NSDecimalNumber roundNumber:vat] floatValue]]];
        [data appendString:@"\t</LINE>\n"];
    }
    
    [data appendString:@"</LINES>\n"];
    
    NSNumber *totalIncVat = [NSDecimalNumber add:combinedTotalUnitPrice to:combinedTotalVat];
    NSNumber *totalVat = [NSDecimalNumber add:combinedTotalVat to:[self shippingTax]];
    NSNumber *grandTotal = [NSDecimalNumber add:totalIncVat to:[self deliveryPrice]];
    grandTotal = [NSDecimalNumber add:grandTotal to:[self shippingTax]];
    
    [data appendString:[NSString stringWithFormat:@"<SUB_TOTAL>%0.2f</SUB_TOTAL>\n", [[NSDecimalNumber roundNumber:combinedTotalUnitPrice] floatValue]]];
    [data appendString:[NSString stringWithFormat:@"<DELIVERY>%0.2f</DELIVERY>\n", [[self deliveryPrice] doubleValue]]];
    [data appendString:[NSString stringWithFormat:@"<DELIVERY_VAT>%0.2f</DELIVERY_VAT>\n", [[self shippingTax] floatValue]]];
    [data appendString:[NSString stringWithFormat:@"<TOTAL_VAT>%0.2f</TOTAL_VAT>\n", [[NSDecimalNumber roundNumber:totalVat] floatValue]]];
    [data appendString:[NSString stringWithFormat:@"<GRAND_TOTAL>%0.2f</GRAND_TOTAL>\n", [[NSDecimalNumber roundNumber:grandTotal] floatValue]]];
    
    PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    
    [data appendString: [NSString stringWithFormat:@"<DEVICE_ID>%@</DEVICE_ID>\n", [feedConfig allocatedDeviceIdentifier]]];
    [data appendString: [NSString stringWithFormat:@"<FEED_NUMBER>%@</FEED_NUMBER>\n", [[self feedNumber] sanitize]]];
    [data appendString: [NSString stringWithFormat:@"<DEVICE_EMAIL>%@</DEVICE_EMAIL>\n", [[[PKAgent currentAgent] email] sanitize]]];
        
    // Add purchase order number to XML:
    [data appendString: [NSString stringWithFormat:@"<PURCHASE_ORDER_NUMBER><![CDATA[%@]]></PURCHASE_ORDER_NUMBER>\n", [[[self order] purchaseOrderNumber] sanitize]]];
    
    // Add trade show boolean to order XML:
    if ([[[self order] tradeShowOrder] boolValue]) {
        [data appendString: @"<TRADE_SHOW_ORDER>1</TRADE_SHOW_ORDER>\n"];
    } else {
        [data appendString: @"<TRADE_SHOW_ORDER>0</TRADE_SHOW_ORDER>\n"];
    }
    
    if ([[[self order] reTax] boolValue]) {
        [data appendString: @"<RE_TAX>1</RE_TAX>\n"];
    } else {
        [data appendString: @"<RE_TAX>0</RE_TAX>\n"];
    }
    
    // Add meta info:
    [data appendString:@"<META>\n"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    if ([appVersion length] == 0) {
        appVersion = @"unknown";
    }
    if ([buildVersion length] == 0) {
        buildVersion = @"unknown";
    }
    
    [data appendString: [NSString stringWithFormat:@"\t<APP_VERSION><![CDATA[%@]]></APP_VERSION>\n", appVersion]];
    [data appendString: [NSString stringWithFormat:@"\t<BUILD_VERSION><![CDATA[%@]]></BUILD_VERSION>\n", buildVersion]];
    [data appendString:@"</META>\n"];
    
    [data appendString:@"</ORDER>\n"];
    
    return (NSString*)data;
}

- (void) saveOrderXml:(NSString*)orderXml toFilename:(NSString*)filename {    
    // Create order_outbox
    if (![FCFileManager existsItemAtPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"order_outbox"]]) {
        [FCFileManager createDirectoriesForPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"order_outbox"]];
        NSLog(@"Created order_outbox at %@", [FCFileManager pathForDocumentsDirectoryWithPath:@"order_outbox"]);
    }
    
    // Save to file
    NSString *path = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"order_outbox/%@", filename]];
    [orderXml writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"Written file to %@", path);
}

- (void)saveOrderXml:(NSString*)orderXml {
    NSString *filename = [NSString stringWithFormat:@"%@.xml", [[self order] orderRef]];
    [self saveOrderXml:orderXml toFilename:filename];
}

#pragma mark - General Methods

- (PKBasket *)copyBasket {
    return [self copyBasketToCustomer:[self customer] currencyCode:[self currencyCode]];
}

- (PKBasket *)copyBasketToCustomer:(PKCustomer *)customer currencyCode:(NSString *)currencyCode {
    if (!customer) {
        return nil;
    }
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    NSString *customerId = [NSString stringWithFormat:@"%i", [customer objectId]];
    
    PKBasket *newBasket = [PKBasket MR_createEntityInContext:localContext];
    
    [newBasket setCreatedAt:[NSDate date]];
    [newBasket setCurrencyCode:currencyCode];
    [newBasket setCustomerId:customerId];
    [newBasket setFeedNumber:[self feedNumber]];
    [newBasket setNotes:[self notes]];
    [newBasket setWasSent:@(NO)];
    [newBasket setBasketStatus:@(PKBasketStatusOpen)];
    [newBasket setVatRate:([self vatRate])];
    [newBasket setDeliveryPrice:[self deliveryPrice]];
    [newBasket setDeliveryPriceOverride:[self deliveryPriceOverride]];
    
    // Add the items:
    [[self items] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, BOOL *stop) {
        PKBasketItem *newBasketItem = [PKBasketItem MR_createEntityInContext:localContext];
        [newBasketItem setProductUuid:[basketItem productUuid]];
        [newBasketItem setProductModel:[basketItem productModel]];
        [newBasketItem setProductTitle:[basketItem productTitle]];
        [newBasketItem setCreatedAt:[NSDate date]];
        [newBasketItem setQuantity:[basketItem quantity]];
        [newBasketItem setUnitPrice:[basketItem unitPrice]];
        [newBasketItem setFxRate:[basketItem fxRate]];
        [newBasketItem setFxIsoCode:[basketItem fxIsoCode]];
        [newBasketItem setIsCustomPriceSet:[basketItem isCustomPriceSet]];
        [newBasket addItemsObject:newBasketItem];
    }];
    
    // Create an order:
    PKOrder *order = [self order];
    if (order) {
        PKOrder *newOrder = [PKOrder MR_createEntityInContext:localContext];
        
        // Check for the same customer:
        if (customerId == [self customerId]) {
            [newOrder setAddressBillingCompanyName:[order addressBillingCompanyName]];
            [newOrder setAddressBillingContactName:[order addressBillingContactName]];
            [newOrder setAddressBillingAddressLine1:[order addressBillingAddressLine1]];
            [newOrder setAddressBillingAddressLine2:[order addressBillingAddressLine2]];
            [newOrder setAddressBillingCity:[order addressBillingCity]];
            [newOrder setAddressBillingCountry:[order addressBillingCountry]];
            [newOrder setAddressBillingPostcode:[order addressBillingPostcode]];
            [newOrder setAddressDeliveryCompanyName:[order addressDeliveryCompanyName]];
            [newOrder setAddressDeliveryContactName:[order addressDeliveryContactName]];
            [newOrder setAddressDeliveryAddressLine1:[order addressDeliveryAddressLine1]];
            [newOrder setAddressDeliveryAddressLine2:[order addressDeliveryAddressLine2]];
            [newOrder setAddressDeliveryCity:[order addressDeliveryCity]];
            [newOrder setAddressDeliveryCountry:[order addressDeliveryCountry]];
            [newOrder setAddressDeliveryPostcode:[order addressDeliveryPostcode]];
            [newOrder setVatNumber:[order vatNumber]];
            [newOrder setFiscalCode:[order fiscalCode]];
            [newOrder setEmailAddresses:[order emailAddresses]];
            [newOrder setPaymentMethod:[order paymentMethod]];
            [newOrder setPaymentMethodId:[order paymentMethodId]];
            [newOrder setDateRequired:[order dateRequired]];
            [newOrder setNotes:[order notes]];
            [newOrder setDraft:@(NO)];
        } else {
            [newOrder setAddressBillingCompanyName:[customer companyName]];
            [newOrder setAddressBillingContactName:[customer contactName]];
            [order setDraft:@(YES)]; // This will mean the default customer details will get loaded when about to complete order
            [order setPaymentMethodId:@(3)]; // Payment not agreed
        }
        
        [newOrder setOrderRef:[PKBasket generateOrderRef]];
        [newOrder setTradeShowOrder:[order tradeShowOrder]];
        [newBasket setOrder:newOrder];
    }
    
    [newBasket save];
    
    return newBasket;
}

- (NSDate *)date {
    return [self createdAt];
}

#pragma mark - Status Methods

+ (BOOL)cancelAllOpenBasketsForCustomer:(PKCustomer *)customer {
    // Get all the open baskets for the customers:
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSArray *openBaskets = [PKBasket openBasketsForCustomer:customer feedNumber:nil includeErrored:YES context:context];
    
    [openBaskets enumerateObjectsUsingBlock:^(PKBasket * _Nonnull basket, NSUInteger idx, BOOL * _Nonnull stop) {
        [basket setStatus:PKBasketStatusCancelled shouldSave:NO];
    }];
    
    // Save the context:
    [context MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (BOOL)cancelOrder {
    BOOL isSessionBasket = ([PKBasket sessionBasket] == self);
    
    [self setStatus:PKBasketStatusCancelled shouldSave:YES];
    
    // Remove the customer reference (only if the current basket is being cancelled though):
    if (isSessionBasket) {
        if ([PKBasket clearSessionBasket]) {
            [[PKSession sharedInstance] setCurrentCustomer:nil andCurrencyCode:nil];
        }
        
        // Post the notification:
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidSaveOrCancelOrder object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBasketStatusChanged object:nil];
    } else {
        if ([PKBasket sessionBasket]) {
            NSLog(@"[%@] - Session Basket Customer ID: %@", [self class], [[PKBasket sessionBasket] customerId]);
        } else {
            NSLog(@"[%@] - Session Basket is NIL", [self class]);
        }
    }
    
    // Always return YES (for now):
    return YES;
}

- (PKBasketStatus)status {
    return [[self basketStatus] intValue];
}

- (void)save {
    // Check for main thread (force main thread if not):
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(save) withObject:nil waitUntilDone:YES];
        return;
    }
    
    // Save the discount amount:
    if ([[PKSession sharedInstance] discountAmount] != 0) {
        NSLog(@"[%@] - Saving discount rate: %.2f", [self class], [[[PKSession sharedInstance] discountAmount] floatValue]);
        [self setDiscountRate:[[PKSession sharedInstance] discountAmount]];
    }
    
    // Attempt to use the context the basket is attached to:
    NSManagedObjectContext *context = nil;
    if ([self managedObjectContext]) {
        context = [self managedObjectContext];
    }
    
    // If the context is nil use the default context (we're on the main thread so it should be fine):
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Only attempt to save the context if it isn't nil:
    if (context) {
        [context MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronously completion:^(BOOL contextDidSave, NSError *error) {
            if (error) {
                NSLog(@"[%@] - Error saving to context: %@", [self class], [error localizedDescription]);
            } else {
                if (self == [PKBasket sessionBasket]) {
                    // Send out notification:
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidSaveOrCancelOrder object:nil];
                }
                NSLog(@"[%@] - Basket saved", [self class]);
            }
        }];
    } else {
        NSLog(@"[%@] - Error saving to context: %@", [self class], @"Context is nil");
    }
}

#pragma mark - Status Methods

+ (void)setStatus:(PKBasketStatus)status ofBasket:(PKBasket *)basket shouldSave:(BOOL)save {
    if (basket) {
        [basket setBasketStatus:@(status)];
    
        if (save) {
            // Save the status update to core data:
            [basket save];
            
            // Determine if the basket is the session basket:
            if (basket == [PKBasket sessionBasket]) {
                // If the basket is the current session basket do some 'special' things like
                // clear down the customter session if it's saved or cancelled:
                if (status == PKBasketStatusSaved || status == PKBasketStatusCancelled) {
                    // Clear the session basket:
                    if ([PKBasket clearSessionBasket]) {
                        // Clear the customer and currency code:
                        [[PKSession sharedInstance] setCurrentCustomer:nil andCurrencyCode:nil];
                    }
                } else if (status == PKBasketStatusOpen) {
                    // Setup the customer:
                    PKCustomer *customer = [PKCustomer findCustomerWithId:[basket customerId]];
                    [[PKSession sharedInstance] setCurrentCustomer:customer andCurrencyCode:[basket currencyCode]];
                    
                    // Update the discount rate:
                    [[PKSession sharedInstance] setDiscountAmount:[basket discountRate]];
                }
                
                // Send notication:
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBasketStatusChanged object:nil];
            } else {
                // If the basket isn't the current session basket do some 'special' things:
                // This isn't the current session basket:
                if (status == PKBasketStatusOpen) {
                    // Close the current basket if there is one:
                    if ([PKBasket sessionBasket]) {
                        [[PKBasket sessionBasket] setStatus:PKBasketStatusSaved shouldSave:YES];
                    }
                    
                    // Set this basket as the current session basket:
                    if ([PKBasket setSessionBasket:basket]) {
                        // Setup the customer:
                        PKCustomer *customer = [PKCustomer findCustomerWithId:[basket customerId]];
                        [[PKSession sharedInstance] setCurrentCustomer:customer andCurrencyCode:[basket currencyCode]];
                        
                        // Update the discount rate:
                        NSLog(@"[%@] - Setting discount rate: %.2f", [basket class], [[basket discountRate] floatValue]);
                        [[PKSession sharedInstance] setDiscountAmount:[basket discountRate]];
                    }
                    
                    // Send notication:
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBasketStatusChanged object:nil];
                }
            }
        }
    }
}

- (void)setStatus:(PKBasketStatus)status shouldSave:(BOOL)shouldSave {
    [PKBasket setStatus:status ofBasket:self shouldSave:shouldSave];
}

//- (int)status {
//    return [[self basketStatus] intValue];
//}

+ (NSArray *)statusItems {
    NSMutableArray *items = [NSMutableArray array];
//    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusError wasSent:NO], @"status" : @(PKBasketStatusError), @"class" : @"PKBasket"}];
    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusSaved wasSent:NO], @"status" : @(PKBasketStatusSaved), @"class" : @"PKBasket"}];
    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusOpen wasSent:NO], @"status" : @(PKBasketStatusOpen), @"class" : @"PKBasket"}];
    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusComplete wasSent:NO], @"status" : @(PKBasketStatusComplete), @"wasSent" : @(NO), @"class" : @"PKBasket"}];
    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusComplete wasSent:YES], @"status" : @(PKBasketStatusComplete), @"wasSent" : @(YES), @"class" : @"PKBasket"}];
    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusQuote wasSent:NO], @"status" : @(PKBasketStatusQuote), @"wasSent" : @(NO), @"class" : @"PKBasket"}];
    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusQuote wasSent:YES], @"status" : @(PKBasketStatusQuote), @"wasSent" : @(YES), @"class" : @"PKBasket"}];
    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusOutstanding wasSent:NO], @"status" : @(PKBasketStatusOutstanding), @"class" : @"PKBasket"}];
    [items addObject:@{@"name" : [PKBasket nameForStatus:PKBasketStatusCancelled wasSent:NO], @"status" : @(PKBasketStatusCancelled), @"class" : @"PKBasket"}];
    return items;
}

+ (NSString *)nameForStatus:(PKBasketStatus)status wasSent:(BOOL)wasSent {
    switch (status) {
        default:
        case PKBasketStatusError:
            return NSLocalizedString(@"Order Error", nil);
            break;
        case PKBasketStatusSaved:
            return NSLocalizedString(@"Saved Order", nil);
            break;
        case PKBasketStatusOpen:
            return NSLocalizedString(@"Open Order", nil);
            break;
        case PKBasketStatusComplete:
            if (wasSent) {
                return NSLocalizedString(@"Complete / Sent", nil);
            } else {
                return NSLocalizedString(@"Complete / Not Sent", nil);
            }
            break;
        case PKBasketStatusQuote:
            if (wasSent) {
                return NSLocalizedString(@"Quote / Sent", nil);
            } else {
                return NSLocalizedString(@"Quote / Not Sent", nil);
            }
            break;
        case PKBasketStatusOutstanding:
            return NSLocalizedString(@"Outstanding", nil);
            break;
        case PKBasketStatusCancelled:
            return NSLocalizedString(@"Cancelled", nil);
            break;
    }
}

- (NSString *)statusName {
    return [PKBasket nameForStatus:[self status] wasSent:[[self wasSent] boolValue]];
}

#pragma mark - Invoice Methods

+ (PKBasket *)createWithInvoice:(PKInvoice *)invoice {
    PKCustomer *customer = [PKCustomer findCustomerWithSageId:[invoice sageId]];
    NSString *currencyCode = [[PKCurrency currencyInfoForCurrencyCode:[invoice currencyType]] objectForKey:@"iso"];
    return [self createWithInvoice:invoice customer:customer currencyCode:currencyCode];
}


+ (PKBasket *)createWithInvoice:(PKInvoice *)invoice customer:(PKCustomer *)customer currencyCode:(NSString *)currencyCode {
    // Use the default context:
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    // Get the feed number:
    NSString *feedNumber = [[[PKSession sharedInstance] currentFeedConfig] number];
    
    // Get the customer:
    NSString *customerId = [NSString stringWithFormat:@"%i", (int)[customer objectId]];
    
    // Create a temp basket:
    PKBasket *basket = [PKBasket MR_createEntityInContext:context];
    
    // Setup the basket params:
    [basket setCreatedAt:[NSDate date]];
    [basket setCustomerId:customerId];
    [basket setFeedNumber:feedNumber];
    [basket setCurrencyCode:currencyCode];
    [basket setStatus:PKBasketStatusOpen shouldSave:NO];
    [basket setDeliveryPrice:@([invoice carrNet])];
    
    // Setup the VAT rate:
    float vatRate = ([invoice taxAmount]/[invoice netAmount]) * 100.f;
    [basket setVatRate:@(vatRate)];
    //[basket save];
    
    // Insert empty order object
    PKOrder *order = [PKOrder MR_createEntityInContext:context];
    [order setAddressBillingCompanyName:[customer companyName]];
    [order setDraft:@(YES)];
    [basket setOrder:order];
    
    // Add the invoice lines to the basket:
    [[invoice invoiceLines] enumerateObjectsUsingBlock:^(PKInvoiceLine *invoiceLine, NSUInteger idx, BOOL *stop) {
        PKProduct *product = [PKProduct findWithProductCode:[invoiceLine productCode]
                                              forFeedConfig:[[PKSession sharedInstance] currentFeedConfig]
                                                  inContext:context];
        
        NSNumber *price = [NSDecimalNumber divide:[invoiceLine itemNetAmount] by:[invoiceLine orderQty]];
        
        if (product) {
            [basket addOrUpdateProduct:product
                              quantity:[invoiceLine orderQty]
                                 price:price
                        customPriceSet:NO
                    productPriceObject:[product priceForQuantity:[invoiceLine orderQty]]
                           incremental:NO
                               context:context
                              skipSave:YES];
        }
    }];
    
    [basket save];
    
    NSLog(@"Basket item count: %d", (int)[[basket items] count]);
    return basket;
}

#pragma mark -

@end
