//
//  PKCreateCustomerViewController.m
//  Puckator
//
//  Created by Luke Dixon on 05/08/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCreateCustomerViewController.h"
#import "PKLocalCustomer+Operations.h"
#import "PKCurrencyViewController.h"

@interface PKCreateCustomerViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSave;
@property (weak, nonatomic) IBOutlet UILabel *labelCompanyName;
@property (weak, nonatomic) IBOutlet UILabel *labelContactName;
@property (weak, nonatomic) IBOutlet UILabel *labelEmailAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelTelephone;
@property (weak, nonatomic) IBOutlet UILabel *labelMobile;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCompanyName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldContactName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTelephone;
@property (weak, nonatomic) IBOutlet UITextField *textFieldMobile;

@end

@implementation PKCreateCustomerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:NSLocalizedString(@"Customer Details", nil)];
    
    // Setup the label text for localization:
    [[self buttonSave] setTitle:NSLocalizedString(@"Save", nil)];
    
    [[self labelCompanyName] setText:NSLocalizedString(@"Company Name", nil)];
    [[self labelContactName] setText:NSLocalizedString(@"Contact Name", nil)];
    [[self labelEmailAddress] setText:NSLocalizedString(@"Email Address", nil)];
    [[self labelMobile] setText:NSLocalizedString(@"Mobile", nil)];
    [[self labelTelephone] setText:NSLocalizedString(@"Telephone", nil)];
    
    [[self textFieldCompanyName] setPlaceholder:NSLocalizedString(@"Company Name", nil)];
    [[self textFieldContactName] setPlaceholder:NSLocalizedString(@"Contact Name", nil)];
    [[self textFieldEmailAddress] setPlaceholder:NSLocalizedString(@"Email Address", nil)];
    [[self textFieldMobile] setPlaceholder:NSLocalizedString(@"Mobile", nil)];
    [[self textFieldTelephone] setPlaceholder:NSLocalizedString(@"Telephone", nil)];
    
    [[self textFieldCompanyName] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [[self textFieldContactName] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [[self textFieldEmailAddress] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[self textFieldMobile] setKeyboardType:UIKeyboardTypePhonePad];
    [[self textFieldTelephone] setKeyboardType:UIKeyboardTypePhonePad];
}

- (IBAction)buttonSavePressed:(id)sender {
    // Check the form has been filled out:
    if ([[[self textFieldCompanyName] text] length] != 0 &&
        [[[self textFieldContactName] text] length] != 0 &&
        [[[self textFieldEmailAddress] text] length] != 0 &&
        [[[self textFieldTelephone] text] length] != 0 &&
        [[[self textFieldMobile] text] length] != 0) {
        [FSThread runOnMain:^{
            PKLocalCustomer *customer = [PKLocalCustomer createWithCompanyName:[[self textFieldCompanyName] text]
                                                                   contactName:[[self textFieldContactName] text]
                                                                         email:[[self textFieldEmailAddress] text]
                                                                     telephone:[[self textFieldTelephone] text]
                                                                        mobile:[[self textFieldMobile] text]];
            if (customer) {
                NSLog(@"[%@] - Customer Created: %@", [self class], [customer customerId]);
                PKCurrencyViewController *currencyViewController = [PKCurrencyViewController createWithCustomer:[customer toCustomer] delegate:[self delegate]];
                [[self navigationController] pushViewController:currencyViewController animated:YES];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                    message:NSLocalizedString(@"Unable to create a new customer, please contact your support team.", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
                                                            message:NSLocalizedString(@"Please enter all information", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
