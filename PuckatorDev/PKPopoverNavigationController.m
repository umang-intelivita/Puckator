//
//  PKPopoverNavigationController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 27/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKPopoverNavigationController.h"

@interface PKPopoverNavigationController ()

@end

@implementation PKPopoverNavigationController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self forcePopoverSize];
}

- (CGSize)preferredContentSize {
    return [[self.viewControllers lastObject] preferredContentSize];
}

- (void) forcePopoverSize {
//    return;
//    CGSize currentSetSizeForPopover = self.preferredContentSize;
//    [[self popoverReference] setPopoverContentSize:currentSetSizeForPopover animated:YES];
}

@end
