//
//  PKFeedConfig.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms.h>
#import "PKProduct+Operations.h"

@class PKCurrency;

// Blocks
typedef void(^PKFeedConfigRegistrationCompleted)(BOOL success, NSError *error, int deviceIdentifier);

typedef enum {
    PKProgressStepWaiting = 0,
    PKProgressStepDownloading = 1,
    PKProgressStepExtracting = 2,
    PKProgressStepImporting = 3,
    PKProgressStepFinished = 4,
    PKProgressStepUndefined = 100
} PKProgressStep;

typedef enum {
    PKFeedConfigTypeDataFeed = 0,
    PKFeedConfigTypeSQLDownloader = 1,
    PKFeedConfigTypeImageDownloader = 2
} PKFeedConfigType;

typedef enum : NSUInteger {
    PKFeedXMLTypeCustomer
} PKFeedXMLType;

@interface PKFeedConfig : NSObject <FXForm>

@property (nonatomic, assign) BOOL supplierSearch;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSNumber *allocatedDeviceIdentifier;  // This is the ID returned by the Puckator API
@property (nonatomic, strong) NSNumber *isWiped;
@property (nonatomic, strong) NSString *defaultWarehouse;
@property (nonatomic, assign) BOOL hasSyncronised;                  // Determine if this feed has ever been syncronised!
@property (nonatomic, strong) NSDate *dateLastSyncronised;
@property (nonatomic, assign) PKFeedConfigType type;                // This is DataFeed by default, but may be ImageDownloader for the special image download operation

@property (nonatomic, strong) NSDictionary *syncData;               // This is the temporary data returned by the server for the purposes of syncing data. Not persisted between sync.
@property (nonatomic, strong) NSMutableArray *feedQueue;            // A queue of PKFeed operations waiting to be processed by the sync process
@property (nonatomic, assign) int totalFeedsEnqueued;               // The total number of feeds that have been queued so far (used for calculating overall progress)
@property (nonatomic, assign) BOOL isSyncProcessing;                // Determines if sync is currently in progress
@property (nonatomic, assign) BOOL isSyncFinished;                  // Determines if the sync is finished (i.e. success/failed)
@property (nonatomic, strong) NSString *statusText;                 // The current status text message for UI display purposes
@property (nonatomic, assign) PKProgressStep progressStep;          // The current progress step type (i.e. downloading, extracting, etc)
@property (nonatomic, assign) BOOL isSuppliersEnabled;
@property (nonatomic, assign) BOOL shouldShowRevokeFeed;

#pragma mark - Constructors

+ (PKFeedConfig*) createWithDictionary:(NSDictionary*)dictionary;

#pragma mark - Data

- (NSDictionary*) toDictionary;
- (void) fromDictionary:(NSDictionary*)dictionaryRepresentation;
- (NSString*) installationId;

#pragma mark - Data Fetching

/**
 *  Returns an array of supported currencies on this feed, each object is a PKCurrency.
 *
 *  @return An array of supported currencies, or nil if nothing found
 */
- (NSArray*) currencies;
- (NSArray*) uniqueCurrencies;
- (PKCurrency *)currencyWithCurrencyId:(int)currencyId;

// The default delivery price
- (float) defaultDeliveryCost;
- (float) defaultDeliveryCostForISO:(NSString *)iso;
- (float) defaultDeliveryFreeAfter;
- (float) defaultDeliveryFreeAfterForISO:(NSString *)iso;

// The number of new days a product is deemed "new".  This method fetches values from Core Data.  Use sparingly.
- (int) newProductDays;

// Returns the default VAT rate for this feed
- (float) defaultVatRate;

#pragma mark - Methods

// Fetches an array of feeds stored within the keychain
+ (NSArray*) feeds;

// Saves an array of feed objecrs in a specific order
+ (BOOL) saveFeedConfigs:(NSArray*)configs;

// Delete a single feed
- (NSError*) deleteConfig;

// Saves a single feed
- (NSError*) save;

// Returns the default currency code for this feed
- (NSString *)defaultCurrencyIsoCode;

- (PKProductWarehouse)warehouse;

#pragma mark - Networking

// Registers the feed on the puckator API
- (void) registerFeed:(PKFeedConfigRegistrationCompleted)completionBlock;

// Returns a description of the feed config
- (NSString*) description;

// Formatted version of sync date
- (NSString*) dateLastSyncFormatted;

#pragma mark - Progress Updates

- (void) notifyProgressUpdate;
- (void) updateStatusText:(NSString*)statusText;
- (void) updateStatusText:(NSString*)statusText withProgressStep:(PKProgressStep)progressStep;

#pragma mark - Database Helper Methods
- (NSString *)xmlFilenameForType:(PKFeedXMLType)type;

- (BOOL)isIT;
- (BOOL)isES;

@end
