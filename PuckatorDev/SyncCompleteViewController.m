//
//  SyncCompleteViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 20/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "SyncCompleteViewController.h"
#import "PKTranslate.h"
#import "UIColor+Puckator.h"
#import "AFSoundManager.h"
#import "PKConstant.h"
#import "UIApplication+FS.h"

@implementation SyncCompleteViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Hide the icon
    [[self buttonIcon] setAlpha:0.0f];
    [[self buttonIcon] setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
    
    // Update the title
    [self setTitle:NSLocalizedString(@"Puckator", nil)];
    [[self labelTitle] setText:NSLocalizedString(@"Sync Complete!", nil)];
    [[self labelTimeTaken] setText:@""];
    [[self buttonContinue] setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
    [[self view] setBackgroundColor:[UIColor puckatorPrimaryColor]];
    
    // Hide the back button
    [[self navigationItem] setHidesBackButton:YES];
    
    // Hide the toolbar
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Animate the icon
    [UIView animateWithDuration:0.33 animations:^{
        [[self buttonIcon] setAlpha:1.0f];
        [[self buttonIcon] setTransform:CGAffineTransformIdentity];
    }];
    
    // Play sound
#if !TARGET_IPHONE_SIMULATOR
    [[AFSoundManager sharedManager] startPlayingLocalFileWithName:@"TwoCheers.wav" atPath:nil withCompletionBlock:nil];
#endif
}

- (IBAction)buttonDismiss:(id)sender {
    // Reset the app:
    [[UIApplication sharedApplication] exitAppWithWarningController:self withNotification:YES];
}

@end
