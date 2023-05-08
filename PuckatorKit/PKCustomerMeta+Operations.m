//
//  PKCustomerMeta+Operations.m
//  Puckator
//
//  Created by Jamie Chapman on 25/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCustomerMeta+Operations.h"
#import <MagicalRecord/MagicalRecord.H>

@implementation PKCustomerMeta (Operations)

+ (NSArray*) allKeyValuesForCustomerId:(NSString*)customerId feedNumber:(NSString*)feedNumber {
    if(customerId && feedNumber) {
        NSArray *results = [PKCustomerMeta MR_findAllSortedBy:@"key" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"customerId == %@ AND feedNumber == %@", customerId, feedNumber]];
        NSMutableArray *resultsAsDict = [[NSMutableArray alloc] init];
        for(PKCustomerMeta *meta in results) {
            if ([[meta key] length] != 0 && [[meta value] length] != 0) {
                [resultsAsDict addObject:@{@"key": [meta key], @"value": [meta value]}];
            }
        }
        return (NSArray*)resultsAsDict;
    } else {
        return nil;
    }
}

+ (NSDictionary*) keyValueForCustomerId:(NSString*)customerId feedNumber:(NSString*)feedNumber key:(NSString*)key {
    NSArray *results = [PKCustomerMeta MR_findAllSortedBy:@"key" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"customerId == %@ AND feedNumber == %@ AND key == %@", customerId, feedNumber, key]];
    if([results count] >= 1) {
        PKCustomerMeta *meta = [results firstObject];
        return @{@"key":[meta key], @"value":[meta value]};
    } else {
        return nil;
    }
}

+ (void) setKey:(NSString*)key value:(NSString*)value customerId:(NSString*)customerId feedNumber:(NSString*)feedNumber {
    
    PKCustomerMeta *meta = [PKCustomerMeta MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    [meta setCustomerId:customerId];
    [meta setFeedNumber:feedNumber];
    [meta setKey:key];
    [meta setValue:value];
    
    [[NSManagedObjectContext MR_defaultContext] save:nil];
}

@end
