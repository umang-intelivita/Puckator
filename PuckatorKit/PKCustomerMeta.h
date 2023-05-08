//
//  PKCustomerMeta.h
//  
//
//  Created by Jamie Chapman on 25/06/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PKCustomerMeta : NSManagedObject

@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSString * customerId;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * value;

@end
