//
//  PKCustomer.h
//  PuckatorDev
//
//  Created by Luke Dixon on 03/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKDisplayData.h"
#import "PKDatabaseObject.h"

@class PKLocalCustomer;
@class PKAddress;
@class PKEmailAddress;

typedef enum : NSUInteger {
    PKCustomerSearchScopeCompany,
    PKCustomerSearchScopeSage,
    PKCustomerSearchScopeContact,
    PKCustomerSearchScopeTown,
    PKCustomerSearchScopePostcode
} PKCustomerSearchScope;

@interface PKCustomer : PKDatabaseObject <PKDisplayData>

@property (assign, nonatomic) BOOL isCoreDataObject;
@property (assign, nonatomic) int objectId;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *sageId;
@property (strong, nonatomic) NSString *accountRef;
@property (strong, nonatomic) NSString *repName;
@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *emailSales;
@property (strong, nonatomic) NSString *emailOther;
@property (strong, nonatomic) NSString *telephone;
@property (strong, nonatomic) NSString *mobile;
@property (assign, nonatomic) int defaultAddressId;
@property (strong, nonatomic) NSString *currencyId;
@property (assign, nonatomic) double turnoverYTD;
@property (assign, nonatomic) double turnoverPYTD;
@property (assign, nonatomic) double balance;
@property (assign, nonatomic) double current;
@property (assign, nonatomic) double days30;
@property (assign, nonatomic) double days60;
@property (assign, nonatomic) double days90;
@property (assign, nonatomic) double days120;
@property (assign, nonatomic) double creditLimit;
@property (strong, nonatomic) NSString *feedName;
@property (assign, nonatomic) CLLocationCoordinate2D defaultAddressCoordinate;
@property (strong, nonatomic) NSString *paymentTerms;

// Recent customer vars
@property (nonatomic, assign) BOOL isPinned;
@property (nonatomic, strong) NSDate *dateLastSelected;

- (NSString *)companyNameWithSageId;

//+ (int)allCustomerCount;
//+ (NSArray *)allCustomers;
//+ (NSArray *)allCustomersForPage:(int)page;
//+ (NSArray *)findCustomerForName:(NSString *)name;
+ (NSArray *)findCustomersWithScope:(PKCustomerSearchScope)scope searchText:(NSString *)searchText;
+ (NSArray *)findCustomersWithValidGeoAddressForXMLFilename:(NSString *)filename;

+ (PKCustomer *)findCustomerWithId:(NSString *)customerId;
+ (PKCustomer *)findCustomerWithSageId:(NSString *)sageId;
+ (PKCustomer *)findCustomerWithAccountRef:(NSString *)accountRef;

+ (NSArray *)findCustomersWithIds:(NSArray *)customerObjectIds;
- (NSArray *)invoices;
- (NSArray<PKAddress *> *)addresses;

- (NSString *)cleanFeedName;

- (NSArray<PKEmailAddress *> *)emailAddresses;

- (PKLocalCustomer *)coreDataCustomer;

- (PKAddress *)invoiceAddress;
- (PKAddress *)deliveryAddress;

- (BOOL)isOverCreditLimit;

@end
