//
//  PKProductsViewController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuckatorKit.h"
#import "FSBaseCollectionViewController.h"
#import "PKGenericTableViewController.h"
#import "PKCustomerSelectionDelegate.h"
#import "PKCustomersViewController.h"
#import "PKBrowseTableViewController.h"
#import "PKCatalogueNavigationController.h"
#import "PKCustomCategoryBar.h"

@class PKProductsViewController;

typedef enum : NSUInteger {
    PKProductsDisplayModeSmall,
    PKProductsDisplayModeMedium,
    PKProductsDisplayModeLarge,
} PKProductsDisplayMode;

typedef enum : NSUInteger {
    PKProductModeCategory,
    PKProductModeSearch,
    PKProductModeSupplier,
    PKProductModeTop,
    PKProductModeNew,
    PKProductModeNewAvailable,
    PKProductModeInStock,
    PKProductModeCustomerProducts,
} PKProductMode;

@protocol PKProductsViewControllerDelegate<NSObject>
@optional
- (void)pkProductsViewController:(PKProductsViewController *)controller didMoveToPage:(int)page;
@required
- (void)pkProductsViewController:(PKProductsViewController *)controller didMoveToIndexPath:(NSIndexPath *)indexPath;
- (void)pkProductsViewController:(PKProductsViewController *)controller didSelectIndexPath:(NSIndexPath*)indexPath;
@end

@protocol PKProductsViewControllerDataSource <NSObject>
@required
- (NSArray *)pkProductsViewControllerRequestsProducts:(PKProductsViewController *)controller;
- (NSArray *)pkProductsViewControllerFilterProducts:(PKProductsViewController *)controller;
@end

@interface PKProductsViewController : FSBaseCollectionViewController <PKProductsViewControllerDelegate, PKProductsViewControllerDataSource, PKGenericTableDelegate, PKCustomerSelectionDelegate, PKBrowseTableViewControllerDelegate, PKCatalogueNavigationControllerButtonDelegate, PKSearchDelegate, PKCustomCategoryBarDelegate>

@property (weak, nonatomic) id<PKProductsViewControllerDelegate>delegate;
@property (weak, nonatomic) id<PKProductsViewControllerDataSource>dataSource;

@property (assign, nonatomic) PKProductsDisplayMode displayMode;
@property (nonatomic, assign) id<PKProductsViewControllerDelegate> searchDelegate;  // Used for the split view search mode

@property (strong, nonatomic) PKCategory *category;

//- (void)setCategory:(PKCategory *)category;

+ (instancetype)createWithDisplayMode:(PKProductsDisplayMode)displayMode indexPath:(NSIndexPath *)indexPath;

+ (instancetype)createWithProduct:(PKProduct *)product displayMode:(PKProductsDisplayMode)displayMode;
+ (instancetype)createWithProducts:(NSArray *)products displayMode:(PKProductsDisplayMode)displayMode;
+ (instancetype)createWithProductMode:(PKProductMode)productMode displayMode:(PKProductsDisplayMode)displayMode;
+ (instancetype)createWithProducts:(NSArray *)products productMode:(PKProductMode)productMode displayMode:(PKProductsDisplayMode)displayMode;

+ (instancetype)createWithBasket:(PKBasket *)basket indexPath:(NSIndexPath *)indexPath displayMode:(PKProductsDisplayMode)displayMode;
+ (instancetype)createWithBasketItem:(PKBasketItem *)basket displayMode:(PKProductsDisplayMode)displayMode;

// Updates and reloads the UI
- (void) updateProducts:(NSArray*)products;
- (int) productsCount;

@end
