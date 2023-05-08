//
//  FSCollectionViewZoomTransition.m
//  PuckatorDev
//
//  Created by Luke Dixon on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKZoomTransitioning.h"

static NSTimeInterval const DEAnimatedTransitionDuration = 5.5f;
static NSTimeInterval const DEAnimatedTransitionMarcoDuration = 0.15f;

@interface PKZoomTransitioning ()

@property (assign, nonatomic) CGPoint point;
@property (assign, nonatomic) CGRect frame;

@end

@implementation PKZoomTransitioning

+ (instancetype)createWithPoint:(CGPoint)point {
    PKZoomTransitioning *transitioning = [PKZoomTransitioning new];
    [transitioning setPoint:point];
    return transitioning;
}

+ (instancetype)createWithFrame:(CGRect)frame {
    PKZoomTransitioning *transitioning = [PKZoomTransitioning new];
    [transitioning setFrame:frame];
    return transitioning;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    if (self.reverse) {
        [container insertSubview:toViewController.view belowSubview:fromViewController.view];
    }
    else {
        //toViewController.view.center = [self point];
        
        toViewController.view.frame = [self frame];
        //toViewController.view.alpha = 0.0f;
        
        //toViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [container addSubview:toViewController.view];
        
    }
    
    [UIView animateWithDuration:DEAnimatedTransitionDuration delay:0.f usingSpringWithDamping:0.75f initialSpringVelocity:0.5f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        if (self.reverse) {
            //fromViewController.view.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            fromViewController.view.frame = [self frame];
            //fromViewController.view.alpha = 0.0f;
            
            toViewController.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }
        else {
            //toViewController.view.transform = CGAffineTransformIdentity;
            //toViewController.view.center = [[fromViewController view] center];
            
            toViewController.view.frame = fromViewController.view.bounds;
            toViewController.view.alpha = 1.0f;
            
            //fromViewController.view.layer.anchorPoint = CGPointMake(0.1f, 0.1f);
            
            fromViewController.view.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return DEAnimatedTransitionDuration;
}

@end