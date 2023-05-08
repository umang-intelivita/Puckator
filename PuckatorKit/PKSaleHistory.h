//
//  PKSaleHistory.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 26/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKProductSaleHistory;

typedef enum {
    PKSaleHistoryTypeYearToDate = 0,
    PKSaleHistoryTypePriorYear = 1,
    PKSaleHistoryTypePriorTwoYear = 2
} PKSaleHistoryType;

typedef enum {
    PKSaleHistoryDateFormatMonthNameOnly = 0,
    PKSaleHistoryDateFormatMonthNameAndYear = 1,
    PKSaleHistoryDateFormatMonthAsNumber = 2,
    PKSaleHistoryDateFormatMonthAsNumberAndYear = 3,
    PKSaleHistoryDateFormatMonthNameShortOnly = 4,
    PKSaleHistoryDateFormatYearNameOnly = 6
} PKSaleHistoryDateFormat;

@interface PKSaleHistory : NSObject

#pragma mark - Constructors

// Creates an instance of
- (id) initWithSaleHistory:(PKProductSaleHistory*)productSaleHistory
                   forType:(PKSaleHistoryType)type
             andMonthIndex:(int)monthIndex;

#pragma mark - Properties

@property (nonatomic, strong) NSDate *date;                 // An approx date. Used for calculating a date so we can use iOS to get a localised date
@property (nonatomic, assign) PKSaleHistoryType type;       // Either YTD or Prior
@property (nonatomic, assign) int value;                    // The actual value associated with the date
@property (nonatomic, assign) BOOL error;                   // This indicates something went wrong when finding a value

#pragma mark - Methods

// Returns the month name and year in a given format, e.g. "January 2014", "01/2014", "Janary" or "01".
- (NSString*) dateStringWithFormat:(PKSaleHistoryDateFormat)formatType;

@end
