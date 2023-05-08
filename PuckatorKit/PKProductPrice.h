//
//  PKProductPrice.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PKProduct;

@interface PKProductPrice : NSManagedObject

@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * priceTier;
@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSNumber * rateGBP;
@property (nonatomic, retain) NSNumber * rateEUR;
@property (nonatomic, retain) NSNumber * rateSEK;
@property (nonatomic, retain) NSNumber * ratePLN;
@property (nonatomic, retain) NSNumber * rateDKK;
@property (nonatomic, retain) NSNumber * rateRMB;
@property (nonatomic, retain) NSNumber * rateCZK;
@property (nonatomic, retain) NSNumber * oldPrice;
@property (nonatomic, retain) NSNumber * displayIndex;
@property (nonatomic, retain) PKProduct *product;

@end
