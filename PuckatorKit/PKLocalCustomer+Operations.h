//
//  PKLocalCustomer+Operations.h
//  Puckator
//
//  Created by Luke Dixon on 05/08/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKLocalCustomer.h"
@class PKCustomer;

@interface PKLocalCustomer (Operations)

- (PKCustomer *)toCustomer;
+ (PKLocalCustomer *)createWithCompanyName:(NSString *)companyName contactName:(NSString *)contactName email:(NSString *)email telephone:(NSString *)telephone mobile:(NSString *)mobile;
+ (PKLocalCustomer *)customerWithCustomerId:(int)customerId;

// Removes customers that have been replaced by real customers (from sage/nexus/etc):
+ (void)purgeReplacedCustomers;

- (BOOL)saveAddressesFromBasket:(PKBasket *)basket;

@end