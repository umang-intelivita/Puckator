//
//  PKCountry.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 20/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface PKCountry : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *isoCode;
@property (nonatomic, assign) int objectId;
@property (nonatomic, assign) int weight;
@property (nonatomic, assign) bool chargeVAT;

#pragma mark - Factories

+ (instancetype)create;
+ (instancetype)createFromResultSet:(FMResultSet *)resultSet;

#pragma mark - Class Methods

+ (NSArray*) allCountries;
+ (PKCountry*) countryWithNameLike:(NSString*)countryName;
+ (PKCountry*) countryWithExactName:(NSString*)countryName;

@end
