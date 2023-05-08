//
//  NSArray+Extended.m
//  PuckatorDev
//
//  Created by Luke Dixon on 09/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "NSArray+Extended.h"

@implementation NSArray (Extended)

- (void)enumerateObjectsUsingBlockWithFirstAndLast:(void (^)(id, NSUInteger, BOOL, BOOL, BOOL *))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx, idx == 0, idx == [self count] - 1, stop);
    }];
}

@end