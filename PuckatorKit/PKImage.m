//
//  PKImage.m
//  PuckatorDev
//
//  Created by Luke Dixon on 05/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKImage.h"
#import "PKProduct.h"
#import "PKImage+Operations.h"

@implementation PKImage

@dynamic domain;
@dynamic feedNumber;
@dynamic name;
@dynamic order;
@dynamic relatedToClass;
@dynamic relatedToUuid;
@dynamic product;

- (void)dealloc {
//    [self removeCachedImage];
}

@end
