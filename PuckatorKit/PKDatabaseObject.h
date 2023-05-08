//
//  PKDatabaseObject.h
//  Puckator
//
//  Created by Luke Dixon on 14/07/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKDatabase.h"
#import "FMResultSet+Additional.h"

@interface PKDatabaseObject : NSObject

+ (instancetype)createFromResultSet:(FMResultSet *)resultSet;

@end