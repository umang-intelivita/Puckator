//
//  FSZoomTransitioningDelegate.h
//  PuckatorDev
//
//  Created by Luke Dixon on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKZoomTransitioning.h"

@interface PKZoomTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

+ (instancetype)createWithPoint:(CGPoint)point;
+ (instancetype)createWithFrame:(CGRect)frame;

@end