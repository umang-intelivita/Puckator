//
//  UITabBarController+Puckator.h
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UITabBarControllerTabCatalogue,
    UITabBarControllerTabCustomers,
    UITabBarControllerTabOrder
} UITabBarControllerTab;

@interface UITabBarController (Puckator)

- (void)setSelectedTab:(UITabBarControllerTab)tab;

@end