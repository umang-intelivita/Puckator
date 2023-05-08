//
//  PKAddress.h
//  PuckatorDev
//
//  Created by Luke Dixon on 03/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKDisplayData.h"
#import "FMDB.h"

@class PKCountry;

@interface PKAddress : NSObject <PKDisplayData>

@property (assign, nonatomic) int objectId;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *vat;
@property (strong, nonatomic) NSString *lineOne;
@property (strong, nonatomic) NSString *lineTwo;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *postcode;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *iso;
@property (assign, nonatomic) double geoLat;
@property (assign, nonatomic) double geoLong;
@property (strong, nonatomic) NSString *customerId;
@property BOOL isDefaultDeliveryAddress;
@property BOOL isDefaultInvoiceAddress;

+ (instancetype)create;
+ (instancetype)createFromResultSet:(FMResultSet *)resultSet;

+ (NSArray *)findAddressesForXMLFilename:(NSString *)xmlFilename defaultAddressesOnly:(BOOL)defaultOnly;

- (NSString *)multiLineAddress;
- (PKCountry *)pkCountry;

- (CLLocation *)location;
- (CLLocationCoordinate2D)coordinate;

@end
