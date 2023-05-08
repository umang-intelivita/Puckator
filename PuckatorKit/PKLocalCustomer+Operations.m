//
//  PKLocalCustomer+Operations.m
//  Puckator
//
//  Created by Luke Dixon on 05/08/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKLocalCustomer+Operations.h"
#import "PKCustomer.h"
#import "PKOrder.h"
#import "PKLocalAddress+Operations.h"

@implementation PKLocalCustomer (Operations)

+ (NSString *)generateTemporaryAccountReference {
    int deviceId = [[[[PKSession sharedInstance] currentFeedConfig] allocatedDeviceIdentifier] intValue];
    NSString *accountRef = [NSString stringWithFormat:@"%d%d", deviceId, arc4random()%99999];
    return accountRef;
}

+ (NSString *)generateCustomerId {
    return [PKLocalCustomer generateTemporaryAccountReference];
    //return [[NSUUID UUID] UUIDString];
}

+ (PKLocalCustomer *)customerWithCustomerId:(int)customerId {
    return [PKLocalCustomer MR_findFirstByAttribute:@"customerId" withValue:[NSString stringWithFormat:@"%d", customerId] inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (PKLocalCustomer *)createWithCompanyName:(NSString *)companyName contactName:(NSString *)contactName email:(NSString *)email telephone:(NSString *)telephone mobile:(NSString *)mobile {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    
    // Create the customer:
    PKLocalCustomer *customer = [PKLocalCustomer MR_createEntityInContext:localContext];
    [customer setCustomerId:[PKLocalCustomer generateCustomerId]];
    [customer setAccountRef:[PKLocalCustomer generateTemporaryAccountReference]];
    [customer setCompanyName:companyName];
    [customer setContactName:contactName];
    [customer setEmail:email];
    [customer setTelephone:telephone];
    [customer setMobile:mobile];
    
    // Save the context:
    [localContext MR_saveOnlySelfAndWait];
    
    return customer;
}

- (BOOL)saveAddressesFromBasket:(PKBasket *)basket {
    if ([basket order]) {
        PKOrder *order = [basket order];
        
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            PKLocalCustomer *customer = [PKLocalCustomer MR_findFirstByAttribute:@"customerId" withValue:[self customerId] inContext:localContext];
            
            // Create the billing address:
            PKLocalAddress *billingAddress = [PKLocalAddress createWithCustomerId:[self customerId]
                                                                      companyName:[order addressBillingCompanyName]
                                                                      contactName:[order addressBillingContactName]
                                                                          lineOne:[order addressBillingAddressLine1]
                                                                          lineTwo:[order addressBillingAddressLine2]
                                                                             city:[order addressBillingCity]
                                                                            state:[order addressBillingState]
                                                                          country:[order addressBillingCountry]
                                                                         postcode:[order addressBillingPostcode]
                                                                              vat:[order vatNumber]
                                                                              iso:@""
                                                                              idx:@(0)
                                                                          context:localContext];
            if (billingAddress) {
                NSLog(@"[%@] - Billing Address Created/Updated", [self class]);
            } else {
                NSLog(@"[%@] - Billing Address Failed", [self class]);
            }
            
            [customer addAddressesObject:billingAddress];
            
            // Create a delivery address:
            PKLocalAddress *deliveryAddress = [PKLocalAddress createWithCustomerId:[self customerId]
                                                                       companyName:[order addressDeliveryCompanyName]
                                                                       contactName:[order addressDeliveryContactName]
                                                                           lineOne:[order addressDeliveryAddressLine1]
                                                                           lineTwo:[order addressDeliveryAddressLine2]
                                                                              city:[order addressDeliveryCity]
                                                                             state:[order addressDeliveryState]
                                                                           country:[order addressDeliveryCountry]
                                                                          postcode:[order addressDeliveryPostcode]
                                                                               vat:[order vatNumber]
                                                                               iso:@""
                                                                               idx:@(1)
                                                                           context:localContext];
            if (deliveryAddress) {
                NSLog(@"[%@] - Delivery Address Created/Updated", [self class]);
            } else {
                NSLog(@"[%@] - Delivery Address Failed", [self class]);
            }
            
            [customer addAddressesObject:deliveryAddress];
        }];
    }
    
    return YES;
}

+ (void)purgeReplacedCustomers {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSArray *localCustomers = [PKLocalCustomer MR_findAllInContext:context];
    NSMutableArray *replacedCustomers = [NSMutableArray array];
    
    [localCustomers enumerateObjectsUsingBlock:^(PKLocalCustomer *localCustomer, NSUInteger idx, BOOL * _Nonnull stop) {
        PKCustomer *customer = [PKCustomer findCustomerWithAccountRef:[localCustomer accountRef]];
        if ([[customer accountRef] isEqualToString:[localCustomer accountRef]]) {
            // Delete the local customer:
            if (localCustomer) {
                [replacedCustomers addObject:localCustomer];
            }
        }
    }];
    
    if ([replacedCustomers count] != 0) {
        [replacedCustomers enumerateObjectsUsingBlock:^(PKLocalCustomer *localCustomer, NSUInteger idx, BOOL * _Nonnull stop) {
            [PKRecentCustomer removeCustomer:[localCustomer toCustomer] context:context];
        }];
        
        // Tell the context to delete the replaced customers:
        [context MR_deleteObjects:replacedCustomers];
        
        // Save context:
        [context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            if (!error) {
                NSLog(@"[%@] - Deleted replaced local customers", [self class]);
            } else {
                NSLog(@"[%@] - Error replacing local customers: %@", [self class], [error localizedDescription]);
            }
        }];
    }
}

- (PKCustomer *)toCustomer {
    PKCustomer *customer = [[PKCustomer alloc] init];
    
    [customer setIsCoreDataObject:YES];
    [customer setObjectId:[[self customerId] intValue]];
    [customer setSageId:@""];
    [customer setAccountRef:[self accountRef]];
    [customer setCompanyName:[self companyName]];
    [customer setRepName:[self repName]];
    [customer setContactName:[self contactName]];
    [customer setEmail:[self email]];
    [customer setTelephone:[self telephone]];
    [customer setMobile:[self mobile]];
    [customer setDefaultAddressId:-1];
    [customer setTurnoverPYTD:0];
    [customer setTurnoverYTD:0];
    [customer setBalance:0];
    [customer setCurrent:0];
    [customer setDays30:0];
    [customer setDays60:0];
    [customer setDays90:0];
    [customer setDays120:0];
    [customer setCurrencyId:[self currencyId]];
    
    return customer;
}

@end
