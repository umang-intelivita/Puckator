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
    PKKeyPadFunctionNone,
    PKKeyPadFunctionAdd,
    PKKeyPadFunctionSubtract,
    PKKeyPadFunctionMultiply,
    PKKeyPadFunctionDivide
} PKKeyPadFunction;

typedef enum : NSUInteger {
    PKKeyPadModeQuantity,
    PKKeyPadModePrice,
    PKKeyPadModeDecimal
} PKKeyPadMode;

@class PKKeyPad;

@protocol PKKeyPadDelegate<NSObject>
- (void)pkKeyPad:(PKKeyPad *)keyPad didEnterValue:(NSNumber *)value;
- (void)pkKeyPad:(PKKeyPad *)keyPad didSelectPrice:(NSNumber *)price quantity:(NSNumber *)quantity;
- (void)pkKeyPad:(PKKeyPad *)keyPad didSelectDiscount:(NSNumber *)discount quantity:(NSNumber *)quantity;
- (void)pkKeyPad:(PKKeyPad *)keyPad didSelectQuantity:(NSNumber *)quantity;
@end

@interface PKKeyPad : FSBaseViewController

@property (weak, nonatomic) id<PKKeyPadDelegate> delegate;

@property (strong, nonatomic) NSString *identifier;

+ (instancetype)createWithProduct:(PKProduct *)product mode:(PKKeyPadMode)mode delegate:(id<PKKeyPadDelegate>)delegate;
+ (instancetype)createWithProduct:(PKProduct *)product delegate:(id<PKKeyPadDelegate>)delegate;
+ (instancetype)createWithBasketItem:(PKBasketItem *)basketItem delegate:(id<PKKeyPadDelegate>)delegate;
+ (instancetype)createWithBasketItem:(PKBasketItem *)basketItem mode:(PKKeyPadMode)mode delegate:(id<PKKeyPadDelegate>)delegate;
+ (instancetype)createWithIdentifier:(NSString *)identifier mode:(PKKeyPadMode)mode delegate:(id<PKKeyPadDelegate>)delegate;

@end
