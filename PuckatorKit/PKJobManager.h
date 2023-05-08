//
//  PKJobManager.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DOSingleton/DOSingleton.h>

@class PKJob;

@interface PKJobManager : DOSingleton {
}

// Creates a newjob in the job manager
- (PKJob*) createJobWithTitle:(NSString*)title;
- (PKJob*) createJobWithTitle:(NSString*)title forFeedNumber:(NSString*)feedNumber;

// Gets the next unique nonce value
- (int) nextNonce;

@end
