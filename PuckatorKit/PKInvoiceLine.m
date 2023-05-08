//
//  PKInvoiceLine.m
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKInvoiceLine.h"
#import "PKInvoice.h"
#import "PKProduct+Operations.h"
#import "NSDate+MK.h"

@implementation PKInvoiceLine

+ (instancetype)create {
    return [[PKInvoiceLine alloc] init];
}

+ (instancetype)createFromResultSet:(FMResultSet *)resultSet {
    PKInvoiceLine *invoiceLine = [PKInvoiceLine create];
    [invoiceLine setProductCode:[resultSet stringForColumnIfExists:@"PRODUCT_CODE"]];
    [invoiceLine setOrderQty:@([resultSet intForColumnIfExists:@"QTY_ORDER"])];
    [invoiceLine setItemNetAmount:[NSDecimalNumber roundString:[resultSet stringForColumn:@"ITEM_NET_AMOUNT"]]];
    return invoiceLine;
}

+ (NSArray *)invoiceLinesForInvoice:(PKInvoice *)invoice {
    NSMutableArray *invoiceLines = [NSMutableArray array];
    NSString *query = [NSString stringWithFormat:@"SELECT * from InvoiceLine where __INVOICE_ID == '%@' AND __FROM == %d", [invoice objectId], [invoice from]];
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKInvoiceLine *invoiceLine = [PKInvoiceLine createFromResultSet:resultSet];
            if (invoiceLine) {
                [invoiceLines addObject:invoiceLine];
            }
        }
    }];
    
    // Return the invoices array:
    return invoiceLines;
}

+ (NSDictionary *)previousPricesForCustomer:(PKCustomer *)customer {
    // Do not execute the SQL if the customer or sageId aren't valid:
    if (!customer || [[customer sageId] length] == 0) {
        return nil;
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT IL.PRODUCT_CODE, IL.ITEM_NET_AMOUNT, IL.QTY_ORDER, I.INVOICE_CREATE_DATE, I.ID FROM Invoice AS I JOIN InvoiceLine AS IL ON I.ID = IL.__INVOICE_ID WHERE I.SAGE_ID = '%@' ORDER BY I.ID DESC", [customer sageId]];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            NSString *productCode = [resultSet stringForColumnIfExists:@"PRODUCT_CODE"];
            double netAmount = [resultSet doubleForColumnIfExists:@"ITEM_NET_AMOUNT"];
            double qtyOrder = (double)[resultSet intForColumnIfExists:@"QTY_ORDER"];
            NSString *invoiceCreateDate = [resultSet stringForColumnIfExists:@"INVOICE_CREATE_DATE"];
            NSString *invoiceId = [resultSet stringForColumnIfExists:@"ID"];
            double amount = netAmount / qtyOrder;
            
            if ([dictionary objectForKey:productCode]) {
                NSDictionary *productDictionary = [dictionary objectForKey:productCode];
                NSString *existingDateStr = [[productDictionary objectForKey:@"date"] stringValue];
                
                NSDate *currentDate = [NSDate mk_dateFromString:invoiceCreateDate];
                NSDate *existingDate = [NSDate mk_dateFromString:existingDateStr];
                
                if ([currentDate mk_isLaterThanDate:existingDate]) {
                    [dictionary setObject:@{@"id" : invoiceId, @"date": invoiceCreateDate, @"qty" : @(qtyOrder), @"net_amount" : @(netAmount), @"unit_amount" : @(amount)} forKey:productCode];
                }
            } else {
                [dictionary setObject:@{@"id" : invoiceId, @"date": invoiceCreateDate, @"qty" : @(qtyOrder), @"net_amount" : @(netAmount), @"unit_amount" : @(amount)} forKey:productCode];
            }
        }
    }];
    
    return dictionary;
}

+ (NSDictionary *)backOrderProductsForCustomer:(PKCustomer *)customer {
    // Do not execute the SQL if the customer or sageId aren't valid:
    if (!customer || [[customer sageId] length] == 0) {
        return nil;
    }
    
    //NSString *query = [NSString stringWithFormat:@"SELECT IL.PRODUCT_CODE, IL.QTY_ORDER FROM Invoice AS I JOIN InvoiceLine AS IL ON I.ID = IL.__INVOICE_ID WHERE I.SAGE_ID = '%@' AND length(I.ID) == 4 GROUP BY IL.PRODUCT_CODE ORDER BY I.INVOICE_CREATE_DATE", [customer sageId]];
    
    NSString *query = [NSString stringWithFormat:@"SELECT SUM(QTY_ORDER) AS SUM_QTY, IL.PRODUCT_CODE, IL.QTY_ORDER, I.ID, I.TYPE FROM Invoice AS I JOIN InvoiceLine AS IL ON I.ID = IL.__INVOICE_ID WHERE I.SAGE_ID = '%@' AND (I.TYPE == %lu OR I.TYPE == %lu) GROUP BY IL.PRODUCT_CODE ORDER BY I.INVOICE_CREATE_DATE", [customer sageId], (unsigned long)PKInvoiceStatusOutstanding, (unsigned long)PKInvoiceStatusInWarehouse];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            NSString *productCode = [resultSet stringForColumnIfExists:@"PRODUCT_CODE"];
            double qtyOrder = (double)[resultSet intForColumnIfExists:@"SUM_QTY"];
            
            if ([dictionary objectForKey:productCode]) {
                int currentQty = [[dictionary objectForKey:productCode] intValue];
                currentQty += qtyOrder;
                [dictionary setObject:@(currentQty) forKey:productCode];
            } else {
                [dictionary setObject:@(qtyOrder) forKey:productCode];
            }
        }
    }];
    
    return dictionary;
}

- (PKProduct *)product {
    PKProduct *product = [PKProduct findWithProductCode:[self productCode] forFeedConfig:nil inContext:nil];
    return product;
}

@end
