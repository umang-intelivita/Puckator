//
//  PKFeedCategory.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PuckatorKit.h"


// Fetches and parse categories from the Puckator server and stores in the internal database
@interface PKFeedCategory : PKFeed <PKFeedDelegate>

#pragma mark - Public Properties

#pragma mark - Factories and Constructors

/**
 *  Creates a new instance of a PKFeedCategory that will import products into an internal database
 *
 *  @param url The URL in which to fetch the Products
 *
 *  @return An instance of PKFeedCategory
 */
+ (instancetype) createWithUrl:(NSURL*)url
                     andConfig:(PKFeedConfig*)config;

#pragma mark - Public Methods

@end
