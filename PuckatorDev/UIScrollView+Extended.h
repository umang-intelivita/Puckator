//
//  UIScrollView+Extended.h
//  PuckatorDev
//
//  Created by Luke Dixon on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Extended)

- (int)currentPage;
- (void)setPage:(int)page animated:(BOOL)animated;
- (void)nextPageAnimated:(BOOL)animated;
- (void)prevPageAnimated:(BOOL)animated;

@end