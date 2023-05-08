//
//  PKAddress.m
//  PuckatorDev
//
//  Created by Luke Dixon on 03/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKAddress.h"
#import "FMResultSet+Additional.h"
#import "PKTranslate.h"
#import "NSString+Utils.h"
#import "PKCountry.h"

@implementation PKAddress

+ (instancetype)create {
    return [[PKAddress alloc] init];
}

+ (instancetype)createFromResultSet:(FMResultSet *)resultSet {
    PKAddress *address = [PKAddress create];
    
    [address setObjectId:[resultSet intForColumnIfExists:@"__ID"]];
    [address setCompanyName:[resultSet stringForColumnIfExists:@"ADDRESS_COMPANY"]];
    [address setContactName:[resultSet stringForColumnIfExists:@"ADDRESS_NAME"]];
    [address setVat:[resultSet stringForColumnIfExists:@"ADDRESS_VAT"]];
    [address setLineOne:[resultSet stringForColumnIfExists:@"ADDRESS_ONE"]];
    [address setLineTwo:[resultSet stringForColumnIfExists:@"ADDRESS_TWO"]];
    [address setPostcode:[resultSet stringForColumnIfExists:@"ADDRESS_POSTCODE"]];
    [address setCity:[resultSet stringForColumnIfExists:@"ADDRESS_CITY"]];
    [address setState:[resultSet stringForColumnIfExists:@"ADDRESS_STATE"]];
    [address setCountry:[resultSet stringForColumnIfExists:@"ADDRESS_COUNTRY"]];
    [address setIso:[resultSet stringForColumnIfExists:@"ADDRESS_ISO"]];
    [address setGeoLat:[resultSet doubleForColumnIfExists:@"ADDRESS_GEO_LAT"]];
    [address setGeoLong:[resultSet doubleForColumnIfExists:@"ADDRESS_GEO_LNG"]];
    [address setCustomerId:[resultSet stringForColumnIfExists:@"CUSTOMER_ID"]];
    [address setIsDefaultDeliveryAddress:([resultSet intForColumnIfExists:@"ADDRESS_DEFAULT_DELIVERY"] == 0 ? NO : YES)];
    
    return address;
}

+ (NSArray *)findAddressesForXMLFilename:(NSString *)xmlFilename defaultAddressesOnly:(BOOL)defaultOnly {
    NSMutableArray *addresses = [NSMutableArray array];
    
    NSString *query = [NSString stringWithFormat:@"SELECT DISTINCT A.__ID AS __ID, A.ADDRESS_GEO_LAT, A.ADDRESS_COMPANY, A.ADDRESS_GEO_LNG, A.ADDRESS_ONE, A.ADDRESS_POSTCODE, A.ADDRESS_DEFAULT_DELIVERY, C.ID AS CUSTOMER_ID FROM Address AS A JOIN Customer AS C ON A.__CUSTOMER_ID = C.ID JOIN Schema AS S ON C.__FROM == S.ID WHERE S.FILE == '%@' AND A.ADDRESS_GEO_LAT != 0 AND A.ADDRESS_GEO_LNG != 0", xmlFilename];
    
    if (defaultOnly) {
        query = [query stringByAppendingString:@" AND A.__ID = C.DEFAULT_ADDRESS_ID"];
    }
    
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKAddress *address = [PKAddress createFromResultSet:resultSet];
            if (address) {
                [addresses addObject:address];
            }
        }
    }];
    
    return addresses;
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:[self coordinate].latitude longitude:[self coordinate].longitude];
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self geoLat], [self geoLong]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n----------\nAddress (ID: %i):\n----------\n Company Name: %@ (%@)\n Contact Name: %@\n Geo Lat: %.5f\n Geo Long: %.5f\n Line 1: %@\n Line 2: %@\n City: %@\n Postcode: %@\n State: %@\n Country: %@\n ISOs: %@\nVAT: %@",
            [self objectId],
            [self companyName],
            [self customerId],
            [self contactName],
            [self geoLat],
            [self geoLong],
            [self lineOne],
            [self lineTwo],
            [self city],
            [self postcode],
            [self state],
            [self country],
            [self iso],
            [self vat]];
}

- (PKDisplayData *)displayData {
    PKDisplayData *displayData = [PKDisplayData create];
    
    [displayData openSection];
    [displayData addTitle:NSLocalizedString(@"Company Name", nil) data:[self companyName]];
    [displayData addTitle:NSLocalizedString(@"VAT", nil) data:[self vat]];
    [displayData addTitle:NSLocalizedString(@"Contact Name", nil) data:[self contactName]];
    [displayData closeSection];
    
    [displayData openSection];
    
    if ([self isDefaultInvoiceAddress]) {
        [displayData addTitle:NSLocalizedString(@"Default Invoice Address", nil) data:[self lineOne]];
    } else if ([self isDefaultDeliveryAddress]) {
        [displayData addTitle:NSLocalizedString(@"Default Delivery Address", nil) data:[self lineOne]];
    } else {
        [displayData addTitle:NSLocalizedString(@"Address", nil) data:[self lineOne]];
    }
    
    [displayData addTitle:nil data:[self lineOne]];
    [displayData addTitle:nil data:[self lineTwo]];
    [displayData addTitle:nil data:[self city]];
    [displayData addTitle:nil data:[self postcode]];
    [displayData addTitle:nil data:[self state]];
    [displayData addTitle:nil data:[self country]];
    
    [displayData closeSection];
    
    return displayData;
}

- (NSString *)multiLineAddress {
    NSMutableString *string = [NSMutableString string];
    
    if ([self isDefaultInvoiceAddress]) {
        [string appendFormat:@"%@:\n", NSLocalizedString(@"Default Invoice Address", nil)];
    }
    if ([self isDefaultDeliveryAddress]) {
        [string appendFormat:@"%@:\n", NSLocalizedString(@"Default Delivery Address", nil)];
    }
    
    if ([[[self companyName] sanitize] length] != 0) {
        [string appendFormat:@"%@\n", [[self companyName] sanitize]];
    }
    
    if ([[[self contactName] sanitize] length] != 0) {
        [string appendFormat:@"%@\n", [[self contactName] sanitize]];
    }
    
    if ([[[self lineOne] sanitize] length] != 0) {
        [string appendFormat:@"%@\n", [[self lineOne] sanitize]];
    }
    
    if ([[[self lineTwo] sanitize] length] != 0) {
        [string appendFormat:@"%@\n", [[self lineTwo] sanitize]];
    }
    
    if ([[[self city] sanitize] length] != 0) {
        [string appendFormat:@"%@\n", [[self city] sanitize]];
    }
    
    if ([[[self postcode] sanitize] length] != 0) {
        [string appendFormat:@"%@\n", [[self postcode] sanitize]];
    }
    
    if ([[[self state] sanitize] length] != 0) {
        [string appendFormat:@"%@\n", [[self state] sanitize]];
    }
    
    if ([[[self country] sanitize] length] != 0) {
        [string appendFormat:@"%@\n", [[self country] sanitize]];
    }
    
    if ([[string sanitize] length] > 2) {
        return [[string sanitize] substringToIndex:([string length] - 1)];
    } else {
        return nil;
    }
}

- (CGFloat)heightForMultiLineAddress {
    return [[self multiLineAddress] sizeWithAttributes:nil].height;
}

- (PKCountry *)pkCountry {
    return [PKCountry countryWithExactName:[self country]];
}

@end
