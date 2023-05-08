//
//  PKFeedTableViewCell.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeedTableViewCell.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"

@implementation PKFeedTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void) setFeedConfiguration:(PKFeedConfig *)feedConfiguration {
    _feedConfiguration = feedConfiguration;
    [[self labelFeedName] setText:[_feedConfiguration name]];
    [[self labelFeedNumber] setText:[_feedConfiguration number]];
    
    BOOL invalidImage = YES;
    if([_feedConfiguration iconName]) {
        if([[NSBundle mainBundle] pathForResource:[_feedConfiguration iconName] ofType:nil]) {
            invalidImage = NO;
        }
    }
    
    // Load the icon
    if(!invalidImage) {
        [[self imageViewIcon] setImage:[UIImage imageNamed:[_feedConfiguration iconName]]];
    } else {
        [[self imageViewIcon] setImage:[UIImage imageNamed:@"PKFeedUnknown.png"]];
    }
    
    // Apply a radius to the image
    [[self imageViewIcon] setClipsToBounds:YES];
    [[self imageViewIcon] layer].cornerRadius = 2;
    
    // Toggle User Interface elements for custom message cells
    [[self imageViewIcon] setHidden:[self isCustomMessageCell]];
    [[self labelFeedInfo] setHidden:[self isCustomMessageCell]];
    [[self labelFeedName] setHidden:[self isCustomMessageCell]];
    [[self labelFeedNumber] setHidden:[self isCustomMessageCell]];
    [[self labelFullWidth] setHidden:![self isCustomMessageCell]];
        
    // Is this a custom cell?  If so, lets format the message
    if([self isCustomMessageCell]) {
        if([[self message] rangeOfString:@"\n\n"].location != NSNotFound) {
            if([self message]) {
                NSArray *strings = [[self message] componentsSeparatedByString:@"\n\n"];
                NSMutableAttributedString *attributedStringMessage = [[NSMutableAttributedString alloc] init];
                [attributedStringMessage appendAttributedString:[[NSAttributedString alloc] initWithString:[strings firstObject]
                                                                                                attributes:@{NSForegroundColorAttributeName: [UIColor puckatorPrimaryColor],
                                                                                                             NSFontAttributeName: [UIFont puckatorContentTitle]}]];
                [attributedStringMessage appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                [attributedStringMessage appendAttributedString:[[NSAttributedString alloc] initWithString:[strings lastObject]
                                                                                                attributes:@{NSForegroundColorAttributeName: [UIColor puckatorSubtitleColor],
                                                                                                             NSFontAttributeName: [UIFont puckatorContentText]}]];
                [[self labelFullWidth] setAttributedText:attributedStringMessage];
                [[self labelFullWidth] setNumberOfLines:-1];
            } else {
                [[self labelFullWidth] setText:@"Error Loading Content"];
            }
        }
    }
    
    // Customize other stuff
    [[self buttonSwitch] setBackgroundColor:[UIColor puckatorPrimaryColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if(animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
    }
    
    if(editing) {
        [[self labelFeedInfo] setAlpha:0.0f];
    } else {
        [[self labelFeedInfo] setAlpha:1.0f];
    }
    
    if(animated) {
        [UIView commitAnimations];
    }
}

- (void) enableSwitchButton {
    [[self buttonSwitch] setBackgroundColor:[UIColor puckatorPrimaryColor]];
    [[self buttonSwitch] setTitle:NSLocalizedString(@"Switch to...", nil) forState:UIControlStateNormal];
}

- (void) disableSwitchButton {
    [[self buttonSwitch] setBackgroundColor:[UIColor lightGrayColor]];
    [[self buttonSwitch] setTitle:NSLocalizedString(@"Unavailable", nil) forState:UIControlStateNormal];
}

- (void) showActiveButton {
    [[self buttonSwitch] setBackgroundColor:[UIColor puckatorGreen]];
    [[self buttonSwitch] setTitle:NSLocalizedString(@"Active", nil) forState:UIControlStateNormal];
}


@end
