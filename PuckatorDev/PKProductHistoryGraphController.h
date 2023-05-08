//
//  PKProductHistoryGraphController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 29/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBaseViewController.h"

@interface PKProductHistoryGraphController : FSBaseViewController

#pragma mark - Constructor Methods
+ (instancetype)createWithProduct:(PKProduct *)product warehouse:(PKProductWarehouse)warehouse;

@end
