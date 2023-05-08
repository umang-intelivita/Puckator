//
//  PKFeedConfigMeta.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PKFeedConfigMeta : NSManagedObject

@property (nonatomic, retain) NSString * feedNumber;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) id object;
@property (nonatomic, retain) NSDate * createdAt;

@end
