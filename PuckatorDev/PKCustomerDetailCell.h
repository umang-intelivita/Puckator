//
//  PKCustomerDetailCell.h
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKCustomer;

@interface PKCustomerDetailCell : UITableViewCell

- (void)setupWithCustomer:(PKCustomer *)customer;

@end