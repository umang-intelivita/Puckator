//
//  PKQuantityView.h
//  PuckatorDev
//
//  Created by Luke Dixon on 15/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKKeyPad.h"
#import "PKCustomerSelectionDelegate.h"

@class PKQuantityView;

@protocol PKQuantityViewDelegate<NSObject>

- (void)pkQuantityView:(PKQuantityView *)quantityView addedBasketItem:(PKBasketItem *)basketItem;

@end

IB_DESIGNABLE
@interface PKQuantityView : UIView <UITextFieldDelegate, PKKeyPadDelegate, PKCustomerSelectionDelegate>

@property (weak, nonatomic) id<PKQuantityViewDelegate> delegate;

#pragma mark - Public Methods

- (void)setProduct:(PKProduct *)product andDelegate:(id<PKQuantityViewDelegate>)delegate;
- (void)updateWithProductPrice:(PKProductPrice *)productPrice;
- (void)updateWithQuantity:(NSNumber *)quantity;
- (void)updatePrice:(NSNumber *)price quantity:(NSNumber *)quantity;

@end
