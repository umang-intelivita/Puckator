//
//  PKAgentEditViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKAgentEditViewController.h"
#import "PKAgent.h"
#import "UIAlertView+Puckator.h"
#import "PKTranslate.h"

@interface PKAgentEditViewController ()

@end

@implementation PKAgentEditViewController

+ (instancetype)create {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:[NSBundle mainBundle]];
    
    if (storyboard) {
        id viewController = [storyboard instantiateViewControllerWithIdentifier:@"PKAgentEditViewController"];
        if ([viewController isKindOfClass:[PKAgentEditViewController class]]) {
            return (PKAgentEditViewController *)viewController;
        }
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        [self setModalInPresentation:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self isEditMode]) {
        [self setTitle:NSLocalizedString(@"Settings", nil)];
    } else {
        [self setTitle:NSLocalizedString(@"Who are you?", nil)];
    }
    
    // Get the current agent, could be empty
    PKAgent *agent = [PKAgent currentAgent];
    [agent setIsEditMode:[self isEditMode]];
    [[self formController] setForm:agent];
 
    // Get first field
    id <FXFormFieldCell> cell = (id <FXFormFieldCell>)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // Select field (assuming it's a text field
    if ([cell respondsToSelector:@selector(textField)]) {
        [((FXFormTextFieldCell *)cell).textField becomeFirstResponder];
    }
    
    // Add a cancel button:
    if ([self isEditMode]) {
        UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonCancelPressed:)];
        [[self navigationItem] setLeftBarButtonItem:buttonCancel];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Focus on the first field if this is a new agent
    if(![[PKAgent currentAgent] firstName]) {
        [self makeFirstFieldFirstResponder];
    }
}

#pragma mark - Event Methods

- (void)buttonCancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Data Methods

- (void)saveAgent:(id)sender {
    // Get the agent object
    PKAgent *agent = (PKAgent*)[[self formController] form];
    
    // Perform some basic validation
    if ([[agent firstName] length] == 0 || [[agent lastName] length] == 0) {
        [UIAlertView showAlertWithTitle:NSLocalizedString(@"Invalid Name!", nil)
                             andMessage:NSLocalizedString(@"Make sure you type your first and last name!", nil)];
        return;
    }
    
    // Ensure the user has entered an e-mail address
    if(! [[agent email] isEmail]) {
        [UIAlertView showAlertWithTitle:NSLocalizedString(@"Invalid E-mail Address!", nil)
                             andMessage:NSLocalizedString(@"Make sure you type a valid e-mail address.", nil)];
        return;
    }
    
    // Save if OK
    [agent save];
    
    if ([self isEditMode]) {
        // Dismiss the view controller in edit mode:
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    } else {
        // Continue to feed confirmation
        [self performSegueWithIdentifier:@"feedsEditSegue" sender:self];
    }
}

#pragma mark -

@end
