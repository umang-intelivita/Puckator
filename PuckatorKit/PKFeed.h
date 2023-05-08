//
//  PKFeed.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKEnumation.h"
#import "PKFeedConfig.h"

@class PKFeed;

@protocol PKFeedDelegate <NSObject>

- (void)pkFeedFinished:(PKFeed *)feed;
- (void)pkFeedDownload:(PKFeed *)feed success:(BOOL)success filePath:(NSURL *)filePath filename:(NSString *)filename error:(NSError *)error;
- (void)pkFeedProgress:(PKFeed *)feed progress:(float)progess;

@end

// Completion blocks
typedef void(^PKFeedCompletionBlock)(BOOL success, NSURL *filePath, NSError *error);

/**
 *  PKFeed is responsible for downloading an individual feed from the server.  To initialize you should
 *  use the `createWithUrl:ofType:` factory method.
 */
@interface PKFeed : NSObject

#pragma mark - Public Properties

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, assign) PKFeedType type;
@property (nonatomic, strong) PKFeedConfig *feedConfig;
@property (nonatomic, copy, readwrite) PKFeedCompletionBlock completionBlock;
@property (nonatomic, assign) id<PKFeedDelegate> delegate;
@property (nonatomic, assign) id<PKFeedDelegate> downloadDelegate;

// Sync related stuff
@property (nonatomic, strong) NSMutableArray *filesToParse;
@property (nonatomic, assign) int totalFilesToParse;

@property (nonatomic, assign) int retryCount; // The number of retries this feed has had.  Max is 3 before deemed a failure.

#pragma mark - Factory Methods / Constructors

/**
 *  Creates a new instance of a Puckator Feed with a designated type
 *
 *  @param url  A fully qualified URL in which the feed is location
 *  @param type The type of feed that is to be downloaded (see @PKEnumation)
 *
 *  @return An instance of a PKFeed.
 */
+ (id) createWithUrl:(NSURL*)url
              ofType:(PKFeedType)type
          withConfig:(PKFeedConfig*)config;

#pragma mark - Public Methods

/**
 *  Connects to the server and downloads the feed payload
 */
- (void) download:(PKFeedCompletionBlock)completionBlock;
- (void)downloadWithDelegate:(id<PKFeedDelegate>)delegate;

#pragma mark - Public Class Utilities

/**
 *  Returns the name of a feed based on an passed type
 *
 *  @param type The type of feed (@PKFeedType)
 *
 *  @return The name of the feed (e.g. Customer, or "Unknown" if unknown)
 */
+ (NSString*) nameForFeedType:(PKFeedType)type;
+ (NSString*) pluralNameForFeedType:(PKFeedType)type;

/**
 *  Returns a feed download URL based on a JWT token
 *
 *  @param token The feed specific JWT access token
 *
 *  @return A URL that will download the feed data from the server based on a secure JWT access token
 */
+ (NSURL*) urlFromToken:(NSString*)token;

+ (NSURL *)tokenizeUrl:(NSString *)url;

// Returns a thread name used for multi-threading purposes
- (NSString*) threadName;

@end
