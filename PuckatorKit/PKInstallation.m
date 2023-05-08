//
//  PKInstallation.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 23/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKInstallation.h"
#import <UIKit/UIKit.h>
#import <FXKeychain/FXKeychain.h>
#import <sys/utsname.h>

@implementation PKInstallation

+ (NSString*) currentInstallationToken {
    
    // Get or set the installation token to the keychain
    FXKeychain *keychain = [FXKeychain defaultKeychain];
    if([keychain objectForKey:@"pkinstallation"]) {
        return [keychain objectForKey:@"pkinstallation"];
    } else {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [keychain setObject:uuid forKey:@"pkinstallation"];
        return uuid;
    }

}

+ (NSString*) currentInstallationJwt {
    // Get or set the installation token to the keychain
    FXKeychain *keychain = [FXKeychain defaultKeychain];
    if([keychain objectForKey:@"pkinstallation_jwt"]) {
        //NSLog(@"JWT: %@", [keychain objectForKey:@"pkinstallation_jwt"]);
        return [keychain objectForKey:@"pkinstallation_jwt"];
    } else {
        return nil;
    }
}

+ (void) setCurrentInstallationJwt:(NSString*)jwt {
    if(jwt && [jwt isKindOfClass:[NSString class]]) {
        FXKeychain *keychain = [FXKeychain defaultKeychain];
        [keychain setObject:jwt forKey:@"pkinstallation_jwt"];
    }
}

+ (void) reset {
    
    // Delete installation token
    FXKeychain *keychain = [FXKeychain defaultKeychain];
    [keychain removeObjectForKey:@"pkinstallation"];
    
}

#pragma mark - version stuff

+ (NSString*) appVersion {
    return @"2.0";
}

+ (NSString*) deviceName {
    return [[UIDevice currentDevice] name];
}

+ (NSString*) deviceOsVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString*) deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end
