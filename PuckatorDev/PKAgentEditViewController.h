//
//  PKAgentEditViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "FXForms.h"
#import "FSFormBaseViewController.h"

@interface PKAgentEditViewController : FSFormBaseViewController <FXFormControllerDelegate>

@property (assign, nonatomic) BOOL isEditMode;

+ (instancetype)create;

@end