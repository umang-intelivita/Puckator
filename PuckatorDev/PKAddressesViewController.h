//
//  PKAddressesViewController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSBaseTableViewController.h"
#import "PKCustomerSelectionDelegate.h"
typedef enum : NSUInteger {
    PKAddressTypeInvoice,
    PKAddressTypeDelivery
} PKAddressType;

@class PKCustomer;
@class PKAddress;
@class PKAddressesViewController;

@protocol PKAddressesViewControllerDelegate <NSObject>
@optional
- (void) pkAddressesViewController:(PKAddressesViewController*)controller didSelectAddress:(PKAddress*)address;
@end

@interface PKAddressesViewController : FSBaseTableViewController

@property (assign, nonatomic) PKAddressType addressType;

+ (instancetype)createWithCustomer:(PKCustomer *)customer addressType:(PKAddressType)addressType delegate:(id<PKCustomerSelectionDelegate>)delegate; // legacy
+ (instancetype)createWithCustomer:(PKCustomer *)customer addressType:(PKAddressType)addressType addressesDelegate:(id<PKAddressesViewControllerDelegate>)delegate; // used in order details view

@end