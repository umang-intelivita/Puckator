//
//  PKRankIndicator.h
//  PuckatorDev
//
//  Created by Luke Dixon on 22/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PKRankIndicatorLevelMax,
    PKRankIndicatorLevelMid,
    PKRankIndicatorLevelMin,
    PKRankIndicatorLevelNone
} PKRankIndicatorLevel;

@interface PKRankIndicator : UIView

@property (assign, nonatomic) PKRankIndicatorLevel rankLevel;
@property (assign, nonatomic) int rankValue;

@end