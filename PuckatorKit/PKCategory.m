//
//  PKCategory.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 30/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCategory.h"
#import "PKImage.h"
#import "PKProduct.h"

@implementation PKCategory

@dynamic active;
@dynamic categoryId;
@dynamic feedNumber;
@dynamic parent;
@dynamic do_not_bulk_discount;
@dynamic sortOrder;
@dynamic title;
@dynamic titleClean;
@dynamic mainImage;
@dynamic products;
@dynamic isCustom;


- (void)dealloc {
    //NSLog(@"[%@] - Dealloc'd", [self class]);
}
@end
