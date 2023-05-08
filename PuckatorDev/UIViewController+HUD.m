//
//  UIViewController+HUD.m
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "UIViewController+HUD.h"
#import <objc/runtime.h>

NSString const *hudKey = @"uiviewcontroller.hud.key";

@implementation UIViewController (HUD)

- (MBProgressHUD *)hud {
    MBProgressHUD *hud = objc_getAssociatedObject(self, &hudKey);
    return hud;
}

- (void)setHud:(MBProgressHUD *)hud {
    objc_setAssociatedObject(self, &hudKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Display Methods

- (void)showHud:(NSString *)title {
    [self showHud:title animated:NO];
}

- (void)showHud:(NSString *)title animated:(BOOL)animated {
    [self showHud:title withSubtitle:nil animated:animated];
}

- (void)showHud:(NSString *)title withSubtitle:(NSString *)subtitle {
    [self showHud:title withSubtitle:subtitle animated:NO];
}

- (void)showHud:(NSString *)title withSubtitle:(NSString *)subtitle animated:(BOOL)animated {
    [self showHud:title withSubtitle:subtitle animated:animated interaction:YES];
}

- (void)showHud:(NSString *)title withSubtitle:(NSString *)subtitle animated:(BOOL)animated interaction:(BOOL)interaction {
    BOOL isNew = NO;
    BOOL isNewStar = NO;
        
    if (![self hud]) {
        [self setHud:[[MBProgressHUD alloc] initWithView:[self view]]];
        [[self hud] setRemoveFromSuperViewOnHide:YES];
    }
    
    if (interaction) {
        [[self view] addSubview:[self hud]];
    } else {
        [[[[UIApplication sharedApplication] delegate] window] addSubview:[self hud]];
    }
    
    // Update labels
    [[self hud] setLabelText:title];
    if ([subtitle length] != 0) {
        [[self hud] setDetailsLabelText:subtitle];
    } else {
        [[self hud] setDetailsLabelText:@""];
    }
    
    // Show the HUD
    [[self hud] show:animated];
}

- (void)hideHud {
    [self hideHudAnimated:NO];
}

- (void)hideHudAnimated:(BOOL)animated {
    [self hideHudAnimated:animated afterDelay:0];
}

- (void)hideHudAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    if (delay > 0) {
        [[self hud] hide:animated afterDelay:delay];
    } else {
        [[self hud] hide:animated];
    }
}

#pragma mark -

@end
