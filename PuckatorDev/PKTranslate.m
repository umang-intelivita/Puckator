//
//  PKTranslate.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKTranslate.h"

@implementation PKTranslate

+ (NSString*) stringForKey:(NSString*)key {
    return [PKTranslate stringForKey:key
                           forLocale:[NSLocale currentLocale]]; /* Replace with this last selected locale, rather than current locale */
}

+ (NSString*) stringForKey:(NSString*)key
                 forLocale:(NSLocale*)locale {
    return key; // Read from file?
}

@end
