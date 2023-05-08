//
//  PKFeedProduct.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 10/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeed.h"

/**
 *  Fetches and parses Product's from a remote URL and stores into a local database
 */
@interface PKFeedProduct : PKFeed <PKFeedDelegate>

#pragma mark - Public Properties



#pragma mark - Factories and Constructors

/**
 *  Creates a new instance of a PKFeedProduct that will import products into an internal database
 *
 *  @param url The URL in which to fetch the Products
 *
 *  @return An instance of PKFeedProduct
 */
+ (instancetype) createWithUrl:(NSURL*)url
                     andConfig:(PKFeedConfig*)config;

#pragma mark - Public Methods

@end
