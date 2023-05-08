//
//  PKCustomerViewController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 10/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKCustomersViewController.h"
#import "UITabBarController+Puckator.h"
#import "FSBaseTableViewController.h"
#import "PKBasketTableViewController.h"

typedef enum : NSUInteger {
    PKCustomerViewControllerOrderTypeCustomer,
    PKCustomerViewControllerOrderTypeRecent,
    PKCustomerViewControllerOrderTypeOpen
} PKCustomerViewControllerOrderType;

@class PKCustomer;

@interface PKCustomerViewController : FSBaseTableViewController <PKCustomerSelectionDelegate, UITableViewDataSource, UITableViewDelegate, PKBasketTableViewControllerDelegate>

@property (strong, nonatomic) PKCustomer *customer;

+ (instancetype)createWithCustomer:(PKCustomer *)customer;
+ (instancetype)createWithOrders:(NSArray *)orders withOrderType:(PKCustomerViewControllerOrderType)orderType;

@end
