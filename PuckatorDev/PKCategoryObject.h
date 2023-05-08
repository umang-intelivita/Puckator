//
//  PKCategoryObject.h
//  Puckator
//
//  Created by Aniruddha Kadam on 06/09/22.
//  Copyright © 2022 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKCategoryObject : NSObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * categoryId;
@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleClean;
@property (nonatomic, retain) PKImage *mainImage;
@property (nonatomic, retain) NSSet *products;
@property (nonatomic, retain) NSNumber * isCustom;

+ (PKCategoryObject *)getPastOrderCategory;

@end

NS_ASSUME_NONNULL_END
