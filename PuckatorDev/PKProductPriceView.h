//
//  PKProductPriceView.h
//  PuckatorDev
//
//  Created by Luke Dixon on 09/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKProductPriceView;

@protocol PKProductPriceViewDelegate<NSObject>
- (void)pkProductPriceView:(PKProductPriceView *)productPriceView wasTappedWithProductPrice:(PKProductPrice *)productPrice;
- (void)pkProductPriceView:(PKProductPriceView *)productPriceView wasTappedWithPrice:(NSNumber *)price quantity:(NSNumber *)quantity;
@end

@interface PKProductPriceView : UIView <UIGestureRecognizerDelegate>

#pragma mark - Constructor Methods
+ (instancetype)createWithProductPrice:(PKProductPrice *)productPrice oldPrice:(NSNumber *)oldPrice frame:(CGRect)frame;
+ (instancetype)createWithPrice:(NSNumber *)price quantity:(NSNumber *)quantity frame:(CGRect)frame;

@property (weak, nonatomic) id<PKProductPriceViewDelegate> delegate;

@end
