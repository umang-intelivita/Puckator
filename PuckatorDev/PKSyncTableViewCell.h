//
//  PKSyncTableViewCell.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKFeedConfig;

@interface PKSyncTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelFeedName;
@property (weak, nonatomic) IBOutlet UILabel *labelStatusMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelProgressText;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void) setFeedConfig:(PKFeedConfig *)feedConfig;

@end