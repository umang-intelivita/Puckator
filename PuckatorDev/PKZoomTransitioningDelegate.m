//
//  FSZoomTransitioningDelegate.m
//  PuckatorDev
//
//  Created by Luke Dixon on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKZoomTransitioningDelegate.h"

@interface PKZoomTransitioningDelegate ()

@property (assign, nonatomic) CGPoint point;
@property (assign, nonatomic) CGRect frame;

@end

@implementation PKZoomTransitioningDelegate

+ (instancetype)createWithPoint:(CGPoint)point {
    PKZoomTransitioningDelegate *delegate = [PKZoomTransitioningDelegate new];
    [delegate setPoint:point];
    return delegate;
}

+ (instancetype)createWithFrame:(CGRect)frame {
    PKZoomTransitioningDelegate *delegate = [PKZoomTransitioningDelegate new];
    [delegate setFrame:frame];
    return delegate;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    PKZoomTransitioning *transitioning = [PKZoomTransitioning createWithFrame:[self frame]];
    return transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    PKZoomTransitioning *transitioning = [PKZoomTransitioning createWithFrame:[self frame]];
    [transitioning setReverse:YES];
    return transitioning;
}

@end