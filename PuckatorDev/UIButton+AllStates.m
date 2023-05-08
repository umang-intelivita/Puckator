//
//  UIButton+AllStates.m
//  PuckatorDev
//
//  Created by Luke Dixon on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "UIButton+AllStates.h"
#import "UIImageView+ImageRenderingMode.h"

@implementation UIButton (AllStates)

- (void)setTitleForAllStates:(NSString *)title {
    [self setTitle:title forState:UIControlStateApplication];
    [self setTitle:title forState:UIControlStateDisabled];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateReserved];
    [self setTitle:title forState:UIControlStateSelected];
}

- (void)setTitleColorForAllStates:(UIColor *)color {
    [self setTitleColor:color forState:UIControlStateApplication];
    [self setTitleColor:color forState:UIControlStateDisabled];
    [self setTitleColor:color forState:UIControlStateHighlighted];
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateReserved];
    [self setTitleColor:color forState:UIControlStateSelected];
}

- (void)setImageForAllStates:(UIImage *)image {
    [self setImage:image forState:UIControlStateApplication];
    [self setImage:image forState:UIControlStateDisabled];
    [self setImage:image forState:UIControlStateHighlighted];
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateReserved];
    [self setImage:image forState:UIControlStateSelected];
}

- (void)setTitleAndImageColorForAllStates:(UIColor *)color {
    [self setTitleColorForAllStates:color];
    
    [self setImage:[[self imageForState:UIControlStateApplication] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
          forState:UIControlStateApplication];
    [self setImage:[[self imageForState:UIControlStateDisabled] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
          forState:UIControlStateDisabled];
    [self setImage:[[self imageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
          forState:UIControlStateHighlighted];
    [self setImage:[[self imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
          forState:UIControlStateNormal];
    [self setImage:[[self imageForState:UIControlStateReserved] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
          forState:UIControlStateReserved];
    [self setImage:[[self imageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
          forState:UIControlStateSelected];
    
    [[self imageView] setImageRenderingMode:UIImageRenderingModeAlwaysTemplate withTintColor:color];
}

- (void)setImageRenderingModeForAllStates:(UIImageRenderingMode)imageRenderingMode {
    [self setImage:[[self imageForState:UIControlStateApplication] imageWithRenderingMode:imageRenderingMode] forState:UIControlStateApplication];
    [self setImage:[[self imageForState:UIControlStateDisabled] imageWithRenderingMode:imageRenderingMode] forState:UIControlStateDisabled];
    [self setImage:[[self imageForState:UIControlStateHighlighted] imageWithRenderingMode:imageRenderingMode] forState:UIControlStateHighlighted];
    [self setImage:[[self imageForState:UIControlStateNormal] imageWithRenderingMode:imageRenderingMode] forState:UIControlStateNormal];
    [self setImage:[[self imageForState:UIControlStateReserved] imageWithRenderingMode:imageRenderingMode] forState:UIControlStateReserved];
    [self setImage:[[self imageForState:UIControlStateSelected] imageWithRenderingMode:imageRenderingMode] forState:UIControlStateSelected];
}

@end