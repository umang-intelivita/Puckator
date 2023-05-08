//
//  PKCategoriesViewController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKCategoryCell.h"
#import "PKFeedsTableViewController.h"
#import "FSBaseCollectionViewController.h"
#import "PKCatalogueNavigationController.h"
#import "PKCustomCategoryBar.h"

@interface PKCategoriesViewController : FSBaseCollectionViewController <PKFeedsTableDelegate, PKCatalogueNavigationControllerButtonDelegate, PKBrowseTableViewControllerDelegate, PKCustomCategoryBarDelegate>

#pragma mark - Constructors

#pragma mark - Properties

#pragma mark - Methods

@end
