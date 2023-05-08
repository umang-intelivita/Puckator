//
//  PKBasketItem.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PKBasket;

@interface PKBasketItem : NSManagedObject

@property (nonatomic, retain) NSString * productUuid;
@property (nonatomic, retain) NSString * productModel;
@property (nonatomic, retain) NSString * productTitle;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * unitPrice;
@property (nonatomic, retain) NSNumber * fxRate;
@property (nonatomic, retain) NSString * fxIsoCode;
@property (nonatomic, retain) PKBasket *basket;
@property (nonatomic, retain) NSNumber * isCustomPriceSet;

@end
