//
//  PKCatalogueNavigationController.h
//  PuckatorDev
//
//  Created by Luke Dixon on 03/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKBrowseTableViewController.h"
#import "PKSearchTableViewController.h"
#import "PKGenericTableViewController.h"
#import "PKCustomerSelectionDelegate.h"
#import "PKNotesViewController.h"
#import "PKLanguageSelectController.h"

typedef enum : NSUInteger {
    PKCatalogueButtonTypeBrowse,
    PKCatalogueButtonTypeNewProducts,
    PKCatalogueButtonTypeNewAvailableProducts,
    PKCatalogueButtonTypeInStockProducts,
    PKCatalogueButtonTypeTopProducts,
    PKCatalogueButtonTypeCustomerProducts,
    PKCatalogueButtonTypeSearch,
    PKCatalogueButtonTypeSort,
    PKCatalogueButtonTypeMenu,
    PKCatalogueButtonTypeBack,
    PKCatalogueButtonTypeBulkAdd,
    PKCatalogueButtonTypeAddCategory
} PKCatalogueButtonType;

@class PKCatalogueNavigationController;

@protocol PKCatalogueNavigationControllerButtonDelegate<NSObject>

@required
- (void)pkCatalogueNavigationController:(PKCatalogueNavigationController *)catalogueNavigationController
                     didPressButtonType:(PKCatalogueButtonType)buttonType;
- (void)pkCatalogueNavigationController:(PKCatalogueNavigationController *)catalogueNavigationController
                     didPressButtonType:(PKCatalogueButtonType)buttonType
                                 sender:(id)sender;
- (void)pkCatalogueNavigationController:(PKCatalogueNavigationController *)catalogueNavigationController
                    didSearchWithParams:(PKSearchParameters *)params
                       andFoundProducts:(NSArray *)products;

- (BOOL)pkCatalogueNavigationControllerShouldDisableSortButton:(PKCatalogueNavigationController *)catalogueNavigationController;
- (BOOL)pkCatalogueNavigationControllerIsCategoryCustom:(PKCatalogueNavigationController *)catalogueNavigationController;
- (PKGenericTableType)pkCatalogueNavigationControlRequestsSortType:(PKCatalogueNavigationController *)catalogueNavigationController;

@end

@interface PKCatalogueNavigationController : UINavigationController <PKSearchDelegate, PKGenericTableDelegate, UINavigationControllerDelegate, PKCustomerSelectionDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) id<PKCatalogueNavigationControllerButtonDelegate, PKBrowseTableViewControllerDelegate, PKSearchDelegate, PKGenericTableDelegate>buttonDelegate;

- (void)addCatalogueNavigationButtons;

- (void)enableSortButton:(BOOL)enable;
- (void)refreshCustomCategoryButton;

@end
