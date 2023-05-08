//
//  FSThread.h
//  MinecraftSeedMap
//
//  Created by Luke Dixon on 13/03/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FSThreadBlock)();

@interface FSThread : NSObject

+ (void)runOnMain:(FSThreadBlock)aBlock;
+ (void)runInBackground:(FSThreadBlock)aBlock;
+ (void)runInBackground:(FSThreadBlock)aBlock withThreadIdentifier:(NSString*)threadIdentifier;

+ (void)afterDelay:(float)delay run:(FSThreadBlock)runBlock;
+ (void)afterDelay:(float)delay run:(FSThreadBlock)runBlock completion:(FSThreadBlock)completionBlock;

@end
