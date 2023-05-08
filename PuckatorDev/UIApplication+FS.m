//
//  UIApplication+FS.m
//  Puckator
//
//  Created by Luke Dixon on 08/03/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import "UIApplication+FS.h"

@implementation UIApplication (FS)

- (void)exitAppWithWarningController:(UIViewController *)warningController withNotification:(BOOL)withNotification {
    if (warningController) {
        NSString *title = NSLocalizedString(@"App Closing", nil);
        NSString *message = NSLocalizedString(@"The app will now close, you can open it again by tapping the icon on your home screen.", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (withNotification) {
                [self setupNotification];
            }
            exit(0);
        }]];
        [warningController presentViewController:alertController animated:YES completion:^{
        }];
    } else {
        if (withNotification) {
            [self setupNotification];
        }
        exit(0);
    }
}

- (void)setupNotification {
}

@end
