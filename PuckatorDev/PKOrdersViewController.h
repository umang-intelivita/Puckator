//
//  PKOrdersViewController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKInvoice.h"

@interface PKOrdersViewController : UITableViewController

+ (instancetype)createWithCustomer:(PKCustomer *)customer;

@end