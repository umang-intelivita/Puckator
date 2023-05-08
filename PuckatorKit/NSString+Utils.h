//
//  NSString+Utils.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

/**
 *  Pads a string with leading whitespace, e.g. "X" with length 5 becomes "X     " and "XY" with length 4 becomes "XY  ".
 *
 *  @param length The length of the string to pad
 *
 *  @return A padded version of the string
 */
- (NSString*) padWithLeadingWhitespace:(int)length;
- (NSString*) padWithTrailingWhitespace:(int)length;

- (NSString *)limitToLength:(int)length truncate:(BOOL)truncate;

- (NSString*) sanitize;
- (NSString *)clean;

- (NSString *)prefixFlagUK;
- (NSString *)prefixFlagEDC;
- (NSString *)suffixFlagUK;
- (NSString *)suffixFlagEDC;

@end
