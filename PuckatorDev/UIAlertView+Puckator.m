//
//  UIAlertView+Puckator.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "UIAlertView+Puckator.h"

@implementation UIAlertView (Puckator)

+ (void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

@end
