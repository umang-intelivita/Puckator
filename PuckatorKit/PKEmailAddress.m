//
//  PKEmail.m
//  Puckator
//
//  Created by Luke Dixon on 09/01/2018.
//  Copyright © 2018 57Digital Ltd. All rights reserved.
//

#import "PKEmailAddress.h"

@implementation PKEmailAddress

+ (instancetype)createWithEmail:(NSString *)email type:(NSString *)type {
    PKEmailAddress *emailAddress = [[PKEmailAddress alloc] init];
    [emailAddress setEmail:email];
    [emailAddress setType:type];
    return emailAddress;
}

@end
