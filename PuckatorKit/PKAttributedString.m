//
//  PKAttributedString.m
//  PuckatorDev
//
//  Created by Luke Dixon on 17/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKAttributedString.h"

@implementation PKAttributedString

+ (NSDictionary *)stringAttributesWithFont:(UIFont *)font color:(UIColor *)color {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (font) {
        [dictionary setObject:font forKey:NSFontAttributeName];
    }
    
    if (color) {
        [dictionary setObject:color forKey:NSForegroundColorAttributeName];
    }
    
    return dictionary;
}

@end