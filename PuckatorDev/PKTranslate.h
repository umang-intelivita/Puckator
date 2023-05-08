//
//  PKTranslate.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

//#undef NSLocalizedString
//#define NSLocalizedString(key)                      NSLocalizedString(key, nil)

//#define NSLocalizedString(key)                        [PKTranslate stringForKey:key] // Uses last selected locale
#define PKLocalizedStringWithLocale(key, locale)      [PKTranslate stringForKey:key forLocale:locale]  // Pass nil for last selected locale

@interface PKTranslate : NSObject

/* 
 
        THIS CLASS IS A STUB.
 
 */

+ (NSString*) stringForKey:(NSString*)key;

+ (NSString*) stringForKey:(NSString*)key
                 forLocale:(NSLocale*)locale;

@end
