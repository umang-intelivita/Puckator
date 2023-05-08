//
//  PKOrder.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 21/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PKOrder : NSManagedObject

@property (nonatomic, retain) NSString * addressBillingCompanyName;
@property (nonatomic, retain) NSString * addressBillingContactName;
@property (nonatomic, retain) NSString * addressBillingAddressLine1;
@property (nonatomic, retain) NSString * addressBillingAddressLine2;
@property (nonatomic, retain) NSString * addressBillingCity;
@property (nonatomic, retain) NSString * addressBillingState;
@property (nonatomic, retain) NSString * addressBillingCountry;
@property (nonatomic, retain) NSString * addressBillingPostcode;
@property (nonatomic, retain) NSString * addressBillingISO;
@property (nonatomic, retain) NSString * addressDeliveryCompanyName;
@property (nonatomic, retain) NSString * addressDeliveryContactName;
@property (nonatomic, retain) NSString * addressDeliveryAddressLine1;
@property (nonatomic, retain) NSString * addressDeliveryAddressLine2;
@property (nonatomic, retain) NSString * addressDeliveryCity;
@property (nonatomic, retain) NSString * addressDeliveryState;
@property (nonatomic, retain) NSString * addressDeliveryCountry;
@property (nonatomic, retain) NSString * addressDeliveryPostcode;
@property (nonatomic, retain) NSString * addressDeliveryISO;
@property (nonatomic, retain) NSString * vatNumber;
@property (nonatomic, retain) NSString * fiscalCode;
@property (nonatomic, retain) NSString * pecEmail;
@property (nonatomic, retain) NSString * emailAddresses;
@property (nonatomic, retain) NSString * paymentMethod;
@property (nonatomic, retain) NSNumber * paymentMethodId;
@property (nonatomic, retain) NSDate * dateRequired;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * orderRef;
@property (nonatomic, retain) NSNumber * draft;
@property (nonatomic, retain) NSString * purchaseOrderNumber;
@property (nonatomic, retain) NSNumber * tradeShowOrder;
@property (nonatomic, retain) NSNumber * reTax;
@property (nonatomic, retain) NSString * pdfType;

@end
