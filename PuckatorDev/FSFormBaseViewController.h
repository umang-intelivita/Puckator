//
//  FSFormBaseViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "FSAbstractViewController.h"
#import "UIViewController+SearchBox.h"

@interface FSFormBaseViewController : FXFormViewController

// Makes the first field (assuming it is text) the first responder
- (void) makeFirstFieldFirstResponder;

#pragma mark - HUD

- (void) showHud:(NSString*)title;
- (void) showHud:(NSString*)title withSubtitle:(NSString*)subtitle;
- (void) hideHud;

@end