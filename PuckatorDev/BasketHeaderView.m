//
//  BasketHeaderView.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "BasketHeaderView.h"

@implementation BasketHeaderView

-(instancetype)init {
    if(self = [super init]) {
        [[self labelTester] setText:@"WORKING!"];
    }
    return self;
}

@end
