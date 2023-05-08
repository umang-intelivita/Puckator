//
//  PKCategory+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCategory+Operations.h"
#import "PKFeedConfig.h"
#import <MagicalRecord/MagicalRecord.h>
#import "PKImage+Operations.h"
#import "PKSession.h"
#import "PKConstant.h"

@implementation PKCategory (Operations)

+ (PKCategory*) findOrCreateWithCategoryId:(NSString*)categoryId
                             forFeedConfig:(PKFeedConfig*)feedConfig
                                 inContext:(NSManagedObjectContext*)context {
    // Create a predicate to find the Category entity
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId = %@ AND feedNumber = %@", categoryId, [feedConfig number]];
    
    // Execute the search for this category
    PKCategory *category = [PKCategory MR_findFirstWithPredicate:predicate inContext:context];
    if (!category) {
        // No existing category with that ID, create a new entity
        category = [PKCategory MR_createEntityInContext:context];
        [category setCategoryId:categoryId];
        [category setFeedNumber:[feedConfig number]];
    }
    return category;
}

+ (PKCategory*) categoryForId:(NSString*)categoryId
                forFeedConfig:(PKFeedConfig*)feedConfig
                    inContext:(NSManagedObjectContext*)context {
    // No category ID, no category.  Just the way it is.
    if (!categoryId || !feedConfig) {
        return nil;
    }
    
    if(!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    // Find the category by ID
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId = %@ AND feedNumber = %@", categoryId, [feedConfig number]];
    return [PKCategory MR_findFirstWithPredicate:predicate inContext:context];
}

- (UIImage *)image {
    UIImage *image = [[self mainImage] image];
    if (image) {
        return image;
    } else {
        return [UIImage imageNamed:kPuckatorNoImageName];
    }
}

- (NSString *)styledTitle {
    if ([[self isCustom] boolValue]) {
        return [@"⭐️ " stringByAppendingString:[self title]];
    }
    
    return [self title];
}

+ (NSArray *)bespokeCategoryIds {
    NSFetchRequest *request = [PKCategory MR_requestAll];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[@"categoryId"]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"categoryId" ascending:YES]]];
    [request setReturnsDistinctResults:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", @"BESPOKE"];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *categoryIds = [[NSManagedObjectContext MR_context] executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"[%@] - Error: %@", [self class], [error localizedDescription]);
    }
    
    return [categoryIds valueForKey:@"categoryId"];
}

//+ (NSArray *)allSorted {
//    return [PKCategory allSortedBy:PKCategorySortModeBySortOrder ascending:YES];
//}

+ (void)deleteCustomCategories {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCustom == YES"];
    [PKCategory MR_deleteAllMatchingPredicate:predicate];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}

+ (NSArray *)customSortedBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending {
    NSManagedObjectContext *context;
    PKFeedConfig *feedConfig;
    NSString *sortKey = @"sortOrder";
    
    // Determine the key to sort by
    switch (sortMode) {
        case PKCategorySortModeAlphabetically: {
            sortKey = @"titleClean";
            break;
        }
        case PKCategorySortModeBySortOrder:
        default: {
            sortKey = @"sortOrder";
            break;
        }
    }
    
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    // Return nothing if the feed config has been wiped:
    if ([[feedConfig isWiped] boolValue]) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber == %@ AND (isCustom == YES)", [feedConfig number]];
    return [PKCategory MR_findAllSortedBy:sortKey ascending:ascending withPredicate:predicate inContext:context];
}

+ (NSArray *)allSortedBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending includeCustom:(BOOL)includeCustom {
    return [PKCategory allSortedBy:sortMode ascending:ascending includeCustom:includeCustom feedConfig:nil context:nil];
}

+ (NSArray *)allSortedBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending includeCustom:(BOOL)includeCustom context:(NSManagedObjectContext *)context {
    return [PKCategory allSortedBy:sortMode ascending:ascending includeCustom:includeCustom feedConfig:nil context:context];
}

+ (NSArray *)allSortedBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending includeCustom:(BOOL)includeCustom feedConfig:(PKFeedConfig *)feedConfig context:(NSManagedObjectContext *)context {
    NSString *sortKey = @"sortOrder";
    
    // Determine the key to sort by
    switch (sortMode) {
        case PKCategorySortModeAlphabetically: {
            sortKey = @"titleClean";
            break;
        }
        case PKCategorySortModeBySortOrder:
        default: {
            sortKey = @"sortOrder";
            break;
        }
    }
    
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    
    if (!feedConfig) {
        feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    }
    
    // Return nothing if the feed config has been wiped:
    if ([[feedConfig isWiped] boolValue]) {
        return nil;
    }
    
    if (includeCustom) {
        // Fetch the custom categories:
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber == %@ AND isCustom == YES", [feedConfig number]];
        NSArray<PKCategory *> *customCategories = [PKCategory MR_findAllSortedBy:sortKey ascending:ascending withPredicate:predicate inContext:context];
        
        // Fetch the rest of the categories:
        predicate = [NSPredicate predicateWithFormat:@"feedNumber == %@ AND (isCustom == NO OR isCustom == NULL)", [feedConfig number]];
        NSArray<PKCategory *> *fixedCategories = [PKCategory MR_findAllSortedBy:sortKey ascending:ascending withPredicate:predicate inContext:context];
        
        // Add the arrays together:
        NSMutableArray *categories = [NSMutableArray array];
        [categories addObjectsFromArray:fixedCategories];
        [categories addObjectsFromArray:customCategories];
        return categories;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedNumber == %@ AND (isCustom == NO OR isCustom == NULL)", [feedConfig number]];
        return [PKCategory MR_findAllSortedBy:sortKey ascending:ascending withPredicate:predicate inContext:context];
    }
}

- (NSArray *)productsSortBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending {
    @autoreleasepool {
        NSString *sortKey = @"sortOrder";
        
        // Determine the key to sort by
        switch (sortMode) {
            case PKCategorySortModeAlphabetically: {
                sortKey = @"title";
                break;
            }
            case PKCategorySortModeBySortOrder:
            default: {
                sortKey = @"sortOrder";
                break;
            }
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY categories.categoryId == %@ && feedNumber == %@", [self categoryId], [self feedNumber]];
        return [PKProduct MR_findAllSortedBy:sortKey ascending:ascending withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    }    
}

@end
