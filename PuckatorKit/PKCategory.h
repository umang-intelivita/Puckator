//
//  PKCategory.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 30/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PKImage, PKProduct;

@interface PKCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * categoryId;
@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSNumber * do_not_bulk_discount;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleClean;
@property (nonatomic, retain) PKImage *mainImage;
@property (nonatomic, retain) NSSet *products;
@property (nonatomic, retain) NSNumber * isCustom;
@end

@interface PKCategory (CoreDataGeneratedAccessors)

- (void)addProductsObject:(PKProduct *)value;
- (void)removeProductsObject:(PKProduct *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
