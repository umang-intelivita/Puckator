//
//  PKOrder.h
//  PuckatorDev
//
//  Created by Luke Dixon on 03/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKAddress.h"
//#import "PKAddress.h"
#import "PKDatabase.h"
#import "PKCustomer.h"

typedef enum : NSUInteger {
    PKInvoiceStatusComplete = 0,
    PKInvoiceStatusOutstanding = 1,
    PKInvoiceStatusInWarehouse = 2,
    PKInvoiceStatusCreditNote = 3
} PKInvoiceStatus;

@interface PKInvoice : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *invoiceDate;
@property (strong, nonatomic) NSString *sageId;
@property (strong, nonatomic) NSString *customerOrderNumber;
@property (assign, nonatomic) double carrNet;
@property (assign, nonatomic) double carrTax;
@property (assign, nonatomic) double netAmount;
@property (assign, nonatomic) double taxAmount;
@property (strong, nonatomic) NSString *invoiceCreateDate;
@property (strong, nonatomic) NSString *invoiceModifyDate;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) int statusCode;
@property (assign, nonatomic) BOOL isOrder;
@property (assign, nonatomic) int from;

@property (assign, nonatomic) int currencyType;

@property (strong, nonatomic) PKAddress *address;
@property (strong, nonatomic) PKAddress *deliveryAddress;

#pragma mark - Data Methods
+ (NSArray *)allInvoices;
+ (NSArray *)allInvoicesForCustomer:(PKCustomer *)customer;
+ (NSArray *)archivedInvoicesForCustomer:(PKCustomer *)customer;
- (NSArray *)invoiceLines;

#pragma mark - Status Methods
- (PKInvoiceStatus)status;
+ (NSArray *)statusItems;
+ (NSString *)nameForStatus:(PKInvoiceStatus)status;
- (NSString *)statusTitle;

#pragma mark - Helper Methods
- (NSString *)formattedVatRate;
- (NSString *)currencyCode;
- (double)vatTotal;
- (double)vatRate;
- (NSString *)formattedInvoiceDate;
- (NSString *)currencySymbol;
- (NSString *)formattedNetTotal;
- (NSString *)formatPrice:(double)price;
- (NSAttributedString *)formattedOrderAndCustomerNumber;
- (double)grandTotal;
- (UIColor *)colorForStatus;
- (NSString *)contactNameDefault;

@end
