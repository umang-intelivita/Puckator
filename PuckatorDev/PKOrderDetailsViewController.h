//
//  OrderDetailsViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 13/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSBaseViewController.h"
#import "PKCountrySelectionTableViewController.h"
#import "PKAddressesViewController.h"
#import "EmailAddressTableViewController.h"
#import "PKDatePickerController.h"

@class PKOrderDetailsViewController;
@protocol OrderDetailsDelegate <NSObject>
@required
- (void) orderDetailsViewController:(PKOrderDetailsViewController*)orderDetails didSentOrder:(BOOL)didSendOrder;
@end

@interface PKOrderDetailsViewController : FSBaseViewController <UITextFieldDelegate, PKCountrySelectionDelegate, UITextViewDelegate, PKAddressesViewControllerDelegate, EmailAddressDelegate, PKDatePickerControllerDelegate>

@property (nonatomic, assign) id<OrderDetailsDelegate> delegate;
@property (nonatomic, assign) BOOL isQuote;
@property (nonatomic, strong) PKBasket *basket;

#pragma mark - Validate Fields
- (BOOL) validateFields;

@end
