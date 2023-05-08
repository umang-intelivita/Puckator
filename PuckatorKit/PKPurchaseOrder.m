//
//  PKPurchaseOrder.m
//  Puckator
//
//  Created by Luke Dixon on 18/09/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKPurchaseOrder.h"

@implementation PKPurchaseOrder

+ (instancetype)createWithNumber:(NSString *)number dateString:(NSString *)dateString quantityString:(NSString *)quantityString {
    // Remove the time from the date string:
    dateString = [[dateString componentsSeparatedByString:@" "] firstObject];
    
    PKPurchaseOrder *purchaseOrder = [[PKPurchaseOrder alloc] init];
    
    [purchaseOrder setNumber:[NSNumber numberWithInt:[number intValue]]];
    [purchaseOrder setQuantity:[NSNumber numberWithInt:[quantityString intValue]]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    [purchaseOrder setDate:[formatter dateFromString:dateString]];
    [purchaseOrder setDateString:dateString];
    
    return purchaseOrder;
}

- (NSString *)formattedDescription {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    if ([self shipmentStatus] == PKShipmentStatusShipped) {
        return [NSString stringWithFormat:@"%@ (%d) 🚢", [dateFormatter stringFromDate:[self date]], [[self quantity] intValue]];
    }
    
    return [NSString stringWithFormat:@"%@ (%d)", [dateFormatter stringFromDate:[self date]], [[self quantity] intValue]];
}

@end
