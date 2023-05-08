//
//  UIImageView+ImageRenderingMode.h
//  PuckatorDev
//
//  Created by Luke Dixon on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ImageRenderingMode)

- (void)setImageRenderingMode:(UIImageRenderingMode)imageRenderingMode;
- (void)setImageRenderingMode:(UIImageRenderingMode)imageRenderingMode withTintColor:(UIColor *)tintColor;

@end