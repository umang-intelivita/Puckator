//
//  PKPurchaseOrder.h
//  Puckator
//
//  Created by Luke Dixon on 18/09/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PKShipmentStatusNotShipped = 0,
    PKShipmentStatusShipped = 1
} PKShipmentStatus;

@interface PKPurchaseOrder : NSObject

@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSNumber *quantity;
@property (assign, nonatomic) PKShipmentStatus shipmentStatus;

+ (instancetype)createWithNumber:(NSString *)number dateString:(NSString *)dateString quantityString:(NSString *)quantityString;
- (NSString *)formattedDescription;

@end
