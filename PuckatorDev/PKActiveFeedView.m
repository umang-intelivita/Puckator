//
//  PKActiveFeedView.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 10/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKActiveFeedView.h"
#import "PKTranslate.h"
#import "PKSession.h"
#import <FCFileManager/FCFileManager.h>
#import "PKFeedsTableViewController.h"
#import "PKConstant.h"

@interface PKActiveFeedView()
@property (nonatomic, strong) UIImageView *imageViewFeedIcon;
@property (nonatomic, strong) UILabel *labelActiveFeed;
@property (nonatomic, strong) UIView *viewHairline;
@end

@implementation PKActiveFeedView

-(void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor puckatorGreen]];
    
    // Listen for active feed change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFeed)
                                                 name:kNotificationFeedDidChange
                                               object:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if(![self imageViewFeedIcon]) {
        int width = 40;
        [self setImageViewFeedIcon:[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-width-10, 5, width, width)]];
        [self imageViewFeedIcon].layer.cornerRadius = self.imageViewFeedIcon.frame.size.width / 2;
        [self imageViewFeedIcon].layer.borderWidth = 2;
        [self imageViewFeedIcon].layer.borderColor = [UIColor whiteColor].CGColor;
        [[self imageViewFeedIcon] setClipsToBounds:YES];
        [[self imageViewFeedIcon] setBackgroundColor:[UIColor puckatorPrimaryColor]];
        [[self imageViewFeedIcon] setContentMode:UIViewContentModeScaleToFill];
        [[self imageViewFeedIcon] setUserInteractionEnabled:NO];
        [[self view] addSubview:[self imageViewFeedIcon]];
    }
    
    if(![self labelActiveFeed]) {
        [self setLabelActiveFeed:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 50, 50)]];
        [[self labelActiveFeed] setBackgroundColor:[UIColor clearColor]];
        [[self labelActiveFeed] setTextColor:[UIColor whiteColor]];
        [[self labelActiveFeed] setFont:[UIFont fontWithName:@"Avenir-Medium" size:14]];
        [[self labelActiveFeed] setTextAlignment:NSTextAlignmentCenter];
        [[self labelActiveFeed] setNumberOfLines:0];
        [[self labelActiveFeed] setUserInteractionEnabled:NO];
        [[self view] addSubview:[self labelActiveFeed]];
    }
    
    if(![self viewHairline]) {
        [self setViewHairline:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)]];
        [[self viewHairline] setBackgroundColor:[UIColor puckatorDarkerGreen]];
        [[self view] addSubview:[self viewHairline]];
    }
    
    // Add tap recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSwitch:)];
    [[self view] addGestureRecognizer:tapGestureRecognizer];
    
    [self reloadFeed];
}

- (void) tappedSwitch:(id)sender {
    UIPopoverController *popoverController = [PKFeedsTableViewController switchFeedsPopoverFromViewController:self];
    [popoverController setPassthroughViews:@[]];
    [popoverController setBackgroundColor:[UIColor colorWithHexString:@"efeff4"]];
    [popoverController presentPopoverFromRect:CGRectMake(self.view.bounds.size.width/2, 0, 0, 0) inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void) reloadFeed {
    // Get the active feed
    PKFeedConfig *activeFeed = [[PKSession sharedInstance] currentFeedConfig];
    
    NSString *feedName = NSLocalizedString(@"No active feed", nil);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    if(activeFeed) {
        feedName = [activeFeed name];
        if([feedName length] == 0) {
            feedName = [activeFeed number];
        }
        
        [[self imageViewFeedIcon] setImage:[UIImage imageNamed:[activeFeed iconName]]];
        
    } else {
        [[self imageViewFeedIcon] setImage:nil];
    }
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:feedName attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:14], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"TAP TO SWITCH", nil)] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:10], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    [[self labelActiveFeed] setAttributedText:attributedString];
}

@end
