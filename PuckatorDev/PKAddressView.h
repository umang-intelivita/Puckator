//
//  PKAddressView.h
//  PuckatorDev
//
//  Created by Luke Dixon on 10/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKAddress;

@interface PKAddressView : UIView

#pragma mark - Constructor Methods
+ (instancetype)createWithAddress:(PKAddress *)address frame:(CGRect)frame;

@end