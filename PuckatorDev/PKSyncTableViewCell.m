//
//  PKSyncTableViewCell.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKSyncTableViewCell.h"
#import "PKConstant.h"
#import "PKTranslate.h"

@interface PKSyncTableViewCell ()

// The Feed Config
@property (nonatomic, strong) PKFeedConfig *feedConfig;

@end

@implementation PKSyncTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [[[self imageViewIcon] layer] setCornerRadius:2];
    [[self imageViewIcon] setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setFeedConfig:(PKFeedConfig *)feedConfig {
    _feedConfig = feedConfig;
    
    // Update UI:
    __weak PKSyncTableViewCell *weakSelf = self;
    [FSThread runOnMain:^{
        [[weakSelf labelFeedName] setText:[_feedConfig name]];
    }];
    
    // Update status
    [self updateStatus];
    
    //[[self activityIndicator] startAnimating];
    
    // Setup a notification centre observer for this feed
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateFeedConfig:)
                                                 name:[NSString stringWithFormat:@"%@.%@", kNotificationSyncProgressUpdate, [feedConfig number]]
                                               object:nil];
}

- (void) updateStatus {
    NSMutableString *statusText = [NSMutableString stringWithString:NSLocalizedString(@"Queued", nil)];
    
    
    __weak PKSyncTableViewCell *weakSelf = self;
    BOOL syncFinished = !([[self feedConfig] isSyncProcessing] && ![[self feedConfig] isSyncFinished]);
    float progress = 0.0f;
//    int imageTag = 0;
    
    if ([self feedConfig] && [[self feedConfig] statusText]) {
        statusText = [NSMutableString stringWithString:[[self feedConfig] statusText]];
        int remainingFeeds = (int)([[self feedConfig] totalFeedsEnqueued] - [[[self feedConfig] feedQueue] count]);
        if (remainingFeeds <= 0) {
            remainingFeeds = 1;
        }
        
        [statusText insertString:[NSString stringWithFormat:NSLocalizedString(@"Step %d/%d:", @"Informs the user which step they are in during the sync. E.g. Step 1/5:"), remainingFeeds, [[self feedConfig] totalFeedsEnqueued]] atIndex:0];
    }
    
    
    if ([[self feedConfig] totalFeedsEnqueued] == [[[self feedConfig] feedQueue] count]) {
        progress = 0.0f;
    } else {
        float feedsRemaining = (float)([[self feedConfig] totalFeedsEnqueued] - [[[self feedConfig] feedQueue] count]);
        float percentCompleted = (feedsRemaining / (float)[[self feedConfig] totalFeedsEnqueued]);
        progress = percentCompleted;
    }
    
    // Update the UI:
    dispatch_async(dispatch_get_main_queue(), ^{
        if (syncFinished) {
            [[weakSelf activityIndicator] stopAnimating];
        } else {
            [[weakSelf activityIndicator] startAnimating];
        }
        
        [[weakSelf labelStatusMessage] setText:statusText];
        
        // Check for error message:
        BOOL error = NO;
        if ([[statusText lowercaseString] containsString:@"error"]) {
            error = YES;
        }
        if (error) {
            [[weakSelf labelStatusMessage] setTextColor:[UIColor redColor]];
        }
        
        // Load the grahic:
        UIImage *image = nil;
        if ([[weakSelf feedConfig] iconName] && [[weakSelf imageViewIcon] tag] == 0) {
           // imageTag = 1;
            image = [UIImage imageNamed:[[self feedConfig] iconName]];
        }
        
        if ([[self feedConfig] type] == PKFeedConfigTypeImageDownloader) {
            image = [UIImage imageNamed:@"PKFeedImages.png"];
        } else if ([[self feedConfig] type] == PKFeedConfigTypeSQLDownloader) {
            image = [UIImage imageNamed:@"PKFeedUnknown.png"];
        }
        
        [[weakSelf imageViewIcon] setImage:image];
        
        // Update progress:
        if ([[weakSelf progressView] progress] != progress) {
            [[weakSelf progressView] setProgress:progress];
        }
    });
}

#pragma mark - Listen for observer changes

- (void)didUpdateFeedConfig:(NSNotification*)notification {
    //@synchronized(self) {
        if ([[notification object] isKindOfClass:[PKFeedConfig class]]) {
            [self setFeedConfig:(PKFeedConfig *)[notification object]];
        }
        
        [self updateStatus];
    //}
}

@end
