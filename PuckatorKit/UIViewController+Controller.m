//
//  UIViewController+Controller.m
//  SkinEditor
//
//  Created by Luke Dixon on 24/02/2014.
//  Copyright (c) 2014 Private. All rights reserved.
//

#import "UIViewController+Controller.h"

@implementation UIViewController (Controller)

#pragma mark - Constructor Methods

+ (instancetype)createWithNibName:(NSString *)nibName {
    return [[self alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
}

+ (instancetype)createFromStoryboardNamed:(NSString *)storyboardName {
    return [self createFromStoryboardNamed:storyboardName withStoryboardId:NSStringFromClass([self class])];
}

+ (instancetype)createFromStoryboardNamed:(NSString *)storyboardName
                         withStoryboardId:(NSString *)storyboardId {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName
                                                         bundle:[NSBundle mainBundle]];
    
    if (!storyboard) {
        NSLog(@"[%@] - Storyboard missing: %@", [self class], storyboardName);
        return nil;
    }
    
    // Attempt to load the view controller:
    return [storyboard instantiateViewControllerWithIdentifier:storyboardId];
}

- (UINavigationController *)withNavigationController {
    return [self withNavigationControllerWithModalPresentationMode:UIModalPresentationFullScreen];
}

- (UINavigationController *)withNavigationControllerWithModalPresentationMode:(UIModalPresentationStyle)modalPresentationStyle {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    [[navigationController navigationBar] setTranslucent:NO];
    [navigationController setModalPresentationStyle:modalPresentationStyle];
    return navigationController;
}

#pragma mark - Public Methods

- (UIBarButtonItem *)barButtonItemDismiss {
    return [self barButtonItemDismissWithTitle:NSLocalizedString(@"Cancel", nil)];
}

- (UIBarButtonItem *)barButtonItemDismissWithTitle:(NSString *)title {
    // Add a dismiss button:
    return [self barButtonItemWithTitle:title andAction:@selector(dismissModalViewController)];
}

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title andAction:(SEL)action {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:action];
    return button;
}

- (void)setRightNavigationButton:(UIBarButtonItem *)barButtonItem {
    if ([self navigationItem]) {
        [[self navigationItem] setRightBarButtonItem:barButtonItem];
    }
}

- (void)setLeftNavigationButton:(UIBarButtonItem *)barButtonItem {
    if ([self navigationItem]) {
        [[self navigationItem] setLeftBarButtonItem:barButtonItem];
    }
}

#pragma mark -

@end