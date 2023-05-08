//
//  NSString+Utils.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString*) padWithLeadingWhitespace:(int)length {
    return [self padWithWhitespace:length isLeading:YES];
}

- (NSString*) padWithTrailingWhitespace:(int)length {
    return [self padWithWhitespace:length isLeading:NO];
}

- (NSString*) padWithWhitespace:(int)length isLeading:(BOOL)leading {
    if([self length] >= length) {
        return self;
    } else {
        int paddingRequired = length - (int)[self length];
        NSMutableString *padding = [[NSMutableString alloc] initWithString:@""];
        for(int i=0; i < paddingRequired; i++) {
            [padding appendString:@" "];
        }
        if(leading) {
            return [NSString stringWithFormat:@"%@%@", padding, self];
        } else {
            return [NSString stringWithFormat:@"%@%@", self, padding];
        }
    }
}

- (NSString *)limitToLength:(int)length truncate:(BOOL)truncate {
    NSString *copiedString = [self sanitize];
    
    @try {
        NSString *truncationStr = @"...";
        if ([copiedString length] > length) {
            if (truncate) {
                length = (length - [truncationStr length]);
            }
            
            copiedString = [copiedString substringToIndex:length];
            
            if (truncate) {
                copiedString = [copiedString stringByAppendingString:truncationStr];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        return self;
    }
    
    return copiedString;
}

- (NSString *)clean {
    NSMutableString *clean = [NSMutableString stringWithString:self];
    CFMutableStringRef cleanRef = (__bridge CFMutableStringRef)clean;
    CFStringTransform(cleanRef, nil, kCFStringTransformToLatin, NO);
    CFStringTransform(cleanRef, nil, kCFStringTransformStripCombiningMarks, NO);
    CFStringTrimWhitespace(cleanRef);
    CFStringLowercase(cleanRef,(__bridge CFLocaleRef)[NSLocale localeWithLocaleIdentifier:@"en-US"]);
    return clean;
}

- (NSString*) sanitize {
    if (self == nil) {
        return @"";
    }
    if ([self length] == 0) {
        return @"";
    }
    if ([self isEqualToString:@"(null)"]) {
        return @"";
    }
    
    // Remove double spaces
    NSString *result = self;
    while ([result containsString:@"  "]) {
        result = [result stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    // Trim whitespace
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Return new string
    return result;
}

- (NSString *)prefixFlagUK {
    return [@"🇬🇧 " stringByAppendingString:self];
}

- (NSString *)prefixFlagEDC {
    return [@"🇪🇺 " stringByAppendingString:self];
}

- (NSString *)suffixFlagUK {
    return [self stringByAppendingString:@" 🇬🇧"];
}

- (NSString *)suffixFlagEDC {
    return [self stringByAppendingString:@" 🇪🇺"];
}

@end
