//
//  PKJob.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKJob : NSObject

@property (nonatomic, strong) NSUUID *uuid;             // A unique identifier for the job
@property (nonatomic, assign) int nonce;                // A unique non-repeatable value, used for sequencing mainly
@property (nonatomic, strong) NSString *feedNumber;     // The associated feed number (if applicable)
@property (nonatomic, strong) NSString *title;          // The title of the job
@property (nonatomic, strong) NSDictionary *userInfo;   // Any misc user info that needs to be stored
@property (nonatomic, assign) BOOL finished;            // Flag to determine if this job has now finished
@property (nonatomic, assign) BOOL success;             // Job is finished and successful if true
@property (nonatomic, assign) BOOL failure;             // Job is finished and is a failure
@property (nonatomic, strong) NSString *error;          // An Error message
@property (nonatomic, strong) NSError *errorObject;     // An error object
@property (nonatomic, assign) int progress;             // For determinate progress based jobs, i.e. 10% of Products Imported
@property (nonatomic, assign) int count;                // For count based jobs, i.e. 10 Products Imported

// Flags the job as finished & sucessful
- (void) completeJob;

// Flags job as finished & failed
- (void) failJobWithErrorMessage:(NSString*)errorMessage;
- (void) failJobWithErrorMessage:(NSString*)errorMessage andError:(NSError*)error;

@end
