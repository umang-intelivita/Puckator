//
//  PKBasketStandardHeaderViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasketStandardHeaderViewController.h"
#import "PKSession.h"
#import "PKCustomer.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"
#import <MKFoundationKit/MKFoundationKit.h>
#import "PKOrder.h"
#import "PKBasket+Operations.h"
#import "PKOrder+Operations.h"

@interface PKBasketStandardHeaderViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonWholesale;
@property (weak, nonatomic) IBOutlet UIButton *buttonMidPrice;
@property (weak, nonatomic) IBOutlet UIButton *buttonCarton;
@property (weak, nonatomic) IBOutlet UILabel *labelCustomerName;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonSearch;
@property (weak, nonatomic) IBOutlet UILabel *labelTitleCustomer;
@property (weak, nonatomic) IBOutlet UILabel *labelTitleOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *labelInvoiceAddressTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelInvoiceAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryAddressTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryAddress;
@property (weak, nonatomic) IBOutlet UIButton *buttonZero;
@property (weak, nonatomic) IBOutlet UIButton *buttonDiscount;

@end

@implementation PKBasketStandardHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Localization:
    [[self labelTitleCustomer] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Customer", nil)]];
    [[self labelDeliveryAddressTitle] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Delivery Address", nil)]];
    [[self labelInvoiceAddressTitle] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Invoice Address", nil)]];
    [[self labelTitleOrderDate] setText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"Order Date", nil)]];
    
    [self style];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self loadDetails];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDetails];
}

- (void) style {
    // Set the bg color
    [[self view] setBackgroundColor:[UIColor puckatorPrimaryColorAccent]];
    
//    // Style the quick add button
//    [[[self buttonSearch] layer] setCornerRadius:5];
//    [[[self buttonSearch] layer] setBorderColor:[UIColor whiteColor].CGColor];
//    [[[self buttonSearch] layer] setBorderWidth:1];
//    [[self buttonSearch] setBackgroundColor:[UIColor puckatorPrimaryColor]];
//    [[self buttonSearch] setAttributedTitle:nil forState:UIControlStateNormal];
    [[self buttonSearch] setTitle:NSLocalizedString(@"Quick Add", nil) forState:UIControlStateNormal];
  
//    // Design the text for the search button
//    NSMutableAttributedString *attributedSearchText = [[NSMutableAttributedString alloc] init];
//    [attributedSearchText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Quick", nil) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-MediumItalic" size:18], NSForegroundColorAttributeName:[UIColor whiteColor]}]];
//    [attributedSearchText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Add", nil)] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Medium" size:18], NSForegroundColorAttributeName:[UIColor whiteColor]}]];
//    [[self buttonSearch] setAttributedTitle:attributedSearchText forState:UIControlStateNormal];
    
//    // Style W button
//    [[[self buttonWholesale] layer] setCornerRadius:5];
//    [[[self buttonWholesale] layer] setBorderColor:[UIColor whiteColor].CGColor];
//    [[[self buttonWholesale] layer] setBorderWidth:1];
//    [[self buttonWholesale] setBackgroundColor:[UIColor puckatorPrimaryColor]];
//    [[[self buttonWholesale] titleLabel] setFont:[UIFont puckatorContentTitle]];
//
//    // Style M button
//    [[[self buttonMidPrice] layer] setCornerRadius:5];
//    [[[self buttonMidPrice] layer] setBorderColor:[UIColor whiteColor].CGColor];
//    [[[self buttonMidPrice] layer] setBorderWidth:1];
//    [[self buttonMidPrice] setBackgroundColor:[UIColor puckatorPrimaryColor]];
//    [[[self buttonMidPrice] titleLabel] setFont:[UIFont puckatorContentTitle]];
//
//    // Style W button
//    [[[self buttonCarton] layer] setCornerRadius:5];
//    [[[self buttonCarton] layer] setBorderColor:[UIColor whiteColor].CGColor];
//    [[[self buttonCarton] layer] setBorderWidth:1];
//    [[self buttonCarton] setBackgroundColor:[UIColor puckatorPrimaryColor]];
//    [[[self buttonCarton] titleLabel] setFont:[UIFont puckatorContentTitle]];
    
    [self styleButton:[self buttonZero]];
    [self styleButton:[self buttonDiscount]];
    [self styleButton:[self buttonWholesale]];
    [self styleButton:[self buttonMidPrice]];
    [self styleButton:[self buttonCarton]];
    [self styleButton:[self buttonSearch]];

    // Style headers
    [[self labelTitleCustomer] setTextColor:[UIColor whiteColor]];
    [[self labelTitleOrderDate] setTextColor:[UIColor whiteColor]];
//    [[self labelTitleCustomer] setFont:[UIFont puckatorContentTextBold]];
//    [[self labelTitleOrderDate] setFont:[UIFont puckatorContentTextBold]];
//    [[self labelCustomerName] setFont:[UIFont puckatorContentText]];
//    [[self labelOrderDate] setFont:[UIFont puckatorContentText]];
}

- (void)styleButton:(UIButton *)button {
    [[button layer] setCornerRadius:5];
    [[button layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[button layer] setBorderWidth:1];
    [button setBackgroundColor:[UIColor puckatorPrimaryColor]];
    [[button titleLabel] setFont:[UIFont puckatorContentTitle]];
}

- (void)loadDetails {
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkBasketStandardHeaderViewController:requestedBasketObject:)]) {
        id object = [[self delegate] pkBasketStandardHeaderViewController:self requestedBasketObject:YES];
        
        PKBasket *basket = [object isKindOfClass:[PKBasket class]] ? object : nil;
        PKInvoice *invoice = [object isKindOfClass:[PKInvoice class]] ? object : nil;;
        
        if (basket) {
            // Load the customer - rushed job, due to meeting in 30 mins...!
            PKCustomer *customer = [PKCustomer findCustomerWithId:[basket customerId]];
            
            if (!customer) {
                [[self labelCustomerName] setText:NSLocalizedString(@"Customer not found", nil)];
            } else {
                [[self labelCustomerName] setText:[customer companyNameWithSageId]];
                
//                if (![basket order]) {
//                    [[self labelCustomerName] setText:NSLocalizedString(@"Order is missing", nil)];
//                } else {
//                    [[self labelCustomerName] setText:[[basket order] addressBillingCompanyName]];
//                }
            }
            
            // Display the date:
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [[self labelOrderDate] setText:[dateFormatter stringFromDate:[basket createdAt]]];
            
            [[self labelDeliveryAddress] setHidden:YES];
            [[self labelDeliveryAddressTitle] setHidden:YES];
            
            // Check the order for valid delivery address:
            PKAddress *address = [[basket order] deliveryAddress];
            if (!address) {
                // Attempt to get the delivery address:
                address = [customer deliveryAddress];
            }
            
            if (address) {
                [[self labelInvoiceAddressTitle] setText:[NSLocalizedString(@"Delivery Address", nil) stringByAppendingString:@":"]];
                [[self labelInvoiceAddress] setText:[address multiLineAddress]];
            } else {
                // Delivery address is missing, therefore attempt to get
                // the invoice address:
                address = [customer invoiceAddress];
                
                // Display the invoice address is found:
                if (address) {
                    [[self labelInvoiceAddressTitle] setText:[NSLocalizedString(@"Invoice Address", nil) stringByAppendingString:@":"]];
                    [[self labelInvoiceAddress] setText:[address multiLineAddress]];
                } else {
                    // No address found, therefore, hide the labels:
                    [[self labelInvoiceAddress] setHidden:YES];
                    [[self labelInvoiceAddressTitle] setHidden:YES];
                }
            }
            
            [[self labelCustomerName] setFrame:CGRectMake([[self labelCustomerName] frame].origin.x,
                                                          [[self labelCustomerName] frame].origin.y,
                                                          [[self view] frame].size.width,
                                                          [[self labelCustomerName] frame].size.height)];
            
            // Style the buttons etc:
            if ([basket status] == PKBasketStatusOpen) {
                [[self buttonCarton] setEnabled:YES];
                [[self buttonCarton] setAlpha:1.0f];
                [[self buttonWholesale] setEnabled:YES];
                [[self buttonWholesale] setAlpha:1.0f];
                [[self buttonMidPrice] setEnabled:YES];
                [[self buttonMidPrice] setAlpha:1.0f];
                [[self buttonZero] setEnabled:YES];
                [[self buttonZero] setAlpha:1.0f];
            } else {
                [[self buttonCarton] setHidden:YES];
                [[self buttonWholesale] setHidden:YES];
                [[self buttonMidPrice] setHidden:YES];
                [[self buttonSearch] setHidden:YES];
                [[self buttonZero] setHidden:YES];
            }
        } else if (invoice) {
            PKCustomer *customer = [PKCustomer findCustomerWithSageId:[invoice sageId]];
            
            [[self labelCustomerName] setText:[customer companyNameWithSageId]];
            
            [[self labelOrderDate] setText:[invoice formattedInvoiceDate]];
            
            [[self labelInvoiceAddress] setText:[[invoice address] multiLineAddress]];
            [[self labelInvoiceAddress] sizeToFit];
            [[self labelInvoiceAddress] setFrame:CGRectMake([[self labelInvoiceAddress] frame].origin.x,
                                                            [[self labelInvoiceAddress] frame].origin.y,
                                                            [[self labelInvoiceAddress] frame].size.width,
                                                            [[self labelInvoiceAddress] frame].size.height)];
            
            [[self labelDeliveryAddress] setText:[[invoice deliveryAddress] multiLineAddress]];
            [[self labelDeliveryAddress] sizeToFit];
            [[self labelDeliveryAddress] setFrame:CGRectMake([[self labelDeliveryAddress] frame].origin.x,
                                                             [[self labelDeliveryAddress] frame].origin.y,
                                                             [[self labelDeliveryAddress] frame].size.width,
                                                             [[self labelDeliveryAddress] frame].size.height)];
            
            [[self buttonCarton] setHidden:YES];
            [[self buttonWholesale] setHidden:YES];
            [[self buttonMidPrice] setHidden:YES];
            [[self buttonSearch] setHidden:YES];
            [[self buttonZero] setHidden:YES];
        } else {
            [[self labelCustomerName] setText:NSLocalizedString(@"Customer not selected", nil)];
            [[self labelOrderDate] setText:@"-"];
            
            [[self buttonCarton] setEnabled:NO];
            [[self buttonCarton] setAlpha:0.25f];
            [[self buttonWholesale] setEnabled:NO];
            [[self buttonWholesale] setAlpha:0.25f];
            [[self buttonMidPrice] setEnabled:NO];
            [[self buttonMidPrice] setAlpha:0.25f];
            [[self buttonZero] setEnabled:NO];
            [[self buttonZero] setAlpha:0.25f];
        }
    } else {
        [[self labelCustomerName] setText:@"WARNING - DELEGATE NOT RESPONDING!"];
        [[self labelOrderDate] setText:@"-"];
    }
}

- (IBAction)buttonSearchPressed:(id)sender {
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkBasketStandardHeaderViewController:didPressSearchButton:)]) {
        [[self delegate] pkBasketStandardHeaderViewController:self didPressSearchButton:YES];
    }
}
- (IBAction)buttonPressed:(id)sender {
    NSString *elementName = nil;
    if (sender == [self buttonWholesale]) {
        elementName = @"wholesale";
    } else if (sender == [self buttonCarton]) {
        elementName = @"carton";
    } else if (sender == [self buttonMidPrice]) {
        elementName = @"midPrice";
    } else if (sender == [self buttonZero]) {
        elementName = @"zeroPrice";
    } else if (sender == [self buttonDiscount]) {
        elementName = @"displayDiscount";
    }
 
    // Inform the delegate
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkBasketStandardHeaderViewController:didInteractWithElementName:)]) {
        [[self delegate] pkBasketStandardHeaderViewController:self didInteractWithElementName:elementName];
    } else {
        NSLog(@"Delegate is not responding in PKBasketStandardHeaderViewController!");
    }
}

- (id)elementForName:(NSString *)name {
    if ([name isEqualToString:@"wholesale"]) {
        return [self buttonWholesale];
    } else if ([name isEqualToString:@"carton"]) {
        return [self buttonCarton];
    } else if ([name isEqualToString:@"midPrice"]) {
        return [self buttonMidPrice];
    } else if ([name isEqualToString:@"zeroPrice"]) {
        return [self buttonZero];
    } else if ([name isEqualToString:@"displayDiscount"]) {
        return [self buttonDiscount];
    }
    return nil;
}

@end
