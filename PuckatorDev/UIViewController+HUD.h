//
//  UIViewController+HUD.h
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface UIViewController (HUD)

- (void)showHud:(NSString *)title;
- (void)showHud:(NSString *)title animated:(BOOL)animated;
- (void)showHud:(NSString *)title withSubtitle:(NSString *)subtitle;
- (void)showHud:(NSString *)title withSubtitle:(NSString *)subtitle animated:(BOOL)animated;
- (void)showHud:(NSString *)title withSubtitle:(NSString *)subtitle animated:(BOOL)animated interaction:(BOOL)interaction;
- (void)hideHud;
- (void)hideHudAnimated:(BOOL)animated;
- (void)hideHudAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@end