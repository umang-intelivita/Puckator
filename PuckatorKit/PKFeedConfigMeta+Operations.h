//
//  PKFeedConfigMeta+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKFeedConfigMeta.h"
#import "PKFeedConfig.h"

@interface PKFeedConfigMeta (Operations)

#pragma mark - Setters

/**
 *  Updates the associated feed currencies attached to a feed config
 *
 *  @param feedConfig The PKFeedConfig instance
 *  @param currencies The currencies to save and associate
 *  @param context The core data context, or nil for default
 */
+ (void) syncroniseCurrenciesWithFeedConfig:(PKFeedConfig*)feedConfig
                                 currencies:(NSArray*)currencies
                                    context:(NSManagedObjectContext*)context;

+ (void) syncroniseFeedMetaDataWithFeedConfig:(PKFeedConfig*)feedConfig
                                   currencies:(NSDictionary*)metaData
                                      context:(NSManagedObjectContext*)context;


+ (void)saveFeedMetaDataWithFeedConfig:(PKFeedConfig *)feedConfig group:(NSString *)group key:(NSString *)key object:(id)metaData context:(NSManagedObjectContext *)context save:(BOOL)save;
+ (void)saveFeedMetaDataWithFeedConfig:(PKFeedConfig *)feedConfig group:(NSString *)group key:(NSString *)key object:(id)metaData;
+ (id)feedMetaDataWithFeedConfig:(PKFeedConfig *)feedConfig group:(NSString *)group key:(NSString *)key;

#pragma mark - Getters

/**
 *  Fetches currencies for a given feed
 *
 *  @param feedConfig The feed configuration
 *  @param context    An array of supported currencies
 *
 *  @return The set of currencies for this feed
 */
+ (NSArray*) currenciesForFeedConfig:(PKFeedConfig*)feedConfig
                             context:(NSManagedObjectContext*)context;

+ (NSDictionary*) feedMetaDataForFeedConfig:(PKFeedConfig*)feedConfig
                                    context:(NSManagedObjectContext*)context;


+ (PKFeedConfigMeta *)feedConfigMetaObjectForFeedConfig:(PKFeedConfig*)feedConfig
                                                context:(NSManagedObjectContext*)context;

@end
