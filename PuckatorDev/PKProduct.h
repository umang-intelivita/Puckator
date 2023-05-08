//
//  PKProduct.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PKDataObject.h"

@class PKImage;

@interface PKProduct : PKDataObject

@property (nonatomic, retain) NSNumber * availableStock;
@property (nonatomic, retain) NSNumber * backOrders;
@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSNumber * carton;
@property (nonatomic, retain) NSString * descText;
@property (nonatomic, retain) NSString * dimension;
@property (nonatomic, retain) NSNumber * inner;
@property (nonatomic, retain) NSString * manufacturer;
@property (nonatomic, retain) NSString * material;
@property (nonatomic, retain) NSNumber * minOrderQuantity;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSNumber * ordered;
@property (nonatomic, retain) NSNumber * multiples;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * purchaseUnit;
@property (nonatomic, retain) NSNumber * stockLevel;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalSold;
@property (nonatomic, retain) NSNumber * totalValue;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * valuePosition;
@property (nonatomic, retain) NSNumber * vat;
@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSSet *images;
@end

@interface PKProduct (CoreDataGeneratedAccessors)

- (void)addImagesObject:(PKImage *)value;
- (void)removeImagesObject:(PKImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
