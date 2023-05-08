//
//  PKBasketCreateTableViewCell.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasketCreateTableViewCell.h"

@interface PKBasketCreateTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;

@end

@implementation PKBasketCreateTableViewCell

- (void)awakeFromNib {
    [[self labelMessage] setText:NSLocalizedString(@"Create a new order", nil)];
}

- (void)setupCreateItemModeForBasket:(PKBasket *)basket {
    [[self labelMessage] setText:NSLocalizedString(@"Add products to this order", nil)];
    [[self imageViewIcon] setImage:[UIImage imageNamed:@"TabBasketCreate"]];
}

@end