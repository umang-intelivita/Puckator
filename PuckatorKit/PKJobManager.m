//
//  PKJobManager.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKJobManager.h"
#import "PKJob.h"

@interface PKJobManager()
@property (nonatomic, strong) NSMutableArray *jobs;
@property (nonatomic, assign) int nonce;
@end

@implementation PKJobManager

- (id)init
{
    if (!self.isInitialized) {
        self = [super init];
        
        if (self) {
            [self setJobs:[NSMutableArray array]];
        }
    }
    
    return self;
}

- (PKJob*) createJobWithTitle:(NSString*)title {
    return [self createJobWithTitle:title forFeedNumber:nil];
}

- (PKJob*) createJobWithTitle:(NSString*)title forFeedNumber:(NSString*)feedNumber {
    PKJob *job = [[PKJob alloc] init];
    [job setTitle:title];
    [job setFeedNumber:feedNumber];
    if (job) {
        [[self jobs] addObject:job];
    }
    return job;
}

- (int) nextNonce {
    return ++_nonce;
}

@end
