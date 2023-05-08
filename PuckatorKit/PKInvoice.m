//
//  PKOrder.m
//  PuckatorDev
//
//  Created by Luke Dixon on 03/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKInvoice.h"
#import "PKInvoiceLine.h"
#import "FMResultSet+Additional.h"
#import <MKFoundationKit/MKFoundationKit.h>
#import "PKBasket+Operations.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"

@interface PKInvoice ()

@property (strong, nonatomic) NSArray *invoiceLines;

@end

@implementation PKInvoice

+ (instancetype)create {
    return [[PKInvoice alloc] init];
}

+ (instancetype)createFromResultSet:(FMResultSet *)resultSet {
    PKInvoice *invoice = [PKInvoice create];
    [invoice setObjectId:[resultSet stringForColumnIfExists:@"ID"]];
    [invoice setFrom:[resultSet intForColumnIfExists:@"__FROM"]];
    
    NSString *invoiceDate = [resultSet stringForColumnIfExists:@"INVOICE_DATE"];
    NSDate *date = [NSDate mk_dateFromString:invoiceDate withFormat:@"yyyy-MM-dd hh:mm"];
    [invoice setDate:date];
    [invoice setInvoiceDate:invoiceDate];
    [invoice setSageId:[resultSet stringForColumnIfExists:@"SAGE_ID"]];
    [invoice setCustomerOrderNumber:[resultSet stringForColumnIfExists:@"CUST_ORDER_NUMBER"]];
    [invoice setCarrNet:[resultSet doubleForColumnIfExists:@"CARR_NET"]];
    [invoice setCarrTax:[resultSet doubleForColumnIfExists:@"CARR_TAX"]];
    [invoice setNetAmount:[resultSet doubleForColumnIfExists:@"NET_AMOUNT"]];
    [invoice setTaxAmount:[resultSet doubleForColumnIfExists:@"TAX_AMOUNT"]];
    [invoice setCurrencyType:[resultSet intForColumn:@"CURRENCY_TYPE"]];
    
    PKAddress *address = [PKAddress create];
    [address setContactName:[resultSet stringForColumnIfExists:@"NAME"]];
    [address setLineOne:[resultSet stringForColumnIfExists:@"ADDRESS_1"]];
    [address setLineTwo:[resultSet stringForColumnIfExists:@"ADDRESS_2"]];
    [address setCity:[resultSet stringForColumnIfExists:@"CITY"]];
    [address setState:[resultSet stringForColumnIfExists:@"STATE"]];
    [address setPostcode:[resultSet stringForColumnIfExists:@"POSTCODE"]];
    [invoice setAddress:address];
    
    PKAddress *deliveryAddress = [PKAddress create];
    [deliveryAddress setContactName:[resultSet stringForColumnIfExists:@"DEL_NAME"]];
    [deliveryAddress setLineOne:[resultSet stringForColumnIfExists:@"DEL_ADDRESS_1"]];
    [deliveryAddress setLineTwo:[resultSet stringForColumnIfExists:@"DEL_ADDRESS_2"]];
    [deliveryAddress setCity:[resultSet stringForColumnIfExists:@"DEL_CITY"]];
    [deliveryAddress setState:[resultSet stringForColumnIfExists:@"DEL_STATE"]];
    [deliveryAddress setPostcode:[resultSet stringForColumnIfExists:@"DEL_POSTCODE"]];
    [invoice setDeliveryAddress:deliveryAddress];
    [invoice setStatusCode:[resultSet intForColumn:@"TYPE"]];
    
    return invoice;
}

+ (NSArray *)allInvoices {
    NSMutableArray *invoices = [NSMutableArray array];
    [PKDatabase executeQuery:@"SELECT * from Invoice" database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKInvoice *invoice = [PKInvoice createFromResultSet:resultSet];
            [invoices addObject:invoice];
        }
    }];
    
    // Return the invoices array:
    return invoices;
}

+ (NSArray *)allInvoicesForCustomer:(PKCustomer *)customer {
    NSMutableArray *invoices = [NSMutableArray array];
    
    if ([[customer sageId] length] != 0) {
        NSString *query = [NSString stringWithFormat:@"SELECT * from Invoice where SAGE_ID == '%@'", [customer sageId]];
        [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
            @synchronized (self) {
                while ([resultSet next]) {
                    PKInvoice *invoice = [PKInvoice createFromResultSet:resultSet];
                    [invoices addObject:invoice];
                }
            }
        }];
    }
    
    // Add all the saved baskets/orders:
    NSArray *baskets = [PKBasket ordersAndQuotesForCustomer:customer feedNumber:nil context:nil];
    [invoices addObjectsFromArray:baskets];
    
    // Sort all the invoices and baskets:
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [invoices sortUsingDescriptors:@[sortDescriptor]];
    
    // Return the invoices array:
    return invoices;
}

+ (NSArray *)archivedInvoicesForCustomer:(PKCustomer *)customer {
    NSMutableArray *invoices = [NSMutableArray array];
    
    // Add all the saved baskets/orders:
    NSMutableArray *baskets = [[PKBasket archivedOrdersAndQuotesForCustomer:customer feedNumber:nil context:nil] mutableCopy];
    
    // Remove the session basket:
    [baskets removeObject:[PKBasket sessionBasket]];
    
    // Add the remaining baskets to the array:
    [invoices addObjectsFromArray:baskets];
    
    // Sort all the invoices and baskets:
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [invoices sortUsingDescriptors:@[sortDescriptor]];
    
    // Return the invoices array:
    return invoices;
}

- (NSArray *)invoiceLines {
    if (!_invoiceLines) {
        _invoiceLines = [PKInvoiceLine invoiceLinesForInvoice:self];
    }
    return _invoiceLines;
}

- (PKInvoiceStatus)status {
    return [self statusCode];
}

+ (NSArray *)statusItems {
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:@{@"name" : [PKInvoice nameForStatus:PKInvoiceStatusComplete], @"status" : @(PKInvoiceStatusComplete), @"class" : @"PKInvoice"}];
    [items addObject:@{@"name" : [PKInvoice nameForStatus:PKInvoiceStatusOutstanding], @"status" : @(PKInvoiceStatusOutstanding), @"class" : @"PKInvoice"}];
    [items addObject:@{@"name" : [PKInvoice nameForStatus:PKInvoiceStatusInWarehouse], @"status" : @(PKInvoiceStatusInWarehouse), @"class" : @"PKInvoice"}];
    [items addObject:@{@"name" : [PKInvoice nameForStatus:PKInvoiceStatusCreditNote], @"status" : @(PKInvoiceStatusCreditNote), @"class" : @"PKInvoice"}];
    return items;
}

+ (NSString *)nameForStatus:(PKInvoiceStatus)status {
    switch (status) {
        case PKInvoiceStatusComplete:
            return NSLocalizedString(@"Order Complete", nil);
            break;
        case PKInvoiceStatusOutstanding:
            return NSLocalizedString(@"Outstanding Order", nil);
            break;
        case PKInvoiceStatusInWarehouse:
            return NSLocalizedString(@"In Warehouse", nil);
            break;
        case PKInvoiceStatusCreditNote:
            return NSLocalizedString(@"Credit Note", nil);
            break;
        default:
            return [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Unknown Status", nil), (int)status];
            break;
    }
}

- (NSString *)statusTitle {
    return [PKInvoice nameForStatus:[self status]];
}

#pragma mark - Public Methods

- (NSDate *)date {
    NSString *justDate = [[[self invoiceDate] componentsSeparatedByString:@" "] firstObject];
    NSDate *date = [NSDate mk_dateFromString:justDate withFormat:@"yyyy-MM-dd"];
    return date;
}

#pragma mark - Helper Methods

- (double)grandTotal {
    return [self carrNet] + [self carrTax] + [self netAmount] + [self taxAmount];
}

- (double)vatRate {
    return ([self taxAmount]/[self netAmount]) * 100.f;
}

- (NSString *)formattedVatRate {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.minimumFractionDigits = 0;
    numberFormatter.maximumFractionDigits = 2;
    numberFormatter.minimumIntegerDigits = 1;
    return [NSString stringWithFormat:@"%@%%", [numberFormatter stringFromNumber:@([self vatRate])]];
}

- (double)vatTotal {
    return [self taxAmount] + [self carrTax];
}

- (NSAttributedString *)formattedOrderAndCustomerNumber {
    NSString *invoiceId = [self objectId];
    NSString *customerOrderNumber = [self customerOrderNumber];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    if ([invoiceId length] != 0) {
        NSAttributedString *extraAttributedString = [[NSAttributedString alloc] initWithString:invoiceId
                                                                                    attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor puckatorDarkGray]]];
        
        if ([extraAttributedString length] != 0) {
            [attributedString appendAttributedString:extraAttributedString];
        }
    }
    
    if ([customerOrderNumber length] != 0) {
        // Check if we need to add a new line:
        if ([attributedString length] != 0) {
            customerOrderNumber = [@"\n" stringByAppendingString:customerOrderNumber];
        }
        
        NSAttributedString *extraAttributedString = [[NSAttributedString alloc] initWithString:customerOrderNumber
                                                                                    attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:10] color:[UIColor puckatorDarkGray]]];
        
        if ([extraAttributedString length] != 0) {
            [attributedString appendAttributedString:extraAttributedString];
        }
    }
    
    return attributedString;
}

- (UIColor *)colorForStatus {
    UIColor *color = nil;
    
    if ([self status] == PKInvoiceStatusComplete) {
        color = [UIColor blackColor];
    } else if ([self status] == PKInvoiceStatusOutstanding) {
        color = [UIColor blueColor];
    } else if ([self status] == PKInvoiceStatusCreditNote) {
        color = [UIColor redColor];
    } else if ([self status] == PKInvoiceStatusInWarehouse) {
        color = [UIColor orangeColor];
    }
    
    return color;
}

- (NSString *)formattedInvoiceDate {
    NSString *justDate = [[[self invoiceDate] componentsSeparatedByString:@" "] firstObject];
    NSDate *date = [NSDate mk_dateFromString:justDate withFormat:@"yyyy-MM-dd"];
    return [date mk_formattedStringUsingFormat:@"dd MMM yyyy"];
}

- (NSString *)currencyCode {
    return [[PKCurrency currencyInfoForCurrencyCode:[self currencyType]] objectForKey:@"iso"];
}

- (NSString *)currencySymbol {
    return [[PKCurrency currencyInfoForCurrencyCode:[self currencyType]] objectForKey:@"symbol"];
}

- (NSString *)formattedNetTotal {
    NSString *currencySymbol = [self currencySymbol];
    return [NSString stringWithFormat:@"%@%.2f", currencySymbol, [self netAmount]];
}

- (NSString *)formatPrice:(double)price {
    NSString *currencySymbol = [self currencySymbol];
    return [NSString stringWithFormat:@"%@%.2f", currencySymbol, price];
}

- (NSString *)contactNameDefault {
    NSString *contactName = [[self address] contactName];
    if ([contactName length] == 0) {
        contactName = [[self deliveryAddress] contactName];
    }
    return contactName;
}

#pragma mark -

@end
