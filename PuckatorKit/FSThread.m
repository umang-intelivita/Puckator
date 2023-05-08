//
//  FSThread.m
//  MinecraftSeedMap
//
//  Created by Luke Dixon on 13/03/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "FSThread.h"

@implementation FSThread

+ (void)runOnMain:(FSThreadBlock)aBlock {
    if (aBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            aBlock();
        });
    }
}

+ (void)runInBackground:(FSThreadBlock)aBlock {
    [FSThread runInBackground:aBlock withThreadIdentifier:[[NSUUID UUID] UUIDString]];
}

+ (void)runInBackground:(FSThreadBlock)aBlock withThreadIdentifier:(NSString*)threadIdentifier {
    NSString *random = [NSString stringWithFormat:@"com.fsthread.%@", threadIdentifier];
    const char *name = [random cStringUsingEncoding:NSASCIIStringEncoding];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create(name, 0);
    dispatch_async(backgroundQueue, ^{
        aBlock();
    });
}

+ (void)afterDelay:(float)delay run:(FSThreadBlock)runBlock {
    [FSThread afterDelay:delay run:runBlock completion:nil];
}

+ (void)afterDelay:(float)delay run:(FSThreadBlock)runBlock completion:(FSThreadBlock)completionBlock {
    float millis = 1000 * delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, millis * NSEC_PER_MSEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), runBlock);
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), completionBlock);
        }
    });
}

@end
