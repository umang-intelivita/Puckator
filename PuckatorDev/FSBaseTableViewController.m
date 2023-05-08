//
//  FSBaseTableViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSBaseTableViewController.h"

@implementation FSBaseTableViewController

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setViewDidAppearCalled:animated];
    
    if (@available(iOS 13.0, *)) {
        if ([self respondsToSelector:@selector(setModalInPresentation:)]) {
            [self setModalInPresentation:YES];
        }
    }
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
