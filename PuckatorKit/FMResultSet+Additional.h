//
//  FMResultSet+Additional.h
//  PuckatorDev
//
//  Created by Luke Dixon on 05/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FMResultSet.h"

@interface FMResultSet (Additional)

- (NSString *)stringForColumnIfExists:(NSString *)columnName;
- (NSDate *)dateForColumnIfExists:(NSString *)columnName;
- (double)doubleForColumnIfExists:(NSString *)columnName;
- (int)intForColumnIfExists:(NSString *)columnName;
- (BOOL)boolForColumnIfExists:(NSString *)columnName;

@end