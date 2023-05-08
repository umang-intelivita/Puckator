//
//  NSError+FS.m
//  MyFutureMOT
//
//  Created by Luke Dixon on 21/02/2017.
//  Copyright © 2017 Luke Dixon. All rights reserved.
//

#import "NSError+FS.h"
#import <RMError/NSError+RMError.h>

@implementation NSError (FS)

+ (NSError *)create:(NSString *)description {
    return [NSError create:description code:-1];
}

+ (NSError *)create:(NSString *)description code:(int)code {
    return [NSError errorWithCode:code description:description domain:[[NSBundle mainBundle] bundleIdentifier]];
}

@end
