//
//  NSArray+Extended.h
//  PuckatorDev
//
//  Created by Luke Dixon on 09/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extended)

- (void)enumerateObjectsUsingBlockWithFirstAndLast:(void (^)(id obj, NSUInteger idx, BOOL isFirst, BOOL isLast, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);

@end