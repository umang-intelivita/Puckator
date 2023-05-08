//
//  NSDecimalNumber+FS.m
//  Puckator
//
//  Created by Luke Dixon on 08/02/2019.
//  Copyright © 2019 57Digital Ltd. All rights reserved.
//

#import "NSDecimalNumber+FS.h"

@implementation NSDecimalNumber (FS)

+ (NSNumber *)roundDouble:(double)number {
    return [NSDecimalNumber roundString:[@(number) stringValue]];
}

+ (NSNumber *)roundNumber:(NSNumber *)number {
    return [NSDecimalNumber roundString:[number stringValue]];
}

+ (NSNumber *)roundString:(NSString *)number {
    if ([number length] == 0) {
        return nil;
    }
    
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:number];
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                              scale:2
                                                                                   raiseOnExactness:NO
                                                                                    raiseOnOverflow:NO
                                                                                   raiseOnUnderflow:NO
                                                                                raiseOnDivideByZero:NO];
    NSDecimalNumber *numberRounded = [decimalNumber decimalNumberByRoundingAccordingToBehavior:behavior];
    return (NSNumber *)numberRounded;
}

+ (instancetype)decimalNumberWithNumber:(NSNumber *)number {
    if (!number) {
        number = @(0);
    }
    return [NSDecimalNumber decimalNumberWithString:[number stringValue]];
}

+ (NSNumber *)divide:(NSNumber *)numberA by:(NSNumber *)numberB {
    NSDecimalNumber *decimalA = [NSDecimalNumber decimalNumberWithNumber:numberA];
    NSDecimalNumber *decimalB = [NSDecimalNumber decimalNumberWithNumber:numberB];
    
    if ([numberA doubleValue] == 0 || [numberB doubleValue] == 0) {
        return @(0);
    }
    
    return (NSNumber *)[decimalA decimalNumberByDividingBy:decimalB];
}

+ (NSNumber *)multiply:(NSNumber *)numberA by:(NSNumber *)numberB {
    NSDecimalNumber *decimalA = [NSDecimalNumber decimalNumberWithNumber:numberA];
    NSDecimalNumber *decimalB = [NSDecimalNumber decimalNumberWithNumber:numberB];
    return (NSNumber *)[decimalA decimalNumberByMultiplyingBy:decimalB];
}

+ (NSNumber *)add:(NSNumber *)numberA to:(NSNumber *)numberB {
    NSDecimalNumber *decimalA = [NSDecimalNumber decimalNumberWithNumber:numberA];
    NSDecimalNumber *decimalB = [NSDecimalNumber decimalNumberWithNumber:numberB];
    return (NSNumber *)[decimalA decimalNumberByAdding:decimalB];
}

+ (NSNumber *)subtract:(NSNumber *)numberA from:(NSNumber *)numberB {
    NSDecimalNumber *decimalA = [NSDecimalNumber decimalNumberWithNumber:numberA];
    NSDecimalNumber *decimalB = [NSDecimalNumber decimalNumberWithNumber:numberB];
    return (NSNumber *)[decimalB decimalNumberBySubtracting:decimalA];
}

@end
