//
//  PKInvoiceLine.h
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet+Additional.h"

@class PKInvoice;

@interface PKInvoiceLine : NSObject

@property (strong, nonatomic) NSString *productCode;
@property (strong, nonatomic) NSNumber *orderQty;
@property (strong, nonatomic) NSNumber *itemNetAmount;

+ (instancetype)createFromResultSet:(FMResultSet *)resultSet;
+ (NSArray *)invoiceLinesForInvoice:(PKInvoice *)invoice;
+ (NSDictionary *)previousPricesForCustomer:(PKCustomer *)customer;
+ (NSDictionary *)backOrderProductsForCustomer:(PKCustomer *)customer;

- (PKProduct *)product;

@end
