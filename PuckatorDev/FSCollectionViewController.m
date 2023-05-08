//
//  FSCollectionViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 22/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "FSCollectionViewController.h"
#import "UIColor+Puckator.h"

@implementation FSCollectionViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewDidLoadCalled:YES];
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
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setViewDidDisappearCalled:YES];
}

#pragma mark -

@end