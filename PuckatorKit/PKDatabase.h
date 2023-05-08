//
//  PKDatabase.h
//  PuckatorDev
//
//  Created by Luke Dixon on 05/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "DOSingleton.h"
#import "FMDB.h"

typedef enum : NSUInteger {
    PKDatabaseTypeAccounts,
    PKDatabaseTypeProducts
} PKDatabaseType;

@interface PKDatabase : DOSingleton

@property (nonatomic, strong) NSString *feedNumber;

// Restarts the database after sync
+ (FMDatabase *)database:(PKDatabaseType)databaseType;
+ (BOOL)isDatabaseHealthly:(PKDatabaseType)databaseType;
- (void)restart;

//+ (int)intForQuery:(NSString *)query database:(PKDatabaseType)databaseType;
//+ (NSDate *)dateForQuery:(NSString *)query database:(PKDatabaseType)databaseType;
//- (int)intForQuery:(NSString *)query;

//+ (FMResultSet *)executeQuery:(NSString *)query database:(PKDatabaseType)databaseType;
+ (FMResultSet *)executeQuery:(NSString *)query database:(PKDatabaseType)databaseType resultSet:(void (^)(FMResultSet *resultSet))block;
//- (FMResultSet *)executeQuery:(NSString *)query database:(PKDatabaseType)databaseType resultSet:(void (^)(FMResultSet *resultSet))block;

+ (BOOL)executeUpdate:(NSString *)update database:(PKDatabaseType)databaseType;

+ (BOOL)closeDatabase:(PKDatabaseType)databaseType;
+ (BOOL)createIndexes;

//- (FMResultSet *)executeQuery:(NSString *)query;

//+ (void)executeQuery:(NSString *)query
//           classType:(Class)classType
//           chuckSize:(int)chuckSize
//             newData:(void (^)(NSArray *newData))newData
//           completed:(void (^)(BOOL finished))completion;

@end
