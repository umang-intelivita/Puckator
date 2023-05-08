//
//  UIView+Animate.h
//  MinecraftEncore
//
//  Created by Luke Dixon on 02/12/2014.
//  Copyright (c) 2014 Private. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+FrameHelper.h"

@interface UIView (Animate)

- (void)shake;
- (void)bounce;
- (void)pop;

+ (void)animateWithDuration:(NSTimeInterval)duration usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);

@end