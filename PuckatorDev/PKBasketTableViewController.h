//
//  PKBasketTableViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 14/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBaseTableViewController.h"
#import "PKBasketItemTableViewCell.h"
#import "PKKeyPad.h"
#import "PKCustomerSelectionDelegate.h"
#import "PKCustomersViewController.h"
#import "PKGenericTableViewController.h"
#import "PKOrderDetailsViewController.h"
#import "PKBasketStandardHeaderViewController.h"
#import "PKBasketCalculationTableViewCell.h"


typedef void(^FSGetItemsBlock)(NSArray *items);

typedef enum : NSUInteger {
    PKBasketTableViewControllerModeEmpty,
    PKBasketTableViewControllerModeBasket,
    PKBasketTableViewControllerModeInvoice
} PKBasketTableViewControllerMode;

@class PKBasketTableViewController;

@protocol PKBasketTableViewControllerDelegate<NSObject>
- (void)pkBasketTableViewController:(PKBasketTableViewController *)basketTableViewController didOpenBasket:(PKBasket *)basket;
@end

@interface PKBasketTableViewController : FSBaseTableViewController <PKBasketItemCellDelegate, PKKeyPadDelegate, PKCustomerSelectionDelegate, PKGenericTableDelegate, OrderDetailsDelegate, PKBasketStandardDelegate, PKBasketCalculatonCellDelegate>

@property (weak, nonatomic) id<PKBasketTableViewControllerDelegate> delegate;

/**
 *  Create a new controller
 *
 *  @return A new instance of the controller
 */
+ (instancetype)createController;

+ (instancetype)createWithBasket:(PKBasket *)basket delegate:(id<PKBasketTableViewControllerDelegate>)delegate;
+ (instancetype)createWithInvoice:(PKInvoice *)invoice delegate:(id<PKBasketTableViewControllerDelegate>)delegate;

@end
