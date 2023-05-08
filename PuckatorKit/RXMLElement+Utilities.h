//
//  RXMLElement+Utilities.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 10/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "RXMLElement.h"

@interface RXMLElement (Utilities)

// Returns either a string value or an empty string if missing
- (NSString*) stringOrEmptyString:(NSString*)child;

// Gets a string for a given key, or nil if it does not exist
- (NSString*) stringForKey:(NSString*)key;

// Determines if a string value exists for a given key
- (BOOL) stringExistsForKey:(NSString*)key;

@end
