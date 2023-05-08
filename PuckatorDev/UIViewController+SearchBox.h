//
//  UIViewController+SearchBox.h
//  PuckatorDev
//
//  Created by Luke Dixon on 18/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKSearchTableViewController.h"

@interface UIViewController (SearchBox) <UITextFieldDelegate, PKSearchCategoryDelegate, PKSearchDelegate>

- (void)addSearchBox;

@end