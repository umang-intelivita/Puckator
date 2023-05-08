//
//  UIView+Animate.m
//  MinecraftEncore
//
//  Created by Luke Dixon on 02/12/2014.
//  Copyright (c) 2014 Private. All rights reserved.
//

#import "UIView+Animate.h"

@implementation UIView (Animate)

- (void)shake {
    float duration = 0.1f;
    float magnitude = 5.f;
    float x = [self x];
    [UIView animateWithDuration:duration animations:^{
        [self increaseX:magnitude];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self increaseX:-(magnitude * 2)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                [self increaseX:(magnitude * 1.5)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration animations:^{
                    [self increaseX:-(magnitude * 1.5)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:duration animations:^{
                        [self setX:x];
                    } completion:^(BOOL finished) {
                    }];
                }];
            }];
        }];
    }];
}

- (void)bounce {
    float duration = 0.1f;
    float magnitude = 5.f;
    float y = [self y];
    [UIView animateWithDuration:duration animations:^{
        [self increaseY:-magnitude];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self setY:y];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                [self increaseY:-(magnitude * 0.5)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration animations:^{
                    [self setY:y];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:duration animations:^{
                        [self increaseY:-(magnitude * 0.25)];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:duration animations:^{
                            [self setY:y];
                        } completion:^(BOOL finished) {
                        }];
                    }];
                }];
            }];
        }];
    }];
}

- (void)pop {
    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:0.25f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setTransform:CGAffineTransformMakeScale(0.8f, 0.8f)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:0.25f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            [self setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
        } completion:^(BOOL finished) {
            [self setTransform:CGAffineTransformIdentity];
        }];
    }];
}


+ (void)animateWithDuration:(NSTimeInterval)duration
     usingSpringWithDamping:(CGFloat)dampingRatio
      initialSpringVelocity:(CGFloat)velocity
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:duration
                          delay:0.f
         usingSpringWithDamping:dampingRatio
          initialSpringVelocity:velocity
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animations
                     completion:completion];
}

@end