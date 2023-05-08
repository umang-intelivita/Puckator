//
//  PKOrderHistoryCell.h
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKInvoice;

@interface PKOrderHistoryCell : UITableViewCell

- (void)setupWithInvoice:(PKInvoice *)invoice;
- (void)setupWithBasket:(PKBasket *)basket;
- (void)setupWithInvoiceOrBasket:(id)object;

@end