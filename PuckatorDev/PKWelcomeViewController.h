//
//  PKWelcomeViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBaseViewController.h"

@interface PKWelcomeViewController : FSBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelLanguageTitle;
@property (weak, nonatomic) IBOutlet UIView *viewLanguageContainer;
@property (nonatomic, assign) BOOL isCancelDisabled;

- (IBAction)buttonLanguagePressed:(id)sender;

@end
