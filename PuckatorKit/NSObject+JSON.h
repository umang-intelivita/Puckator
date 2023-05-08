//
//  NSObject+JSON.h
//  SkinEditor
//
//  Created by Luke Dixon on 13/01/2014.
//  Copyright (c) 2014 Private. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSON)

- (NSString *)json;
- (NSString *)jsonWithPrettyPrint:(BOOL)prettyPrint;

- (NSData *)jsonData;

+ (instancetype)objectFromJson:(NSString *)json;
+ (instancetype)objectFromJson:(NSString *)json error:(NSError **)error;

@end