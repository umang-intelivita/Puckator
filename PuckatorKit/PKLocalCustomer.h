//
//  PKLocalCustomer.h
//  Puckator
//
//  Created by Luke Dixon on 05/08/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PKLocalAddress;

@interface PKLocalCustomer : NSManagedObject

@property (nonatomic, retain) NSString * customerId;
@property (nonatomic, retain) NSString * repName;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * currencyId;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * accountRef;
@property (nonatomic, retain) NSSet * addresses;
@end

@interface PKLocalCustomer (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(PKLocalAddress *)value;
- (void)removeAddressesObject:(PKLocalAddress *)value;
- (void)addAddresses:(NSSet *)values;
- (void)removeAddresses:(NSSet *)values;

@end
