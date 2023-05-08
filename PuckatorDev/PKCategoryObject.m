//
//  PKCategoryObject.m
//  Puckator
//
//  Created by Aniruddha Kadam on 06/09/22.
//  Copyright © 2022 57Digital Ltd. All rights reserved.
//

#import "PKCategoryObject.h"

@implementation PKCategoryObject

@synthesize active;
@synthesize categoryId;
@synthesize feedNumber;
@synthesize parent;
@synthesize sortOrder;
@synthesize title;
@synthesize titleClean;
@synthesize mainImage;
@synthesize products;
@synthesize isCustom;

+ (PKCategoryObject *)getPastOrderCategory {
    PKCategoryObject * category = [[PKCategoryObject alloc] init];
    category.feedNumber = @"sasd";
    category.active = [NSNumber numberWithInt:1];
    category.parent = [NSNumber numberWithInt:1];
    category.sortOrder = [NSNumber numberWithInt:1];
    category.title = @"Past Order";
    category.titleClean = @"Past Order";
    category.mainImage = [UIImage imageNamed:@"PKNoImage"];
    category.isCustom = [NSNumber numberWithInt:1];
    return category;
}

@end
