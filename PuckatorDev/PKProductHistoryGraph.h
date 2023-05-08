//
//  PKProductHistoryGraph.h
//  PuckatorDev
//
//  Created by Luke Dixon on 29/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphKit.h"

@interface PKProductHistoryGraph : UIView <GKLineGraphDataSource>

#pragma mark - Constructor Methods
+ (instancetype)createWithProduct:(PKProduct *)product warehouse:(PKProductWarehouse)warehouse frame:(CGRect)frame;

@end
