//
//  PKAddressesViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKAddressesViewController.h"
#import "PKCurrencyViewController.h"
#import "PKCustomer.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"
#import "UIButton+Puckator.h"
#import "PKAddress.h"

@interface PKAddressesViewController ()

@property (assign, nonatomic) PKCustomer *customer;
@property (strong, nonatomic) NSArray *addresses;
@property (weak, nonatomic) id<PKCustomerSelectionDelegate> delegate;
@property (nonatomic, weak) id<PKAddressesViewControllerDelegate> addressesDelegate;

@end

@implementation PKAddressesViewController

#pragma mark - Constructor Methods

+ (instancetype)createWithCustomer:(PKCustomer *)customer addressType:(PKAddressType)addressType delegate:(id<PKCustomerSelectionDelegate>)delegate {
    PKAddressesViewController *addressesViewController = [[PKAddressesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [addressesViewController setAddressType:addressType];
    [addressesViewController setCustomer:customer];
    [addressesViewController setDelegate:delegate];
    [addressesViewController setupUI];
    return addressesViewController;
}

+ (instancetype)createWithCustomer:(PKCustomer *)customer addressType:(PKAddressType)addressType addressesDelegate:(id<PKAddressesViewControllerDelegate>)delegate {
    PKAddressesViewController *addressesViewController = [[PKAddressesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [addressesViewController setAddressType:addressType];
    [addressesViewController setCustomer:customer];
    [addressesViewController setAddressesDelegate:delegate];
    [addressesViewController setupUI];
    return addressesViewController;
}

#pragma mark - Private Methods

- (void)setupUI {
    // Setup the title:
    switch ([self addressType]) {
        case PKAddressTypeInvoice:
            [self setTitle:NSLocalizedString(@"Billing Address", nil)];
            break;
        case PKAddressTypeDelivery:
            [self setTitle:NSLocalizedString(@"Delivery Address", nil)];
            break;
        default:
            [self setTitle:NSLocalizedString(@"Select Address", nil)];
            break;
    }
    
    // Add back button
    UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPressCancel:)];
    [[self navigationItem] setLeftBarButtonItem:buttonCancel];
    
    [self setAddresses:[[self customer] addresses]];
    [[self tableView] reloadData];
    
    // Add a clear button if in address selection mode
    if([self addressesDelegate]) {
        UIBarButtonItem *buttonClear = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil)
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(buttonClearPressed:)];
        [[self navigationItem] setRightBarButtonItem:buttonClear];
    }
}

#pragma mark - Public Methods

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([[self addresses] count] + 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Get the address:
    PKAddress *address = [[self addresses] objectAtIndex:([indexPath row] - 0)];
//    NSLog(@"Address: %@", address);
    [[cell textLabel] setNumberOfLines:0];
    [[cell textLabel] setText:[address multiLineAddress]];
    [[cell textLabel] setFont:[UIFont puckatorContentText]];
    
    // Create an assessory button if needed
    if(![cell accessoryView]) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setUserInteractionEnabled:NO];
        [button setFrame:CGRectMake(0, 0, 100, 50)];
        [button setTitle:NSLocalizedString(@"Select", nil) forState:UIControlStateNormal];
        [button puckatorApplyTheme];
        
        [cell setAccessoryView:button];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 192;
}

- (void) buttonClearPressed:(id)sender {
    if([self addressesDelegate]) {
        if([[self addressesDelegate] respondsToSelector:@selector(pkAddressesViewController:didSelectAddress:)]) {
            [[self addressesDelegate] pkAddressesViewController:self didSelectAddress:nil];
        }
    }
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self addressesDelegate]) {
        
        // Call the delgate and pass back the selected address...
        PKAddress *selectedAddress = [[self addresses] objectAtIndex:([indexPath row])];
        if([[self addressesDelegate] respondsToSelector:@selector(pkAddressesViewController:didSelectAddress:)]) {
            [[self addressesDelegate] pkAddressesViewController:self didSelectAddress:selectedAddress];
        }
        
    } else {
        if ([self addressType] == PKAddressTypeInvoice) {
            PKAddressesViewController *addressesViewController = [PKAddressesViewController createWithCustomer:[self customer] addressType:PKAddressTypeDelivery delegate:[self delegate]];
            [[self navigationController] pushViewController:addressesViewController animated:YES];
        } else {
            PKCurrencyViewController *currencyViewController = [PKCurrencyViewController createWithCustomer:[self customer] delegate:[self delegate]];
            [[self navigationController] pushViewController:currencyViewController animated:YES];
        }
    }
}

#pragma mark - Cancel

- (void) didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

@end
