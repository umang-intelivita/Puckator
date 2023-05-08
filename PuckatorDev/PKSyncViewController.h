//
//  PKSyncViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBaseViewController.h"
#import "PKFeed.h"

typedef enum {
    PKSyncOriginTypeConfiguration = 0,
    PKSyncOriginTypePopover = 1
} PKSyncOriginType;


@interface PKSyncViewController : FSBaseViewController <UITableViewDataSource, UITableViewDelegate, PKFeedDelegate>

// The context in which the sync UI is being displayed
@property (nonatomic, assign) PKSyncOriginType origin;

+ (instancetype)createWithOriginType:(PKSyncOriginType)syncOriginType;

@end
