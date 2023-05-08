//
//  PKLocalAddress.h
//  Puckator
//
//  Created by Luke Dixon on 05/08/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PKLocalCustomer;

@interface PKLocalAddress : NSManagedObject

@property (nonatomic, retain) NSString * customerId;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * vat;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * lineOne;
@property (nonatomic, retain) NSString * lineTwo;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * iso;
@property (nonatomic, retain) NSNumber * idx;
@property (nonatomic, retain) PKLocalCustomer *customer;

@end
