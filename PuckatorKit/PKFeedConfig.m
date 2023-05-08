//
//  PKFeedConfig.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeedConfig.h"
#import "PKTranslate.h"
#import <FXKeychain/FXKeychain.h>
#import "NSObject+JSON.h"
#import <AFNetworking/AFNetworking.h>
#import "PKAgent.h"
#import "PKConstant.h"
#import "NSError+PKError.h"
#import "PKInstallation.h"
#import "PKFeedConfigMeta+Operations.h"
#import "PKCurrency.h"
#import "NSArray+Extended.h"

#define kFeedResponseCodeSuccess                @"OK"
#define kFeedResponseCodeInvalidFeed            @"X11"
#define kFeedResponseCodeSuspendedFeed          @"X10"
#define kFeedResponseCodeBadLicenseFeed         @"X08"

@interface PKFeedConfig()
@property (nonatomic, copy, readwrite) PKFeedConfigRegistrationCompleted registrationCompletionBlock;
@property (nonatomic, strong) NSDictionary *cachedMetaData;
@property (strong, nonatomic) NSArray *currencies;
@property (strong, nonatomic) NSArray *uniqueCurrencies;
@end

@implementation PKFeedConfig

- (BOOL)isSuppliersEnabled {
    if (kPuckatorDebugForceSupplierSearch) {
        return YES;
    }
    return [self supplierSearch];
    //return [[self number] isEqualToString:@"55244305.89114844"];
}

#pragma mark - Overidden Methods

/*
 2	85096661.27669658	Spanish Feed	23rd Mar 2012 14:44	Yes
 4	55244305.89114844	MS Feed	23rd May 2012 15:43	Yes
 8	99706979.86965473	Italian Feed	19th Oct 2012 09:32	Yes
 9	50301580.78461077	French Feed	10th Dec 2012 14:49	Yes
 13	22527264.36065412	NL feed	27th Aug 2013 13:05	Yes
 15	91375487.84968454	Portugal Feed	26th Nov 2013 14:03	Yes
 18	77450221.53939276	Swedish Feed	27th Jan 2014 12:39	Yes
 19	65173536.92515722	Polish	21st Feb 2014 16:27	Yes
 22	78376203.78079987	Czech Feed
 */

- (void)setNumber:(NSString *)number {
    if ([number isEqualToString:@"__en"]) {
        number = @"55244305.89114844";
    } else if ([number isEqualToString:@"__es"]) {
        number = @"85096661.27669658";
    } else if ([number isEqualToString:@"__it"]) {
        number = @"99706979.86965473";
    } else if ([number isEqualToString:@"__fr"]) {
        number = @"50301580.78461077";
    } else if ([number isEqualToString:@"__nl"]) {
        number = @"22527264.36065412";
    } else if ([number isEqualToString:@"__pl"]) {
        number = @"91375487.84968454";
    } else if ([number isEqualToString:@"__se"]) {
        number = @"77450221.53939276";
    } else if ([number isEqualToString:@"__ph"]) {
        number = @"65173536.92515722";
    } else if ([number isEqualToString:@"__cz"]) {
        number = @"78376203.78079987";
    } else if ([number isEqualToString:@"__de"]) {
        number = @"13888323.43937597";
    }
    
    _number = number;
    
    // Clear the currency caches:
    _currencies = nil;
    _uniqueCurrencies = nil;
}

#pragma mark - FXForm Fields (used for displaying this object in the user interface)

- (NSArray *)fields {
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    if (![self allocatedDeviceIdentifier]) {
        [fields addObject:@{FXFormFieldKey: @"number", FXFormFieldTitle: NSLocalizedString(@"Feed Number", nil), FXFormFieldPlaceholder: NSLocalizedString(@"Puckator provided Feed Number", nil)}];
    } else {
        [fields addObject:@{FXFormFieldKey: @"number", FXFormFieldTitle:[NSString stringWithFormat:@"%@ 🔒", NSLocalizedString(@"Feed Number", nil)], FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldPlaceholder: NSLocalizedString(@"Puckator provided Feed Number", nil)}];
    }
    
    [fields addObject:@{FXFormFieldKey: @"name", FXFormFieldTitle: NSLocalizedString(@"Feed Name", nil), FXFormFieldPlaceholder: NSLocalizedString(@"e.g. Puckator UK", nil), FXFormFieldHeader: NSLocalizedString(@"CONFIGURE FEED", nil) }];
    [fields addObject:@{FXFormFieldKey: @"iconName", FXFormFieldTitle: NSLocalizedString(@"Custom Icon", nil), FXFormFieldType:FXFormFieldTypeLabel, FXFormFieldOptions: @[@"PKFeedUK.png", @"PKFeedFR.png", @"PKFeedES.png", @"PKFeedSE.png", @"PKFeedPL.png", @"PKFeedIT.png", @"PKFeedNL.png", @"PKFeedCZ.png", @"PKFeedDE.png", @"PKFeedHU.png", @"PKFeedPT.png", @"PKFeedEU.png"], FXFormFieldFooter:NSLocalizedString(@"Need help finding your Feed Number?  Contact Puckator Support.", nil) }];
    [fields addObject:@{FXFormFieldHeader: @"", FXFormFieldTitle: NSLocalizedString(@"Save Feed", nil), FXFormFieldAction: @"saveFeed:"}];
    
    return fields;
}

#pragma mark - Constructors

+ (PKFeedConfig*) createWithDictionary:(NSDictionary*)dictionary {
    PKFeedConfig *instance = [[PKFeedConfig alloc] init];
    if(dictionary) {
        [instance fromDictionary:dictionary];
    }
    return instance;
}

- (id) init {
    if (self = [super init]) {
        //NSString *installationId = [self installationId]; // Get/generate an installation ID
        
        // Listen for sync notifications so we can clear the internal cache
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSync:) name:kNotificationSyncComplete object:nil];
        
    }
    return self;
}

- (void) didSync:(id)sender {
    [self setCachedMetaData:nil];
}

#pragma mark - Data

- (NSDictionary*) toDictionary {
    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionary];
    if([self uuid]) {
        [dictionaryRepresentation setObject:[self uuid] forKey:@"uuid"];
    }
    if([self name]) {
        [dictionaryRepresentation setObject:[self name] forKey:@"name"];
    }
    if([self number]) {
        [dictionaryRepresentation setObject:[self number] forKey:@"number"];
    }
    if([self iconName]) {
        [dictionaryRepresentation setObject:[self iconName] forKey:@"icon_name"];
    }
    if([self allocatedDeviceIdentifier]) {
        [dictionaryRepresentation setObject:@([[self allocatedDeviceIdentifier] intValue]) forKey:@"allocated_device_identifier"];
    }
    if([self isWiped]) {
        [dictionaryRepresentation setObject:[self isWiped] forKey:@"is_wiped"];
    }
    if([self hasSyncronised]) {
        [dictionaryRepresentation setObject:@([self hasSyncronised]) forKey:@"has_synced"];
    }
    if([self dateLastSyncronised]) {
        [dictionaryRepresentation setObject:[self dateLastSyncronised] forKey:@"date_last_sync"];
    }
    if ([self defaultWarehouse]) {
        [dictionaryRepresentation setObject:[self defaultWarehouse] forKey:@"default_warehouse"];
    }
    
    [dictionaryRepresentation setObject:@([self supplierSearch]) forKey:@"supplier_search"];
    
    return dictionaryRepresentation;
}

- (void) fromDictionary:(NSDictionary*)dictionaryRepresentation {
    if([dictionaryRepresentation objectForKey:@"uuid"]) {
        [self setUuid:[dictionaryRepresentation objectForKey:@"uuid"]];
    }
    if([dictionaryRepresentation objectForKey:@"name"]) {
        [self setName:[dictionaryRepresentation objectForKey:@"name"]];
    }
    if([dictionaryRepresentation objectForKey:@"number"]) {
        [self setNumber:[dictionaryRepresentation objectForKey:@"number"]];
    }
    if([dictionaryRepresentation objectForKey:@"icon_name"]) {
        [self setIconName:[dictionaryRepresentation objectForKey:@"icon_name"]];
    }
    if([dictionaryRepresentation objectForKey:@"allocated_device_identifier"]) {
        [self setAllocatedDeviceIdentifier:@([[dictionaryRepresentation objectForKey:@"allocated_device_identifier"] intValue])];
    }
    if([dictionaryRepresentation objectForKey:@"is_wiped"]) {
        [self setIsWiped:[dictionaryRepresentation objectForKey:@"is_wiped"]];
    }
    if([dictionaryRepresentation objectForKey:@"default_warehouse"]) {
        [self setDefaultWarehouse:[dictionaryRepresentation objectForKey:@"default_warehouse"]];
    }
    if([dictionaryRepresentation objectForKey:@"has_synced"]) {
        [self setHasSyncronised:[[dictionaryRepresentation objectForKey:@"has_synced"] boolValue]];
    }
    if([dictionaryRepresentation objectForKey:@"date_last_sync"]) {
        [self setDateLastSyncronised:[dictionaryRepresentation objectForKey:@"date_last_sync"]];
    }
    
    [self setSupplierSearch:[[dictionaryRepresentation objectForKey:@"supplier_search"] boolValue]];
}

- (NSString*) installationId {
    return [PKInstallation currentInstallationToken];
}

#pragma mark - Methods

+ (NSArray*) feeds {
    
    // Read feed configuration from the keychain
    FXKeychain *keychain = [FXKeychain defaultKeychain];
    
    // Loop through the stored feed dicts
    NSArray *feeds = [keychain objectForKey:@"feeds"];
    
    // Create PKFeedConfig objects from each stored feed
    NSMutableArray *feedObjects = [NSMutableArray array];
    for(NSDictionary *feed in feeds) {
        PKFeedConfig *feedConfig = [PKFeedConfig createWithDictionary:feed];
        if (feedConfig) {            
            if ([[feedConfig isWiped] boolValue] == YES) {
                NSLog(@"is Wiped");
            } else {

                [feedObjects addObject:feedConfig];
            }
        }
    }
    
    // Return the feed objects (may be an empty array)
    return feedObjects;
}

// Saves an array of feed objecrs in a specific order
+ (BOOL) saveFeedConfigs:(NSArray*)configs {

    // Create dictionaries from each object
    NSMutableArray *configurations = [NSMutableArray array];
    for(PKFeedConfig *config in configs) {
        NSDictionary *dict = [config toDictionary];
        if (dict) {
            [configurations addObject:dict];
        }
    }
    
    // Save to keychain
    FXKeychain *keychain = [FXKeychain defaultKeychain];
    [keychain setAccessibility:FXKeychainAccessibleAlways];
    
    if(configs) {
        [keychain setObject:configurations forKey:@"feeds"];
    } else {
        [keychain setObject:@[] forKey:@"feeds"];
    }
    
    return NO;
}

// Delete a single feed
- (NSError*) deleteConfig {
    // Is this feed for images?  Never save it!
    if([self type] == PKFeedConfigTypeImageDownloader ||
       [self type] == PKFeedConfigTypeSQLDownloader) {
       return nil;
    }
    // Fetch all the feeds
    NSMutableArray *feeds = [NSMutableArray arrayWithArray:[PKFeedConfig feeds]];
    
    // Find the feed object to update
    BOOL found = NO;
    int  i = 0;
    for(PKFeedConfig *config in feeds) {
        if([[config uuid] isEqual:[self uuid]]) {
            [feeds replaceObjectAtIndex:i withObject:self];
            found = YES;
            break;
        }
        
        i++;
    }
    
    if (found) {
        [feeds removeObject:self];
    }
    
    // Perform some validation
    NSError *error = nil;
    for(PKFeedConfig *config in feeds) {
        if(![[config uuid] isEqual:[self uuid]]) {
            NSLog(@"Matching %@ vs %@", [config number], [self number]);
            if([[config number] isEqual:[self number]]) {
                NSLog(@"Matched! %@", [config number]);
                error = [NSError errorWithDomain:@""
                                            code:1
                                        userInfo:@{NSLocalizedDescriptionKey:@"Feed with that number already exists!"}];
                break;
            } else {
                NSLog(@"Not Matched! %@", [config number]);

            }
        }
    }
    
    // Save the feeds if no validation errors occured
    if(!error) {
        [PKFeedConfig saveFeedConfigs:feeds];
    }
    
    // Return error if any
    return error;
}

// Saves a single feed
- (NSError*) save {
    
    // Is this feed for images?  Never save it!
    if([self type] == PKFeedConfigTypeImageDownloader ||
       [self type] == PKFeedConfigTypeSQLDownloader) {
       return nil;
    }
    
    // Fetch all the feeds
    NSMutableArray *feeds = [NSMutableArray arrayWithArray:[PKFeedConfig feeds]];
    
    // Find the feed object to update
    BOOL found = NO;
    int  i = 0;
    for(PKFeedConfig *config in feeds) {
        if([[config uuid] isEqual:[self uuid]]) {
            [feeds replaceObjectAtIndex:i withObject:self];
            found = YES;
            break;
        }
        
        i++;
    }
    
    // If no feed was found, insert it
    if (!found) {
        [self setUuid:[[NSUUID UUID] UUIDString]];
        if (self) {
            [feeds addObject:self];
        }
    }
    
    // Perform some validation
    NSError *error = nil;
    for(PKFeedConfig *config in feeds) {
        if(![[config uuid] isEqual:[self uuid]]) {
            NSLog(@"Matching %@ vs %@", [config number], [self number]);
            if([[config number] isEqual:[self number]]) {
                NSLog(@"Matched! %@", [config number]);
                error = [NSError errorWithDomain:@""
                                            code:1
                                        userInfo:@{NSLocalizedDescriptionKey:@"Feed with that number already exists!"}];
                break;
            } else {
                NSLog(@"Not Matched! %@", [config number]);

            }
        }
    }
    
    // Save the feeds if no validation errors occured
    if(!error) {
        [PKFeedConfig saveFeedConfigs:feeds];
    }
    
    // Return error if any
    return error;
}

#pragma mark - Networking

- (void) registerFeed:(PKFeedConfigRegistrationCompleted)completionBlock {
    // Get the agent back
    PKAgent *agent = [PKAgent currentAgent];
    
    // Create a new ID
    NSMutableString *uuid = [NSMutableString stringWithString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    [uuid replaceCharactersInRange:NSMakeRange(0, 6) withString:@"PUCK2-"];
    
    // Define the content type as JSON
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [[manager responseSerializer] setAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
    
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[manager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Pass the parmeters to the web service
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[self installationId] forKey:@"installation_token"];
    [parameters setObject:[self number] forKey:@"feed_number"];
    [parameters setObject:uuid forKey:@"device_udid"];
    [parameters setObject:[NSString stringWithFormat:@"%@ %@", [agent firstName], [agent lastName]] forKey:@"agent_name"];
    [parameters setObject:[agent email] forKey:@"agent_email"];
    [parameters setObject:@"iOS" forKey:@"device_os"];
    [parameters setObject:[PKInstallation deviceModel] forKey:@"device_model"];
    [parameters setObject:[PKInstallation deviceOsVersion] forKey:@"device_os_version"];
    [parameters setObject:[PKInstallation appVersion] forKey:@"app_version"];
    [parameters setObject:[PKInstallation deviceName] forKey:@"device_name"];
    
    NSLog(@"Posting params: %@", parameters);
    [manager GET:kPuckatorEndpointRegistration parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"Server responded with: %@", responseObject);
          NSLog(@"RESP = %@ ", [[NSString alloc] initWithData:[operation responseData] encoding:NSUTF8StringEncoding]);
          BOOL success = [[responseObject objectForKey:@"success"] boolValue];
          if (success) {
              NSDictionary *feedInformation = [responseObject objectForKey:@"this_feed"];
              int deviceIdentifier = [[feedInformation objectForKey:@"ID"] intValue];
              
              // Get the device ID for this feed
              [self setAllocatedDeviceIdentifier:@(deviceIdentifier)];
              
              
              BOOL value = [[feedInformation valueForKey:@"RequiresWipe"] boolValue];
              
              [self setIsWiped:@(NO)];
              [self setDefaultWarehouse:[[responseObject objectForKey:@"DefaultWarehouse"] stringValue]];
              
              // Update the JWT token if one is available
              if ([responseObject objectForKey:@"jwt_token"]) {
                  [PKInstallation setCurrentInstallationJwt:[responseObject objectForKey:@"jwt_token"]];
              }
              
              // Setup supplier search:
              BOOL supplierSearch = [[feedInformation objectForKey:@"SupplierSearch"] boolValue];
              [self setSupplierSearch:supplierSearch];
              
              // Save the feed
              [self save];
              
              // Complete
              completionBlock(YES, nil, deviceIdentifier);
          } else {
              // Should this feed be wiped?
              if ([responseObject objectForKey:@"wipe"]) {
                  BOOL wipe = [[responseObject objectForKey:@"wipe"] boolValue];
                  if (wipe) {
                      [self setIsWiped:@(YES)];
                      [self save];
                  }
              }
              
              // Respond with an error message
              if ([responseObject objectForKey:@"message"]) {
                  NSError *error = [NSError errorWithDescription:[responseObject objectForKey:@"message"]
                                                    andErrorCode:kPuckatorErrorCodeFeedGenericError];
                  completionBlock(NO, error, -1);
              } else {
                  NSError *error = [NSError errorWithDescription:NSLocalizedString(@"The feed number entered is invalid!", nil)
                                                    andErrorCode:kPuckatorErrorCodeFeedGenericError];
                  completionBlock(NO, error, -1);
              }
          }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        // A general HTTP networking error occured
        NSError *errorObj = [NSError errorWithDescription:NSLocalizedString(@"Error connecting to the Puckator Server.\n\nPlease ensure you are connected to a Wi-Fi or Cellular Network.", nil)
                                          andErrorCode:kPuckatorErrorNetworkProblem];
        completionBlock(NO, errorObj, -1);
    }];
    
}

#pragma mark - Progress Updates

- (void) updateStatusText:(NSString*)statusText {
    [self updateStatusText:statusText
          withProgressStep:PKProgressStepUndefined];
}

- (void) updateStatusText:(NSString*)statusText
         withProgressStep:(PKProgressStep)progressStep {        
        // Only update the progress of this step if not finished already
        //if([self progressStep] != PKProgressStepFinished) {
            [self setStatusText:statusText];
            [self setProgressStep:progressStep];
            [self notifyProgressUpdate];
        //}
}

- (void)notifyProgressUpdate {
    // Get the notification key
    NSString *notificationKey = [NSString stringWithFormat:@"%@.%@", kNotificationSyncProgressUpdate, [self number]];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationKey object:self];
}

#pragma mark - Data

- (PKCurrency *)currencyWithCurrencyId:(int)currencyId {
    NSArray *currencies = [self uniqueCurrencies];
    __block PKCurrency *currency = nil;
    
    [currencies enumerateObjectsUsingBlock:^(PKCurrency *c, NSUInteger idx, BOOL * _Nonnull stop) {
        printf("%d",[[c currentId] intValue]);
        if ([[c currentId] intValue] == currencyId) {
            currency = c;
            *stop = YES;
        }
    }];
    
    return currency;
}

- (NSArray *)uniqueCurrencies {
    if ([_uniqueCurrencies count] == 0) {
        _uniqueCurrencies = [PKCurrency currenciesWithArray:[PKFeedConfigMeta currenciesForFeedConfig:self context:nil] uniqueOnly:YES];
    }
    return _uniqueCurrencies;
}

- (NSArray *)currencies {
    if ([_currencies count] == 0) {
        _currencies = [PKCurrency currenciesWithArray:[PKFeedConfigMeta currenciesForFeedConfig:self context:nil]];
    }
    return _currencies;
}

- (float) defaultDeliveryCost {
    NSArray *currencies = [PKFeedConfigMeta currenciesForFeedConfig:self context:nil];
    for(NSDictionary *currency in currencies) {
        if([currency objectForKey:@"DELIVERY_CHARGE"]) {
            return [[currency objectForKey:@"DELIVERY_CHARGE"] floatValue];
        }
    }
    return 0.0f;
}

- (float)defaultDeliveryCostForISO:(NSString *)iso {
    // Get all the currencies:
    NSArray *currencies = [self currencies];
    
    // Loop the currencies to find the one that matches the given iso code:
    __block NSNumber *cost = nil;
    [currencies enumerateObjectsUsingBlock:^(PKCurrency *currency, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[currency code] isEqualToString:iso]) {
            cost = [currency deliveryCharge];
        }
    }];

    // If a cost isn't found then return the default postage cost:
    if (!cost || [cost isKindOfClass:[NSNull class]]) {
        cost = @([self defaultDeliveryCost]);
    }
    
    // Return the float value of cost:
    if ([cost respondsToSelector:@selector(floatValue)]) {
        return [cost floatValue];
    }
    
    // Something went wrong:
    return 0.f;
}

- (float) defaultDeliveryFreeAfter {
    NSArray *currencies = [PKFeedConfigMeta currenciesForFeedConfig:self context:nil];
    for(NSDictionary *currency in currencies) {
        if([currency objectForKey:@"DELIVERY_FREE_AFTER"]) {
            return [[currency objectForKey:@"DELIVERY_FREE_AFTER"] floatValue];
        }
    }
    return 0.0f;
}

- (float)defaultDeliveryFreeAfterForISO:(NSString *)iso {
    // Get all the currencies:
    NSArray *currencies = [self currencies];
    
    // Loop the currencies to find the one that matches the given iso code:
    __block NSNumber *freeAfter = nil;
    [currencies enumerateObjectsUsingBlock:^(PKCurrency *currency, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[currency code] isEqualToString:iso]) {
            freeAfter = [currency deliveryFreeAfter];
            *stop = YES;
        }
    }];
    
    // If a cost isn't found then return the default postage cost:
    if (!freeAfter || [freeAfter isKindOfClass:[NSNull class]]) {
        freeAfter = @([self defaultDeliveryFreeAfter]);
    }
    
    // Return the float value of cost:
    if ([freeAfter respondsToSelector:@selector(floatValue)]) {
        return [freeAfter floatValue];
    }
    
    return CGFLOAT_MAX;
}

- (NSDictionary*) metaData {
    if([self cachedMetaData]) {
        return [self cachedMetaData];
    } else {
        [self setCachedMetaData:[PKFeedConfigMeta feedMetaDataForFeedConfig:self context:nil]];
        return [self cachedMetaData];
    }
}

- (int) newProductDays {
    NSDictionary *metaData = [self metaData];
    if([metaData objectForKey:@"NewProductDays"]) {
        return [[metaData objectForKey:@"NewProductDays"] intValue];
    } else {
        return 180;
    }
}

- (float) defaultVatRate {
    NSDictionary *metaData = [self metaData];
    if([metaData objectForKey:@"DefaultVAT"]) {
        return [[metaData objectForKey:@"DefaultVAT"] floatValue];
    } else {
        return 20.0f;
    }
}

- (NSString *)defaultCurrencyIsoCode {
    NSDictionary *metaData = [self metaData];
    if ([metaData objectForKey:@"DefaultISO"]) {
        __block NSString *defaultIsoCode = [metaData objectForKey:@"DefaultISO"];
        
        // Attempt to find the conversion between the country ISO code and the currency code:
        // E.g. GB == GBP, SE == SEK, ES == EUR, etc:
        NSArray *currencies = [self currencies];
        [currencies enumerateObjectsUsingBlock:^(PKCurrency *currency, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[currency countryCode] lowercaseString] isEqualToString:[defaultIsoCode lowercaseString]]) {
                defaultIsoCode = [currency code];
                *stop = YES;
            }
        }];
        
        return defaultIsoCode;
    } else {
        // Always default back to GBP:
        return @"GBP";
    }
}

- (BOOL)isES {
    return [[self number] isEqualToString:@"85096661.27669658"];
}

- (BOOL)isIT {
    return [[self number] isEqualToString:@"99706979.86965473"];
}

#pragma mark - Util

- (PKProductWarehouse)warehouse {
    PKProductWarehouse warehouse = PKProductWarehouseUK;
    if ([[[self defaultWarehouse] lowercaseString] isEqualToString:@"edc"]) {
        warehouse = PKProductWarehouseEDC;
    }
    return warehouse;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"PKFeedConfig: %@", [self number]];
}

- (NSString*) dateLastSyncFormatted {
    if([self dateLastSyncronised]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        return [formatter stringFromDate:[self dateLastSyncronised]];
    } else {
        return NSLocalizedString(@"Never syncronised", nil);
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSyncComplete object:nil];
}



@end
