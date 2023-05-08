//
//  UIButton+AllStates.h
//  PuckatorDev
//
//  Created by Luke Dixon on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (AllStates)

- (void)setTitleForAllStates:(NSString *)title;
- (void)setImageForAllStates:(UIImage *)image;
- (void)setTitleColorForAllStates:(UIColor *)color;
- (void)setTitleAndImageColorForAllStates:(UIColor *)color;
- (void)setImageRenderingModeForAllStates:(UIImageRenderingMode)imageRenderingMode;

@end