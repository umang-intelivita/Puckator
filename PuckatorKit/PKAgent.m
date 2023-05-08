//
//  PKAgent.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKAgent.h"
#import "PKTranslate.h"
#import <FXKeychain/FXKeychain.h>
#import "PKEmailAddress.h"

@interface PKAgent ()


@end

@implementation PKAgent

#pragma mark - FXForm Fields (used for displaying this object in the user interface)

- (NSArray *)fields {
    if ([self isEditMode]) {
        return @[@{FXFormFieldKey:      @"firstName",       FXFormFieldTitle: NSLocalizedString(@"First Name", nil),     FXFormFieldPlaceholder: NSLocalizedString(@"Your first name", nil)},
                 @{FXFormFieldKey:      @"lastName",        FXFormFieldTitle: NSLocalizedString(@"Last Name", nil),      FXFormFieldPlaceholder: NSLocalizedString(@"Your last name", nil)},
                 @{FXFormFieldKey:      @"email",           FXFormFieldTitle: NSLocalizedString(@"E-mail Address", nil), FXFormFieldPlaceholder: NSLocalizedString(@"Your e-mail address", nil) },
                 @{FXFormFieldHeader:   @"",                FXFormFieldTitle: NSLocalizedString(@"Save", nil),       FXFormFieldAction: @"saveAgent:"}];
    } else {
        return @[@{FXFormFieldKey:      @"firstName",       FXFormFieldTitle: NSLocalizedString(@"First Name", nil),     FXFormFieldPlaceholder: NSLocalizedString(@"Your first name", nil), FXFormFieldHeader: NSLocalizedString(@"AUTHENTICATE WITH PUCKATOR.NET", nil) },
                 @{FXFormFieldKey:      @"lastName",        FXFormFieldTitle: NSLocalizedString(@"Last Name", nil),      FXFormFieldPlaceholder: NSLocalizedString(@"Your last name", nil)},
                 @{FXFormFieldKey:      @"email",           FXFormFieldTitle: NSLocalizedString(@"E-mail Address", nil), FXFormFieldPlaceholder: NSLocalizedString(@"Your e-mail address", nil) },
                 @{FXFormFieldHeader:   @"",                FXFormFieldTitle: NSLocalizedString(@"Continue", nil),       FXFormFieldAction: @"saveAgent:"}];
    }
}

#pragma mark - Marshalling to/from NSDictionary

- (NSDictionary*) toDictionary {
    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionary];
    if([self firstName]) {
        [dictionaryRepresentation setObject:[self firstName] forKey:@"first_name"];
    }
    if([self lastName]) {
        [dictionaryRepresentation setObject:[self lastName] forKey:@"last_name"];
    }
    if([self email]) {
        [dictionaryRepresentation setObject:[self email] forKey:@"email"];
    }
    return dictionaryRepresentation;
}

- (void) fromDictionary:(NSDictionary*)dictionaryRepresentation {
    if([dictionaryRepresentation objectForKey:@"first_name"]) {
        [self setFirstName:[dictionaryRepresentation objectForKey:@"first_name"]];
    }
    if([dictionaryRepresentation objectForKey:@"last_name"]) {
        [self setLastName:[dictionaryRepresentation objectForKey:@"last_name"]];
    }
    if([dictionaryRepresentation objectForKey:@"email"]) {
        [self setEmail:[dictionaryRepresentation objectForKey:@"email"]];
    }
}

- (PKEmailAddress *)emailAddress {
    return [PKEmailAddress createWithEmail:[self email] type:nil];
}

- (NSArray<PKEmailAddress *> *)emailAddresses {
    PKEmailAddress *emailAddress = [self emailAddress];
    if (emailAddress) {
        return @[emailAddress];
    }
    return nil;
}

#pragma mark - Getting/Saving

+ (PKAgent *)currentAgent {
    // Read feed configuration from the keychain
    FXKeychain *keychain = [FXKeychain defaultKeychain];
    
    // Loop through the stored feed dicts
    NSDictionary *agent = [keychain objectForKey:@"agent"];
    PKAgent *agentObject = [[PKAgent alloc] init];
    if(agent && [agent isKindOfClass:[NSDictionary class]]) {
        [agentObject fromDictionary:agent];
    }
    return agentObject;
}

- (void) save {
    
    // Save to keychain
    FXKeychain *keychain = [FXKeychain defaultKeychain];
    [keychain setAccessibility:FXKeychainAccessibleAlways];
    
    // Convert the agent to a dictionary
    NSDictionary *dictionaryRepresentation = [self toDictionary];
    [keychain setObject:dictionaryRepresentation forKey:@"agent"];
    
}

@end
