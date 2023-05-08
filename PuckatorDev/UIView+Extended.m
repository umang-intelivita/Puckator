//
//  UIView+Extended.m
//  PuckatorDev
//
//  Created by Luke Dixon on 22/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "UIView+Extended.h"

@implementation UIView (Extended)

- (void)removeAllSubviews {
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
}

- (UIViewController *)viewController {
    Class vcc = [UIViewController class];
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass: vcc]) {
            return (UIViewController *)responder;
        }
    }
    
    return nil;
}

@end