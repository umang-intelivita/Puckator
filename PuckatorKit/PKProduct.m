//
//  PKProduct.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProduct.h"
#import "PKCategory.h"
#import "PKImage.h"
#import "PKProductPrice.h"
#import "PKProductSaleHistory.h"

@implementation PKProduct

@dynamic availableStock;
@dynamic backOrders;
@dynamic barcode;
@dynamic carton;
@dynamic descText;
@dynamic dimension;
@dynamic feedNumber;
@dynamic fromXmlFile;
@dynamic inner;
@dynamic manufacturer;
@dynamic material;
@dynamic minOrderQuantity;
@dynamic model;
@dynamic multiples;
@dynamic ordered;
@dynamic position;
@dynamic productId;
@dynamic purchaseUnit;
@dynamic stockLevel;
@dynamic title;
@dynamic totalSold;
@dynamic totalValue;
@dynamic uuid;
@dynamic valuePosition;
@dynamic vat;
@dynamic categories;
@dynamic images;
@dynamic mainImage;
@dynamic saleHistory;
@dynamic saleHistoryEDC;
@dynamic prices;
@dynamic dateAdded;
@dynamic dateAvailable;
@dynamic firstPrice;
@dynamic inactive;
@dynamic categoryIds;
@dynamic dateDue;
@dynamic dateDueEDC;
@dynamic purchaseOrdersCSV;
@dynamic isNew;
@dynamic isNewStar;
@dynamic isNewEDC;
@dynamic toBeDiscontinued;
@dynamic buyer;
@dynamic monthsToSell;
@dynamic fobPrice;
@dynamic landedCostPrice;
@dynamic positionGlobal;
@dynamic totalSoldGlobal;
@dynamic totalValueGlobal;
@dynamic valuePositionGlobal;
@dynamic lock_to_carton_qty;
@dynamic lock_to_carton_price;
@dynamic MAXIMUM_DISCOUNT;
@dynamic orderedEDC;
@dynamic fobPriceEDC;
@dynamic backOrdersEDC;
@dynamic stockLevelEDC;
@dynamic dateAvailableEDC;
@dynamic availableStockEDC;
@dynamic monthsToSellEDC;
@dynamic landedCostPriceEDC;
@dynamic toBeDiscontinuedEDC;
@dynamic purchaseOrdersCSVEDC;

- (void)dealloc {
    //NSLog(@"[%@] - Product dealloc'd", [self class]);
}

@end
