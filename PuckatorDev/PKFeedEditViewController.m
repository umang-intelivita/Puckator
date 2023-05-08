//
//  PKFeedEditViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 10/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeedEditViewController.h"
//#import <M13ProgressSuite/M13ProgressHUD.h>
#import "UIAlertView+Puckator.h"

@interface PKFeedEditViewController ()

@end

@implementation PKFeedEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:NSLocalizedString(@"Feed Information", nil)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Focus on the first field
    [self makeFirstFieldFirstResponder];
    
    // Show error if this device has been wiped
    if ([[(PKFeedConfig*)[[self formController] form] isWiped] boolValue] == YES) {
        [UIAlertView showAlertWithTitle:NSLocalizedString(@"Access Revoked", nil)
                             andMessage:NSLocalizedString(@"Access to this feed has been revoked by a Puckator Administrator.\n\nIf you feel this is in error please contact Puckator.", nil)];
    }
}

#pragma mark - Actions

- (void) saveFeed:(id)sender {
    // Save the configuration object
    PKFeedConfig *configuration = (PKFeedConfig*)[[self formController] form];
    
    // Perform some validation on the form
    if ([[configuration name] length] == 0) {
        [UIAlertView showAlertWithTitle:NSLocalizedString(@"Invalid Feed Name", nil)
                             andMessage:NSLocalizedString(@"Please enter a value!", nil)];
        return;
    }
    
    if ([[configuration number] length] == 0) {
        [UIAlertView showAlertWithTitle:NSLocalizedString(@"Invalid Feed Number", nil)
                             andMessage:NSLocalizedString(@"Please enter a value!", nil)];
        return;
    }
    
    NSError *error = [configuration save];
    if (error) {
        // Show error if any validation errors occured, such as the feed number already existing
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Feed", nil)
                                                        message:NSLocalizedString(@"You have already added this Feed Number!", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"No error, save is OK");
        
        [self showHud:NSLocalizedString(@"Updating...", nil)];
        [configuration registerFeed:^(BOOL success, NSError *error, int deviceIdentifier) {
            if(success) {
                [[self navigationController] popViewControllerAnimated:YES];
            } else {
                [UIAlertView showAlertWithTitle:NSLocalizedString(@"Feed Error", nil) andMessage:[error localizedDescription]];
            }
            [self hideHud];
        }];
        
    }
}

@end
