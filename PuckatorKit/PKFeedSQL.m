//
//  PKFeedSQL.m
//  PuckatorDev
//
//  Created by Luke Dixon on 23/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKFeedSQL.h"
#import "FCFileManager.h"
#import "PKInvoice.h"
#import "PKDatabase.h"
#import "PKImage+Operations.h"
#import "PKProductPrice+Operations.h"
#import "PKConstant.h"
#import <MKFoundationKit/MKFoundationKit.h>
#import "PKLocalCustomer+Operations.h"
#import "PKFeedImages.h"

#define kProductBatchSize   1000

@interface PKFeedSQL ()

@property (assign, nonatomic) PKFeedSQLEndpoint endpoint;
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) FMDatabaseQueue *queue;
@property (assign, nonatomic) int skip;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;

@end

@implementation PKFeedSQL

#pragma mark - Factories / Constructors

+ (instancetype) createWithConfig:(PKFeedConfig*)config andEndpoint:(PKFeedSQLEndpoint)endpoint {
    NSString *url = nil;
    
    switch (endpoint) {
        default:
        case PKFeedSQLEndpointAccounts:
            url = kPuckatorEndpointAccountsPayload;
            
            BOOL databaseHealthy = [PKDatabase isDatabaseHealthly:PKDatabaseTypeAccounts];
            databaseHealthy = NO;
            if (databaseHealthy && [[NSUserDefaults standardUserDefaults] objectForKey:@"account_sql_filename"] && [FCFileManager isFileItemAtPath:[self filePathToSQLiteFile]]) {
                url = [NSString stringWithFormat:@"%@?existing_filename=%@", url, [[NSUserDefaults standardUserDefaults] objectForKey:@"account_sql_filename"]];
            }
            
            break;
        case PKFeedSQLEndpointData:
            url = [[config syncData] objectForKey:@"url"];
            break;
    }
    
    PKFeedSQL *feed = [super createWithUrl:[PKFeed tokenizeUrl:url]
                                    ofType:endpoint == PKFeedSQLEndpointAccounts ? PKFeedTypeSQLAccounts : PKFeedTypeSQLData
                                withConfig:config];
    [feed setEndpoint:endpoint];
    
    if (endpoint == PKFeedSQLEndpointData) {
        NSString *filename = [[url componentsSeparatedByString:@"/"] lastObject];
        filename = [[filename componentsSeparatedByString:@"?"] firstObject];
        filename = [filename stringByReplacingOccurrencesOfString:@".zip" withString:@""];
        [feed setFilename:[NSString stringWithFormat:@"%@.sqlite3", filename]];
    }
    
    return feed;
}

#pragma mark - Public Methods

- (void)downloadWithDelegate:(id<PKFeedDelegate>)delegate {
    // Update status message
    NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Downloading %@...", @"Used during the sync process to inform the user which process is currently being downloaded. E.g. 'Downloading Product...'"), [PKFeed pluralNameForFeedType:[self type]]];
    
    [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepDownloading];
    
    // Download file
    [self setDelegate:delegate];
    [super downloadWithDelegate:self];
}

+ (NSString *)folderPath {
    return [FCFileManager pathForDocumentsDirectoryWithPath:@"sql"];
}

+ (NSString *)filePathToSQLiteFile {
    return [NSString stringWithFormat:@"%@/%@", [PKFeedSQL folderPath], [PKFeedSQL filename]];
}

+ (NSString *)filePathToSQLiteFile:(PKDatabaseType)databaseType {
    NSString *path = nil;
    
    switch (databaseType) {
        case PKDatabaseTypeAccounts:
            path = [NSString stringWithFormat:@"%@/%@", [PKFeedSQL folderPath], [PKFeedSQL filename]];
            break;
        case PKDatabaseTypeProducts:
            path = [NSString stringWithFormat:@"%@/%@", [PKFeedSQL folderPath], [self filename]];
            break;
    }
    
    return path;
}

- (NSString *)filePathToSQLiteFile {
    return [NSString stringWithFormat:@"%@/%@", [PKFeedSQL folderPath], [self filename]];
}

+ (NSString *)filename {
    return @"pkfeed.sqlite3";
}

- (NSString *)filename {
    if ([_filename length] == 0) {
        return @"pkfeed.sqlite3";
    } else {
        return _filename;
    }
}

- (void)beginParse {
    if ([self queue]) {
        [[self queue] close];
        [self setQueue:nil];
    }
    
    if (![self queue]) {
        NSString *filepath = [self filePathToSQLiteFile];
        NSLog(@"[%@] - Setting up queue for: %@", [self class], filepath);
        [self setQueue:[FMDatabaseQueue databaseQueueWithPath:filepath]];
    }
    
    // Parse the categories first:
    [self parseCategories];
}

- (void)parseCategories {
    // Save the categories:
    [[self queue] inDatabase:^(FMDatabase *db) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Get the local context:
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
            
            // Get the existing categories:
            NSMutableArray *existingCategories = [[PKCategory allSortedBy:PKCategorySortModeAlphabetically ascending:YES includeCustom:NO feedConfig:[self feedConfig] context:localContext] mutableCopy];
            
            int categoryCount = [db intForQuery:@"SELECT COUNT(ID) FROM Category"];
            
            if ([existingCategories count] != 0 && [existingCategories count] != categoryCount) {
                // Remove all existing categories:
                [localContext MR_deleteObjects:existingCategories];
                [existingCategories removeAllObjects];
            }
            
            FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM Category"];
            while ([resultSet next]) {
                PKCategory *category = nil;
                
                int uuid = [[resultSet stringForColumnIfExists:@"ID"] intValue];
                
                for (PKCategory *c in existingCategories) {
                    if ([[c categoryId] intValue] == uuid) {
                        category = c;
                        [existingCategories removeObject:c];
                        break;
                    }
                }
                
                if (!category) {
                    category = [PKCategory MR_createEntityInContext:localContext];
                }
                NSLog(@"Document Path: %@", resultSet);
            
                
                [category setCategoryId:[NSString stringWithFormat:@"%i", uuid]];
                [category setFeedNumber:[[self feedConfig] number]];
                [category setTitle:[resultSet stringForColumnIfExists:@"NAME"]];
//                [category setDO_NOT_BULK_DISCOUNT:[resultSet stringForColumnIfExists:@"DO_NOT_BULK_DISCOUNT"]];
                [category setSortOrder:@([resultSet intForColumnIfExists:@"SORT_ORDER"])];
                [category setParent:@([resultSet intForColumnIfExists:@"PARENT"])];
                [category setDo_not_bulk_discount:@([resultSet intForColumnIfExists:@"do_not_bulk_discount"])];
                [category setActive:@([resultSet intForColumnIfExists:@"ACTIVE"])];
                [category setTitleClean:[[category title] clean]];
                [category setIsCustom:@(NO)];
                
                // Create an image for the category, if one exists:
                NSString *imageFilename = [resultSet stringForColumnIfExists:@"__IMAGE"];
                PKImage *image = nil;
                if ([imageFilename length] != 0) {
                    // Create an image:
                    image = [PKImage findOrCreateWithImageId:imageFilename
                                                    atDomain:kPuckatorEndpointDefaultImageDomain
                                        forRelatedEntityUuid:[NSString stringWithFormat:@"%i", uuid]
                                   forRelatedEntityClassType:@"Category"
                                               forFeedConfig:[self feedConfig]
                                                   inContext:localContext];
                }
                
                if (image) {
                    // Update the image filename:
                    [image setName:imageFilename];
                }
                
                // Set the image to the category:
                [category setMainImage:image];
            }
            
            
            //[localContext MR_saveOnlySelfAndWait];
            [localContext MR_saveToPersistentStoreAndWait];
        
            [self parseBatchedProducts];
            
        });
    }];
}

- (void)parseBatchedProducts {
    // Create a query:
    __block int total = 0;
    __block int processed = 0;
    __block NSDate *dateGenerated = nil;
    
    [[self queue] inDatabase:^(FMDatabase *db) {
        total = [db intForQuery:@"SELECT COUNT(*) FROM Product"];
        dateGenerated = [db dateForQuery:@"select DATE_GENERATED from FeedMeta"];
    }];
    
    NSLog(@"[%@] - Total products to parse: %d", [self class], total);
    
    @try {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (![strongSelf coordinator]) {
                [strongSelf setCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
            }
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextWithStoreCoordinator:[self coordinator]];
            [localContext setRetainsRegisteredObjects:NO];
            [localContext setUndoManager:nil];
            
            NSArray *existingCategories = [PKCategory allSortedBy:PKCategorySortModeAlphabetically ascending:YES includeCustom:NO feedConfig:[strongSelf feedConfig] context:localContext];
            NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uuid" ascending:YES]];
            NSMutableArray *existingProducts = [[[PKProduct allProductsForFeedConfig:[strongSelf feedConfig]
                                                                           inContext:localContext]
                                                 sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
            
            while (total != processed) {
                NSString *query = [NSString stringWithFormat:@"SELECT * FROM Product ORDER BY ID LIMIT %d OFFSET %d", kProductBatchSize, [strongSelf skip]];
                processed += [strongSelf parseProductsForQuery:query existingProducts:&existingProducts existingCategories:existingCategories context:localContext];
                
                [strongSelf setSkip:processed];
                NSLog(@"[%@] - Products parsed so far: %d / %d", [strongSelf class], processed, total);
            }
            
            // Save the date generated:
            if (dateGenerated) {
                [PKFeedConfigMeta saveFeedMetaDataWithFeedConfig:[strongSelf feedConfig]
                                                           group:kPuckatorMetaGroupSqlDates
                                                             key:kPuckatorMetaKeySqlProductsProcessedDate
                                                          object:dateGenerated
                                                         context:localContext
                                                            save:NO];
            }
            
            // Delete the existing products that are left:
            if ([existingProducts count] != 0) {
                [localContext MR_deleteObjects:existingProducts];
            }
            
            [localContext MR_saveOnlySelfWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                if (contextDidSave) {
                    NSLog(@"[%@] - DATE_GENERATED Saved: %@", [strongSelf class], dateGenerated);
                } else {
                    NSLog(@"[%@] - Error: %@", [strongSelf class], [error description]);
                }
            }];
            
            [[strongSelf feedConfig] updateStatusText:@"Done!" withProgressStep:PKProgressStepFinished];
            
            if ([[strongSelf delegate] respondsToSelector:@selector(pkFeedFinished:)]) {
                [[strongSelf delegate] pkFeedFinished:strongSelf];
            }
            
            NSLog(@"[%@] - All products have been parsed", [strongSelf class]);
        });
    } @catch (NSException *exception) {
        NSLog(@"[%@] - ERROR: %@", [self class], [exception description]);
    } @finally {
        
    }
}

- (int)parseProductsForQuery:(NSString *)query existingProducts:(NSMutableArray **)existingProducts existingCategories:(NSArray *)existingCategories context:(NSManagedObjectContext *)localContext {
    __weak __typeof(self)weakSelf = self;
    @autoreleasepool {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        __block int processed = 0;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        // Save the products:
        [[strongSelf queue] inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                PKProduct *product = nil;
                NSMutableArray *currentImages = nil;
                
                int uuid = [resultSet intForColumnIfExists:@"ID"];
                
                for (PKProduct *p in *existingProducts) {
                    if ([[p uuid] intValue] == uuid) {
                        product = p;
                        [*existingProducts removeObject:p];
                        break;
                    }
                }
                
                if (!product) {
                    product = [PKProduct MR_createEntityInContext:localContext];
                }
                
                NSString *productId = [NSString stringWithFormat:@"%d", uuid];
                [product setUuid:@(uuid)];
                [product setProductId:productId];
                [product setFeedNumber:[[self feedConfig] number]];
                [product setModel:[resultSet stringForColumnIfExists:@"MODEL"]];
                [product setManufacturer:[resultSet stringForColumnIfExists:@"MANUFACTURER"]];
                [product setBarcode:[resultSet stringForColumnIfExists:@"BARCODE"]];
                [product setOrdered:@([resultSet intForColumnIfExists:@"ORDERED"])];
                [product setStockLevel:@([resultSet intForColumnIfExists:@"STOCKLEVEL"])];
                [product setAvailableStock:@([resultSet intForColumnIfExists:@"AVAILABLE_STOCK"])];
                [product setDateAdded:[resultSet dateForColumnIfExists:@"DATE_ADDED"]];
                [product setDateAvailable:[resultSet dateForColumnIfExists:@"DATE_AVAILABLE"]];
                
                [product setTitle:[resultSet stringForColumnIfExists:@"TITLE"]];
                [product setDescText:[resultSet stringForColumnIfExists:@"DESCRIPTION"]];
                [product setDimension:[resultSet stringForColumnIfExists:@"DIMENSION"]];
                [product setMaterial:[resultSet stringForColumnIfExists:@"MATERIAL"]];
                [product setBackOrders:@([resultSet intForColumnIfExists:@"BACK_ORDERS"])];
                [product setTotalSold:@([resultSet intForColumnIfExists:@"TOTAL_SOLD"])];
                [product setPosition:@([resultSet intForColumnIfExists:@"POSITION"])];
                [product setTotalValue:@([resultSet intForColumnIfExists:@"TOTAL_VALUE"])];
                [product setValuePosition:@([resultSet intForColumnIfExists:@"VALUE_POSITION"])];
                [product setVat:@([resultSet intForColumnIfExists:@"VAT"])];
                [product setMultiples:@([resultSet intForColumnIfExists:@"MULTIPLIES"])];
                [product setMinOrderQuantity:@([resultSet intForColumnIfExists:@"MIN_ORDER_QTY"])];
                [product setPurchaseUnit:@([resultSet intForColumnIfExists:@"PURCHASE_UNIT"])];
                [product setInner:@([resultSet intForColumnIfExists:@"INNER"])];
                [product setCarton:@([resultSet intForColumnIfExists:@"CARTON"])];
                [product setInactive:@([resultSet intForColumnIfExists:@"__DELETED"])];
                [product setPurchaseOrdersCSV:[resultSet stringForColumnIfExists:@"__PURCHASE_ORDERS"]];
                [product setIsNew:@([resultSet intForColumnIfExists:@"NEW"])];
                [product setIsNewStar:@([resultSet intForColumnIfExists:@"NEW_STAR"])];
                [product setIsNewEDC:@([resultSet intForColumnIfExists:@"NEW_EDC"])];
                [product setToBeDiscontinued:@([resultSet intForColumnIfExists:@"TBD"])];
                [product setLock_to_carton_qty:@([resultSet intForColumnIfExists:@"lock_to_carton_qty"])];
                [product setLock_to_carton_price:@([resultSet intForColumnIfExists:@"lock_to_carton_price"])];
//                [product setMAXIMUM_DISCOUNT:@([resultSet intForColumnIfExists:@"MAXIMUM_DISCOUNT"])];
                [product setBuyer:[resultSet stringForColumnIfExists:@"BUYER"]];
                [product setMonthsToSell:@([resultSet intForColumnIfExists:@"MONTHS_TO_SELL"])];
                                                
                // LUKE ADDED - 06/07/2017:
                [product setFobPrice:@([resultSet doubleForColumnIfExists:@"FOB_PRICE"])];
                [product setLandedCostPrice:@([resultSet doubleForColumnIfExists:@"LANDED_COST_PRICE"])];
                [product setPositionGlobal:@([resultSet doubleForColumnIfExists:@"POSITION_GLOBAL"])];
                [product setTotalSoldGlobal:@([resultSet doubleForColumnIfExists:@"TOTAL_SOLD_GLOBAL"])];
                [product setTotalValueGlobal:@([resultSet doubleForColumnIfExists:@"TOTAL_VALUE_GLOBAL"])];
                [product setValuePositionGlobal:@([resultSet doubleForColumnIfExists:@"VALUE_POSITION_GLOBAL"])];
                
                // LUKE ADDED - 18/05/2021 - EDC:
                [product setAvailableStockEDC:@([resultSet intForColumnIfExists:@"AVAILABLE_STOCK_EDC"])];
                [product setOrderedEDC:@([resultSet intForColumnIfExists:@"ORDERED_EDC"])];
                [product setFobPriceEDC:@([resultSet doubleForColumnIfExists:@"FOB_PRICE_EDC"])];
                [product setBackOrdersEDC:@([resultSet intForColumnIfExists:@"BACK_ORDERS_EDC"])];
                [product setStockLevelEDC:@([resultSet intForColumnIfExists:@"STOCKLEVEL_EDC"])];
                [product setDateAvailableEDC:[resultSet dateForColumnIfExists:@"DATE_AVAILABLE_EDC"]];
                
                
//                if ([[product model] isEqualToString:@"BUD319"]) {
//                    NSString *dateStr = [resultSet stringForColumn:@"DATE_AVAILABLE_EDC"];
//                    NSLog(@"%@", dateStr);
//                }
                
                [product setMonthsToSellEDC:@([resultSet intForColumnIfExists:@"MONTHS_TO_SELL_EDC"])];
                [product setLandedCostPriceEDC:@([resultSet doubleForColumnIfExists:@"LANDED_COST_PRICE_EDC"])];
                [product setToBeDiscontinuedEDC:@([resultSet intForColumnIfExists:@"TBD_EDC"])];
                [product setPurchaseOrdersCSVEDC:[resultSet stringForColumnIfExists:@"__PURCHASE_ORDERS_EDC"]];
                
                // Set the due date:
                NSString *dueDate = [resultSet stringForColumnIfExists:@"DATE_AVAILABLE"];
                dueDate = [dueDate stringByReplacingOccurrencesOfString:@" 00:00" withString:@" 12:00"];
                NSDate *result = [formatter dateFromString:dueDate];
                [product setDateDue:result];
                
                dueDate = [resultSet stringForColumnIfExists:@"DATE_AVAILABLE_EDC"];
                dueDate = [dueDate stringByReplacingOccurrencesOfString:@" 00:00" withString:@" 12:00"];
                result = [formatter dateFromString:dueDate];
                [product setDateDueEDC:result];
                
                // Remove the old categories:
//                [product removeCategories:[product categories]];
                
                [[product categories] enumerateObjectsUsingBlock:^(PKCategory *category, BOOL * _Nonnull stop) {
                    if ([[category isCustom] boolValue] == NO) {
                        [product removeCategoriesObject:category];
                    }
                }];
                
                // Setup the categories:
                NSMutableString *categoryIdsStr = [NSMutableString string];
                NSArray *categoryIds = [[resultSet stringForColumnIfExists:@"__CATEGORY_IDS"] componentsSeparatedByString:@","];
                [categoryIds enumerateObjectsUsingBlock:^(id categoryId, NSUInteger idx, BOOL *stop) {
                    if ([categoryId isKindOfClass:[NSString class]] && [categoryId length] != 0) {
                        
                        // Attempt to get the category:
                        NSPredicate *predicate = nil;
                        PKCategory *category = nil;
                        
                        @try {
                            // Try to create the predicate:
                            predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", categoryId];
                        } @catch (NSException *exception) {
                            predicate = nil;
                        } @finally {
                            // Filter the array of categories:
                            NSArray *filteredArray = nil;
                            if (existingCategories && predicate) {
                                filteredArray = [existingCategories filteredArrayUsingPredicate:predicate];
                            }
                            
                            if ([filteredArray count] > 1) {
                                NSLog(@"[%@] - Error: Filtered category array has more than one category", [self class]);
                            }
                            
                            // Get the from the array:
                            category = [filteredArray firstObject];
                        }
                        
                        // Attempt to assign the category:
                        @try {
                            if (category) {
                                [product addCategoriesObject:category];
                                [category addProductsObject:product];
                            }
                        } @catch (NSException *exception) {
                            NSLog(@"[%@] - Error: %@", [self class], [exception description]);
                        } @finally {
                        }
                        
                        [categoryIdsStr appendFormat:@"-%@-", categoryId];
                    }                    
                }];
                [product setCategoryIds:categoryIdsStr];
                
                //                        [existingCategories enumerateObjectsUsingBlock:^(PKCategory *category, NSUInteger idx, BOOL *stop) {
                //                            if ([[category categoryId] intValue] == [categoryId intValue]) {
                //                                [product addCategoriesObject:category];
                //                                [category addProductsObject:product];
                //                                *stop = YES;
                //                            }
                //                        }];
                
                // Setup the images:
                NSArray *images = [[resultSet stringForColumnIfExists:@"__IMAGES"] componentsSeparatedByString:@","];
                NSString *primaryImageName = [resultSet stringForColumnIfExists:@"__image_primary"];
                if (!currentImages) {
                    currentImages = [[[product images] allObjects] mutableCopy];
                }
                
                NSMutableArray *newImageNames = [NSMutableArray array];
                NSMutableArray *oldImageNames = [NSMutableArray array];
                [currentImages enumerateObjectsUsingBlock:^(PKImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([image name]) {
                        [oldImageNames addObject:[image name]];
                    }
                }];
                
                [images enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
                    // Ensure the filename is valid
                    if ([filename length] != 0) {
                        // Check if it needs to be added:
                        PKImage *image = nil;
                        
                        for (PKImage *i in currentImages) {
                            if ([[i name] isEqualToString:filename]) {
                                image = i;
                                [currentImages removeObject:i];
                                break;
                            }
                        }
                        
                        if (!image) {
                            // Create a new pointer to an image:
                            image = [PKImage createWithImageId:filename
                                                      atDomain:kPuckatorEndpointDefaultImageDomain
                                          forRelatedEntityUuid:productId
                                     forRelatedEntityClassType:@"Product"
                                                 forFeedConfig:[self feedConfig]
                                                     inContext:localContext];
                            if (filename) {
                                [newImageNames addObject:filename];
                            }
                        }
                        
                        // Inject the order into the object
                        [image setOrder:@(idx)];
                        
                        // Associate with product
                        [product addImagesObject:image];
                        
                        // Is this the first image?  Set as the primary image if so!
                        if ([filename isEqualToString:primaryImageName]) {
                            [product setMainImage:image];
                        }
                    }
                }];
                
                // Remove the other images:
                if ([currentImages count] != 0) {
                    //NSLog(@"[%@] - %@ images remain: %@", [self class], model, currentImages);
                    
                    [currentImages enumerateObjectsUsingBlock:^(PKImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
                        //NSLog(@"[%@] - Removing images for image named: %@", [self class], [image name]);
                        [PKFeedImages removeImageFilesNamed:[image name]];
                    }];
                    
                    [product removeImages:[NSSet setWithArray:currentImages]];
                    [localContext MR_deleteObjects:currentImages];
                }
                
                // Parse the product prices:
                NSArray *existingPrices = [[product prices] allObjects];
                for (int t = 0; t <= 2; t++) {
                    NSString *prefix = [NSString stringWithFormat:@"__price_t%d", t];
                    
                    int displayIndex = -1;
                    NSString *tier = [resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_price_tier", prefix]];
                    
                    if ([[tier uppercaseString] isEqualToString:@"NORMAL"]) {
                        displayIndex = 0;
                    } else if ([[tier uppercaseString] isEqualToString:@"T1"]) {
                        displayIndex = 1;
                    } else if ([[tier uppercaseString] isEqualToString:@"T2"]) {
                        displayIndex = 2;
                    }
                    
                    if (displayIndex < 0) {
                        continue;
                    }
                    
                    // Only parse the rest of the data if the display index is valid:
                    NSString *valueString = [resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_value", prefix]];
                    NSNumber *value = [NSDecimalNumber roundString:valueString];
                    
                    int quantity = [resultSet intForColumnIfExists:[NSString stringWithFormat:@"%@_qty", prefix]];
                    NSNumber *gbp = [NSDecimalNumber roundString:[resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_gbp", prefix]]];
                    NSNumber *eur = [NSDecimalNumber roundString:[resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_eur", prefix]]];
                    NSNumber *sek = [NSDecimalNumber roundString:[resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_sek", prefix]]];
                    NSNumber *pln = [NSDecimalNumber roundString:[resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_pln", prefix]]];
                    NSNumber *dkk = [NSDecimalNumber roundString:[resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_dkk", prefix]]];
                    NSNumber *rmb = [NSDecimalNumber roundString:[resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_rmb", prefix]]];
                    NSNumber *czk = [NSDecimalNumber roundString:[resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_czk", prefix]]];
                    NSNumber *old = [NSDecimalNumber roundString:[resultSet stringForColumnIfExists:[NSString stringWithFormat:@"%@_old_price", prefix]]];
                    
                    // Generate the product price objects:
                    PKProductPrice *price = nil;
                    for (PKProductPrice *p in existingPrices) {
                        if ([[p displayIndex] intValue] == displayIndex) {
                            price = p;
                            break;
                        }
                    }
                    
                    if (!price) {
                        price = [PKProductPrice createWithForProduct:product
                                                       forFeedConfig:[self feedConfig]
                                                           inContext:localContext];
                    }
                    
                    [price setDisplayIndex:@(displayIndex)];
                    
                    [price setValue:value];
                    [price setQuantity:@(quantity)];
                    [price setRateGBP:gbp];
                    [price setRateEUR:eur];
                    [price setRateSEK:sek];
                    [price setRatePLN:pln];
                    [price setRateDKK:dkk];
                    [price setRateRMB:rmb];
                    [price setRateCZK:czk];
                    [price setOldPrice:old];
                    
                    if (displayIndex == 0) {
                        [product setFirstPrice:value];
                    }
                    
                    // Add to the product:
                    [product addPricesObject:price];
                }
                
                // ---------------------
                // -- Product History --
                // ---------------------
                PKProductSaleHistory *saleHistory = [product saleHistory];
                if(!saleHistory) {
                    saleHistory = [PKProductSaleHistory MR_createEntityInContext:localContext];
                }
                
                // Get the history data from the SQL database:
                NSArray *historyPriorTwo = [[resultSet stringForColumnIfExists:@"__HISTORY_PRIOR_2_YR_QTY_SOLD"] componentsSeparatedByString:@","];
                NSArray *historyPrior = [[resultSet stringForColumnIfExists:@"__HISTORY_PRIOR_YR_QTY_SOLD"] componentsSeparatedByString:@","];
                NSArray *historyCurrent = [[resultSet stringForColumnIfExists:@"__HISTORY_QTY_SOLD"] componentsSeparatedByString:@","];
                                
                // Create a single array with all the returned history in:
                NSMutableArray *history = [NSMutableArray array];
                if ([historyPriorTwo count] == 12) {
                    [history addObjectsFromArray:historyPriorTwo];
                }
                if ([historyPrior count] == 12) {
                    [history addObjectsFromArray:historyPrior];
                }
                if ([historyCurrent count] == 12) {
                    [history addObjectsFromArray:historyCurrent];
                }
                
                // Check which version of the history has been returned:
                if ([history count] == 24) {
                    // Legacy history data found:
                    [history enumerateObjectsUsingBlock:^(NSString *h, NSUInteger idx, BOOL *stop) {
                        int month = (int)(idx + 1);
                        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"setPrior_%d:", month]);
                        if (month > 12) {
                            month = (month - 12);
                            selector = NSSelectorFromString([NSString stringWithFormat:@"setCurrent_%d:", month]);
                        }
                        
                        if ([saleHistory respondsToSelector:selector]) {
                            [saleHistory performSelector:selector withObject:@([h intValue])];
                        }
                    }];
                } else if ([history count] == 36) {
                    // New history data found:
                    [history enumerateObjectsUsingBlock:^(NSString *h, NSUInteger idx, BOOL *stop) {
                        int month = (int)(idx + 1);
                        SEL selector = nil;
                        
                        if (month <= 12) {
                            selector = NSSelectorFromString([NSString stringWithFormat:@"setPriorTwo_%d:", month]);
                        } else if (month <= 24) {
                            month = (month - 12);
                            selector = NSSelectorFromString([NSString stringWithFormat:@"setPrior_%d:", month]);
                        } else if (month <= 36) {
                            month = (month - 24);
                            selector = NSSelectorFromString([NSString stringWithFormat:@"setCurrent_%d:", month]);
                        }
                        
                        if ([saleHistory respondsToSelector:selector]) {
                            [saleHistory performSelector:selector withObject:@([h intValue])];
                        }
                    }];
                }
                
                [product setSaleHistory:saleHistory];
                // ---------------------
                
                // -------------------------
                // -- Product History EDC --
                // -------------------------
                saleHistory = [product saleHistoryEDC];
                if(!saleHistory) {
                    saleHistory = [PKProductSaleHistory MR_createEntityInContext:localContext];
                }
                
                // Get the history data from the SQL database:
                historyPriorTwo = [[resultSet stringForColumnIfExists:@"__HISTORY_PRIOR_2_YR_QTY_SOLD_EDC"] componentsSeparatedByString:@","];
                historyPrior = [[resultSet stringForColumnIfExists:@"__HISTORY_PRIOR_YR_QTY_SOLD_EDC"] componentsSeparatedByString:@","];
                historyCurrent = [[resultSet stringForColumnIfExists:@"__HISTORY_QTY_SOLD_EDC"] componentsSeparatedByString:@","];
                                
                // Create a single array with all the returned history in:
                history = [NSMutableArray array];
                if ([historyPriorTwo count] == 12) {
                    [history addObjectsFromArray:historyPriorTwo];
                }
                if ([historyPrior count] == 12) {
                    [history addObjectsFromArray:historyPrior];
                }
                if ([historyCurrent count] == 12) {
                    [history addObjectsFromArray:historyCurrent];
                }
                
                // Check which version of the history has been returned:
                if ([history count] == 24) {
                    // Legacy history data found:
                    [history enumerateObjectsUsingBlock:^(NSString *h, NSUInteger idx, BOOL *stop) {
                        int month = (int)(idx + 1);
                        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"setPrior_%d:", month]);
                        if (month > 12) {
                            month = (month - 12);
                            selector = NSSelectorFromString([NSString stringWithFormat:@"setCurrent_%d:", month]);
                        }
                        
                        if ([saleHistory respondsToSelector:selector]) {
                            [saleHistory performSelector:selector withObject:@([h intValue])];
                        }
                    }];
                } else if ([history count] == 36) {
                    // New history data found:
                    [history enumerateObjectsUsingBlock:^(NSString *h, NSUInteger idx, BOOL *stop) {
                        int month = (int)(idx + 1);
                        SEL selector = nil;
                        
                        if (month <= 12) {
                            selector = NSSelectorFromString([NSString stringWithFormat:@"setPriorTwo_%d:", month]);
                        } else if (month <= 24) {
                            month = (month - 12);
                            selector = NSSelectorFromString([NSString stringWithFormat:@"setPrior_%d:", month]);
                        } else if (month <= 36) {
                            month = (month - 24);
                            selector = NSSelectorFromString([NSString stringWithFormat:@"setCurrent_%d:", month]);
                        }
                        
                        if ([saleHistory respondsToSelector:selector]) {
                            [saleHistory performSelector:selector withObject:@([h intValue])];
                        }
                    }];
                }
                
                [product setSaleHistoryEDC:saleHistory];
                // ---------------------
                
                
                processed++;
                
                int total = [strongSelf skip] + processed;
                if (total % 100 == 0) {
                    [[self feedConfig] updateStatusText:[NSString stringWithFormat:NSLocalizedString(@"Products processed %d...", @"Used during the sync process to inform the user how many products have been processed."), total] withProgressStep:PKProgressStepImporting];
                }
            }
        }];
        
        [localContext MR_saveToPersistentStoreAndWait];
        [[strongSelf feedConfig] updateStatusText:[NSString stringWithFormat:NSLocalizedString(@"Products processed %d...", @"Used during the sync process to inform the user how many products have been processed."), ([strongSelf skip] + processed)] withProgressStep:PKProgressStepImporting];
            
        return processed;
    }
}

- (void)pkFeedProgress:(PKFeed *)feed progress:(float)progess {
    NSLog(@"Progress: %.2f", progess);
}

- (void)pkFeedDownload:(PKFeed *)feed success:(BOOL)success filePath:(NSURL *)filePath filename:(NSString *)filename error:(NSError *)error {
    if (success) {
        // Update progress
        __block NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Extracting %@...", @"Used during the sync process to inform the user which process is currently being extracted. E.g. 'Extracting Product...'"), [PKFeed pluralNameForFeedType:[self type]]];
        [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
        
        NSString *path = [NSString stringWithFormat:@"%@%@", [filePath filePathURL], [self filename]];
        path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSError *error = nil;
        if ([FCFileManager isFileItemAtPath:path error:&error]) {
            NSLog(@"[%@] - SQL located here: %@", [self class], filePath);
            NSString *folderPath = [PKFeedSQL folderPath];
            NSString *copyPath = [self filePathToSQLiteFile];
            
            // Create the folder if required:
            if (![FCFileManager isDirectoryItemAtPath:folderPath]) {
                [FCFileManager createDirectoriesForFileAtPath:folderPath];
            }
            
            // Remove the old sql file:
            if ([FCFileManager isFileItemAtPath:copyPath]) {
                NSLog(@"[%@] Is going to delete... %@", [self class], copyPath);
                BOOL didDelete = [FCFileManager removeItemAtPath:copyPath];
                NSLog(@"[%@] Did delete? %d", [self class], didDelete);
            }
            
            // Copy the temp file into a non-temp place:
            if ([FCFileManager copyItemAtPath:path toPath:copyPath error:&error]) {
                NSLog(@"[%@] - SQL move to here: %@", [self class], copyPath);
            }
        }
        
        if (error) {
            NSLog(@"[%@] - %@", [self class], [error description]);
        } else {
            //[[NSUserDefaults standardUserDefaults] objectForKey:@"account_sql_filename"]
            if ([self endpoint] == PKFeedSQLEndpointAccounts) {
                [[NSUserDefaults standardUserDefaults] setObject:filename forKey:@"account_sql_filename"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Importing %@...", @"Used during the sync process to inform the user which process is currently being importing. E.g. 'Importing Product...'"), [PKFeed pluralNameForFeedType:[self type]]];
                [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepImporting];
                
                // Create the indexes:
                [PKDatabase createIndexes];
            }
            
            // Restart the database:
            [[PKDatabase sharedInstance] restart];
            
            if ([self endpoint] == PKFeedSQLEndpointAccounts) {
                // Remove any local customers with 'real' customers:
                [PKLocalCustomer purgeReplacedCustomers];
            }
        }
        
        // Extract the dates:
        if ([self endpoint] == PKFeedSQLEndpointAccounts) {
            
        } else {
            FMDatabase *database = [FMDatabase databaseWithPath:[self filePathToSQLiteFile]];
            if ([database open]) {
                NSDate *dateGenerated = [database dateForQuery:@"select DATE_GENERATED from FeedMeta"];
                [PKFeedConfigMeta saveFeedMetaDataWithFeedConfig:[self feedConfig]
                                                           group:kPuckatorMetaGroupSqlDates
                                                             key:kPuckatorMetaKeySqlProductsGeneratedDate
                                                          object:dateGenerated];
                
                NSString *xmlFile = [database stringForQuery:@"select XML_CUSTOMER from FeedMeta"];
                [PKFeedConfigMeta saveFeedMetaDataWithFeedConfig:[self feedConfig]
                                                           group:kPuckatorMetaGroupSqlXmlFiles
                                                             key:kPuckatorMetaKeySqlXmlCustomerFile
                                                          object:xmlFile];
            }
        }
        
        if ([self endpoint] == PKFeedSQLEndpointAccounts) {
            // Update progress
            statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Success importing %@...", @"Used during the sync process to inform the user if a process was success during the sync process. E.g. 'Success importing Products'"), [PKFeed pluralNameForFeedType:[self type]]];
            [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepFinished];
            
            if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkFeedFinished:)]) {
                [[self delegate] pkFeedFinished:self];
            }
        } else {
            // Start parsing categories:
            [self beginParse];
        }
    } else {
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkFeedFinished:)]) {
            [[self delegate] pkFeedFinished:self];
        }
        
        // Update progress
        NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Error importing %@...", @"Used during the sync process to inform the user if a process failed during the sync process. E.g. 'Error importing Products'"), [PKFeed pluralNameForFeedType:[self type]]];
        
//        if([[[feed url] absoluteString] containsString:@"wiped-device"]) {
//            [[[PKSession instance] currentFeedConfig] syncData];
//        }
        
        [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepFinished];
    }
}

- (void)downloadFile {
}

#pragma mark -

@end
