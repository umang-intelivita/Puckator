//
//  PKRankIndicator.m
//  PuckatorDev
//
//  Created by Luke Dixon on 22/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKRankIndicator.h"
#import "UIColor+Puckator.h"

@implementation PKRankIndicator

#pragma mark - View Lifecycle

- (void)awakeFromNib {
    [[self layer] setCornerRadius:[self bounds].size.width * 0.5f];
    [self setupGestureRecognizers];
}

#pragma mark - Private Methods

- (void)setupGestureRecognizers {
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)]];
}

#pragma mark - Event Methods

- (void)viewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    NSLog(@"Tapped");
}

#pragma mark - Overridden Methods

- (void)setRankValue:(int)rankValue {
    if (rankValue > 0 && rankValue <= 100) {
        [self setRankLevel:PKRankIndicatorLevelMax];
    } else if (rankValue > 100 && rankValue <= 300) {
        [self setRankLevel:PKRankIndicatorLevelMid];
    } else if (rankValue > 300 && rankValue <= 500) {
        [self setRankLevel:PKRankIndicatorLevelMin];
    } else {
        [self setRankLevel:PKRankIndicatorLevelNone];
    }
}

- (void)setRankLevel:(PKRankIndicatorLevel)level {
    switch (level) {
        case PKRankIndicatorLevelMax:
            [self setBackgroundColor:[UIColor puckatorRankMax]];
            break;
        case PKRankIndicatorLevelMid:
            [self setBackgroundColor:[UIColor puckatorRankMid]];
            break;
        case PKRankIndicatorLevelMin:
            [self setBackgroundColor:[UIColor puckatorRankMin]];
            break;
        default:
            [self setBackgroundColor:[UIColor puckatorDarkGray]];
            break;
    }
}

#pragma mark -

@end