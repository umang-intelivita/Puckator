//
//  PKSearchParameters.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 26/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    /* Searching text */
    PKSearchParameterTypeSearchByAll = 0,
    PKSearchParameterTypeSearchByCodeOnly = 1,
    PKSearchParameterTypeSearchByTitleAndDesc = 2,
    PKSearchParameterTypeSearchByTitleOnly = 3,
    
    /* Sorting */
    PKSearchParameterTypeSortByPopularFirst = 10,
    PKSearchParameterTypeSortByBestSellers = 11,
    
    /* Product Sorting */
    PKSearchParameterTypeProductCode = 100,
    PKSearchParameterTypePrice = 101,
    PKSearchParameterTypeDateAdded = 102,
    PKSearchParameterTypeTotalSold = 103,
    PKSearchParameterTypeTotalValue = 104,
    PKSearchParameterTypeStockAvailable = 105,
    PKSearchParameterTypeProductTitle = 106
    
} PKSearchParameterType;

@interface PKSearchParameters : NSObject

@property (nonatomic, strong) NSString *searchText;                 // Freeform text query
@property (nonatomic, strong) NSDictionary *filterCategoryIds;      // An NSDictionary where the key corresponds to a category ID
@property (nonatomic, assign) PKSearchParameterType scope;          // The scope in which to search, e.g. product code only, or code/text/desc, etc.
@property (nonatomic, assign) PKSearchParameterType sortBy;         // Sort by
@property (nonatomic, strong) NSNumber *priceMin;                   // Used for filtering by price (min)
@property (nonatomic, strong) NSNumber *priceMax;                   // Used for filtering by price (max)
@property (nonatomic, assign) BOOL hideBespoke;                     // Hide the bespoke products

// Turn a type of a title
+ (NSString*) titleForParameterType:(PKSearchParameterType)type;
+ (NSString *)titleForPriceFilter:(PKSearchParameters *)parameters;

@end