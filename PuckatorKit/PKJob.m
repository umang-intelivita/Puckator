//
//  PKJob.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKJob.h"
#import "PKJobManager.h"

@implementation PKJob

- (id) init {
    if(self = [super init]) {
        [self setUuid:[NSUUID UUID]];
        [self setNonce:[[PKJobManager sharedInstance] nextNonce]];
    }
    return self;
}

- (void) completeJob {
    [self setFinished:YES];
    [self setSuccess:YES];
    [self setFailure:NO];
    
    // Update job
    [self update];
}

- (void) failJobWithErrorMessage:(NSString*)errorMessage {
    [self failJobWithErrorMessage:errorMessage andError:nil];
}

- (void) failJobWithErrorMessage:(NSString*)errorMessage andError:(NSError*)error {
    [self setFinished:YES];
    [self setSuccess:NO];
    [self setFailure:YES];
    
    if(errorMessage) {
        [self setError:errorMessage];
    }
    if(error) {
        [self setErrorObject:error];
    }
    
    // Update job
    [self update];
}

- (void) update {
    NSLog(@"Job update: Job: %@, Finish? %d, Success? %d, Fail? %d, ErrMsg=%@, Err=%@", [self title], [self finished], [self success], [self failure], [self error], [self errorObject]);
}

@end
