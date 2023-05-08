//
//  PKFeedTableViewCell.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKFeedConfig.h"

@interface PKFeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelFeedName;
@property (weak, nonatomic) IBOutlet UILabel *labelFeedNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelFeedInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelFullWidth;
@property (weak, nonatomic) IBOutlet UIButton *buttonSwitch;

/* The feed configuration */
@property (nonatomic, strong) PKFeedConfig *feedConfiguration;
@property (nonatomic, assign) BOOL isCustomMessageCell;             // If YES, all other fields except labelFullWidth will be hidden
@property (nonatomic, strong) NSString *message;                    // If isCustomMessageCell=YES, this message is displayed.  E.g. "TITLE HERE\n\nMessage Here"

- (void) enableSwitchButton;
- (void) disableSwitchButton;
- (void) showActiveButton;

@end
