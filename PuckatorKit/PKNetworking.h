//
//  PKNetworking.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKEnumation.h"

typedef void(^PKNetworkingCompletionBlock)(BOOL success, NSURL *filePath, NSString *filename, NSError *error);
typedef void(^PKNetworkingProgressBlock)(float progess);
typedef void(^PKNetworkingGenericCompletionBlock)(BOOL success, NSDictionary *userInfo, NSError *error);

/**
 *  A convenient API that removes a lot of the boilerplate associated with AFNetworking
 */
@interface PKNetworking : NSObject

/**
 *  Downloads a file with an expected file format
 *
 *  @param url    The location of the file to download
 *  @param format The format expected from the server
 *  @param completionBlock The completion block to call upon success/failure
 */
- (void) downloadFileAtUrl:(NSURL*)url
               withOptions:(NSDictionary*)options
       withCompletionBlock:(PKNetworkingCompletionBlock)completionBlock;

- (void) downloadFileAtUrl:(NSURL*)url
               withOptions:(NSDictionary*)options
         withProgressBlock:(PKNetworkingProgressBlock)progressBlock
       withCompletionBlock:(PKNetworkingCompletionBlock)completionBlock;

#pragma mark - Utilities

/**
 *  Checks for an active network.  Pings the Puckator server and checks if it is reachable
 *
 *  @param completionBlock The completion block to call upon success/failure
 */
+ (void) checkConnectivityWithCompletionBlock:(PKNetworkingGenericCompletionBlock)completionBlock;

/**
 *  Fetches a sync manifest from the server.  This is used as a starting point for downloading the various XML files.
 *  The client must have a JWT token issued before calling this method, or an error will be raised immediately.
 *
 *  @param completionBlock The completion block to call upon success/failure
 */
+ (void) fetchSyncManifest:(PKNetworkingGenericCompletionBlock)completionBlock;

@end
