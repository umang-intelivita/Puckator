//
//  NSObject+JSON.m
//  SkinEditor
//
//  Created by Luke Dixon on 13/01/2014.
//  Copyright (c) 2014 Private. All rights reserved.
//

#import "NSObject+JSON.h"

@implementation NSObject (JSON)

- (NSString *)jsonWithPrettyPrint:(BOOL)prettyPrint {
    // Create the json string object to return:
    NSString *json = nil;
    
    // Attempt to parse the object into json:
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    // Check for errors:
    if (!error) {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"[%@] - JSON PARSE ERROR:\n %@", [self class], error.description);
    }
    
    // Return the json object:
    return json;
}

- (NSString *)json {
    return [self jsonWithPrettyPrint:NO];
}

- (NSData *)jsonData {
    return [[self json] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (instancetype)objectFromJson:(NSString *)json {
    NSError *error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:NSJSONReadingMutableContainers
                                                   error:&error];
    
    if (!error) {
        // No error found, therefore return the json obj:
        return jsonObj;
    } else {
        NSLog(@"[%@] - JSON PARSE ERROR:\n %@", [self class], error.description);
    }
    
    // Nothing else to return, therefore return nil:
    return nil;
}

+ (instancetype)objectFromJson:(NSString *)json error:(NSError **)error_ {
    NSError *error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:NSJSONReadingMutableContainers
                                                   error:&error];
    
    if (jsonObj) {
        // No error found, therefore return the json obj:
        return jsonObj;
    } else if (error_) {
        *error_ = error;
    }
    
    // Nothing else to return, therefore return nil:
    return nil;
}

@end