//
//  PKSearchParameters.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 26/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKSearchParameters.h"
#import "PKTranslate.h"
#import "PKProductPrice+Operations.h"

@implementation PKSearchParameters

- (id) init {
    if(self = [super init]) {
    
        // Provide some sensible default values
        [self setScope:PKSearchParameterTypeSearchByAll];
        [self setSortBy:PKSearchParameterTypeSortByPopularFirst];
    
    }
    return self;
}

+ (NSString *)titleForPriceFilter:(PKSearchParameters *)parameters {
    NSMutableString *title = [NSMutableString string];
    
    if ([[parameters priceMin] floatValue] > 0 && [[parameters priceMax] floatValue] > 0) {
        [title appendFormat:@"%@ %@ - %@", NSLocalizedString(@"Priced between", @"Used when filtering by price (between)"),
         [PKProductPrice formattedPrice:[parameters priceMin]],
         [PKProductPrice formattedPrice:[parameters priceMax]]];
    } else if ([[parameters priceMin] floatValue] > 0) {
        [title appendFormat:@"%@ %@", NSLocalizedString(@"Priced greater than", @"Used when filtering by price (greater than)"),
         [PKProductPrice formattedPrice:[parameters priceMin]]];
    } else if ([[parameters priceMax] floatValue] > 0) {
        [title appendFormat:@"%@ %@", NSLocalizedString(@"Priced less than", @"Used when filtering by price (less than)"),
         [PKProductPrice formattedPrice:[parameters priceMax]]];
    } else {
        [title appendString:NSLocalizedString(@"Priced...", @"Used when filtering by price (no selection)")];
    }
    
    return title;
}

+ (NSString*) titleForParameterType:(PKSearchParameterType)type {
    
    switch (type) {
        case PKSearchParameterTypeSearchByAll: {
            return NSLocalizedString(@"Product Code, Title & Description", nil);
        }
        case PKSearchParameterTypeSearchByCodeOnly: {
            return NSLocalizedString(@"Product Code Only", nil);
        }
        case PKSearchParameterTypeSearchByTitleAndDesc: {
            return NSLocalizedString(@"Title & Description Only", nil);
        }
        case PKSearchParameterTypeSearchByTitleOnly: {
            return NSLocalizedString(@"Title Only", nil);
        }
        case PKSearchParameterTypeSortByBestSellers: {
            return NSLocalizedString(@"Best Sellers First", nil);
        }
        case PKSearchParameterTypeSortByPopularFirst: {
            return NSLocalizedString(@"Most Popular First", nil);
        }
        case PKSearchParameterTypeProductCode: {
            return NSLocalizedString(@"Product Code", nil);
        }
        case PKSearchParameterTypePrice: {
            return NSLocalizedString(@"Price", nil);
        }
        case PKSearchParameterTypeDateAdded: {
            return NSLocalizedString(@"Date Added", nil);
        }
        case PKSearchParameterTypeTotalSold: {
            return NSLocalizedString(@"Total Sold", nil);
        }
        case PKSearchParameterTypeTotalValue: {
            return NSLocalizedString(@"Total Value", nil);
        }
        case PKSearchParameterTypeStockAvailable: {
            return NSLocalizedString(@"Stock Available", nil);
        }
        case PKSearchParameterTypeProductTitle: {
            return NSLocalizedString(@"Product Title", nil);
        }
        default: {
            return @"TITLE_UNAVAILABLE_FOR_TYPE";
        }
    }
}

@end
