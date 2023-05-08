//
//  PKOrderSyncViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 26/05/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSAbstractViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface PKOrderSyncViewController : FSAbstractViewController <MFMailComposeViewControllerDelegate>

#pragma mark - Methods

+ (instancetype)create;
+ (NSMutableArray *)orderFilenames;

@end
