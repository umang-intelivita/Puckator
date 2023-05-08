//
//  PKSaleHistory.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 26/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKSaleHistory.h"
#import "PKProductSaleHistory+Operations.h"
#import <NSDate+Calendar/NSDate+Calendar.h>

@implementation PKSaleHistory

- (id)initWithSaleHistory:(PKProductSaleHistory*)productSaleHistory forType:(PKSaleHistoryType)type andMonthIndex:(int)monthIndex {
    if (self = [super init]) {
        if (monthIndex <= 0 || monthIndex > 12) {
            assert(@"Month index must be 1-12 in PKSaleHistory!");
        }
        
//
//        if (type == PKSaleHistoryTypePriorYear) {
//            [self setDate:[NSDate dateWithYear:(date.year-1) month:monthIndex day:1]];
//
//            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"prior_%d", monthIndex]);
//            if ([productSaleHistory respondsToSelector:selector]) {
//                [self setValue:[[productSaleHistory performSelector:selector] integerValue]];
//            } else {
//                [self setError:YES]; // The entity did not respond as expected!
//            }
//        } else {
//            [self setDate:[NSDate dateWithYear:(date.year) month:monthIndex day:1]];
//
//            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"current_%d", monthIndex]);
//            if ([productSaleHistory respondsToSelector:selector]) {
//                [self setValue:[[productSaleHistory performSelector:selector] integerValue]];
//            } else {
//                [self setError:YES]; // The entity did not respond as expected!
//            }
//        }
        
        NSDate *date = [NSDate date];
        SEL selector = nil;
        switch (type) {
            case PKSaleHistoryTypeYearToDate: {
                [self setDate:[NSDate dateWithYear:(date.year) month:monthIndex day:1]];
                selector = NSSelectorFromString([NSString stringWithFormat:@"current_%d", monthIndex]);
                break;
            }
            case PKSaleHistoryTypePriorYear: {
                [self setDate:[NSDate dateWithYear:(date.year-1) month:monthIndex day:1]];
                selector = NSSelectorFromString([NSString stringWithFormat:@"prior_%d", monthIndex]);
                break;
            }
            case PKSaleHistoryTypePriorTwoYear: {
                [self setDate:[NSDate dateWithYear:(date.year-2) month:monthIndex day:1]];
                selector = NSSelectorFromString([NSString stringWithFormat:@"priorTwo_%d", monthIndex]);
                break;
            }
            default: {
                selector = nil;
                break;
            }
        }
        
        if (selector && [productSaleHistory respondsToSelector:selector]) {
            [self setValue:[[productSaleHistory performSelector:selector] integerValue]];
        } else {
            // The object didn't respond to the selector therefore set error to YES:
            [self setError:YES];
        }
        
    }
    return self;
}

- (NSString*) dateStringWithFormat:(PKSaleHistoryDateFormat)formatType {
    return [self dateStringWithLocale:nil withFormat:formatType];
}

- (NSString*) dateStringWithLocale:(NSLocale*)locale withFormat:(PKSaleHistoryDateFormat)formatType {
    if ([self date]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[self stringFormatForType:formatType]];
        return [dateFormatter stringFromDate:[self date]];
    } else {
        return @"?";
    }
}

- (NSString*) stringFormatForType:(PKSaleHistoryDateFormat)format {
    switch (format) {
        case PKSaleHistoryDateFormatMonthNameShortOnly: {
            return @"MMM";
        }
        case PKSaleHistoryDateFormatMonthNameOnly: {
            return @"MMMM";
        }
        case PKSaleHistoryDateFormatMonthNameAndYear: {
            return @"MMMM yyyy";
        }
        case PKSaleHistoryDateFormatMonthAsNumber: {
            return @"MM";
        }
        case PKSaleHistoryDateFormatYearNameOnly: {
            return @"YYYY";
        }
        case PKSaleHistoryDateFormatMonthAsNumberAndYear:
        default: {
            return @"MM/YYYY";
        }
    }
}

@end
