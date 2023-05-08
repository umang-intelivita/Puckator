//
//  PKRecentCustomer+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 18/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKRecentCustomer+Operations.h"
#import "PKCustomer.h"

@implementation PKRecentCustomer (Operations)

+ (BOOL) addCustomer:(PKCustomer*)customer context:(NSManagedObjectContext*)context {    
    // Bail out if no customer
    if (!customer) {
        return NO;
    }
    
    // Use default context if not provided
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Check if this is already a recent customer
    PKRecentCustomer *recentCustomer = [PKRecentCustomer MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"customerId = %d", [customer objectId]]
                                                                         inContext:context];
    if(recentCustomer) {
        [recentCustomer setDateUpdated:[NSDate date]];
    } else {
        recentCustomer = [PKRecentCustomer MR_createEntityInContext:context];
        [recentCustomer setUuid:[[NSUUID UUID] UUIDString]];
        [recentCustomer setCustomerId:@([customer objectId])];
        [recentCustomer setDateCreated:[NSDate date]];
        [recentCustomer setDateUpdated:[recentCustomer dateCreated]];
        [recentCustomer setPinned:@(NO)];
    }
    
    [context MR_saveToPersistentStoreAndWait];
    return YES;
}

+ (BOOL) removeCustomer:(PKCustomer*)customer context:(NSManagedObjectContext*)context {
    // Bail out if no customer
    if (!customer) {
        return NO;
    }
    
    // Use default context if not provided
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Check if this is already a recent customer
    PKRecentCustomer *recentCustomer = [PKRecentCustomer MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"customerId = %d", [customer objectId]]
                                                                         inContext:context];
    
    if (recentCustomer) {
        [recentCustomer MR_deleteEntityInContext:context];
        
        // Save
        NSError *error = nil;
        if([context save:&error]) {
            return YES;
        } else {
            NSLog(@"Error deleting RecentCustomer.  Error is %@", [error localizedDescription]);
            return NO;
        }
    } else {
        NSLog(@"Customer does not exist in RecentCustomers");
        return NO;
    }
}

+ (void) clearCustomersIncludingPinned:(BOOL)deletedPinned context:(NSManagedObjectContext*)context {
    // Use default context if not provided
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Delete and update context
    [PKRecentCustomer MR_deleteAllMatchingPredicate:[NSPredicate predicateWithValue:YES] inContext:context];
    
    NSError *error = nil;
    if(![context save:&error]) {
        NSLog(@"Error clearing customers! %@", [error localizedDescription]);
    }
}

+ (NSArray*) all {    
    // Get a list of recent customers
    NSArray *recentCustomers = [PKRecentCustomer MR_findAllSortedBy:@"dateUpdated" ascending:NO];
    
    NSMutableArray *customerIds = [[NSMutableArray alloc] init];
    for(PKRecentCustomer *customer in recentCustomers) {
        NSNumber *customerId = [customer customerId];
        if (customerId) {
            [customerIds addObject:customerId];
        }
    }
    
    // Go through each one and query from SQL
    NSArray *foundCustomers = [PKCustomer findCustomersWithIds:customerIds];
    
    // Sort the found customers by dateUpdated
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for(PKRecentCustomer *customer in recentCustomers) {
        for(PKCustomer *foundCustomer in foundCustomers) {
            if([[customer customerId] intValue] == [foundCustomer objectId]) {
                [foundCustomer setIsPinned:[[customer pinned] boolValue]];
                [foundCustomer setDateLastSelected:[customer dateUpdated]];
                if (foundCustomer) {
                    [results addObject:foundCustomer];
                }
                break;
            }
        }
    }
    return results;
}

- (BOOL) pin {
    [self setPinned:@(YES)];
    NSError *error = nil;
    if([[NSManagedObjectContext MR_defaultContext] save:&error]) {
        return YES;
    } else {
        NSLog(@"Error pinning customer: %@", [error localizedDescription]);
        return NO;
    }
}

- (BOOL) unpin {
    [self setPinned:@(NO)];
    NSError *error = nil;
    if([[NSManagedObjectContext MR_defaultContext] save:&error]) {
        return YES;
    } else {
        NSLog(@"Error pinning customer: %@", [error localizedDescription]);
        return NO;
    }
}

- (BOOL) togglePin {
    if([[self pinned] boolValue] == YES) {
        return [self unpin];
    } else {
        return [self pin];
    }
}

@end
