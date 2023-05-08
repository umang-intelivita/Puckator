//
//  UIViewController+Lifecycle.h
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Lifecycle)

- (BOOL)viewDidLoadCalled;
- (BOOL)viewWillAppearCalled;
- (BOOL)viewDidAppearCalled;
- (BOOL)viewWillDisappearCalled;
- (BOOL)viewDidDisappearCalled;

- (void)setViewDidLoadCalled:(BOOL)called;
- (void)setViewWillAppearCalled:(BOOL)called;
- (void)setViewDidAppearCalled:(BOOL)called;
- (void)setViewWillDisappearCalled:(BOOL)called;
- (void)setViewDidDisappearCalled:(BOOL)called;

@end