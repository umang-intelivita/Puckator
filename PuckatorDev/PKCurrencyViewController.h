//
//  PKCurrenciesViewController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSBaseTableViewController.h"
#import "PKCustomerSelectionDelegate.h"

@class PKLocalCustomer;
@class PKCustomer;

@interface PKCurrencyViewController : FSBaseTableViewController

+ (instancetype)createWithCustomer:(PKCustomer *)customer delegate:(id<PKCustomerSelectionDelegate>)delegate;
+ (instancetype)createWithCustomer:(PKCustomer *)customer delegate:(id<PKCustomerSelectionDelegate>)delegate orderCopyMode:(BOOL)orderCopyMode;

@end
