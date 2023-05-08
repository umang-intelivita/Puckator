//
//  PKFeedManifest.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 08/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeed.h"

/**
 *  PKFeedManifest is a subclass of PKFeed, it is responsible for fetching the URL's for the various different feeds and
 *  creating individual PKFeed instances for each individual feed type.  It also fetches configuration values and stores them
 *  within a dictionary.  The intention is that the system will download each feed individual, parse and store the responses 
 *  in a local database.
 */
@interface PKFeedManifest : PKFeed

#pragma mark - Properties

/**
 *  An array of feeds returned from the manifest
 */
@property (nonatomic, strong) NSMutableArray *feeds;

/**
 *  Configuration values returned by the feed
 */
@property (nonatomic, strong) NSMutableDictionary *configuration;

#pragma mark - Factory Methods / Constructors

/**
 *  Creates a new instance of a Puckator Manifest Feed
 *
 *  @param url  A fully qualified URL in which the manifest feed is location
 *
 *  @return An instance of a PKFeedManifest.
 */
//+ (instancetype) createWithUrl:(NSURL*)url;

#pragma mark - Methods

/**
 *  Downloads the manifest from the server
 *
 *  @param completionBlock The completion block to call
 */
- (void) download:(PKFeedCompletionBlock)completionBlock;

@end
