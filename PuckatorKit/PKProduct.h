//
//  PKProduct.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FMResultSet+Additional.h"

@class PKCategory, PKImage, PKProductPrice, PKProductSaleHistory;

@interface PKProduct : NSManagedObject

@property (nonatomic, retain) NSNumber * availableStock;
@property (nonatomic, retain) NSNumber * availableStockEDC;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSNumber * isNewStar;
@property (nonatomic, retain) NSNumber * isNewEDC;
@property (nonatomic, retain) NSNumber * lock_to_carton_qty;
@property (nonatomic, retain) NSNumber * lock_to_carton_price;
@property (nonatomic, retain) NSNumber * MAXIMUM_DISCOUNT;
@property (nonatomic, retain) NSNumber * backOrders;
@property (nonatomic, retain) NSNumber * backOrdersEDC;
@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSNumber * carton;
@property (nonatomic, retain) NSString * descText;
@property (nonatomic, retain) NSString * dimension;
@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSString * fromXmlFile;
@property (nonatomic, retain) NSNumber * inner;
@property (nonatomic, retain) NSString * manufacturer;
@property (nonatomic, retain) NSString * material;
@property (nonatomic, retain) NSNumber * minOrderQuantity;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSNumber * multiples;
@property (nonatomic, retain) NSNumber * ordered;
@property (nonatomic, retain) NSNumber * orderedEDC;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSNumber * purchaseUnit;
@property (nonatomic, retain) NSNumber * stockLevel;
@property (nonatomic, retain) NSNumber * stockLevelEDC;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * categoryIds;
@property (nonatomic, retain) NSNumber * totalSold;
@property (nonatomic, retain) NSNumber * totalValue;
@property (nonatomic, retain) NSNumber * uuid;
@property (nonatomic, retain) NSNumber * valuePosition;
@property (nonatomic, retain) NSNumber * vat;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSDate * dateAvailable;
@property (nonatomic, retain) NSDate * dateAvailableEDC;
@property (nonatomic, retain) NSNumber * firstPrice;
@property (nonatomic, retain) NSSet * categories;
@property (nonatomic, retain) NSSet * images;
@property (nonatomic, retain) PKImage * mainImage;
@property (nonatomic, retain) PKProductSaleHistory * saleHistory;
@property (nonatomic, retain) PKProductSaleHistory * saleHistoryEDC;
@property (nonatomic, retain) NSSet * prices;
@property (nonatomic, retain) NSNumber * inactive;
@property (nonatomic, retain) NSDate * dateDue;
@property (nonatomic, retain) NSDate * dateDueEDC;
@property (nonatomic, retain) NSString * purchaseOrdersCSV;
@property (nonatomic, retain) NSString * purchaseOrdersCSVEDC;
@property (nonatomic, retain) NSNumber * toBeDiscontinued;
@property (nonatomic, retain) NSNumber * toBeDiscontinuedEDC;
@property (nonatomic, retain) NSNumber * fobPrice;
@property (nonatomic, retain) NSNumber * fobPriceEDC;
@property (nonatomic, retain) NSNumber * landedCostPrice;
@property (nonatomic, retain) NSNumber * landedCostPriceEDC;
@property (nonatomic, retain) NSString * buyer;
@property (nonatomic, retain) NSNumber * monthsToSell;
@property (nonatomic, retain) NSNumber * monthsToSellEDC;

// Globals:
@property (nonatomic, retain) NSNumber *positionGlobal;
@property (nonatomic, retain) NSNumber *totalSoldGlobal;
@property (nonatomic, retain) NSNumber *totalValueGlobal;
@property (nonatomic, retain) NSNumber *valuePositionGlobal;

@end

@interface PKProduct (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(PKCategory *)value;
- (void)removeCategoriesObject:(PKCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addImagesObject:(PKImage *)value;
- (void)removeImagesObject:(PKImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addPricesObject:(PKProductPrice *)value;
- (void)removePricesObject:(PKProductPrice *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

@end
