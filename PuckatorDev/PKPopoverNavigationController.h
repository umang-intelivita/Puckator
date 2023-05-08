//
//  PKPopoverNavigationController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 27/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKPopoverNavigationController : UINavigationController

@property (nonatomic, strong) UIPopoverController *popoverReference;

- (void) forcePopoverSize;

@end
