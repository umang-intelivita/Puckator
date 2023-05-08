//
//  NSError+PKError.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 08/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (PKError)

+ (NSError *)errorWithDescription:(NSString *)description andErrorCode:(int)code;

@end