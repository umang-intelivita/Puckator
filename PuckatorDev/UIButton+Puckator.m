//
//  UIButton+Puckator.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 20/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "UIButton+Puckator.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"

@implementation UIButton (Puckator)

- (void) puckatorApplyTheme {
    [[self layer] setCornerRadius:4];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor puckatorPrimaryColor]];
    [[self titleLabel] setFont:[UIFont puckatorContentText]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end
