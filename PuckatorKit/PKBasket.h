//
//  PKBasket.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 21/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PKBasketItem, PKOrder;

@interface PKBasket : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSString * customerId;
@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * wasSent;
@property (nonatomic, retain) NSNumber * basketStatus;
@property (nonatomic, retain) NSNumber * vatRate;
@property (nonatomic, retain) NSNumber * discountRate;
@property (nonatomic, retain) NSNumber * deliveryPrice;
@property (nonatomic, retain) NSNumber * deliveryPriceOverride;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) PKOrder *order;
@end

@interface PKBasket (CoreDataGeneratedAccessors)

- (void)addItemsObject:(PKBasketItem *)value;
- (void)removeItemsObject:(PKBasketItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
