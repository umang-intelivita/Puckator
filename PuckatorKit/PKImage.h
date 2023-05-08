//
//  PKImage.h
//  PuckatorDev
//
//  Created by Luke Dixon on 05/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PKProduct;

@interface PKImage : NSManagedObject

@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * relatedToClass;
@property (nonatomic, retain) NSString * relatedToUuid;
@property (nonatomic, retain) PKProduct *product;

@end
