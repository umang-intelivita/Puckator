//
//  FMResultSet+Additional.m
//  PuckatorDev
//
//  Created by Luke Dixon on 05/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FMResultSet+Additional.h"
#import <MKFoundationKit/NSDate+MK.h>

@implementation FMResultSet (Additional)

- (NSString *)stringForColumnIfExists:(NSString *)columnName {
    columnName = [columnName lowercaseString];
    if ([[self columnNameToIndexMap] objectForKey:columnName]) {
        return [self stringForColumn:columnName];
    } else {
        return nil;
    }
}

- (NSDate *)dateForColumnIfExists:(NSString *)columnName {
    columnName = [columnName lowercaseString];
    if ([[self columnNameToIndexMap] objectForKey:columnName]) {
        NSDate *date = [self dateForColumn:columnName];
        NSString *dateStr = [date mk_formattedStringUsingFormat:@"dd-MM-yyyy"];
        if ([dateStr containsString:@"-0002"] || [dateStr containsString:@"-0000"] || [dateStr containsString:@"-1970"]) {
            date = nil;
        }
        return date;
    } else {
        return nil;
    }
}

- (double)doubleForColumnIfExists:(NSString *)columnName {
    columnName = [columnName lowercaseString];
    if ([[self columnNameToIndexMap] objectForKey:columnName]) {
        return [self doubleForColumn:columnName];
    } else {
        return 0.0;
    }
}

- (int)intForColumnIfExists:(NSString *)columnName {
    columnName = [columnName lowercaseString];
    if ([[self columnNameToIndexMap] objectForKey:columnName]) {
        return [self intForColumn:columnName];
    } else {
        return 0;
    }
}

- (BOOL)boolForColumnIfExists:(NSString *)columnName {
    columnName = [columnName lowercaseString];
    if ([[self columnNameToIndexMap] objectForKey:columnName]) {
        return [self boolForColumn:columnName];
    } else {
        return NO;
    }
}

@end
