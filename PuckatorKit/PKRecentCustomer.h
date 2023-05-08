//
//  PKRecentCustomer.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 18/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PKRecentCustomer : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * customerId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSNumber * pinned;

@end
