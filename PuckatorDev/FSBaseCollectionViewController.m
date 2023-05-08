//
//  FSCollectionViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 22/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "FSBaseCollectionViewController.h"
#import "UIColor+Puckator.h"

@implementation FSBaseCollectionViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewDidLoadCalled:YES];
    
    if (@available(iOS 13.0, *)) {
        if ([self respondsToSelector:@selector(setModalInPresentation:)]) {
            [self setModalInPresentation:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setViewWillAppearCalled:YES];
    [[UIView appearanceWhenContainedIn:[UITabBar class], nil] setTintColor:[UIColor puckatorLightPurple]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setViewDidAppearCalled:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setViewWillDisappearCalled:YES];
    
    if (@available(iOS 13.0, *)) {
        if ([self respondsToSelector:@selector(setModalInPresentation:)]) {
            [self setModalInPresentation:YES];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setViewDidDisappearCalled:YES];
}

#pragma mark -

@end
