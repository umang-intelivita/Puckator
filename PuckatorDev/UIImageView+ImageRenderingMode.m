//
//  UIImageView+ImageRenderingMode.m
//  PuckatorDev
//
//  Created by Luke Dixon on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "UIImageView+ImageRenderingMode.h"

@implementation UIImageView (ImageRenderingMode)

- (void)setImageRenderingMode:(UIImageRenderingMode)imageRenderingMode {
    if ([self image]) {
        [self setImage:[[self image] imageWithRenderingMode:imageRenderingMode]];
    }
}

- (void)setImageRenderingMode:(UIImageRenderingMode)imageRenderingMode withTintColor:(UIColor *)tintColor {
    [self setImageRenderingMode:imageRenderingMode];
    [self setTintColor:tintColor];
}

@end