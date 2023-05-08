//
//  UIScrollView+Extended.m
//  PuckatorDev
//
//  Created by Luke Dixon on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "UIScrollView+Extended.h"

@implementation UIScrollView (Extended)

- (int)currentPage {
    return fabs([self contentOffset].x) / [self bounds].size.width;
}

- (void)setPage:(int)page animated:(BOOL)animated {
    [self setContentOffset:CGPointMake([self bounds].size.width * page, 0) animated:animated];
}

- (void)nextPageAnimated:(BOOL)animated {
    [self setPage:[self currentPage] + 1 animated:animated];
}

- (void)prevPageAnimated:(BOOL)animated {
    [self setPage:[self currentPage] - 1 animated:animated];
}

@end