//
//  RXMLElement+Utilities.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 10/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "RXMLElement+Utilities.h"

@implementation RXMLElement (Utilities)

- (NSString*) stringOrEmptyString:(NSString*)child {
    if([[self child:child].text isKindOfClass:[NSString class]]) {
        return [self child:child].text;
    } else {
        return @"";
    }
}

- (NSString*) stringForKey:(NSString*)key {
    NSString *valueOrEmptyString = [self stringOrEmptyString:key];
    if([valueOrEmptyString length] >= 1) {
        return valueOrEmptyString;
    } else {
        return nil;
    }
}

- (BOOL) stringExistsForKey:(NSString*)key {
    NSString *valueOrEmptyString = [self stringForKey:key];
    if([valueOrEmptyString length] >= 1) {
        return YES;
    } else {
        return NO;
    }
}

@end
