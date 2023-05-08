//
//  PKWelcomeViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKWelcomeViewController.h"
#import "PKTranslate.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"

#define kLanguageButtonTagEnglish       0
#define kLanguageButtonTagSpanish       1
#define kLanguageButtonTagFrench        2

@interface PKWelcomeViewController()
@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (nonatomic, strong) NSArray *languageInstructionText;
@end

@implementation PKWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self setModalInPresentation:YES];
    }
    
    // Customize the title
    [[self navigationItem] setTitle:NSLocalizedString(@"Welcome", nil)];
    
    // Do some initial customization
    [[self labelLanguageTitle] setFont:[UIFont puckatorContentTitle]];
    [[self labelLanguageTitle] setTextColor:[UIColor whiteColor]];
    [[self viewLanguageContainer] setBackgroundColor:[UIColor puckatorPrimaryColor]];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    // Setup translations
    [self setLanguageInstructionText:@[@"Tap your preferred language...",
                                       @"Toque el idioma que desee...",
                                       @"Tapez votre langue préférée..."]];
    
    [self showNextLanguageInstruction:self];
    
    // Show close button
    if (![self isCancelDisabled]) {
        UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(buttonCancelPressed:)];
        [[self navigationItem] setLeftBarButtonItem:buttonClose];
    }
    
    [[self labelVersion] setText:[NSString stringWithFormat:NSLocalizedString(@"You are using version: %@", @"Informs the user of which version of the app they're running. E.g. 'You are using version: 1.0'"), [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]];
}

- (void)animateUserInteface {
    // Shift the interface elements off screen / hide them
    [[self imageViewLogo] setAlpha:0.0f];
    [[self imageViewLogo] setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    [[self viewLanguageContainer] setTransform:CGAffineTransformMakeTranslation(0, 250)];
    [[self viewLanguageContainer] setAlpha:0.0f];
 
    // Animate them in
    [UIView animateWithDuration:0.6f animations:^{
        [[self imageViewLogo] setAlpha:1.0f];
        [[self imageViewLogo] setTransform:CGAffineTransformIdentity];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6f animations:^{
            [[self viewLanguageContainer] setAlpha:1.0f];
            [[self viewLanguageContainer] setTransform:CGAffineTransformIdentity];
        } completion:^(BOOL finished) {
            [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNextLanguageInstruction:) object:nil];
            [self performSelector:@selector(showNextLanguageInstruction:) withObject:nil afterDelay:1.5f];
        }];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:YES animated:[self isViewLoaded]];
    
    // Change languages on the welcome UI
    [self animateUserInteface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) showNextLanguageInstruction:(id)sender {
    // If the sender is self, then quickly configured the first phrase
    if (sender == self) {
        [[self labelLanguageTitle] setText:[self languageInstructionText][0]];
        [[self labelLanguageTitle] setTag:0];
    } else {
        // Animate the transition
        [UIView animateWithDuration:0.5 animations:^{
            // Fade out the current label...
            [[self labelLanguageTitle] setAlpha:0.0f];
        } completion:^(BOOL finished) {
            // Decide on the next translation
             int targetTranslationIndex = [[self labelLanguageTitle] tag] + 1;
             if (targetTranslationIndex >= [[self languageInstructionText] count]) {
                 targetTranslationIndex = 0;
             }
             
             // Set the new text
             [[self labelLanguageTitle] setText:[self languageInstructionText][targetTranslationIndex]];
             [[self labelLanguageTitle] setTag:targetTranslationIndex];
             
             // Animate the transition
             [UIView animateWithDuration:0.5 animations:^{
                 // Fade out the current label...
                 [[self labelLanguageTitle] setAlpha:1.0f];
             } completion:^(BOOL finished) {
                 // Animate again shortly
                 [self performSelector:@selector(showNextLanguageInstruction:) withObject:nil afterDelay:1.5f];
             }];
        }];
    }
}

- (IBAction)buttonLanguagePressed:(id)sender {
    // Stop any delayed selectors
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
    
    // Go to next UI
    [self performSegueWithIdentifier:@"agentEditSegue" sender:self];
}

- (void)buttonCancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
