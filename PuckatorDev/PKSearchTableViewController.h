//
//  PKSearchTableViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 27/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKSearchCategoryTableViewController.h"
#import "PKGenericTableViewController.h"

@class PKSearchTableViewController;
@class PKSearchParameters;

@protocol PKSearchDelegate <NSObject>
@optional
- (BOOL)pkSearchTableViewController:(PKSearchTableViewController*)searchTableViewController didStartSearchWithParameters:(PKSearchParameters*)params;
- (void)pkSearchTableViewController:(PKSearchTableViewController*)searchTableViewController didUpdateSearchParameters:(PKSearchParameters*)params;
@end

@interface PKSearchTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PKSearchCategoryDelegate, PKGenericTableDelegate>

@property (nonatomic, strong) UITextField *sourceTextField;
@property (nonatomic, assign) id<PKSearchDelegate> searchDelegate;  // Used for communicating back to PKProductsSearchViewController
@property (nonatomic, strong) PKSearchParameters *searchParameters; // Holds all the search scoping data

@end
