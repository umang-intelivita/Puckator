//
//  PKProductCell.h
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKProductCellSmall.h"
#import "PKKeyPad.h"
#import "PKCustomerSelectionDelegate.h"
#import "PKQuantityView.h"

#define kPKProductCellPreviousPriceTag  -1

@interface PKProductCellMedium : PKProductCellSmall <PKQuantityViewDelegate>

- (void)updateOrderAmountUI:(PKBasketItem *)basketItem;

@end
