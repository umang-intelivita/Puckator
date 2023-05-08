//
//  PKDatabase.m
//  PuckatorDev
//
//  Created by Luke Dixon on 05/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKDatabase.h"
#import "PKFeedSQL.h"
#import "PKCustomer.h"
#import <objc/message.h>

@interface PKDatabase ()

@property (strong, nonatomic) NSMutableDictionary *databases;
@property (strong, nonatomic) NSMutableDictionary *queues;

@end

@implementation PKDatabase

#pragma mark - Private Database Methods

+ (FMDatabase *)database:(PKDatabaseType)databaseType {
    return [[PKDatabase sharedInstance] openDatabase:databaseType];
}

+ (BOOL)isDatabaseHealthly:(PKDatabaseType)databaseType {
    // Check the file size of the database:
    NSString *databasePath = [PKFeedSQL filePathToSQLiteFile:databaseType];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:databasePath error:nil];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    int fileSize = [fileSizeNumber intValue];
    if (fileSize < 10) {
        return NO;
    }
    
    FMDatabase *database = [PKDatabase database:databaseType];
    if (database) {
        [database close];
        return YES;
    } else {
        return NO;
    }
}

- (FMDatabase *)openDatabase:(PKDatabaseType)databaseType {
    NSString *databasePath = [PKFeedSQL filePathToSQLiteFile:databaseType];
    
    FMDatabase *database = nil;
    if ([databasePath length] != 0) {
        database = [FMDatabase databaseWithPath:databasePath];
    }
    
    BOOL databaseOpened = [database goodConnection];
    if (!databaseOpened) {
        NSLog(@"[%@] - Opening data of type: %d", [self class], (int)databaseType);
        
        //[database openWithFlags:SQLITE_OPEN_READWRITE];
        [database open];
        databaseOpened = [database goodConnection];
    }
    
    if (databaseOpened) {
        // Save the database for next time:
        if (![self databases]) {
            [self setDatabases:[NSMutableDictionary dictionary]];
        }
        
        [[self databases] setObject:database forKey:@(databaseType)];
        return database;
    } else {
        return nil;
    }
}

- (BOOL)closeDatabase:(FMDatabase *)database {
    [database closeOpenResultSets];
    return [database close];
}

- (BOOL)closeDatabaseType:(PKDatabaseType)databaseType {
    NSLog(@"[%@] - Closing data of type: %d", [self class], (int)databaseType);
    return [[self database:databaseType] close];
}

- (FMDatabase *)database:(PKDatabaseType)databaseType {
    FMDatabase *database = [[self databases] objectForKey:@(databaseType)];

    if (![database goodConnection]) {
        NSLog(@"[%@] - Closing data of type: %d", [self class], (int)databaseType);
        [self closeDatabase:database];
        database = nil;
    }
    
    if (!database) {
        database = [self openDatabase:databaseType];
    }
    
    return database;
}

- (FMDatabaseQueue *)queue:(PKDatabaseType)databaseType {
    if (![self queues]) {
        [self setQueues:[NSMutableDictionary dictionary]];
    }
    
    // Attempt to get the queue:
    FMDatabaseQueue *queue = [[self queues] objectForKey:@(databaseType)];
    
    if (!queue) {
        NSString *databasePath = [PKFeedSQL filePathToSQLiteFile:databaseType];
        if ([databasePath length] != 0) {
            queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        }
    }
    
    if (queue) {
        [[self queues] setObject:queue forKey:@(databaseType)];
    }
    
    return queue;
}

- (BOOL)closeQueues {
    [[self queues] enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[FMDatabaseQueue class]]) {
            FMDatabaseQueue *queue = (FMDatabaseQueue *)obj;
            [queue close];
        }
    }];
    
    [[self queues] removeAllObjects];
    return ([[self queues] count] == 0);
}

#pragma mark - Private Methods

//- (int)intForQuery:(NSString *)query database:(PKDatabaseType)databaseType {
//    int count = 0;
//    
//    if ([query length] != 0) {
//        count = (int)[[self database:databaseType] intForQuery:query];
//    }
//    
//    return count;
//}
//
//- (NSDate *)dateForQuery:(NSString *)query database:(PKDatabaseType)databaseType {
//    NSDate *date = nil;
//    
//    if ([query length] != 0) {
//        date = (NSDate *)[[self database:databaseType] dateForQuery:query];
//    }
//    
//    if (!date) {
//        int epoch = [[self database:databaseType] intForQuery:query];
//        if (epoch != 0) {
//            date = [NSDate dateWithTimeIntervalSince1970:epoch];
//        }
//    }
//    
//    return date;
//}

//- (FMResultSet *)executeQuery:(NSString *)query database:(PKDatabaseType)databaseType {
//    // Determine if the query is valid:
//    if ([query length] != 0) {
//        // Query is valid therefore run it on the database:
//        __block FMResultSet *resultSet = nil;
//        FMDatabaseQueue *queue = [self queue:databaseType];
//        if (queue) {
//            [queue inDatabase:^(FMDatabase *db) {
//                resultSet = [db executeQuery:query];
//            }];
//        }
//        
//        return resultSet;
//    }
//    
//    // Query wasn't valid therefore return nil:
//    return nil;
//}

+ (FMResultSet *)executeQuery:(NSString *)query database:(PKDatabaseType)databaseType resultSet:(void (^)(FMResultSet *resultSet))block {
    return [[PKDatabase sharedInstance] executeQuery:query database:databaseType resultSet:block];
}

- (FMResultSet *)executeQuery:(NSString *)query database:(PKDatabaseType)databaseType resultSet:(void (^)(FMResultSet *resultSet))block {
    // Determine if the query is valid:
    if ([query length] != 0) {
        // Query is valid therefore run it on the database:
        __block FMResultSet *resultSet = nil;
        FMDatabaseQueue *queue = [self queue:databaseType];
        if (queue) {
            [queue inDatabase:^(FMDatabase *db) {
                resultSet = [db executeQuery:query];
                if (block) {
                    block(resultSet);
                }
            }];
        }
        
        return resultSet;
    }
    
    // Query wasn't valid therefore return nil:
    return nil;
}

- (BOOL)executeUpdate:(NSString *)update database:(PKDatabaseType)databaseType {
    __block BOOL success = NO;
    if ([update length] != 0) {
//        return [[self database:databaseType] executeUpdate:update];
        FMDatabaseQueue *queue = [self queue:databaseType];
        [queue inDatabase:^(FMDatabase *db) {
            success = [db executeUpdate:update];
        }];
    }
    
    return success;
}

#pragma mark - Public Methods

+ (BOOL)createIndexes {
    BOOL success = YES;
    
    // Create the invoice index:
    NSString *sql = [NSString stringWithFormat:@"CREATE INDEX if not exists invoice_index on Invoice (ID, SAGE_ID);"];
    if (![PKDatabase executeUpdate:sql database:PKDatabaseTypeAccounts]) {
        success = NO;
    }
    
    // Create the invoice line index:
    sql = [NSString stringWithFormat:@"CREATE INDEX if not exists invoice_line_index on InvoiceLine (__INVOICE_ID);"];
    if (![PKDatabase executeUpdate:sql database:PKDatabaseTypeAccounts]) {
        success = NO;
    }
    
    // Create the customer index:
    sql = [NSString stringWithFormat:@"CREATE INDEX if not exists customer_index on Customer (ID, SAGE_ID, COMPANY_NAME, CONTACT_NAME);"];
    if (![PKDatabase executeUpdate:sql database:PKDatabaseTypeAccounts]) {
        success = NO;
    }
    
    // Create the address index:
    sql = [NSString stringWithFormat:@"CREATE INDEX if not exists address_index on Address (__CUSTOMER_ID, __ID, ADDRESS_CITY, ADDRESS_POSTCODE);"];
    if (![PKDatabase executeUpdate:sql database:PKDatabaseTypeAccounts]) {
        success = NO;
    }
    
    // Create the price history index:
    sql = [NSString stringWithFormat:@"CREATE INDEX if not exists price_history_index on PriceHistory (PRODUCT_ID, CURRENCY);"];
    if (![PKDatabase executeUpdate:sql database:PKDatabaseTypeAccounts]) {
        success = NO;
    }
    
    // Return success or fail:
    return success;
}

+ (BOOL)closeDatabase:(PKDatabaseType)databaseType {
    return [[PKDatabase sharedInstance] closeDatabaseType:databaseType];
}

//+ (int)intForQuery:(NSString *)query database:(PKDatabaseType)databaseType {
//    return [[PKDatabase sharedInstance] intForQuery:query database:databaseType];
//}
//
//+ (NSDate *)dateForQuery:(NSString *)query database:(PKDatabaseType)databaseType {
//    return [[PKDatabase sharedInstance] dateForQuery:query database:databaseType];
//}

+ (BOOL)executeUpdate:(NSString *)update database:(PKDatabaseType)databaseType {
    return [[PKDatabase sharedInstance] executeUpdate:update database:databaseType];
}

//+ (FMResultSet *)executeQuery:(NSString *)query database:(PKDatabaseType)databaseType {
//    return [[PKDatabase sharedInstance] executeQuery:query database:databaseType];
//}

- (void)restart {
    [[self databases] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[FMDatabase class]]) {
            FMDatabase *database = (FMDatabase *)obj;
            [database close];
        }
    }];
    
    // Clear the database array:
    [[self databases] removeAllObjects];
    
    // Close the queues too:
    [self closeQueues];
}

#pragma mark -

//+ (void)executeQuery:(NSString *)query
//           classType:(Class)classType
//           chuckSize:(int)chuckSize
//             newData:(void (^)(NSArray *))newData
//           completed:(void (^)(BOOL))completion {
//    SEL selector = @selector(createFromResultSet:);
//    if (class_getClassMethod(classType, selector) != nil) {
//        [FSThread runInBackground:^{
//            // Init the data:
//            FMDatabase *database = [FMDatabase databaseWithPath:[PKFeedSQL filePathToSQLiteFile]];
//            
//            // Open the database:
//            if ([database open]) {
//                // Run the query:
//                FMResultSet *resultSet = [database executeQuery:query];
//                
//                // Used to build up the chucks of objects:
//                NSMutableArray *objects = [NSMutableArray array];
//                
//                // Loop the results:
//                while ([resultSet next]) {
//                    id object = [classType performSelector:selector withObject:resultSet];
//                    
//                    if (object != nil && [object isKindOfClass:classType]) {
//                        [objects addObject:object];
//                    }
//                    
//                    if ([objects count] == chuckSize) {
//                        // Update the UI:
//                        __block NSArray *newObjects = [objects copy];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            newData([newObjects copy]);
//                            newObjects = nil;
//                        });
//                        
//                        [objects removeAllObjects];
//                    }
//                }
//                
//                // Send the rest of the objects:
//                if ([objects count] != 0) {
//                    // Update the UI:
//                    __block NSArray *newObjects = [objects copy];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        newData([newObjects copy]);
//                        newObjects = nil;
//                    });
//                    
//                    [objects removeAllObjects];
//                }
//                
//                // Close the database:
//                [database close];
//                
//                // Call complete:
//                if (completion) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        completion(YES);
//                    });
//                }
//            } else {
//                // Report the failure to open the database:
//                if (completion) {
//                    completion(NO);
//                }
//            }
//        }];
//    } else {
//        NSLog(@"[%@] - The classType of '%@' does not respond to selector: '%@'", [self class], classType, NSStringFromSelector(selector));
//        if (completion) {
//            completion(NO);
//        }
//    }
//}

#pragma mark -

@end
