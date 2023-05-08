//
//  PKFeedSQL.h
//  PuckatorDev
//
//  Created by Luke Dixon on 23/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

//#import "PuckatorKit.h"
#import "PKDatabase.h"
#import "PKFeed.h"

typedef enum : NSUInteger {
    PKFeedSQLEndpointAccounts,
    PKFeedSQLEndpointData
} PKFeedSQLEndpoint;

/*
 https://www.puckator-ipad.net/ipad/api/v57/getSqlPayload?jwt_token=HERE!
 */

/*
 200=ok, 403=forbidden, 404=not found
 */

@interface PKFeedSQL : PKFeed <PKFeedDelegate>

/**
 *  Creates a new instance of a PKFeedImages that will download images from the remote server
 *
 *  @param url The URL in which to fetch the Products
 *
 *  @return An instance of PKFeedCategory
 */
+ (instancetype)createWithConfig:(PKFeedConfig*)config andEndpoint:(PKFeedSQLEndpoint)endpoint;

// Returns the file path to the SQLite file:
+ (NSString *)filePathToSQLiteFile;

+ (NSString *)filePathToSQLiteFile:(PKDatabaseType)databaseType;

@end
