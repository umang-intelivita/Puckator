//
//  PKCreateCustomerViewController.h
//  Puckator
//
//  Created by Luke Dixon on 05/08/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSBaseTableViewController.h"
#import "PKCustomerSelectionDelegate.h"

@interface PKCreateCustomerViewController : UITableViewController

@property (assign, nonatomic) id<PKCustomerSelectionDelegate> delegate;

@end