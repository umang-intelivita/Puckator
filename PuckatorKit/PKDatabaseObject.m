//
//  PKDatabaseObject.m
//  Puckator
//
//  Created by Luke Dixon on 14/07/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKDatabaseObject.h"

@implementation PKDatabaseObject

+ (instancetype)createFromResultSet:(FMResultSet *)resultSet {
    return [[PKDatabaseObject alloc] init];
}

@end