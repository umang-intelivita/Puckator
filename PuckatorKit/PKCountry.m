//
//  PKCountry.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 20/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCountry.h"
#import "FMResultSet+Additional.h"
#import "PKDatabase.h"

@implementation PKCountry

#pragma mark - Factories

+ (instancetype)create {
    return [[PKCountry alloc] init];
}

+ (instancetype)createFromResultSet:(FMResultSet *)resultSet {
    PKCountry *country = [PKCountry create];
    
    [country setObjectId:[resultSet intForColumnIfExists:@"ID"]];
    [country setIsoCode:[resultSet stringForColumnIfExists:@"ISO_CODE_2"]];
    [country setName:[resultSet stringForColumnIfExists:@"NAME"]];
    [country setChargeVAT:[resultSet boolForColumnIfExists:@"VAT_CHARGED"]];
    
    // Apply weights...
    if ([[country isoCode] isEqualToString:@"GB"]) {
        [country setWeight:1000];
    } else if([[country isoCode] isEqualToString:@"GV"]) {
        [country setWeight:999];
    } else if([[country isoCode] isEqualToString:@"GG"]) {
        [country setWeight:998];
    } else if([[country isoCode] isEqualToString:@"FR"]) {
        [country setWeight:997];
    } else if([[country isoCode] isEqualToString:@"ES"]) {
        [country setWeight:996];
    } else {
        [country setWeight:0];
    }
    
    return country;
}

#pragma mark - Class Methods

+ (NSArray*) allCountries {
    NSMutableArray *countries = [NSMutableArray array];
    
    [PKDatabase executeQuery:@"SELECT * from Country ORDER BY NAME" database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKCountry *country = [PKCountry createFromResultSet:resultSet];
            if (country) {
                [countries addObject:country];
            }
        }
    }];
    // Finally, sort by weight then name
    [countries sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:NO],
                                      [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    return countries;
}

+ (PKCountry*) countryWithExactName:(NSString*)countryName {
    NSMutableArray *countries = [NSMutableArray array];
    [PKDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM Country WHERE name = '%@' COLLATE NOCASE", countryName] database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKCountry *country = [PKCountry createFromResultSet:resultSet];
            if (country) {
                [countries addObject:country];
            }
        }
    }];
    if ([countries count] >= 1) {
        return [countries firstObject];
    } else {
        return nil;
    }
}

+ (PKCountry*) countryWithNameLike:(NSString*)countryName {
    NSMutableArray *countries = [NSMutableArray array];
    [PKDatabase executeQuery:[NSString stringWithFormat:@"SELECT * from Country WHERE name LIKE '%%%@%%'", countryName] database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKCountry *country = [PKCountry createFromResultSet:resultSet];
            if (country) {
                [countries addObject:country];
            }
        }
    }];
    if ([countries count] >= 1) {
        return [countries firstObject];
    } else {
        return nil;
    }
}

@end
