//
//  UIViewController+Lifecycle.m
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "UIViewController+Lifecycle.h"
#import <objc/runtime.h>

NSString const *viewDidLoadCalledKey = @"uiviewcontroller.lifecycle.viewdidloadcalled.key";
NSString const *viewWillAppearCalledKey = @"uiviewcontroller.lifecycle.viewwillappearcalled.key";
NSString const *viewDidAppearCalledKey = @"uiviewcontroller.lifecycle.viewdidappearcalled.key";
NSString const *viewWillDisappearCalledKey = @"uiviewcontroller.lifecycle.viewwilldisappearcalled.key";
NSString const *viewDidDisappearCalledKey = @"uiviewcontroller.lifecycle.viewdiddisappearcalled.key";

@implementation UIViewController (Lifecycle)

- (BOOL)viewDidLoadCalled {
    return [objc_getAssociatedObject(self, &viewDidLoadCalledKey) boolValue];
}

- (BOOL)viewWillAppearCalled {
    return [objc_getAssociatedObject(self, &viewWillAppearCalledKey) boolValue];
}

- (BOOL)viewDidAppearCalled {
    return [objc_getAssociatedObject(self, &viewDidAppearCalledKey) boolValue];
}

- (BOOL)viewWillDisappearCalled {
    return [objc_getAssociatedObject(self, &viewWillDisappearCalledKey) boolValue];
}

- (BOOL)viewDidDisappearCalled {
    return [objc_getAssociatedObject(self, &viewDidDisappearCalledKey) boolValue];
}

- (void)setViewDidLoadCalled:(BOOL)called {
    objc_setAssociatedObject(self, &viewDidLoadCalledKey, @(called), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setViewWillAppearCalled:(BOOL)called {
    objc_setAssociatedObject(self, &viewWillAppearCalledKey, @(called), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setViewDidAppearCalled:(BOOL)called {
    objc_setAssociatedObject(self, &viewDidAppearCalledKey, @(called), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setViewWillDisappearCalled:(BOOL)called {
    objc_setAssociatedObject(self, &viewWillDisappearCalledKey, @(called), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setViewDidDisappearCalled:(BOOL)called {
    objc_setAssociatedObject(self, &viewDidDisappearCalledKey, @(called), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end