//
//  PKProductPricesView.h
//  PuckatorDev
//
//  Created by Luke Dixon on 09/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKProductPriceView.h"

@interface PKProductPricesView : UIView

#pragma mark - Constructor Methods
+ (instancetype)createWithProduct:(PKProduct *)product delegate:(id<PKProductPriceViewDelegate>)delegate frame:(CGRect)frame;
- (void)updateProduct:(PKProduct *)product;

@end