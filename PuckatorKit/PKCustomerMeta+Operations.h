//
//  PKCustomerMeta+Operations.h
//  Puckator
//
//  Created by Jamie Chapman on 25/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCustomerMeta.h"

@interface PKCustomerMeta (Operations)

// Returns all associated key/value pairs with this customer ID, each result in the array is an NSDictionary
+ (NSArray*) allKeyValuesForCustomerId:(NSString*)customerId feedNumber:(NSString*)feedNumber;

// Returns a specific key/value pair as an NSDictionary
+ (NSDictionary*) keyValueForCustomerId:(NSString*)customerId feedNumber:(NSString*)feedNumber key:(NSString*)key;

// Saves a key/value pair against a customer/feed pair
+ (void) setKey:(NSString*)key value:(NSString*)value customerId:(NSString*)customerId feedNumber:(NSString*)feedNumber;

@end
