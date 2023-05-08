//
//  CustomersViewController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FSBaseTableViewController.h"
#import "PKCustomerSelectionDelegate.h"
#import "PKInvoiceLine.h"
#import "PKMapViewController.h"

typedef enum : NSUInteger {
    PKCustomersViewControllerModeView,
    PKCustomersViewControllerModeSelect,
    PKCustomersViewControllerModeCopying
} PKCustomersViewControllerMode;

@interface PKCustomersViewController : FSBaseTableViewController <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UINavigationBarDelegate, MKMapViewDelegate>

+ (instancetype)createWithMode:(PKCustomersViewControllerMode)mode;
+ (instancetype)createWithMode:(PKCustomersViewControllerMode)mode delegate:(id<PKCustomerSelectionDelegate>)delegate;

@property (strong, nonatomic) PKCustomer *customer;

@end
