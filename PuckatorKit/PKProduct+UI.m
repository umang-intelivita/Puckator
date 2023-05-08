//
//  PKProduct+UI.m
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProduct+UI.h"
#import <MKFoundationKit/MKFoundationKit.h>

@implementation PKProduct (UI)

- (NSString *)topGrossingTitle {
    int rankGrossing = [[self valuePosition] intValue];
    if (rankGrossing > 0 && rankGrossing <= 100) {
        return NSLocalizedString(@"Top 100 Grossing", nil);
    } else if (rankGrossing > 100 && rankGrossing <= 300) {
        return NSLocalizedString(@"Top 300 Grossing", nil);
    } else if (rankGrossing > 300 && rankGrossing <= 500) {
        return NSLocalizedString(@"Top 500 Grossing", nil);
    } else {
        return nil;
    }
}

- (NSString *)topSellerTitle {
    int rankSeller = [[self position] intValue];
    if (rankSeller > 0 && rankSeller <= 100) {
        return NSLocalizedString(@"Top 100 Seller", nil);
    } else if (rankSeller > 100 && rankSeller <= 300) {
        return NSLocalizedString(@"Top 300 Seller", nil);
    } else if (rankSeller > 300 && rankSeller <= 500) {
        return NSLocalizedString(@"Top 500 Seller", nil);
    } else {
        return nil;
    }
}

- (NSString *)dueDateString {
    int qty = [[self ordered] intValue];
    NSString *dueDateString = nil;
    
    if (qty > 0) {
        if ([[self dateDue] mk_isLaterThanDate:[NSDate date]]) {
            dueDateString = [NSString stringWithFormat:@"(%d) %@", qty, [[self dateDue] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]]];
        }
    }
    
    return dueDateString;
}

- (NSString *)nextDueDateFormatted {
    __block NSString *formattedQty = [NSString string];
    
    // Add the due date:
    __block NSString *dateTitle = nil;
    __block NSString *dateValue = nil;
    __block NSString *formattedDate = nil;
    NSString *formattedDueDate = nil;
    
    if ([[self purchaseOrders] count] == 0) {
        if ([[self dateAvailable] mk_isLaterThanDate:[NSDate date]]) {
            dateTitle = NSLocalizedString(@"Due in", nil);
        } else {
            dateTitle = NSLocalizedString(@"Last received", nil);
        }
        
        formattedDate = [[self dateAvailable] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]];

        if ([[self ordered] intValue] > 0) {
            formattedQty = [NSString stringWithFormat:@"(%d)", [[self ordered] intValue]];
        }
    } else {
        [[self purchaseOrders] enumerateObjectsUsingBlock:^(PKPurchaseOrder *purchaseOrder, NSUInteger idx, BOOL *stop) {
            // Don't show any purchase orders that have the same date as the due in date:
            if ([[purchaseOrder date] mk_isLaterThanDate:[NSDate date]]) {
                // [displayData addTitle:@"P/O" data:[purchaseOrder formattedDescription]];
                dateTitle = NSLocalizedString(@"Due in", nil);
            } else {
                dateTitle = NSLocalizedString(@"Last received", nil);
            }
            
            formattedDate = [[purchaseOrder date] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]];
                
            if ([purchaseOrder shipmentStatus] == PKShipmentStatusShipped) {
                dateTitle = [NSString stringWithFormat:@"🚢 %@", dateTitle];
            }
            
            if ([[purchaseOrder quantity] intValue] > 0) {
                formattedQty = [NSString stringWithFormat:@"(%d)", [[purchaseOrder quantity] intValue]];
            }
            *stop = YES;
        }];
    }
    
    // Check the formatted date is valid:
    if ([formattedDate length] == 0 || [formattedDate containsString:@"null"]) {
        formattedDate = nil;
    }
    
    if ([dateValue length] == 0) {
        if ([formattedQty length] != 0) {
            dateValue = [NSString stringWithFormat:@"%@ %@", formattedDate, formattedQty];
        } else {
            dateValue = [NSString stringWithFormat:@"%@", formattedDate];
        }
    }
    
    if ([dateTitle length] != 0 && [dateValue length] != 0) {
        formattedDueDate = [NSString stringWithFormat:@"%@ %@", dateTitle, dateValue];
    }
    
    return formattedDueDate;
}

- (NSString *)nextDueDateFormattedEDC {
    __block NSString *formattedQty = [NSString string];
    
    // Add the due date:
    __block NSString *dateTitle = nil;
    __block NSString *dateValue = nil;
    __block NSString *formattedDate = nil;
    NSString *formattedDueDate = nil;
    
    if ([[self purchaseOrdersEDC] count] == 0) {
        if ([[self dateAvailableEDC] mk_isLaterThanDate:[NSDate date]]) {
            dateTitle = NSLocalizedString(@"Due in", nil);
        } else {
            dateTitle = NSLocalizedString(@"Last received", nil);
        }
        
        formattedDate = [[self dateAvailableEDC] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]];

        if ([[self orderedEDC] intValue] > 0) {
            formattedQty = [NSString stringWithFormat:@"(%d)", [[self orderedEDC] intValue]];
        }
    } else {
        // Add the purchase orders:
        [[self purchaseOrdersEDC] enumerateObjectsUsingBlock:^(PKPurchaseOrder *purchaseOrder, NSUInteger idx, BOOL *stop) {
            // Don't show any purchase orders that have the same date as the due in date:
            if ([[purchaseOrder date] mk_isLaterThanDate:[NSDate date]]) {
                // [displayData addTitle:@"P/O" data:[purchaseOrder formattedDescription]];
                dateTitle = NSLocalizedString(@"Due in", nil);
            } else {
                dateTitle = NSLocalizedString(@"Last received", nil);
            }
            
            formattedDate = [[purchaseOrder date] mk_formattedStringUsingFormat:[NSDate mk_dateFormatDDMMMYYYY]];
                
            if ([purchaseOrder shipmentStatus] == PKShipmentStatusShipped) {
                dateTitle = [NSString stringWithFormat:@"🚢 %@", dateTitle];
            }
                
            if ([[purchaseOrder quantity] intValue] > 0) {
                formattedQty = [NSString stringWithFormat:@"(%d)", [[purchaseOrder quantity] intValue]];
            }
            
            *stop = YES;
        }];
    }
    
    // Check the formatted date is valid:
    if ([formattedDate length] == 0 || [formattedDate containsString:@"null"]) {
        formattedDate = nil;
    }
    
    if ([dateValue length] == 0) {
        if ([formattedQty length] != 0) {
            dateValue = [NSString stringWithFormat:@"%@ %@", formattedDate, formattedQty];
        } else {
            dateValue = [NSString stringWithFormat:@"%@", formattedDate];
        }
    }
    
    if ([dateTitle length] != 0 && [dateValue length] != 0) {
        formattedDueDate = [NSString stringWithFormat:@"%@ %@", dateTitle, dateValue];
    }
    
    return formattedDueDate;
}

@end
