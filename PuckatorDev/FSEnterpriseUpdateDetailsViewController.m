//
//  FSEnterpriseUpdateDetailsViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 04/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSEnterpriseUpdateDetailsViewController.h"
#import <MKFoundationKit/MKFoundationKit.h>

@interface FSEnterpriseUpdateDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitleWhatsNew;
@property (weak, nonatomic) IBOutlet UITextView *textViewWhatsNew;
@property (weak, nonatomic) IBOutlet UILabel *labelTitleDetails;
@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UIButton *buttonLater;
@property (weak, nonatomic) IBOutlet UIButton *buttonUpdate;
@property (weak, nonatomic) IBOutlet UIView *viewWarning;
@property (weak, nonatomic) IBOutlet UILabel *labelWarningDetail;

@property (nonatomic, strong) NSString *plistUrl;
@property (nonatomic, assign) BOOL forceBrowserFallback;

@end

@implementation FSEnterpriseUpdateDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showUpdateDetails];
    [self applyStyle];
    
    [[self navigationItem] setHidesBackButton:YES];
}

- (void) applyStyle {
    [[[self buttonUpdate] layer] setCornerRadius:4];
    //[[[self buttonUpdate] layer] setBorderColor:[UIColor colorWithHexString:@"#006400"].CGColor];
    //[[[self buttonUpdate] layer] setBorderWidth:2];
    [[self buttonUpdate] setBackgroundColor:[UIColor colorWithHexString:@"#4c924c"]];
    [[self buttonUpdate] setClipsToBounds:YES];
    [[self buttonUpdate] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self buttonUpdate] setTitle:@"Update Now" forState:UIControlStateNormal];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Update Now" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName:[UIColor whiteColor]}]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nInternet Required" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor]}]];
    [[self buttonUpdate] setAttributedTitle:attributedString forState:UIControlStateNormal];
    [[[self buttonUpdate] titleLabel] setNumberOfLines:0];
    [[[self buttonUpdate] titleLabel] setTextAlignment:NSTextAlignmentCenter];
    
    
    [[[self buttonLater] layer] setCornerRadius:4];
    //[[[self buttonLater] layer] setBorderColor:[UIColor colorWithHexString:@"#6a6a6a"].CGColor];
    //[[[self buttonLater] layer] setBorderWidth:2];
    [[self buttonLater] setBackgroundColor:[UIColor colorWithHexString:@"#b5b5b5"]];
    [[self buttonLater] setClipsToBounds:YES];
    [[self buttonLater] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [[self buttonLater] setTitle:@"Try Later" forState:UIControlStateNormal];

}

- (void) showUpdateDetails {
    NSDictionary *updateDetails = [[NSUserDefaults standardUserDefaults] objectForKey:@"LatestUpdateAvailable"];
    if(updateDetails) {
        
        // Show the update details
        NSString *details = [updateDetails objectForKey:@"description"];
        [[self textViewWhatsNew] setText:details];
        
        // Show the version number
        NSString *version = [updateDetails objectForKey:@"version"];
        [[self labelVersion] setText:[NSString stringWithFormat:@"Version: %@", version]];
        
        // Set the padyload url
        [self setPlistUrl:[updateDetails objectForKey:@"plist_url"]];
        
        // Are we to force the use of safari for the update?
        if([[updateDetails objectForKey:@"force_browser_fallback"] boolValue] == YES) {
            [self setForceBrowserFallback:YES];
        }
        
        // Check timings
        int forceInstallInDays = [[updateDetails objectForKey:@"forced_after_days"] intValue];
        if(forceInstallInDays == -1) {
            [[self labelWarningDetail] setText:@"Tap Update Now to get started"];
            [[self viewWarning] setBackgroundColor:[UIColor lightGrayColor]];
        } else if(forceInstallInDays == 0) {
            [[self labelWarningDetail] setText:@"Critical: You must install this update immediately!"];
            [[self viewWarning] setBackgroundColor:[UIColor redColor]];
            [[self buttonLater] setAlpha:0.2f];
            [[self buttonLater] setEnabled:NO];
            [self addSecretBypassOption];
        } else {
            NSDate *requiredInstallBy = [[NSDate date] mk_dateByAddingDays:forceInstallInDays];
            if([[NSDate date] mk_isEarlierThanDate:requiredInstallBy]) {
                int deltaDays = (int)[requiredInstallBy mk_differenceInDaysToDate:[NSDate date]];
                if(deltaDays != 0) {
                    [[self labelWarningDetail] setText:[NSString stringWithFormat:@"You have %d days left to apply this update before your app will stop working as normal.", abs(deltaDays)]];
                } else {
                    [[self labelWarningDetail] setText:@"You must install this update today, otherwise the app will no longer work as intended."];
                }
                [[self viewWarning] setBackgroundColor:[UIColor orangeColor]];
            } else {
                [[self labelWarningDetail] setText:@"Grace period has elapsed! You must install this update now."];
                [[self viewWarning] setBackgroundColor:[UIColor redColor]];
                [[self buttonLater] setAlpha:0.2f];
                [[self buttonLater] setEnabled:NO];
                [self addSecretBypassOption];
            }
        }
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)buttonUpdatePressed:(id)sender {
    
    NSString *url = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [self plistUrl]];
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]] && ![self forceBrowserFallback]) {
        [self dismissViewControllerAnimated:YES completion:^{
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]]; 
        }];
    } else {
        // Fall back to using Safari (either because device doesn't support itms-services:// or we have enabled forced browser updates
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FSEnterpriseUpdate" ofType:@"plist"]];
        NSString *fallbackEndpointUrlFormat = [settings objectForKey:@"fallback_endpoint"];
        NSString *fallbackUri = [[NSString stringWithFormat:fallbackEndpointUrlFormat, [[NSBundle mainBundle] mk_version]] stringByReplacingOccurrencesOfString:@"ts=<time>" withString:[NSString stringWithFormat:@"ts=%d", (int)[[NSDate date] timeIntervalSince1970]]];
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:fallbackUri]]) {
            [self dismissViewControllerAnimated:YES completion:^{
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fallbackUri]];
            }];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enterprise Update Not Possible"
                                                            message:@"Your device could not perform an OTA (Over the air) update and Safari could not be opened either.\n\nPlease contact the administrator."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
    //[self performSelector:@selector(closeApp) withObject:nil afterDelay:3.0];
}

- (void) addSecretBypassOption {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapSkip:)];
    [tapGesture setNumberOfTapsRequired:5];
    [[self viewWarning] addGestureRecognizer:tapGesture];
}

- (void) didDoubleTapSkip:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonTryLaterPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) closeApp {
    [[UIApplication sharedApplication] performSelector:@selector(suspend) withObject:nil];
}

@end
