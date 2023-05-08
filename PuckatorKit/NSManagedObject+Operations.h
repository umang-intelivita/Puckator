//
//  NSManagedObject+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RXMLElement;

typedef enum {
    PKVariableTypeNSString = 0,
    PKVariableTypeNSNumber = 1,
    PKVariableTypeNSNumberBooleanFromCharacter = 2, /* Weird one, "y"=true, else false. Quirk of existing Puckator API */
    PKVariableTypeNSNumberFloat = 3,
    PKVariableTypeNSDate = 4
} PKVariableType;

@interface NSManagedObject (Operations)

- (void) ifStringExistsInElement:(RXMLElement*)element forKey:(NSString*)key thenSetValue:(SEL)selector;
- (void) ifStringExistsInElement:(RXMLElement*)element forKey:(NSString*)key thenSetValue:(SEL)selector andSaveAsType:(PKVariableType)type;

@end
