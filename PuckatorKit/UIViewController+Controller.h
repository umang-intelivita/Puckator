//
//  UIViewController+Controller.h
//  SkinEditor
//
//  Created by Luke Dixon on 24/02/2014.
//  Copyright (c) 2014 Private. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Controller)

#pragma mark - Constructor Methods

+ (instancetype)createWithNibName:(NSString *)nibName;
+ (instancetype)createFromStoryboardNamed:(NSString *)storyboardName;
+ (instancetype)createFromStoryboardNamed:(NSString *)storyboardName
                         withStoryboardId:(NSString *)storyboardId;
- (UINavigationController *)withNavigationController;
- (UINavigationController *)withNavigationControllerWithModalPresentationMode:(UIModalPresentationStyle)modalPresentationStyle;

#pragma mark - Public Methods

#pragma mark - Convenience Methods

@end