//
//  FSFormBaseViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "FSFormBaseViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface FSFormBaseViewController ()
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation FSFormBaseViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewDidLoadCalled:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setViewWillAppearCalled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setViewDidAppearCalled:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setViewWillDisappearCalled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setViewDidDisappearCalled:YES];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) makeFirstFieldFirstResponder {
    
    // Get first field
    id <FXFormFieldCell> cell = (id <FXFormFieldCell>)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // Select field (assuming it's a text field
    if ([cell respondsToSelector:@selector(textField)]) {
        [((FXFormTextFieldCell *)cell).textField becomeFirstResponder];
    }
}

- (void) showHud:(NSString*)title {
    [self showHud:title
     withSubtitle:nil];
}

- (void) showHud:(NSString*)title withSubtitle:(NSString*)subtitle {
    
    BOOL isNew = NO;
    if(![self progressHUD]) {
        [self setProgressHUD:[[MBProgressHUD alloc] initWithView:[self view]]];
        isNew = YES;
    }
    
    // Update labels
    [[self progressHUD] setLabelText:title];
    if(subtitle) {
        [[self progressHUD] setDetailsLabelText:subtitle];
    } else {
        [[self progressHUD] setDetailsLabelText:@""];
    }
    
    // Add it as subview if required
    if(isNew) {
        [[self progressHUD] setRemoveFromSuperViewOnHide:YES];
        [[self view] addSubview:[self progressHUD]];
    }
    
    // Show the HUD
    [[self progressHUD] show:NO];
    
}

- (void) hideHud {
    [[self progressHUD] hide:NO];
    [[self progressHUD] removeFromSuperview];
    [self setProgressHUD:nil];
}

@end
