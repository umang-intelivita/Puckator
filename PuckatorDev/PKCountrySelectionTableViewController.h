//
//  PKCountrySelectionTableViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKCountry;
@class PKCountrySelectionTableViewController;

@protocol PKCountrySelectionDelegate <NSObject>
@optional
- (void) pkCountrySelectionTableViewController:(PKCountrySelectionTableViewController *)countrySelectionTableViewController didSelectCountry:(PKCountry *)country;
@end

@interface PKCountrySelectionTableViewController : UITableViewController

@property (nonatomic, strong) id<PKCountrySelectionDelegate> selectionDelegate;
@property (nonatomic, weak) UITextField *textFieldEditing;

@end