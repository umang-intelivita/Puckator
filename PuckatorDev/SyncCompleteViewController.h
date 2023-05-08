//
//  SyncCompleteViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 20/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSBaseViewController.h"

@interface SyncCompleteViewController : FSBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeTaken;
@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;
@property (weak, nonatomic) IBOutlet UIImageView *buttonIcon;

@end
