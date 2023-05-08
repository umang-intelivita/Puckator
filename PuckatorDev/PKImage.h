//
//  PKImage.h
//  PuckatorDev
//
//  Created by Luke Dixon on 22/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PKImage : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSManagedObject *product;

@end
