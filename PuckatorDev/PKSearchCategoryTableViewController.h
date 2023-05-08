//
//  PKSearchCategoryTableViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 27/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKSearchCategoryTableViewController;
@protocol PKSearchCategoryDelegate <NSObject>
@required
- (void) pkSearchCategoryTableViewController:(PKSearchCategoryTableViewController*)categoryTableViewController didSelectCategories:(NSDictionary*)selectedCategoryIds;
@end

@interface PKSearchCategoryTableViewController : UITableViewController

#pragma mark - Constructors

#pragma mark - Properties

// An array of selected category id's
@property (nonatomic, strong) NSMutableDictionary *selectedCategoryIds;

// The delegate for category selection
@property (nonatomic, assign) id<PKSearchCategoryDelegate> categoryDelegate;

#pragma mark - Methods

@end
