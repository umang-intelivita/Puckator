//
//  UITabBarController+Puckator.m
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "UITabBarController+Puckator.h"

@implementation UITabBarController (Puckator)

- (void)setSelectedTab:(UITabBarControllerTab)tab {
    [self setSelectedIndex:(int)tab];
}

@end