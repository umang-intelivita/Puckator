//
//  PKNotesViewController.m
//  Puckator
//
//  Created by Luke Dixon on 24/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKNotesViewController.h"
#import "PKBasket+Operations.h"
#import "PKOrder.h"

@interface PKNotesViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textViewMain;

@end

@implementation PKNotesViewController

+ (instancetype)create {
    return [[PKNotesViewController alloc] initWithNibName:@"PKNotesViewController" bundle:[NSBundle mainBundle]];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Notes", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PKBasket *basket = [PKBasket sessionBasket];
    if ([basket order]) {
        [[self textViewMain] setText:[[basket order] notes]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    PKBasket *basket = [PKBasket sessionBasket];
    if ([basket order]) {
        [[basket order] setNotes:[[self textViewMain] text]];
        [basket save];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self textViewMain] becomeFirstResponder];
}

#pragma mark - Event Methods

- (void)buttonClosePressed:(id)sender {
}

#pragma mark -

@end
