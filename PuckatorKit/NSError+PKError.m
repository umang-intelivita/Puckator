//
//  NSError+PKError.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 08/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "NSError+PKError.h"

@implementation NSError (PKError)

+ (NSError *)errorWithDescription:(NSString *) description andErrorCode:(int)code {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSError *error = [NSError errorWithDomain:bundleIdentifier code:0 userInfo:@{
                                                                                 NSLocalizedDescriptionKey : description
                                                                                 }];
    return error;
}

@end
