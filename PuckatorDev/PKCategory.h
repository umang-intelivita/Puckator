//
//  PKCategory.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PKProduct;

@interface PKCategory : NSManagedObject

@property (nonatomic, retain) NSString * categoryId;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSSet *products;
@end

@interface PKCategory (CoreDataGeneratedAccessors)

- (void)addProductsObject:(PKProduct *)value;
- (void)removeProductsObject:(PKProduct *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
