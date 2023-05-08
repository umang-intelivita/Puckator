//
//  PKAgent.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms.h>

@class PKEmailAddress;

@interface PKAgent : NSObject <FXForm>

@property (assign, nonatomic) BOOL isEditMode;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;

// Gets the current agent
+ (PKAgent*) currentAgent;

// Saves changes made to the agent
- (void) save;

- (PKEmailAddress *)emailAddress;
- (NSArray <PKEmailAddress *> *)emailAddresses;

@end

