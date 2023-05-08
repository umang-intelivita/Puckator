//
//  FSCollectionViewZoomTransition.h
//  PuckatorDev
//
//  Created by Luke Dixon on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKZoomTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)createWithPoint:(CGPoint)point;
+ (instancetype)createWithFrame:(CGRect)frame;

@property (assign, nonatomic) BOOL reverse;

@end