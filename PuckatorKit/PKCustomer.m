//
//  PKCustomer.m
//  PuckatorDev
//
//  Created by Luke Dixon on 03/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCustomer.h"
#import "PKAddress.h"
#import "PKFeedSQL.h"
#import "PKInvoice.h"
#import "PKLocalCustomer.h"
#import "PKLocalCustomer+Operations.h"
#import "PKLocalAddress+Operations.h"
#import "PKEmailAddress.h"

@implementation PKCustomer

#pragma mark - Constructor Methods

+ (instancetype)createFromResultSet:(FMResultSet *)resultSet {
    PKCustomer *customer = [[PKCustomer alloc] init];
    
    [customer setObjectId:[resultSet intForColumnIfExists:@"ID"]];
    [customer setSageId:[resultSet stringForColumnIfExists:@"SAGE_ID"]];
    [customer setAccountRef:[resultSet stringForColumnIfExists:@"__ACCOUNT_REF"]];
    [customer setCompanyName:[resultSet stringForColumnIfExists:@"COMPANY_NAME"]];
    [customer setRepName:[resultSet stringForColumnIfExists:@"REP"]];
    [customer setContactName:[resultSet stringForColumnIfExists:@"CONTACT_NAME"]];
    [customer setEmail:[resultSet stringForColumnIfExists:@"EMAIL"]];
    [customer setEmailSales:[resultSet stringForColumnIfExists:@"EMAIL_SALES"]];
    [customer setEmailOther:[resultSet stringForColumnIfExists:@"EMAIL_OTHER"]];
    [customer setTelephone:[resultSet stringForColumnIfExists:@"TELEPHONE"]];
    [customer setMobile:[resultSet stringForColumnIfExists:@"MOBILE"]];
    [customer setDefaultAddressId:[resultSet intForColumnIfExists:@"DEFAULT_ADDRESS_ID"]];
    [customer setCurrencyId:[resultSet stringForColumnIfExists:@"CURRENCY_ID"]];
    [customer setTurnoverYTD:[resultSet doubleForColumnIfExists:@"TURNOVER_YTD"]];
    [customer setTurnoverPYTD:[resultSet doubleForColumnIfExists:@"TURNOVER_PRIOR_YEAR"]];
    [customer setBalance:[resultSet doubleForColumnIfExists:@"BALANCE"]];
    [customer setCurrent:[resultSet doubleForColumnIfExists:@"CURRENT"]];
    [customer setDays30:[resultSet doubleForColumnIfExists:@"DAYS_30"]];
    [customer setDays60:[resultSet doubleForColumnIfExists:@"DAYS_60"]];
    [customer setDays90:[resultSet doubleForColumnIfExists:@"DAYS_90"]];
    [customer setDays120:[resultSet doubleForColumnIfExists:@"DAYS_120"]];
    [customer setCreditLimit:[resultSet doubleForColumnIfExists:@"CREDIT_LIMIT"]];
    [customer setFeedName:[resultSet stringForColumnIfExists:@"FILE"]];
    [customer setPaymentTerms:[resultSet stringForColumnIfExists:@"PAYMENT_TERMS"]];
    
    double addressGeoLat = [resultSet doubleForColumnIfExists:@"ADDRESS_GEO_LAT"];
    double addressGeoLng = [resultSet doubleForColumnIfExists:@"ADDRESS_GEO_LNG"];
    
    if (addressGeoLat != 0 && addressGeoLng != 0) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(addressGeoLat, addressGeoLng);
        [customer setDefaultAddressCoordinate:coord];
    }
    
    return customer;
}

#pragma mark - Public Methods

- (NSArray<PKEmailAddress *> *)emailAddresses {
    NSMutableArray *emailAddresses = [NSMutableArray array];
    
    if ([[self email] length] != 0) {
        PKEmailAddress *emailAddress = [PKEmailAddress createWithEmail:[self email]
                                                                  type:NSLocalizedString(@"Default", nil)];
        [emailAddresses addObject:emailAddress];
    }
    if ([[self emailSales] length] != 0) {
        PKEmailAddress *emailAddress = [PKEmailAddress createWithEmail:[self emailSales]
                                                                  type:NSLocalizedString(@"Sales", nil)];
        [emailAddresses addObject:emailAddress];
    }
    if ([[self emailOther] length] != 0) {
        PKEmailAddress *emailAddress = [PKEmailAddress createWithEmail:[self emailOther]
                                                                  type:NSLocalizedString(@"Other", nil)];
        [emailAddresses addObject:emailAddress];
    }
    
    return emailAddresses;
}

- (BOOL)isOverCreditLimit {
    return ([self creditLimit] > 0 && [self balance] > [self creditLimit]);
}

+ (NSArray *)findCustomersWithValidGeoAddressForXMLFilename:(NSString *)filename {
    if ([filename length] == 0) {
        return nil;
    }
    
    NSMutableArray *customers = [NSMutableArray array];    
    NSString *query = [NSString stringWithFormat:@"SELECT DISTINCT A.__ID AS ADDRESS_ID, A.ADDRESS_GEO_LAT, A.ADDRESS_GEO_LNG, A.ADDRESS_ONE, C.ID AS ID, C.COMPANY_NAME, C.SAGE_ID, C.REP, S.FILE FROM Address AS A JOIN Customer AS C ON A.__CUSTOMER_ID = C.ID JOIN Schema AS S ON C.__FROM == S.ID WHERE A.__ID = C.DEFAULT_ADDRESS_ID AND S.FILE == '%@' AND A.ADDRESS_GEO_LAT != 0 AND A.ADDRESS_GEO_LNG != 0", filename];
    
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKCustomer *customer = [PKCustomer createFromResultSet:resultSet];
            if (customer) {
                [customers addObject:customer];
            }
        }
    }];
    
    return customers;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n----------\nCustomer(ID: %i - %@):\n----------\n Company Name: %@\n Lat: %.5f\n Long: %.5f",
            [self objectId],
            [self feedName],
            [self companyName],
            [self defaultAddressCoordinate].latitude,
            [self defaultAddressCoordinate].longitude];
}

+ (NSArray *)findCustomersWithScope:(PKCustomerSearchScope)scope searchText:(NSString *)searchText {
    if ([searchText length] == 0) {
        return nil;
    }
    
    NSMutableArray *customers = [NSMutableArray array];
    
    NSString *scopeColumn = @"COMPANY_NAME";
    
    switch (scope) {
        case PKCustomerSearchScopeCompany:
            scopeColumn = @"COMPANY_NAME";
            break;
        case PKCustomerSearchScopeSage:
            scopeColumn = @"SAGE_ID";
            break;
        case PKCustomerSearchScopeContact:
            scopeColumn = @"CONTACT_NAME";
            break;
        case PKCustomerSearchScopeTown:
            scopeColumn = @"ADDRESS_CITY";
            break;
        case PKCustomerSearchScopePostcode:
            scopeColumn = @"ADDRESS_POSTCODE";
            break;
    }
    
    int limit = 1000;
    
    NSString *query = [NSString stringWithFormat:@"SELECT DISTINCT C.*, S.FILE from Customer as C JOIN Schema S ON C.__FROM == S.ID where %@ LIKE '%%%@%%' LIMIT %d", scopeColumn, searchText, limit];
    
    if (scope == PKCustomerSearchScopePostcode || scope == PKCustomerSearchScopeTown) {
        query = [NSString stringWithFormat:@"SELECT DISTINCT C.*, S.FILE from Customer AS C JOIN Schema AS S ON C.__FROM == S.ID JOIN Address AS A ON A.__CUSTOMER_ID = C.ID where A.%@ LIKE '%@%%' LIMIT %d", scopeColumn, searchText, limit];
    }
    
    NSMutableArray *accountNumbers = [NSMutableArray array];
    
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKCustomer *customer = [PKCustomer createFromResultSet:resultSet];
            if (customer) {
                [customers addObject:customer];
                
                if ([[customer accountRef] length] != 0) {
                    [accountNumbers addObject:[customer accountRef]];
                }
            }
        }
    }];
    
    // Never search core data for sage id:
    if (scope != PKCustomerSearchScopeSage) {
        NSPredicate *predicate = nil;
        
        switch (scope) {
            case PKCustomerSearchScopeCompany:
                predicate = [NSPredicate predicateWithFormat:@"(companyName beginswith[cd] %@) && NOT (accountRef IN %@)", searchText, accountNumbers];
                break;
            case PKCustomerSearchScopeSage:
                break;
            case PKCustomerSearchScopeContact:
                predicate = [NSPredicate predicateWithFormat:@"(contactName beginswith[cd] %@) && NOT (accountRef IN %@)", searchText, accountNumbers];
                break;
            case PKCustomerSearchScopeTown:
                predicate = [NSPredicate predicateWithFormat:@"(ANY addresses.city beginswith[cd] %@) && NOT (accountRef IN %@)", searchText, accountNumbers];
                break;
            case PKCustomerSearchScopePostcode:
                predicate = [NSPredicate predicateWithFormat:@"(ANY addresses.postcode beginswith[cd] %@) && NOT (accountRef IN %@)", searchText, accountNumbers];
                break;
        }
        
        NSArray *coreDataResults = [PKLocalCustomer MR_findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        [coreDataResults enumerateObjectsUsingBlock:^(PKLocalCustomer *localCustomer, NSUInteger idx, BOOL *stop) {
            if (![accountNumbers containsObject:[localCustomer accountRef]]) {
                PKCustomer *customer = [localCustomer toCustomer];
                if (customer) {
                    [customers addObject:customer];
                }
            }
        }];
    }
    
    // Return the customers array:
    return customers;
}

+ (PKCustomer*)findCustomerWithId:(NSString*)customerId {
    if(!customerId) {
        return nil;
    }
    NSArray *customers = [PKCustomer findCustomersWithIds:@[customerId]];
    if([customers count] >= 1) {
        return [customers firstObject];
    } else {
        return nil;
    }
}

+ (PKCustomer *)findCustomerWithAccountRef:(NSString *)accountRef {
    if ([accountRef length] == 0) {
        return nil;
    }
    
    __block PKCustomer *customer = nil;
    
    NSString *query = [NSString stringWithFormat:@"SELECT C.*, S.FILE from Customer as C INNER JOIN Schema S ON C.__FROM == S.ID where C.__ACCOUNT_REF == '%@' LIMIT 1", accountRef];
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            customer = [PKCustomer createFromResultSet:resultSet];
        }
    }];
    
    return customer;
}

+ (PKCustomer *)findCustomerWithSageId:(NSString *)sageId {
    if ([sageId length] == 0) {
        return nil;
    }
    
    __block PKCustomer *customer = nil;
    
    @try {
        NSString *query = [NSString stringWithFormat:@"SELECT C.*, S.FILE from Customer as C INNER JOIN Schema S ON C.__FROM == S.ID where C.SAGE_ID == '%@' LIMIT 1", sageId];
        [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
            while ([resultSet next]) {
                customer = [PKCustomer createFromResultSet:resultSet];
            }
        }];
    } @catch (NSException *exception) {
    } @finally {
    }
    
    return customer;
}

+ (NSArray *)findCustomersWithIds:(NSArray*)customerObjectIds {
    if ([customerObjectIds count] == 0) {
        return @[];
    }
    
    // Turn the array of customer ID's to a CSV
    NSMutableString *list = [[NSMutableString alloc] initWithString:@""];
    for(NSNumber *objectId in customerObjectIds) {
        [list appendFormat:@"%d,", [objectId intValue]];
    }
    list = [NSMutableString stringWithString:[list substringToIndex:[list length]-1]];

    // Dispatch query
    NSMutableArray *customers = [NSMutableArray array];
    NSString *query = [NSString stringWithFormat:@"SELECT C.*, S.FILE from Customer as C INNER JOIN Schema S ON C.__FROM == S.ID where C.ID IN (%@) LIMIT 500", list];
    
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKCustomer *customer = [PKCustomer createFromResultSet:resultSet];
            if (customer) {
                [customers addObject:customer];
            }
        }
    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId IN %@", customerObjectIds];
    NSArray *coreDataResults = [PKLocalCustomer MR_findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    
    [coreDataResults enumerateObjectsUsingBlock:^(PKLocalCustomer *localCustomer, NSUInteger idx, BOOL *stop) {
        PKCustomer *customer = [localCustomer toCustomer];
        if (customer) {
            [customers addObject:customer];
        }
    }];
    
    // Return the customers array:
    return customers;
}

- (NSArray *)invoices {
    return [PKInvoice allInvoicesForCustomer:self];
}

- (NSArray<PKAddress *> *)addresses {
    NSMutableArray *addresses = [NSMutableArray array];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Address WHERE __CUSTOMER_ID == %i ORDER BY __IDX ASC", [self objectId]];
    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            PKAddress *address = [PKAddress createFromResultSet:resultSet];
            if (address) {
                if ([address objectId] == [self defaultAddressId]) {
                    [address setIsDefaultInvoiceAddress:YES];
                }
                
                [addresses addObject:address];
            }
        }
    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(customerId == %d)", [self objectId]];
    NSArray *coreDataResults = [PKLocalAddress MR_findAllSortedBy:@"idx" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    [coreDataResults enumerateObjectsUsingBlock:^(PKLocalAddress *localAddress, NSUInteger idx, BOOL *stop) {
        PKAddress *address = [localAddress toAddress];
        if (address) {
            if ([address objectId] == [self defaultAddressId]) {
                [address setIsDefaultInvoiceAddress:YES];
            }
            
            [addresses addObject:address];
        }
    }];

    return addresses;
}

//- (PKAddress *)defaultDeliveryAddress {
//    NSMutableArray *addresses = [NSMutableArray array];
//
//    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Address WHERE __CUSTOMER_ID == %i ORDER BY __IDX ASC", [self objectId]];
//    [PKDatabase executeQuery:query database:PKDatabaseTypeAccounts resultSet:^(FMResultSet *resultSet) {
//        while ([resultSet next]) {
//            PKAddress *address = [PKAddress createFromResultSet:resultSet];
//            if (address) {
//                [addresses addObject:address];
//            }
//        }
//    }];
//
//    return nil;
//}

- (PKAddress *)invoiceAddress {
    __block PKAddress *invoiceAddress = nil;
    NSArray *addresses = [self addresses];
    
    // Look for the invoice address:
    [addresses enumerateObjectsUsingBlock:^(PKAddress * _Nonnull address, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self defaultAddressId] == [address objectId]) {
            invoiceAddress = address;
            *stop = YES;
        }
    }];
    
    // Default to the first address if invoice address hasn't been found:
    if (!invoiceAddress) {
        invoiceAddress = [addresses firstObject];
    }
    
    return invoiceAddress;
}

- (PKAddress *)deliveryAddress {
    __block PKAddress *deliveryAddress = nil;
    NSArray *addresses = [self addresses];
    
    // Look for the invoice address:
    [addresses enumerateObjectsUsingBlock:^(PKAddress * _Nonnull address, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([address isDefaultDeliveryAddress]) {
            deliveryAddress = address;
            *stop = YES;
        }
    }];
    
    // Default to the first address if invoice address hasn't been found:
    if (!deliveryAddress) {
        deliveryAddress = [self invoiceAddress];
    }
    
    return deliveryAddress;
    
//    NSArray *addresses = [self addresses];
//    if ([addresses count] >= 2) {
//        return [addresses objectAtIndex:1];
//    }
//    return [self invoiceAddress];
}

- (NSString *)cleanFeedName {
    // Remove the '.xml' from the feedn name:
    NSString *feedName = [[self feedName] stringByReplacingOccurrencesOfString:@".xml" withString:@""];
    
    // Attempt to split the feed name by '-':
    NSArray *components = [feedName componentsSeparatedByString:@"-"];
    
    if ([components count] == 2) {
        NSString *countryCode = [components firstObject];
        NSString *feedType = [components lastObject];
        return [NSString stringWithFormat:@"%@ %@", [countryCode uppercaseString], [feedType capitalizedString]];
    } else {
        return [[feedName stringByReplacingOccurrencesOfString:@"-" withString:@" "] uppercaseString];
    }
}

- (NSString *)companyNameWithSageId {
    if ([[self sageId] length] != 0) {
        return [[self companyName] stringByAppendingFormat:@" (%@)", [self sageId]];
    }
    return [self companyName];
}

- (NSString *)paymentTerms {
    if ([_paymentTerms length] == 0) {
        return @"-";
    } else {
        return _paymentTerms;
    }
}

#pragma mark - CoreData Methods


- (PKLocalCustomer *)coreDataCustomer {
    if ([self isCoreDataObject]) {
        return [PKLocalCustomer customerWithCustomerId:[self objectId]];
    }
    
    return nil;
}

#pragma mark - PKDisplayData Methods

- (PKDisplayData *)displayData {
    PKDisplayData *displayData = [PKDisplayData create];
    
    [displayData openSection];
    [displayData addTitle:NSLocalizedString(@"Rep Name", nil) data:[self repName]];
    
    int currencyId = -1;
    if ([[self currencyId] length] != 0) {
        currencyId = [[self currencyId] intValue];
    }
    if (currencyId != -1) {
        NSString *symbol = [[PKCurrency currencyInfoForCurrencyCode:currencyId] objectForKey:@"symbol"];
        if ([symbol length] != 0) {
            [displayData addTitle:NSLocalizedString(@"Currency", nil) data:[NSString stringWithFormat:@"%@ (%@)", [self currencyId], symbol]];
        } else {
            [displayData addTitle:NSLocalizedString(@"Currency", nil) data:[self currencyId]];
        }
    } else {
        [displayData addTitle:NSLocalizedString(@"Currency", nil) data:NSLocalizedString(@"Unknown", nil)];
    }
    
    if ([self isOverCreditLimit]) {
        [displayData addTitle:NSLocalizedString(@"Balance", nil) data:[NSString stringWithFormat:@"%.2f", [self balance]] foregroundRight:[UIColor colorWithHexString:@"#c0392b"] backgroundRight:nil];
    } else {
        [displayData addTitle:NSLocalizedString(@"Balance", nil) data:[NSString stringWithFormat:@"%.2f", [self balance]]];
    }
    
    [displayData addTitle:NSLocalizedString(@"Current", nil) data:[NSString stringWithFormat:@"%.2f", [self current]]];
    [displayData addTitle:NSLocalizedString(@"30 Days", nil) data:[NSString stringWithFormat:@"%.2f", [self days30]]];
    [displayData addTitle:NSLocalizedString(@"60 Days", nil) data:[NSString stringWithFormat:@"%.2f", [self days60]]];
    [displayData addTitle:NSLocalizedString(@"90 Days", nil) data:[NSString stringWithFormat:@"%.2f", [self days90]]];
    [displayData addTitle:NSLocalizedString(@"120 Days", nil) data:[NSString stringWithFormat:@"%.2f", [self days120]]];
    
    if ([self isOverCreditLimit]) {
        [displayData addTitle:NSLocalizedString(@"Credit Limit", nil) data:[NSString stringWithFormat:@"%.2f", [self creditLimit]] foregroundRight:[UIColor colorWithHexString:@"#c0392b"] backgroundRight:nil];
    } else {
        [displayData addTitle:NSLocalizedString(@"Credit Limit", nil) data:[NSString stringWithFormat:@"%.2f", [self creditLimit]]];
    }
    
    [displayData addTitle:NSLocalizedString(@"Payment Terms", nil) data:[self paymentTerms]];
    
    [displayData closeSection];
    
    [displayData openSection];
    
    if ([[self sageId] length] == 0) {
        [displayData addTitle:NSLocalizedString(@"Account Ref", nil) data:[self accountRef]];
    } else {
        [displayData addTitle:NSLocalizedString(@"Account Number", nil) data:[self sageId]];
    }
    [displayData addTitle:NSLocalizedString(@"Feed", nil) data:[self cleanFeedName]];
    [displayData addTitle:NSLocalizedString(@"Name", nil) data:[self companyName]];
    [displayData addTitle:NSLocalizedString(@"Email Address", nil) data:[self email]];
    [displayData addTitle:NSLocalizedString(@"Telephone Number", nil) data:[self telephone]];
    [displayData addTitle:NSLocalizedString(@"Mobile Number", nil) data:[self mobile]];
    [displayData addTitle:NSLocalizedString(@"YTD", nil) data:[NSString stringWithFormat:@"%.2f", [self turnoverYTD]]];
    [displayData addTitle:NSLocalizedString(@"Prior Year", nil) data:[NSString stringWithFormat:@"%.2f", [self turnoverPYTD]]];
    [displayData closeSection];
    
    return displayData;
}

#pragma mark -

@end
