//
//  PKOnboardingViewController.m
//  Puckator
//
//  Created by Jamie Chapman on 23/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKOnboardingViewController.h"
#import "PKWelcomeViewController.h"
#import "PKFeedsTableViewController.h"

@interface PKOnboardingViewController ()

@end

@implementation PKOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PKWallpaper.png"]]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkIfWelcomeOrWipe];
}

- (void)checkIfWelcomeOrWipe {
    PKFeedConfig *config = [[PKSession sharedInstance] currentFeedConfig];
    
    if ([[config isWiped] boolValue]) {
        PKFeedsTableViewController *feedsTableViewController = [PKFeedsTableViewController create];
        [self presentViewController:[feedsTableViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
        }];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:nil];
        UINavigationController *welcomeNavController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"MainNavigiationController"];
        
        [(PKWelcomeViewController *)[[welcomeNavController viewControllers] firstObject] setIsCancelDisabled:YES];
        if (@available(iOS 13.0, *)) {
            [(PKWelcomeViewController *)[[welcomeNavController viewControllers] firstObject] setModalInPresentation:YES];
        }
        [self presentViewController:welcomeNavController animated:YES completion:^{
        }];
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
