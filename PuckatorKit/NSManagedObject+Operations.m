//
//  NSManagedObject+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "NSManagedObject+Operations.h"
#import "RXMLElement+Utilities.h"

@implementation NSManagedObject (Operations)

- (void) ifStringExistsInElement:(RXMLElement*)element forKey:(NSString*)key thenSetValue:(SEL)selector {
    [self ifStringExistsInElement:element forKey:key thenSetValue:selector andSaveAsType:PKVariableTypeNSString];
}

- (void) ifStringExistsInElement:(RXMLElement*)element forKey:(NSString*)key thenSetValue:(SEL)selector andSaveAsType:(PKVariableType)type {
    
    id value = [element stringForKey:key];
    if (value) {
        if([self respondsToSelector:selector]) {
            switch (type) {
                case PKVariableTypeNSNumber: {
                    value = @([value intValue]);    // Cast to an NSNumber
                    break;
                }
                case PKVariableTypeNSNumberBooleanFromCharacter: {
                    BOOL boolValue = NO;
                    if ([value isKindOfClass:[NSString class]]) {
                        if([[value lowercaseString] isEqualToString:@"y"]) {
                            boolValue = YES;
                        }
                    }
                    value = [NSNumber numberWithBool:boolValue];
                    break;
                }
                case PKVariableTypeNSNumberFloat: {
                    value = @([value floatValue]);
                    break;
                }
                case PKVariableTypeNSDate: {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                    value = [dateFormatter dateFromString:value];
                    break;
                }
                default:
                case PKVariableTypeNSString: {
                    break;
                }
            }
            
            [self performSelector:selector withObject:value];
        }
    }
}

@end
