//
//  PKProductHistoryView.h
//  PuckatorDev
//
//  Created by Luke Dixon on 28/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKProductHistoryView : UIView <UITableViewDataSource, UITableViewDelegate>

#pragma mark - Constructor Methods
+ (instancetype)createWithProduct:(PKProduct *)product frame:(CGRect)frame;

#pragma mark - Public Methods
- (void)updateWithProduct:(PKProduct *)product warehouse:(PKProductWarehouse)warehouse;

@end
