//
//  PKInstallation.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 23/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKInstallation : NSObject

// Gets (or creates) the current installation token.  This value is assigned to the keychain
+ (NSString*) currentInstallationToken;

// Removes the installation token from the keychain..
+ (void) reset;

// Gets the current JWT token returned by the web service
+ (NSString*) currentInstallationJwt;

// Sets the current JWT token.  This will be used for future server communication.
+ (void) setCurrentInstallationJwt:(NSString*)jwt;

#pragma mark - version stuff

+ (NSString*) appVersion;
+ (NSString*) deviceName;
+ (NSString*) deviceOsVersion;
+ (NSString*) deviceModel;

@end
