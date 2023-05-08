//
//  UIApplication+FS.h
//  Puckator
//
//  Created by Luke Dixon on 08/03/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (FS)

- (void)exitAppWithWarningController:(UIViewController *)warningController withNotification:(BOOL)withNotification;

@end
