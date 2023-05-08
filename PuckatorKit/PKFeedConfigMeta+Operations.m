//
//  PKFeedConfigMeta+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKFeedConfigMeta+Operations.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation PKFeedConfigMeta (Operations)

+ (void) syncroniseCurrenciesWithFeedConfig:(PKFeedConfig*)feedConfig
                                 currencies:(NSArray*)currencies
                                    context:(NSManagedObjectContext*)context {
    
    // Use default context if not specified
    if(!context) context = [NSManagedObjectContext MR_defaultContext];
    
    // Wipe any existing currency entries
    [PKFeedConfigMeta MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"feedNumber = %@ AND group = %@", [feedConfig number], @"currency"]
                                                               inContext:context];
    
    // Create entries for currencies
    PKFeedConfigMeta *meta = [PKFeedConfigMeta MR_createEntityInContext:context];
    [meta setGroup:@"currency"];
    [meta setFeedNumber:[feedConfig number]];
    [meta setKey:@"currency"];
    [meta setObject:currencies];
    [meta setCreatedAt:[NSDate date]];
    
    // Save
    NSError *error = nil;
    if([context save:&error]) {
        NSLog(@"Saved PKFeedConfigMeta for currencies!");
    } else {
        NSLog(@"Error saving PKFeedConfigMeta! %@", [error localizedDescription]);
    }
}

+ (void)saveFeedMetaDataWithFeedConfig:(PKFeedConfig *)feedConfig group:(NSString *)group key:(NSString *)key object:(id)metaData context:(NSManagedObjectContext *)context save:(BOOL)save {
    if ([group length] == 0) {
        return;
    }
    
    if (key == 0) {
        return;
    }
    
    NSManagedObjectContext *_context = context;
    
    if (!_context) {
        _context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Wipe any existing currency entries
    NSPredicate *predicate = nil;
    
    @try {
        predicate = [NSPredicate predicateWithFormat:@"feedNumber = %@ AND group = %@ AND key = %@", [feedConfig number], group, key];
    } @catch (NSException *exception) {
        predicate = nil;
    } @finally {
        if (predicate && _context) {
            [PKFeedConfigMeta MR_deleteAllMatchingPredicate:predicate inContext:_context];
        }
    }
    
    if (!metaData) {
        return;
    }
    
    // Save
    @try {        
        // Create entries for currencies
        PKFeedConfigMeta *meta = [PKFeedConfigMeta MR_createEntityInContext:_context];
        [meta setGroup:group];
        [meta setFeedNumber:[feedConfig number]];
        [meta setKey:key];
        [meta setObject:metaData];
        [meta setCreatedAt:[NSDate date]];
        
        if (save && _context) {
            NSError *error = nil;
            if ([_context save:&error]) {
                NSLog(@"Saved PKFeedConfigMeta for Feed: %@ - Group: %@ - Key: %@\nData: %@", [feedConfig number], group, key, metaData);
            } else {
                NSLog(@"Error saving PKFeedConfigMeta for feed_meta: %@", [error localizedDescription]);
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Error saving PKFeedConfigMeta for feed_meta: %@", [exception description]);
    } @finally {
    }
}

+ (void)saveFeedMetaDataWithFeedConfig:(PKFeedConfig *)feedConfig group:(NSString *)group key:(NSString *)key object:(id)metaData {
    // Use default context if not specified
    [PKFeedConfigMeta saveFeedMetaDataWithFeedConfig:feedConfig group:group key:key object:metaData context:nil save:YES];
}

+ (id)feedMetaDataWithFeedConfig:(PKFeedConfig *)feedConfig group:(NSString *)group key:(NSString *)key {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber = %@ AND group = %@ AND key = %@", [feedConfig number], group, key];
    PKFeedConfigMeta *metaData = [PKFeedConfigMeta MR_findFirstWithPredicate:predicate
                                                                   inContext:context];
    return metaData;
}

+ (void) syncroniseFeedMetaDataWithFeedConfig:(PKFeedConfig*)feedConfig
                                 currencies:(NSDictionary*)metaData
                                    context:(NSManagedObjectContext*)context {
    
    // Use default context if not specified
    if(!context) context = [NSManagedObjectContext MR_defaultContext];
    
    // Wipe any existing currency entries
    [PKFeedConfigMeta MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"feedNumber = %@ AND group = %@", [feedConfig number], @"feed_meta"]
                                          inContext:context];
    
    // Create entries for currencies
    PKFeedConfigMeta *meta = [PKFeedConfigMeta MR_createEntityInContext:context];
    [meta setGroup:@"feed_meta"];
    [meta setFeedNumber:[feedConfig number]];
    [meta setKey:@"feed_meta"];
    [meta setObject:metaData];
    [meta setCreatedAt:[NSDate date]];
    
    // Save
    NSError *error = nil;
    if([context save:&error]) {
        NSLog(@"Saved PKFeedConfigMeta for feed_meta!");
    } else {
        NSLog(@"Error saving PKFeedConfigMeta for feed_meta: %@", [error localizedDescription]);
    }
}

+ (NSArray *)currenciesForFeedConfig:(PKFeedConfig *)feedConfig context:(NSManagedObjectContext*)context {
    // Use default context if not specified
    if (!context) context = [NSManagedObjectContext MR_defaultContext];
    
    // Wipe any existing currency entries
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber = %@ AND key = %@", [feedConfig number], @"currency"];
    PKFeedConfigMeta *metaData = [PKFeedConfigMeta MR_findFirstWithPredicate:predicate inContext:context];
    
    if (metaData) {
        if ([[metaData object] isKindOfClass:[NSArray class]]) {
            return [metaData object];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

+ (NSDictionary*) feedMetaDataForFeedConfig:(PKFeedConfig*)feedConfig
                                    context:(NSManagedObjectContext*)context {
    
    // Use default context if not specified
    if(!context) context = [NSManagedObjectContext MR_defaultContext];
    
    // Wipe any existing currency entries
    PKFeedConfigMeta *metaData = [PKFeedConfigMeta MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"feedNumber = %@ AND key = %@", [feedConfig number], @"feed_meta"]
                                                                   inContext:context];
    
    if(metaData) {
        if([[metaData object] isKindOfClass:[NSDictionary class]]) {
            return [metaData object];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
    
}

+ (PKFeedConfigMeta *)feedConfigMetaObjectForFeedConfig:(PKFeedConfig*)feedConfig
                                                context:(NSManagedObjectContext*)context {
    // Use default context if not specified
    if (!context) context = [NSManagedObjectContext MR_defaultContext];
    
    // Wipe any existing currency entries
    PKFeedConfigMeta *metaData = [PKFeedConfigMeta MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"feedNumber = %@ AND key = %@", [feedConfig number], @"feed_meta"]
                                                                   inContext:context];
    
    return metaData;
}

@end
