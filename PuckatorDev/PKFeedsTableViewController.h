//
//  PKFeedsTableViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PKFeedsTableModeEditor = 0,
    PKFeedsTableModeSwitcher = 1
} PKFeedsTableMode;

@class PKFeedsTableViewController;
@protocol PKFeedsTableDelegate <NSObject>
@required
- (void) pkFeedsTableViewController:(PKFeedsTableViewController*)feedsTableViewController didSwitchFeed:(PKFeedConfig*)feedConfig;
- (void) pkFeedsTableViewController:(PKFeedsTableViewController *)feedsTableViewController didRequestToEditFeeds:(BOOL)didRequestToEditFeeds;
@end

@interface PKFeedsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

// The current mode of the table controller.
//   Editor allows the feeds to be edited/changed/adds.  Switcher allows the user to switch sessions.
@property (nonatomic, assign) PKFeedsTableMode mode;

// The delegate for the feeds switcher, etc.
@property (nonatomic, assign) id<PKFeedsTableDelegate> delegate;

#pragma mark - Popover version

+ (instancetype)create;

// Creates a popover that is suitable for switching the active feed
+ (UIPopoverController*) switchFeedsPopoverFromViewController:(id)sourceViewController;

@end
