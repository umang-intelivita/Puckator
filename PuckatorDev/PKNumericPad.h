//
//  PKNumericPad.h
//  PuckatorDev
//
//  Created by Luke Dixon on 21/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBaseViewController.h"

typedef enum : NSUInteger {
    PKNumericPadFunctionNone,
    PKNumericPadFunctionAdd,
    PKNumericPadFunctionSubtract,
    PKNumericPadFunctionMultiply,
    PKNumericPadFunctionDivide
} PKNumericPadFunction;

@protocol PKNumericPadDelegate<NSObject>
- (void)pkNumericPadDidEnterValue:(int)value;
@end

@interface PKNumericPad : FSBaseViewController

@property (weak, nonatomic) id<PKNumericPadDelegate> delegate;

+ (instancetype)createWithProduct:(PKProduct *)product delegate:(id<PKNumericPadDelegate>)delegate;

@end