//
//  PKAttributedString.h
//  PuckatorDev
//
//  Created by Luke Dixon on 17/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"

@interface PKAttributedString : NSAttributedString

+ (NSDictionary *)stringAttributesWithFont:(UIFont *)font color:(UIColor *)color;

@end