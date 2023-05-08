//
//  PKAddressView.h
//  PuckatorDev
//
//  Created by Luke Dixon on 10/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKDisplayData;
@class PKAddress;

@interface PKDisplayDataView : UIView

#pragma mark - Constructor Methods
+ (instancetype)createWithDisplayData:(PKDisplayData *)displayData
                               origin:(CGPoint)origin
                                width:(CGFloat)width
                               height:(CGFloat)height
                       leftEdgeInsets:(UIEdgeInsets)leftEdgeInsets
                      rightEdgeInsets:(UIEdgeInsets)rightEdgeInsets
                  leftLabelEdgeInsets:(UIEdgeInsets)leftLabelEdgeInsets
                 rightLabelEdgeInsets:(UIEdgeInsets)rightLabelEdgeInsets
                       backgroundLeft:(UIColor *)backgroundLeft
                      backgroundRight:(UIColor *)backgroundRight
                       foregroundLeft:(UIColor *)foregroundLeft
                      foregroundRight:(UIColor *)foregroundRight
                       seperatorColor:(UIColor *)seperatorColor;

@end