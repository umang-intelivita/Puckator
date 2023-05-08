//
//  PKFeedImages.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 20/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PuckatorKit.h"
#import "PKFeed.h"

/*
 * This class is designed to iterate across the PKImage table and find any missing images that need to be downloaded to disk from the server.
 */

@interface PKFeedImages : PKFeed <PKFeedDelegate, NSURLConnectionDelegate>

#pragma mark - Public Properties

@property (nonatomic, assign) int totalNumberOfExpectedDownloads;
@property (nonatomic, assign) int numberOfCompletedDownloads;
@property (nonatomic, assign) int numberOfFailedDownloads;

#pragma mark - Factories and Constructors

/**
 *  Creates a new instance of a PKFeedImages that will download images from the remote server
 *
 *  @param url The URL in which to fetch the Products
 *
 *  @return An instance of PKFeedCategory
 */
+ (instancetype) createWithUrl:(NSURL*)url
                     andConfig:(PKFeedConfig*)config;

#pragma mark - Public Methods

+ (BOOL)removeImageFilesNamed:(NSString *)imageName;

+ (NSArray *)imagesNoAssociatedWithProductInDatabaseInContext:(NSManagedObjectContext *)context;

// This method queries the database and sets a queue up to download the binary data (images) from the server.
//- (void) download:(PKFeedCompletionBlock)completionBlock;

@end
