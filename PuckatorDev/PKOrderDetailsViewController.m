//
//  OrderDetailsViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 13/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKOrderDetailsViewController.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import <HexColors/HexColor.h>
#import "UIButton+Puckator.h"
#import "PKAddress.h"
#import "PKCountry.h"
#import "PKOrder.h"
#import "PKBasket+Operations.h"
#import "PKOrderSyncViewController.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import "PKConstant.h"
#import "FSTextField.h"
#import <MKFoundationKit/MKFoundationKit.h>
#import "PKLocalCustomer+Operations.h"

@interface PKOrderDetailsViewController ()

/* Headings */
@property (weak, nonatomic) IBOutlet UILabel *labelBillingAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelFurtherInfo;
@property (weak, nonatomic) IBOutlet UIButton *buttonCopy;

/* Sections */
@property (weak, nonatomic) IBOutlet UIView *viewBilling;
@property (weak, nonatomic) IBOutlet UIView *viewDelivery;
@property (weak, nonatomic) IBOutlet UIView *viewFurtherInfo;

/* Billing Fields */
@property (weak, nonatomic) IBOutlet UILabel *labelBillingCompanyName;
@property (weak, nonatomic) IBOutlet UILabel *labelBillingContactName;
@property (weak, nonatomic) IBOutlet UILabel *labelBillingAddressLine1;
@property (weak, nonatomic) IBOutlet UILabel *labelBillingCity;
@property (weak, nonatomic) IBOutlet UILabel *labelBillingState;
@property (weak, nonatomic) IBOutlet UILabel *labelBillingCountry;
@property (weak, nonatomic) IBOutlet UILabel *labelBillingPostcode;

/* Delivery Address */
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryCompanyName;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryContactName;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryAddressLine1;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryCity;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryState;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryCountry;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryPostcode;

/* Further Info */
@property (weak, nonatomic) IBOutlet UILabel *labelFurtherInfoVatNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelFurtherInfoEmailConfirmations;
@property (weak, nonatomic) IBOutlet UILabel *labelFurtherInfoMethodOfPayment;
@property (weak, nonatomic) IBOutlet UILabel *labelFurtherInfoDateRequired;
@property (weak, nonatomic) IBOutlet UILabel *labelFurtherInfoNotes;
@property (weak, nonatomic) IBOutlet UILabel *labelFiscaleCode;
@property (weak, nonatomic) IBOutlet UILabel *labelPEC;
@property (weak, nonatomic) IBOutlet UILabel *labelRET;
@property (weak, nonatomic) IBOutlet UILabel *labelPurchaseOrderNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelTradeShowOrder;

/* Fields */
@property (weak, nonatomic) IBOutlet FSTextField *textFieldBillingCompanyName;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldBillingContactName;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldBillingAddressLine1;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldBillingAddressLine2;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldBillingCity;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldBillingState;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldBillingCountry;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldBillingPostcode;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDeliveryCompanyName;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDeliveryContactName;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDeliveryAddressLine1;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDeliveryAddressLine2;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDeliveryCity;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDeliveryState;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDeliveryCountry;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDeliveryPostcode;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldVatNumber;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldEmailAddresses;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldPaymentMethod;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldDateRequired;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldFiscalCode;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldPEC;
@property (weak, nonatomic) IBOutlet FSTextField *textFieldPurchaseOrderNumber;
@property (weak, nonatomic) IBOutlet UITextView *textViewNotes;
@property (nonatomic, assign) int paymentMethodId;
@property (nonatomic, assign) int paymentTermsId;
@property (weak, nonatomic) IBOutlet UISwitch *switchTradeShowOrder;
@property (weak, nonatomic) IBOutlet UISwitch *switchRET;

/* Other */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIPopoverController *currentPopoverController;
@property (nonatomic, strong) NSDate *selectedDeliveryDate;
@property (nonatomic, strong) PKCountry *deliveryCountry;
@property (nonatomic, strong) PKCountry *billingCountry;
@property (nonatomic, strong) PKOrder *order;

/* Buttons */
@property (weak, nonatomic) IBOutlet UIButton *buttonFindDeliveryAddress;
@property (weak, nonatomic) IBOutlet UIButton *buttonFindBillingAddress;
@property (weak, nonatomic) IBOutlet UIButton *buttonClearDeliveryAddress;
@property (weak, nonatomic) IBOutlet UIButton *buttonClearBillingAddress;

// ISO codes:
@property (strong, nonatomic) NSString *isoCodeBilling;
@property (strong, nonatomic) NSString *isoCodeDelivery;

@end

@implementation PKOrderDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a close button
    UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonCancelPressed:)];
    [[self navigationItem] setLeftBarButtonItem:buttonClose];
    
    // Add submit button
    NSString *sendTitle = ([self isQuote] ? NSLocalizedString(@"Send Quote", nil) : NSLocalizedString(@"Send Order", nil));
    UIBarButtonItem *buttonSend = [[UIBarButtonItem alloc] initWithTitle:sendTitle
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(submitOrderPressed:)];
    [buttonSend setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor puckatorGreen]} forState:UIControlStateNormal];
    [[self navigationItem] setRightBarButtonItem:buttonSend];
    
    // Apply theme:
    [self applyTheme];
    [[self scrollView] setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+1)];
    
    // Listen for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboardPressed:) name:UIKeyboardDidHideNotification object:nil];
    
    // Load the order details
    [self loadOrderDetails];
}

- (PKBasket *)currentBasket {
    return [self basket];
}

- (void) loadOrderDetails {
    // If an order has already been setup then
    // don't setup up another:
    if ([self order]) {
        return;
    }
    
    // Setup an order if required:
    if (![[self currentBasket] order]) {
        [self setOrder:[PKOrder MR_createEntity]];
        [[self currentBasket] setOrder:[self order]];
        [[self currentBasket] save];
    }
    
    // Save the order reference:
    [self setOrder:[[self currentBasket] order]];
    
    // Setup the default value on the order:
    if ([[[self order] draft] boolValue] == YES) {
        [self setDefaultValues];
    }
    
    // Display the order details:
    [self displayOrderDetails];
}

- (void) setDefaultValues {
    if ([[self order] paymentMethodId]) {
        [self setPaymentMethodId:[[[self order] paymentMethodId] intValue]];
    } else {
        [self setPaymentMethodId:3];
    }
    
    // Configure default addresses...
    PKCustomer *customer = [[PKSession sharedInstance] currentCustomer];
    NSArray *addresses = [[[PKSession sharedInstance] currentCustomer] addresses];
    
    // TODO: Use the current addresses here:
    if ([addresses count] == 0) {
        PKCustomer *customer = [[PKSession sharedInstance] currentCustomer];
        [[self textFieldBillingCompanyName] setText:[customer companyName]];
        [[self textFieldBillingContactName] setText:[customer contactName]];
        [[self textFieldDeliveryCompanyName] setText:[customer companyName]];
        [[self textFieldDeliveryContactName] setText:[customer contactName]];
    } else {
        PKAddress *deliveryAddress = [customer deliveryAddress];
        PKAddress *invoiceAddress = [customer invoiceAddress];
        [self setAddress:invoiceAddress forAddressType:PKAddressTypeInvoice];
        [self setAddress:deliveryAddress forAddressType:PKAddressTypeDelivery];
    }
    
    // Any more defaults?
    NSString *vatNumber = [self getVatNumber:addresses];
    if(vatNumber) {
        [[self textFieldVatNumber] setText:vatNumber];
    }
    
    [[self textViewNotes] setText:[[[self currentBasket] order] notes]];
    
    // Set default delivery date
    [[self order] setDateRequired:[[NSDate date] mk_dateByAddingDays:1]];
    [[self textFieldDateRequired] setText:[[[self order] dateRequired] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMYYYYSlashed]]];
    
    // No longer a draft, don't bother replacing variables again
    [[self order] setDraft:@(NO)];
    
    [[self switchTradeShowOrder] setOn:[[[self order] tradeShowOrder] boolValue]];
    [[self switchRET] setOn:NO];
    
    [self saveOrderDetails];
    
    //NSString *paymentMethodName = [self paymentMethodNameForId:[self paymentMethodId]];
    //[[self textFieldPaymentMethod] setText:paymentMethodName];
    
    // Commit to database...
    NSError *error = nil;
    [[NSManagedObjectContext MR_defaultContext] save:&error];
    if (!error) {
        NSLog(@"Saved basket/order!");
    } else {
        NSLog(@"Error saving basket/order!");
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self textFieldPEC] setEnabled:[[[PKSession sharedInstance] currentFeedConfig] isIT]];
    [[self labelPEC] setEnabled:[[[PKSession sharedInstance] currentFeedConfig] isIT]];
    [[self textFieldFiscalCode] setEnabled:[[[PKSession sharedInstance] currentFeedConfig] isIT]];
    [[self labelFiscaleCode] setEnabled:[[[PKSession sharedInstance] currentFeedConfig] isIT]];
    [[self switchRET] setEnabled:[[[PKSession sharedInstance] currentFeedConfig] isES]];
    [[self labelRET] setEnabled:[[[PKSession sharedInstance] currentFeedConfig] isES]];
}

- (NSString*) getVatNumber:(NSArray*)addresses {
    if([addresses count] == 1) {
        PKAddress *address = [addresses firstObject];
        if([address vat] && [[address vat] length] >= 1) {
            return [address vat];
        }
    } else if([addresses count] == 2) {
        PKAddress *firstAddress = [addresses firstObject];
        PKAddress *lastAddress = [addresses lastObject];
        if([[[firstAddress vat] lowercaseString] isEqualToString:[[lastAddress vat] lowercaseString]] &&
           [[firstAddress vat] length] >= 1) {
            return [firstAddress vat];
        } else if([[firstAddress vat] length] >= 1 && [[lastAddress vat] length] == 0) {
            return [firstAddress vat];
        } else if([[firstAddress vat] length] == 0 && [[lastAddress vat] length] >= 1) {
            return [lastAddress vat];
        } else if(![[[firstAddress vat] lowercaseString] isEqualToString:[[lastAddress vat] lowercaseString]]
             && ([[firstAddress vat] length] >= 1 || [[lastAddress vat] length] >= 1)) {
            // Two VAT numbers and are both are different
            NSLog(@"Vat numbers are different, ask user to make a choice...");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Which VAT number?", nil)
                                                                           message:NSLocalizedString(@"This customer has two different VAT numbers associated with them, which one would you like to use?", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:[firstAddress vat] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[self textFieldVatNumber] setText:[firstAddress vat]];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:[lastAddress vat] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[self textFieldVatNumber] setText:[lastAddress vat]];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            
            return nil;
        }
    }
    return nil;
}

- (void) displayOrderDetails {
    if([self order]) {
        // Update billing address
        [[self textFieldBillingCompanyName] setText:[[[self order] addressBillingCompanyName] sanitize]];
        [[self textFieldBillingContactName] setText:[[[self order] addressBillingContactName] sanitize]];
        [[self textFieldBillingAddressLine1] setText:[[[self order] addressBillingAddressLine1] sanitize]];
        [[self textFieldBillingAddressLine2] setText:[[[self order] addressBillingAddressLine2] sanitize]];
        [[self textFieldBillingCity] setText:[[[self order] addressBillingCity] sanitize]];
        [[self textFieldBillingState] setText:[[[self order] addressBillingState] sanitize]];
        [[self textFieldBillingCountry] setText:[[[self order] addressBillingCountry] sanitize]];
        [[self textFieldBillingPostcode] setText:[[[self order] addressBillingPostcode] sanitize]];
        
        // Update delivery address
        [[self textFieldDeliveryCompanyName] setText:[[[self order] addressDeliveryCompanyName] sanitize]];
        [[self textFieldDeliveryContactName] setText:[[[self order] addressDeliveryContactName] sanitize]];
        [[self textFieldDeliveryAddressLine1] setText:[[[self order] addressDeliveryAddressLine1] sanitize]];
        [[self textFieldDeliveryAddressLine2] setText:[[[self order] addressDeliveryAddressLine2] sanitize]];
        [[self textFieldDeliveryCity] setText:[[[self order] addressDeliveryCity] sanitize]];
        [[self textFieldDeliveryState] setText:[[[self order] addressDeliveryState] sanitize]];
        [[self textFieldDeliveryCountry] setText:[[[self order] addressDeliveryCountry] sanitize]];
        [[self textFieldDeliveryPostcode] setText:[[[self order] addressDeliveryPostcode] sanitize]];
        
        // Update additional details
        [[self textFieldVatNumber] setText:[[[self order] vatNumber] sanitize]];
        NSLog(@"Payment Method: %@", [[[self order] paymentMethod] sanitize]);
        [[self textFieldPaymentMethod] setText:[[[self order] paymentMethod] sanitize]];
        [self setPaymentMethodId:[[[self order] paymentMethodId] intValue]];
        [[self switchTradeShowOrder] setOn:[[[self order] tradeShowOrder] boolValue]];
        [[self switchRET] setOn:[[[self order] reTax] boolValue]];
        [[self textFieldPurchaseOrderNumber] setText:[[[self order] purchaseOrderNumber] sanitize]];
    
        [[self textFieldEmailAddresses] setText:[[[self order] emailAddresses] sanitize]];
        
        if ([[[[self order] fiscalCode] sanitize] length] >= 1) {
            [[self textFieldFiscalCode] setText:[[[self order] fiscalCode] sanitize]];
        }
        
        if ([[[[self order] pecEmail] sanitize] length] >= 1) {
            [[self textFieldPEC] setText:[[[self order] pecEmail] sanitize]];
        }
        
        // Populate the e-mail if there are no prior values
        if([[[self textFieldEmailAddresses] text] length] == 0) {
            PKCustomer *customer = [PKCustomer findCustomerWithId:[[self currentBasket] customerId]];
            if(customer) {
                if([[[customer email] sanitize] length] >= 1) {
                    [[self textFieldEmailAddresses] setText:[[customer email] sanitize]];
                }
            }
        }
        
        [[self textViewNotes] setText:[[[self order] notes] sanitize]];
        
        if ([[self order] dateRequired]) {
            [[self textFieldDateRequired] setText:[[[self order] dateRequired] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMYYYYSlashed]]];
        } else {
            [[self textFieldDateRequired] setText:@""];
        }
    }
}

- (void) saveOrderDetails {
    // Saves anything in the UI to database
    if ([self order]) {
        // Update the billing details
        [[self order] setAddressBillingCompanyName:[[self textFieldBillingCompanyName] text]];
        [[self order] setAddressBillingContactName:[[self textFieldBillingContactName] text]];
        [[self order] setAddressBillingAddressLine1:[[self textFieldBillingAddressLine1] text]];
        [[self order] setAddressBillingAddressLine2:[[self textFieldBillingAddressLine2] text]];
        [[self order] setAddressBillingCity:[[self textFieldBillingCity] text]];
        [[self order] setAddressBillingState:[[self textFieldBillingState] text]];
        [[self order] setAddressBillingCountry:[[self textFieldBillingCountry] text]];
        [[self order] setAddressBillingPostcode:[[self textFieldBillingPostcode] text]];
        [[self order] setAddressBillingISO:[self isoCodeBilling]];
        
        // Update the shipping details
        [[self order] setAddressDeliveryCompanyName:[[self textFieldDeliveryCompanyName] text]];
        [[self order] setAddressDeliveryContactName:[[self textFieldDeliveryContactName] text]];
        [[self order] setAddressDeliveryAddressLine1:[[self textFieldDeliveryAddressLine1] text]];
        [[self order] setAddressDeliveryAddressLine2:[[self textFieldDeliveryAddressLine2] text]];
        [[self order] setAddressDeliveryCity:[[self textFieldDeliveryCity] text]];
        [[self order] setAddressDeliveryState:[[self textFieldDeliveryState] text]];
        [[self order] setAddressDeliveryCountry:[[self textFieldDeliveryCountry] text]];
        [[self order] setAddressDeliveryPostcode:[[self textFieldDeliveryPostcode] text]];
        [[self order] setAddressDeliveryISO:[self isoCodeDelivery]];
    
        // Update other misc. details
        [[self order] setVatNumber:[[self textFieldVatNumber] text]];
        [[self order] setNotes:[[self textViewNotes] text]];
        [[self order] setPaymentMethodId:@([self paymentMethodId])];
        [[self order] setPaymentMethod:[self paymentMethodNameForId:[self paymentMethodId]]];
        [[self order] setEmailAddresses:[[self textFieldEmailAddresses] text]];
        
        // Save purchase order number and trade show toggle:
        [[self order] setPurchaseOrderNumber:[[self textFieldPurchaseOrderNumber] text]];
        [[self order] setTradeShowOrder:([[self switchTradeShowOrder] isOn]) ? @(1) : @(0)];
        [[self order] setReTax:([[self switchRET] isOn]) ? @(1) : @(0)];
        
        // Populate
        if ([[[[self textFieldFiscalCode] text] sanitize] length] >= 1) {
            [[self order] setFiscalCode:[[[self textFieldFiscalCode] text] sanitize]];
        }
        if ([[[[self textFieldPEC] text] sanitize] length] >= 1) {
            [[self order] setPecEmail:[[[self textFieldPEC] text] sanitize]];
        }
        
        if ([self selectedDeliveryDate]) {
            [[self order] setDateRequired:[self selectedDeliveryDate]];
        }
        
        // Commit to DB!
        NSError *error = nil;
        [[NSManagedObjectContext MR_defaultContext] save:&error];
        if (error) {
            NSLog(@"Error saving order details! %@", [error localizedDescription]);
        }
    }
}

#pragma mark - Text Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField == [self textFieldDeliveryCountry] || textField == [self textFieldBillingCountry]) {
        [self showCountrySelectionFromInput:textField];
        [self dismissKeyboardPressed:nil];
        return NO;
    }
    
    if(textField == [self textFieldPaymentMethod]) {
        [self showPaymentSelection];
        [self dismissKeyboardPressed:nil];
        return NO;
    }
    
    if(textField == [self textFieldDateRequired]) {
        [self showDatePicker];
        [self dismissKeyboardPressed:nil];
        return NO;
    }
    
    if(textField == [self textFieldEmailAddresses]) {
        [self showEmailAddressManager];
        [self dismissKeyboardPressed:nil];
        return NO;
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField == [self textFieldDeliveryCountry] || textField == [self textFieldBillingCountry]) {
        return NO;
    }
    
    if(textField == [self textFieldPaymentMethod]) {
        return NO;
    }
    
    if(textField == [self textFieldDateRequired]) {
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    int offset = 100;
    if (textField == [self textFieldBillingCompanyName] || textField == [self textFieldBillingContactName] || textField == [self textFieldBillingAddressLine1] ||
       textField == [self textFieldDeliveryCompanyName] || textField == [self textFieldDeliveryContactName] || textField == [self textFieldDeliveryAddressLine1]) {
        offset = 60;
    }
    
    if (textField == [self textFieldVatNumber] || textField == [self textFieldPaymentMethod] || textField == [self textFieldDateRequired] || textField == [self textFieldEmailAddresses] || textField == [self textFieldPurchaseOrderNumber]) {
        offset -= [self viewFurtherInfo].frame.origin.y - 40;
    }
    
    [[self scrollView] setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.5)];
    [[self scrollView] setContentOffset:CGPointMake(0, textField.frame.origin.y-offset) animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self validateFields];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [[self scrollView] setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.5)];
    [[self scrollView] setContentOffset:CGPointMake(0, self.view.frame.size.height/2) animated:YES];
}

- (void) dismissKeyboardPressed:(id)sender {
    [[self view] endEditing:YES];
    [[self viewBilling] endEditing:YES];
    [[self viewDelivery] endEditing:YES];
    [[self scrollView] setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+1)];
    [[self scrollView] setContentOffset:CGPointZero animated:YES];
    [self validateFields];
}

- (void) buttonCancelPressed:(id)sender {
    [self saveOrderDetails];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonDuplicatePressedL:(id)sender {
    // Dismiss keyboard
    [self dismissKeyboardPressed:nil];
    
    // Show alert
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Duplicate Address?", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Duplicate", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Copy the text fields
        [UIView animateWithDuration:0.3 animations:^{
            [[self textFieldDeliveryCompanyName] setAlpha:0.0f];
            [[self textFieldDeliveryContactName] setAlpha:0.0f];
            [[self textFieldDeliveryAddressLine1] setAlpha:0.0f];
            [[self textFieldDeliveryAddressLine2] setAlpha:0.0f];
            [[self textFieldDeliveryCity] setAlpha:0.0f];
            [[self textFieldDeliveryState] setAlpha:0.0f];
            [[self textFieldDeliveryCountry] setAlpha:0.0f];
            [[self textFieldDeliveryPostcode] setAlpha:0.0f];
        } completion:^(BOOL finished) {
            
            [[self textFieldDeliveryCompanyName] setText:[[self textFieldBillingCompanyName] text]];
            [[self textFieldDeliveryContactName] setText:[[self textFieldBillingContactName] text]];
            [[self textFieldDeliveryAddressLine1] setText:[[self textFieldBillingAddressLine1] text]];
            [[self textFieldDeliveryAddressLine2] setText:[[self textFieldBillingAddressLine2] text]];
            [[self textFieldDeliveryCity] setText:[[self textFieldBillingCity] text]];
            [[self textFieldDeliveryState] setText:[[self textFieldBillingState] text]];
            [[self textFieldDeliveryCountry] setText:[[self textFieldBillingCountry] text]];
            [[self textFieldDeliveryPostcode] setText:[[self textFieldBillingPostcode] text]];
            
            [UIView animateWithDuration:0.3 animations:^{
                [[self textFieldDeliveryCompanyName] setAlpha:1.0f];
                [[self textFieldDeliveryContactName] setAlpha:1.0f];
                [[self textFieldDeliveryAddressLine1] setAlpha:1.0f];
                [[self textFieldDeliveryAddressLine2] setAlpha:1.0f];
                [[self textFieldDeliveryCity] setAlpha:1.0f];
                [[self textFieldDeliveryState] setAlpha:1.0f];
                [[self textFieldDeliveryCountry] setAlpha:1.0f];
                [[self textFieldDeliveryPostcode] setAlpha:1.0f];
            } completion:^(BOOL finished) {
                [self validateFields];
            }];
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Country Selection

- (void) showCountrySelectionFromInput:(UITextField*)textField {
    // Create country selection table view controller
    PKCountrySelectionTableViewController *countrySelectionTableViewController = [[PKCountrySelectionTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [countrySelectionTableViewController setTextFieldEditing:textField];
    [countrySelectionTableViewController setSelectionDelegate:self];
    
    // Create nav controller, so that we have a nice title
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:countrySelectionTableViewController];
    
    // Show popover
    [self setCurrentPopoverController:[[UIPopoverController alloc] initWithContentViewController:navController]];
    [[self currentPopoverController] presentPopoverFromRect:[textField frame] inView:[textField superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Payment Method

- (void) showPaymentSelection {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    [alertController setTitle:NSLocalizedString(@"Payment Method", nil)];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"30 Days Agreed", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePaymentMethod:NSLocalizedString(@"30 Days Agreed", nil) withId:0];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"30 Days Subject to refs", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePaymentMethod:NSLocalizedString(@"30 Days Subject to refs", nil) withId:1];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Proforma Agreed", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePaymentMethod:NSLocalizedString(@"Proforma Agreed", nil) withId:2];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Payment Method Not Agreed", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePaymentMethod:NSLocalizedString(@"Payment Method Not Agreed", nil) withId:3];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"COD", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updatePaymentMethod:NSLocalizedString(@"COD", nil) withId:4];
    }]];
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    
    // Show as popover
    UIPopoverPresentationController *popoverPresenter = [alertController popoverPresentationController];
    [popoverPresenter setSourceRect:[[self textFieldPaymentMethod] frame]];
    [popoverPresenter setSourceView:[[self textFieldPaymentMethod] superview]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) updatePaymentMethod:(NSString*)method withId:(int)paymentMethodId {
    [[self textFieldPaymentMethod] setText:method];
    [self setPaymentMethodId:paymentMethodId];
    [self validateFields];
    
    if ([[[self textFieldDateRequired] text] length] == 0) {
        [[self textFieldDateRequired] becomeFirstResponder];
    }
}

- (NSString *)paymentMethodNameForId:(int)methodId {
    switch (methodId) {
        default:
        case 0:
            return NSLocalizedString(@"30 Days Agreed", nil);
            break;
        case 1:
            return NSLocalizedString(@"30 Days Subject to refs", nil);
            break;
        case 2:
            return NSLocalizedString(@"Proforma Agreed", nil);
            break;
        case 3:
            return NSLocalizedString(@"Payment Method Not Agreed", nil);
            break;
        case 4:
            return NSLocalizedString(@"COD", nil);
            break;
    }
}

#pragma mark - Date(s)

- (void) showDatePicker {
    if ([self currentPopoverController]) {
        [[self currentPopoverController] dismissPopoverAnimated:NO];
        [self setCurrentPopoverController:nil];
    }
    
    // Create a date picker controller:
    PKDatePickerController *datePickerController = [PKDatePickerController createWithSelectedDate:[self selectedDeliveryDate]
                                                                                      minimumDate:[NSDate date]
                                                                                      maximumDate:[[NSDate date] mk_dateByAddingYears:2]
                                                                                         delegate:self];
    [self setCurrentPopoverController:[[UIPopoverController alloc] initWithContentViewController:[datePickerController withNavigationController]]];
    [[self currentPopoverController] presentPopoverFromRect:[[self textFieldDateRequired] frame]
                                                     inView:[[self textFieldDateRequired] superview]
                                   permittedArrowDirections:UIPopoverArrowDirectionRight
                                                   animated:YES];
}

- (void) didPickDate:(NSDate *)date moveToNextResponder:(BOOL)moveToNextResponder {
    [self setSelectedDeliveryDate:date];
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
    //[dateFormatter setLocale:[NSLocale currentLocale]];
    
    [[self textFieldDateRequired] setText:[date mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMYYYYSlashed]]];
    
    if (moveToNextResponder) {
        [self validateFields];
        if ([[[self textViewNotes] text] length] == 0) {
            [[self textViewNotes] becomeFirstResponder];
        }
    }
}

#pragma mark - Country Picker Delegate

-(void)pkCountrySelectionTableViewController:(PKCountrySelectionTableViewController *)countrySelectionTableViewController didSelectCountry:(PKCountry *)country {
    [[countrySelectionTableViewController textFieldEditing] setText:[country name]];
    [[self currentPopoverController] dismissPopoverAnimated:YES];
    [self setCurrentPopoverController:nil];
    
    if ([countrySelectionTableViewController textFieldEditing] == [self textFieldBillingCountry]) {
        [[self textFieldBillingPostcode] becomeFirstResponder];
        [self setIsoCodeBilling:[country isoCode]];
    } else {
        [[self textFieldDeliveryPostcode] becomeFirstResponder];
        [self setIsoCodeDelivery:[country isoCode]];
    }
    
    if ([country chargeVAT]) {
        NSLog(@"Charge VAT");
    }
}

#pragma mark - Keyboard Tabbing

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // billing and additional info
    if(textField == [self textFieldBillingCompanyName]) {
        return [[self textFieldBillingContactName] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldBillingContactName]) {
        return [[self textFieldBillingAddressLine1] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldBillingAddressLine1]) {
        return [[self textFieldBillingAddressLine2] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldBillingAddressLine2]) {
        return [[self textFieldBillingCity] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldBillingCity]) {
        return [[self textFieldBillingState] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldBillingState]) {
        return [[self textFieldBillingCountry] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldBillingCountry]) {
        return [[self textFieldBillingPostcode] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldBillingPostcode]) {
        return [[self textFieldVatNumber] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldVatNumber]) {
        return [[self textFieldPurchaseOrderNumber] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldPurchaseOrderNumber]) {
        return [[self textFieldEmailAddresses] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldEmailAddresses]) {
        return [[self textFieldPaymentMethod] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldPaymentMethod]) {
        return [[self textFieldDateRequired] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldBillingPostcode]) {
        if([[[self textViewNotes] text] length] != 0) {
            [[self textViewNotes] becomeFirstResponder];
        } else {
            [self dismissKeyboardPressed:nil];
        }
        return NO;
    }
    
    // shipping fields
    if(textField == [self textFieldDeliveryCompanyName]) {
        return [[self textFieldDeliveryContactName] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldDeliveryContactName]) {
        return [[self textFieldDeliveryAddressLine1] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldDeliveryAddressLine1]) {
        return [[self textFieldDeliveryAddressLine2] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldDeliveryAddressLine2]) {
        return [[self textFieldDeliveryCity] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldDeliveryCity]) {
        return [[self textFieldDeliveryState] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldDeliveryState]) {
        return [[self textFieldDeliveryCountry] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldDeliveryCountry]) {
        return [[self textFieldDeliveryPostcode] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldDeliveryPostcode]) {
        return [[self textFieldVatNumber] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldFiscalCode]) {
        return [[self textFieldPEC] becomeFirstResponderIfEmpty];
    } else if(textField == [self textFieldPEC]) {
        return [[self textFieldVatNumber] becomeFirstResponderIfEmpty];
    }
    
    return YES;
}

#pragma mark - Find Address

- (IBAction)buttonFindAddressPressed:(id)sender {
    // End editing
    [self dismissKeyboardPressed:nil];
    
    // Determine which address...
    PKAddressType addressType = PKAddressTypeDelivery;
    if (sender == [self buttonFindBillingAddress]) {
        addressType = PKAddressTypeInvoice;
    }
    
    // Show address picker
    PKAddressesViewController *addressController = [PKAddressesViewController createWithCustomer:[[PKSession sharedInstance] currentCustomer]
                                                                                     addressType:addressType
                                                                               addressesDelegate:self];
    id controller = [addressController withNavigationController];
    [controller setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (void)pkAddressesViewController:(PKAddressesViewController *)controller didSelectAddress:(PKAddress *)address {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self setAddress:address forAddressType:[controller addressType]];
}

- (void) setAddress:(PKAddress *)address forAddressType:(PKAddressType)type {
    if (address) {
        if (type == PKAddressTypeInvoice) {
            [[self textFieldBillingCompanyName] setText:[[address companyName] sanitize]];
            [[self textFieldBillingContactName] setText:[[address contactName] sanitize]];
            [[self textFieldBillingAddressLine1] setText:[[address lineOne] sanitize]];
            [[self textFieldBillingAddressLine2] setText:[[address lineTwo] sanitize]];
            [[self textFieldBillingCity] setText:[[address city] sanitize]];
            [[self textFieldBillingState] setText:[[address state] sanitize]];
            [[self textFieldBillingPostcode] setText:[[address postcode] sanitize]];
            [self setIsoCodeBilling:[[address iso] sanitize]];
            
            [self updateCountryTextField:[self textFieldBillingCountry] withValue:[[address country] sanitize]];
        } else {
            [[self textFieldDeliveryCompanyName] setText:[[address companyName] sanitize]];
            [[self textFieldDeliveryContactName] setText:[[address contactName] sanitize]];
            [[self textFieldDeliveryAddressLine1] setText:[[address lineOne] sanitize]];
            [[self textFieldDeliveryAddressLine2] setText:[[address lineTwo] sanitize]];
            [[self textFieldDeliveryCity] setText:[[address city] sanitize]];
            [[self textFieldDeliveryState] setText:[[address state] sanitize]];
            [[self textFieldDeliveryPostcode] setText:[[address postcode] sanitize]];
            [self setIsoCodeDelivery:[[address iso] sanitize]];
            
            [self updateCountryTextField:[self textFieldDeliveryCountry] withValue:[[address country] sanitize]];
        }
    } else {
        if (type == PKAddressTypeInvoice) {
            [[self textFieldBillingCompanyName] setText:@""];
            [[self textFieldBillingContactName] setText:@""];
            [[self textFieldBillingAddressLine1] setText:@""];
            [[self textFieldBillingAddressLine2] setText:@""];
            [[self textFieldBillingCity] setText:@""];
            [[self textFieldBillingState] setText:@""];
            [[self textFieldBillingPostcode] setText:@""];
            [self setIsoCodeBilling:@""];
            
            [self updateCountryTextField:[self textFieldBillingCountry] withValue:@""];
        } else {
            [[self textFieldDeliveryCompanyName] setText:@""];
            [[self textFieldDeliveryContactName] setText:@""];
            [[self textFieldDeliveryAddressLine1] setText:@""];
            [[self textFieldDeliveryAddressLine2] setText:@""];
            [[self textFieldDeliveryCity] setText:@""];
            [[self textFieldDeliveryState] setText:@""];
            [[self textFieldDeliveryState] setText:@""];
            [[self textFieldDeliveryPostcode] setText:@""];
            [self setIsoCodeDelivery:@""];
            
            [self updateCountryTextField:[self textFieldDeliveryCountry] withValue:@""];
        }
    }
}

- (void) updateCountryTextField:(UITextField*)textField withValue:(NSString*)countryName {
    // If empty string or nil, always set text to have an empty string
    PKCountry *country = nil;
    if(!countryName || [countryName isEqualToString:@""]) {
        [textField setText:@""];
    } else {
        // Search for the country to find the appropriate PKCountry object.
        country = [PKCountry countryWithNameLike:countryName];
        if(country) {
            [textField setText:[country name]];
        } else {
            [textField setText:@""];
        }
    }
    
    // Update the PKCountry object, either to actual value or nil
    if (textField == [self textFieldBillingCountry]) {
        [self setBillingCountry:country];
    } else {
        [self setDeliveryCountry:country];
    }
}

#pragma mark - Email Addresses
 - (void) showEmailAddressManager {
    NSString *currentEmailAddresses =  [[self textFieldEmailAddresses] text];
    PKCustomer *customer = [[PKSession sharedInstance] currentCustomer];
    PKAgent *agent = [PKAgent currentAgent];
    
    EmailAddressTableViewController *emailController = [EmailAddressTableViewController createWithCurrentEmailAddresses:currentEmailAddresses customerEmailAddresses:[customer emailAddresses] agentEmailAddresses:[agent emailAddresses]];
    [emailController setEmailAddresses:[[self textFieldEmailAddresses] text]];
    
//    PKCustomer *customer = [[PKSession sharedInstance] currentCustomer];
//    [emailController setCustomerEmailAddresses:[customer emailAddresses]];
    [emailController setEmailDelegate:self];
    
    UIPopoverController *controller = [[UIPopoverController alloc] initWithContentViewController:[emailController withNavigationController]];
    [controller presentPopoverFromRect:[self textFieldEmailAddresses].frame
                                inView:[[self textFieldEmailAddresses] superview]
              permittedArrowDirections:UIPopoverArrowDirectionLeft
                              animated:YES];
    
}

-(void)emailAddressTableViewController:(EmailAddressTableViewController *)controller didUpdateToEmailAddresses:(NSString *)emailAddresses {
    if(emailAddresses) {
        [[self textFieldEmailAddresses] setText:emailAddresses];
    }
}

#pragma mark - Theme/Style

- (void)applyTheme {
    // Add tap gesture recognizer to cancel the keyboard input
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardPressed:)];
    [[self view] addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardPressed:)];
    [[self viewBilling] addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardPressed:)];
    [[self viewDelivery] addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardPressed:)];
    [[self viewFurtherInfo] addGestureRecognizer:tapGestureRecognizer];
    
    // Set bg color
    [[self view] setBackgroundColor:[UIColor puckatorPrimaryColor]];
    if ([self isQuote]) {
        [[self navigationItem] setTitle:NSLocalizedString(@"Quote Details", nil)];
    } else {
        [[self navigationItem] setTitle:NSLocalizedString(@"Order Details", nil)];
    }
    
    // Localize the strings and theme them!
    [[self labelBillingAddress] setText:NSLocalizedString(@"Billing Address", nil)];
    [[self labelBillingAddress] setFont:[UIFont puckatorContentTitleHeavy]];
    [[self labelBillingAddress] setTextColor:[UIColor puckatorPrimaryColor]];
    
    [[self labelDeliveryAddress] setText:NSLocalizedString(@"Delivery Address", nil)];
    [[self labelDeliveryAddress] setFont:[UIFont puckatorContentTitleHeavy]];
    [[self labelDeliveryAddress] setTextColor:[UIColor puckatorPrimaryColor]];
    
    [[self labelFurtherInfo] setText:NSLocalizedString(@"Further Information", nil)];
    [[self labelFurtherInfo] setFont:[UIFont puckatorContentTitleHeavy]];
    [[self labelFurtherInfo] setTextColor:[UIColor puckatorPrimaryColor]];
    
    // Style the copy button
    [[self buttonCopy] setBackgroundColor:[UIColor puckatorPrimaryColor]];
    [[[self buttonCopy] layer] setCornerRadius:self.buttonCopy.frame.size.width/2];
    [[[self buttonCopy] layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[[self buttonCopy] layer] setBorderWidth:2];
    
    // Theme sections
    [[[self viewBilling] layer] setCornerRadius:6];
    [[[self viewBilling] layer] setBorderWidth:1];
    [[[self viewBilling] layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    [[[self viewDelivery] layer] setCornerRadius:6];
    [[[self viewDelivery] layer] setBorderWidth:1];
    [[[self viewDelivery] layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    [[[self viewFurtherInfo] layer] setCornerRadius:6];
    [[[self viewFurtherInfo] layer] setBorderWidth:1];
    [[[self viewFurtherInfo] layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    // Theme input labels for BILLING
    [[self labelBillingCompanyName] setFont:[UIFont puckatorContentTextBold]];
    [[self labelBillingCompanyName] setTextColor:[UIColor darkGrayColor]];
    [[self labelBillingCompanyName] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Company Name", nil)]];
    
    [[self labelBillingContactName] setFont:[UIFont puckatorContentTextBold]];
    [[self labelBillingContactName] setTextColor:[UIColor darkGrayColor]];
    [[self labelBillingContactName] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Contact Name", nil)]];
    
    [[self labelBillingAddressLine1] setFont:[UIFont puckatorContentTextBold]];
    [[self labelBillingAddressLine1] setTextColor:[UIColor darkGrayColor]];
    [[self labelBillingAddressLine1] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Address", nil)]];
    
    [[self labelBillingCity] setFont:[UIFont puckatorContentTextBold]];
    [[self labelBillingCity] setTextColor:[UIColor darkGrayColor]];
    [[self labelBillingCity] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"City", nil)]];
    
    [[self labelBillingState] setFont:[UIFont puckatorContentTextBold]];
    [[self labelBillingState] setTextColor:[UIColor darkGrayColor]];
    [[self labelBillingState] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"State", nil)]];
    
    [[self labelBillingCountry] setFont:[UIFont puckatorContentTextBold]];
    [[self labelBillingCountry] setTextColor:[UIColor darkGrayColor]];
    [[self labelBillingCountry] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Country", nil)]];
    
    [[self labelBillingPostcode] setFont:[UIFont puckatorContentTextBold]];
    [[self labelBillingPostcode] setTextColor:[UIColor darkGrayColor]];
    [[self labelBillingPostcode] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Postcode", nil)]];
    
    // Theme input labels for SHIPPING
    [[self labelDeliveryCompanyName] setFont:[UIFont puckatorContentTextBold]];
    [[self labelDeliveryCompanyName] setTextColor:[UIColor darkGrayColor]];
    [[self labelDeliveryCompanyName] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Company Name", nil)]];
    
    [[self labelDeliveryContactName] setFont:[UIFont puckatorContentTextBold]];
    [[self labelDeliveryContactName] setTextColor:[UIColor darkGrayColor]];
    [[self labelDeliveryContactName] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Contact Name", nil)]];
    
    [[self labelDeliveryAddressLine1] setFont:[UIFont puckatorContentTextBold]];
    [[self labelDeliveryAddressLine1] setTextColor:[UIColor darkGrayColor]];
    [[self labelDeliveryAddressLine1] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Address", nil)]];
    
    [[self labelDeliveryCity] setFont:[UIFont puckatorContentTextBold]];
    [[self labelDeliveryCity] setTextColor:[UIColor darkGrayColor]];
    [[self labelDeliveryCity] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"City", nil)]];
    
    [[self labelDeliveryState] setFont:[UIFont puckatorContentTextBold]];
    [[self labelDeliveryState] setTextColor:[UIColor darkGrayColor]];
    [[self labelDeliveryState] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"State", nil)]];
    
    [[self labelDeliveryCountry] setFont:[UIFont puckatorContentTextBold]];
    [[self labelDeliveryCountry] setTextColor:[UIColor darkGrayColor]];
    [[self labelDeliveryCountry] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Country", nil)]];
    
    [[self labelDeliveryPostcode] setFont:[UIFont puckatorContentTextBold]];
    [[self labelDeliveryPostcode] setTextColor:[UIColor darkGrayColor]];
    [[self labelDeliveryPostcode] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Postcode", nil)]];
    
    /* Style further info box */
    [[self labelFurtherInfoVatNumber] setFont:[UIFont puckatorContentTextBold]];
    [[self labelFurtherInfoVatNumber] setTextColor:[UIColor darkGrayColor]];
    [[self labelFurtherInfoVatNumber] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"VAT Number", nil)]];
    
    [[self labelFurtherInfoEmailConfirmations] setFont:[UIFont puckatorContentTextBold]];
    [[self labelFurtherInfoEmailConfirmations] setTextColor:[UIColor darkGrayColor]];
    [[self labelFurtherInfoEmailConfirmations] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"E-mail confirmation to", nil)]];
    
    [[self labelFurtherInfoMethodOfPayment] setFont:[UIFont puckatorContentTextBold]];
    [[self labelFurtherInfoMethodOfPayment] setTextColor:[UIColor darkGrayColor]];
    [[self labelFurtherInfoMethodOfPayment] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Method of Payment", nil)]];
    
    [[self labelFurtherInfoDateRequired] setFont:[UIFont puckatorContentTextBold]];
    [[self labelFurtherInfoDateRequired] setTextColor:[UIColor darkGrayColor]];
    [[self labelFurtherInfoDateRequired] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Date Required", nil)]];
    
    [[self labelFurtherInfoNotes] setFont:[UIFont puckatorContentTextBold]];
    [[self labelFurtherInfoNotes] setTextColor:[UIColor darkGrayColor]];
    [[self labelFurtherInfoNotes] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Notes", nil)]];
    
    [[self labelFiscaleCode] setFont:[UIFont puckatorContentTextBold]];
    [[self labelFiscaleCode] setTextColor:[UIColor darkGrayColor]];
    [[self labelFiscaleCode] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Fiscal Number (IT)", nil)]];
    
    [[self labelPEC] setFont:[UIFont puckatorContentTextBold]];
    [[self labelPEC] setTextColor:[UIColor darkGrayColor]];
    [[self labelPEC] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"PEC Email Address (IT)", nil)]];
    
    [[self labelRET] setFont:[UIFont puckatorContentTextBold]];
    [[self labelRET] setTextColor:[UIColor darkGrayColor]];
    [[self labelRET] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"RE Tax (ES)", nil)]];
    
    [[self labelPurchaseOrderNumber] setFont:[UIFont puckatorContentTextBold]];
    [[self labelPurchaseOrderNumber] setTextColor:[UIColor darkGrayColor]];
    [[self labelPurchaseOrderNumber] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Purchase Order Number", nil)]];
    
    [[self labelTradeShowOrder] setFont:[UIFont puckatorContentTextBold]];
    [[self labelTradeShowOrder] setTextColor:[UIColor darkGrayColor]];
    [[self labelTradeShowOrder] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Trade Show Order", nil)]];
    
    // Theme notes!
    [[[self textViewNotes] layer] setCornerRadius:5];
    [[[self textViewNotes] layer] setBorderColor:[HXColor colorWithHexString:@"e6e6e6"].CGColor];
    [[[self textViewNotes] layer] setBorderWidth:1];
    
    // Theme the buttons
    [[self buttonFindBillingAddress] puckatorApplyTheme];
    [[self buttonFindBillingAddress] setTitle:NSLocalizedString(@"Choose", nil) forState:UIControlStateNormal];
    [[self buttonFindDeliveryAddress] puckatorApplyTheme];
    [[self buttonFindDeliveryAddress] setTitle:[[self buttonFindBillingAddress] titleForState:UIControlStateNormal] forState:UIControlStateNormal];
    [[self buttonClearBillingAddress] puckatorApplyTheme];
    [[self buttonClearDeliveryAddress] puckatorApplyTheme];
    
    [[self buttonClearBillingAddress] setHidden:YES];
    [[self buttonClearDeliveryAddress] setHidden:YES];
}

#pragma mark - Server

- (void) submitOrderPressed:(id)sender {
    NSString *title = NSLocalizedString(@"PDF Style", nil);
    NSString *message = NSLocalizedString(@"Which style of PDF would you like to send to the customer?", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [[alertController popoverPresentationController] setBarButtonItem:sender];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Standard Product List", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self submitOrderWithPDFType:@"list"];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Large Product Images", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self submitOrderWithPDFType:@"2X2"];
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

- (void)submitOrderWithPDFType:(NSString *)pdfType {
    // Set the pdf type:
    [[self order] setPdfType:pdfType];
    
    // Save changes
    [self saveOrderDetails];
    
    if ([self validateFields]) {
        // Create buttons
        RIButtonItem *buttonCancel = [RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", nil) action:nil];
        
        RIButtonItem *buttonSend = [RIButtonItem itemWithLabel:NSLocalizedString(@"Send", nil) action:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                // Get the current basket:
                PKBasket *basket = [self currentBasket];
                
                // Update the status of the basket:
                //[basket setStatus:[self isQuote] ? PKBasketStatusQuote : PKBasketStatusComplete shouldSave:YES];
                
                // Set the basket status as in error for now...
                // it will be set to complete or quoted once we hear back from the server:
                [basket setStatus:PKBasketStatusError shouldSave:YES];
                
                // Serialize to XML and push to server
                NSString *xml = [basket transformToOrderXmlStringIsQuote:[self isQuote]];
                [basket saveOrderXml:xml];
                
                // Update the current customer:
                PKCustomer *customer = [[PKSession sharedInstance] currentCustomer];
                if ([customer isCoreDataObject]) {
                    PKLocalCustomer *localCustomer = [customer coreDataCustomer];
                    if (localCustomer) {
                        [localCustomer saveAddressesFromBasket:[self currentBasket]];
                    }
                }
                
                // Clear the current customer:
                if ([PKBasket clearSessionBasket]) {
                    [[PKSession sharedInstance] setCurrentCustomer:nil andCurrencyCode:nil];
                }
                
                if ([self delegate] && [[self delegate] respondsToSelector:@selector(orderDetailsViewController:didSentOrder:)]) {
                    // Tell preview controller that an order is about to be sent...
                    [[self delegate] orderDetailsViewController:self didSentOrder:YES];
                    
                    // Dismiss the current view controller
                    [self dismissViewControllerAnimated:YES completion:^{
                        // Show the sync controller
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncOrderRequest object:nil];
                    }];
                } else {
                    NSLog(@"Error - delegate does not respond to orderDetailsViewController:didSentOrder:");
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }];
        
        // Show confirmation
        NSString *orderType = [([self isQuote] ? NSLocalizedString(@"quote", nil) : NSLocalizedString(@"order", nil)) lowercaseString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to send this %@?", @"Used to confirm with the user whether they want to send either an order or a quote. E.g. 'Are you sure you want to send this quote?'"), orderType]
                                                        message:nil
                                               cancelButtonItem:buttonCancel
                                               otherButtonItems:buttonSend, nil];
        [alert show];
    }
}

#pragma mark - Validate Fields

- (void)displayErrorTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL) validateFields {
    __block BOOL isValid = YES;
    
    // Validate the email addresses:
    if ([[[self textFieldEmailAddresses] text] length] == 0) {
        NSString *title = NSLocalizedString(@"No E-mail Address", nil);
        NSString *message = NSLocalizedString(@"Please provide at least one valid e-mail address before trying to submit the order.", nil);
        [self displayErrorTitle:title message:message];
        return NO;
    } else {
        
        // Validate the individual email addresses:
        __block NSString *invalidEmailAddress = nil;
        NSArray<NSString *> *emailAddresses = [[[self textFieldEmailAddresses] text] componentsSeparatedByString:@";"];
        [emailAddresses enumerateObjectsUsingBlock:^(NSString * _Nonnull emailAddress, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([emailAddress length] != 0 && ![emailAddress mk_isValidEmail]) {
                invalidEmailAddress = emailAddress;
                isValid = NO;
                *stop = YES;
            }
        }];
        
        if (!isValid && [invalidEmailAddress length] != 0) {
            NSString *title = NSLocalizedString(@"Invalid E-mail Address", nil);
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Sorry, '%@' is not a valid e-mail address, please fix this issue before trying to submit the order again.", nil), invalidEmailAddress];
            [self displayErrorTitle:title message:message];
            return NO;
        }
    }
    
    // Validate the notes:
    int notesMaxLength = 180;
    __block NSString *notes = [[self textViewNotes] text];
    if ([notes length] > notesMaxLength) {
        UIAlertAction *actionDismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            notes = [notes substringToIndex:notesMaxLength];
            [[self textViewNotes] setText:notes];
        }];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notes Warning" message:[NSString stringWithFormat:NSLocalizedString(@"Order notes can only be %d characters in length. Your notes have been cropped to this maximum length.\n\nPlease check your notes to make sure they are still informative before attempting to send this order again.", nil), notesMaxLength] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:actionDismiss];
        [self presentViewController:alertController animated:YES completion:^{
        }];
        return NO;
    }
    
    PKCustomer *customer = [[PKSession sharedInstance] currentCustomer];
    
    // Check for existing customer:
    if (![customer isCoreDataObject]) {
        if ([self isQuote]) {
            // Nothing is compulsory for existing customers and quotes:
            return YES;
        } else {
            return [[self textFieldPaymentMethod] isValid];
        }
    }
    
    // Loop billing fields
    for (FSTextField *field in [[self viewBilling] subviews]) {
        // Skip the state/county fields:
        if (field == [self textFieldBillingState]) {
            continue;
        }
        
        // Validate the other fields:
        if ([field isKindOfClass:[FSTextField class]]) {
            if(![field isValid]) {
                isValid = NO;
            }
        }
    }
    
    // Loop billing fields
    for (FSTextField *field in [[self viewDelivery] subviews]) {
        // Skip the state/county fields:
        if (field == [self textFieldDeliveryState]) {
            continue;
        }
        
        if ([field isKindOfClass:[FSTextField class]]) {
            if(![field isValid]) {
                isValid = NO;
            }
        }
    }
    
    // Loop billing fields
    for (FSTextField *field in [[self viewFurtherInfo] subviews]) {
        // Skip the payment method for quotes:
        if ([self isQuote] && field == [self textFieldPaymentMethod]) {
            continue;
        }
        
        if ([field isKindOfClass:[FSTextField class]]) {
            if(![field isValid]) {
                isValid = NO;
            }
        }
    }
    
    return isValid;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PKDatePickerControllerDelegate Methods

- (void)pkDatePicker:(PKDatePickerController *)datePickerController didSelectDate:(NSDate *)date isDone:(BOOL)done {
    if (done) {
        if ([self currentPopoverController]) {
            [[self currentPopoverController] dismissPopoverAnimated:NO];
            [self setCurrentPopoverController:nil];
        } else {
            [datePickerController dismissViewControllerAnimated:NO completion:^{
            }];
        }
    }

    [self didPickDate:date moveToNextResponder:done];
}

#pragma mark -

@end
