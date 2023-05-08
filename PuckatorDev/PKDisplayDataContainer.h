//
//  PKDataDisplayContainer.h
//  PuckatorDev
//
//  Created by Luke Dixon on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKDisplayDataView.h"

@interface PKDisplayDataContainer : UIScrollView

@property (assign, nonatomic) CGFloat sectionPadding;
@property (assign, nonatomic) CGFloat rowPadding;
@property (assign, nonatomic) CGFloat cellPadding;

+ (instancetype)createWithFrame:(CGRect)frame dataDisplayItems:(NSArray *)dataDisplayItems;
- (void)updateDataDisplayItems:(NSArray *)dataDisplayItems;

@end