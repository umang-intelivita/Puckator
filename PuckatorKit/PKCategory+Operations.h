//
//  PKCategory+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCategory.h"
#import <UIKit/UIKit.h>

@class PKFeedConfig;

typedef enum {
    PKCategorySortModeBySortOrder = 0,
    PKCategorySortModeAlphabetically = 1
} PKCategorySortMode;

@interface PKCategory (Operations)

// Fetches or creates a category entity in the database
+ (PKCategory*) findOrCreateWithCategoryId:(NSString*)categoryId
                       forFeedConfig:(PKFeedConfig*)feedConfig
                           inContext:(NSManagedObjectContext*)context;

// Finds a category with a given category ID
+ (PKCategory*) categoryForId:(NSString*)categoryId
                forFeedConfig:(PKFeedConfig*)feedConfig
                    inContext:(NSManagedObjectContext*)context;

// Return the UIImage from the main PKImage:
- (UIImage *)image;

- (NSString *)styledTitle;

+ (NSArray *)bespokeCategoryIds;

//+ (NSArray *)allSorted __deprecated_msg("Use allSortedBy:ascending: instead.");
+ (NSArray *)customSortedBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending;
+ (NSArray *)allSortedBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending includeCustom:(BOOL)includeCustom;
+ (NSArray *)allSortedBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending includeCustom:(BOOL)includeCustom context:(NSManagedObjectContext *)context;
+ (NSArray *)allSortedBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending includeCustom:(BOOL)includeCustom feedConfig:(PKFeedConfig *)feedConfig context:(NSManagedObjectContext *)context;
- (NSArray *)productsSortBy:(PKCategorySortMode)sortMode ascending:(BOOL)ascending;
+ (void)deleteCustomCategories;

@end
