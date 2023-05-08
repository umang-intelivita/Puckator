//
//  PKBrowseTableViewController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 02/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSBaseTableViewController.h"

typedef enum : NSUInteger {
    PKBrowseTableViewControllerFilterAllProducts,
    PKBrowseTableViewControllerFilterTopSellers,
    PKBrowseTableViewControllerFilterTopGrossing,
    PKBrowseTableViewControllerFilterNewProducts
} PKBrowseTableViewControllerFilter;

typedef enum : NSUInteger {
    PKBrowseTableViewControllerModeCategories,
    PKBrowseTableViewControllerModeSuppliers,
    PKBrowseTableViewControllerModeBuyers
} PKBrowseTableViewControllerMode;

@class PKBrowseTableViewController;

@protocol PKBrowseTableViewControllerDelegate<NSObject>
- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectCategory:(PKCategory *)category;
- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectSupplier:(NSString *)supplier;
- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectBuyer:(NSString *)buyer;
- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectFilter:(PKBrowseTableViewControllerFilter)filter;
- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectPastOrders:(NSString *)title;

@end


@interface PKBrowseTableViewController : FSBaseTableViewController

@property (weak, nonatomic) id<PKBrowseTableViewControllerDelegate> delegate;

+ (instancetype)createWithDelegate:(id<PKBrowseTableViewControllerDelegate>)delegate;
+ (instancetype)createWithMode:(PKBrowseTableViewControllerMode)mode delegate:(id<PKBrowseTableViewControllerDelegate>)delegate;

@end
