//
//  NSDecimalNumber+FS.h
//  Puckator
//
//  Created by Luke Dixon on 08/02/2019.
//  Copyright © 2019 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (FS)

+ (instancetype)decimalNumberWithNumber:(NSNumber *)number;
+ (NSNumber *)roundDouble:(double)number;
+ (NSNumber *)roundString:(NSString *)number;
+ (NSNumber *)roundNumber:(NSNumber *)number;

+ (NSNumber *)divide:(NSNumber *)numberA by:(NSNumber *)numberB;
+ (NSNumber *)multiply:(NSNumber *)numberA by:(NSNumber *)numberB;
+ (NSNumber *)add:(NSNumber *)numberA to:(NSNumber *)numberB;
+ (NSNumber *)subtract:(NSNumber *)numberA from:(NSNumber *)numberB;

@end
