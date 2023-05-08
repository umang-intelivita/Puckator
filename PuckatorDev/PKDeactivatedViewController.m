//
//  PKDeactivatedViewController.m
//  Puckator
//
//  Created by Luke Dixon on 02/02/2016.
//  Copyright © 2016 57Digital Ltd. All rights reserved.
//

#import "PKDeactivatedViewController.h"
#import "PKFeedsTableViewController.h"
#import "UIColor+Puckator.h"

@interface PKDeactivatedViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *buttonSwitch;


@end

@implementation PKDeactivatedViewController

+ (instancetype)create {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:[NSBundle mainBundle]];
    if (storyboard) {
        id viewController = [storyboard instantiateViewControllerWithIdentifier:@"PKDeactivatedViewController"];
        if ([viewController isKindOfClass:[PKDeactivatedViewController class]]) {
            return (PKDeactivatedViewController *)viewController;
        }
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PKWallpaper.png"]]];
    
    float radius = 10;
    [[[self viewContainer] layer] setCornerRadius:radius];
    [[[self viewContainer] layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[[self viewContainer] layer] setShadowOffset:CGSizeZero];
    [[[self viewContainer] layer] setShadowOpacity:0.75f];
    [[[self viewContainer] layer] setShadowRadius:10];
    
    [[[self buttonSwitch] layer] setCornerRadius:radius];
    [[self buttonSwitch] setBackgroundColor:[UIColor puckatorPrimaryColor]];
}

- (void)prepareForInterfaceBuilder {
    [[self view] setBackgroundColor:[UIColor redColor]];
//    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PKWallpaper.png"]]];
}

- (IBAction)buttonSwitchPressed:(id)sender {
    UIPopoverController *popoverController = [PKFeedsTableViewController switchFeedsPopoverFromViewController:self];
    [popoverController presentPopoverFromRect:[[self buttonSwitch] frame] inView:[[self buttonSwitch] superview] permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

@end