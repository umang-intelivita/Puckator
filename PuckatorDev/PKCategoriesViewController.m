//
//  PKCategoriesViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKCategoriesViewController.h"
#import "PKProductsViewController.h"
#import "UIColor+Puckator.h"
#import "AppDelegate.h"
//#import "UIViewController+MenuButton.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import "UIViewController+SearchBox.h"
#import "PKCatalogueNavigationController.h"
#import "PKProductsSearchViewController.h"
#import "UIView+FrameHelper.h"
#import "PKCategoryObject.h"

@interface PKCategoriesViewController ()

@property (strong, nonatomic) UICollectionViewFlowLayout *smallLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *largeLayout;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) PKCategory *selectedCategory;
@property (strong, nonatomic) PKCustomCategoryBar *customCategoryBar;

@property (nonatomic, strong) UIPopoverController *activePopoverController; // Used to dismiss the popover when another UIBarButtonItem is selected

@end

@implementation PKCategoriesViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Catalogue", nil)];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];    
    
    // Setup the collection view style:
    [self setClearsSelectionOnViewWillAppear:YES];
    [[self collectionView] setBackgroundColor:[UIColor puckatorBorderColor]];
    [[self collectionView] setOpaque:NO];
    
    // Register the collection view nibs:
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKCategoryCell"
                                                      bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PKCategoryCell"];
    
    [self addSearchBox];
}

- (void)viewWillAppear:(BOOL)animated {
    // Setup categories:
    if ([self categories]) {
        [self setSelectedCategory:nil];
        [self setCategories:nil];
    }
    
    [self reloadCategories];
    
    [super viewWillAppear:animated];
    [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    
    __weak PKCategoriesViewController *weakSelf = self;
    [(PKCatalogueNavigationController *)[self navigationController] setButtonDelegate:weakSelf];
    
    if ([[PKSession sharedInstance] customCategoryBar]) {
        [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeNone];
        [[[PKSession sharedInstance] customCategoryBar] setProductButtonsEnabled:NO];
        [[[PKSession sharedInstance] customCategoryBar] setDelegate:self];
    }
}

- (void)reloadCategories {
    NSArray * allCategories = [PKCategory allSortedBy:PKCategorySortModeAlphabetically ascending:YES includeCustom:YES];
    NSMutableArray * mutableCategories = [[NSMutableArray alloc] initWithArray:allCategories];
//    if([[PKSession instance] currentCustomer]) {
//        [mutableCategories insertObject:[PKCategoryObject getPastOrderCategory] atIndex:0];
//    }
    [self setCategories:mutableCategories];
    [[self collectionView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [[self collectionView] reloadData];
    [[PKSession sharedInstance] setSelectedCategoryId:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private Methods

#pragma mark - Public Methods

- (void) dismissActivePopover {
    // Dismiss active popover
    if([self activePopoverController]) {
        [[self activePopoverController] dismissPopoverAnimated:NO];
        [self setActivePopoverController:nil];
    }
    
}

- (void) dismissActivePopoverThenPresentNewPopover:(UIPopoverController*)newPopoverController fromBarButtonItem:(UIBarButtonItem*)buttonItem {
    
    // Close active popover (if any)
    [self dismissActivePopover];
    
    [self setActivePopoverController:newPopoverController];
    [[self activePopoverController] setPassthroughViews:@[]];
    [[self activePopoverController] presentPopoverFromBarButtonItem:buttonItem
                                           permittedArrowDirections:UIPopoverArrowDirectionUp
                                                           animated:NO];
    
}

#pragma mark - Event Methods

- (void)buttonLoginPressed:(id)sender {
    
    // Close any popovers, or we will get issues
    [self dismissActivePopover];
    
    // Show sync interface
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:[NSBundle mainBundle]];
    id viewController = [storyboard instantiateInitialViewController];
    [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:viewController animated:YES completion:^{
    }];
}

- (void) buttonSwitchFeedsPressed:(UIBarButtonItem*)sender {    // Dismiss active popover
    if([self activePopoverController]) {
        [[self activePopoverController] dismissPopoverAnimated:YES];
        [self setActivePopoverController:nil];
    }
    
    UIPopoverController *popoverController = [PKFeedsTableViewController switchFeedsPopoverFromViewController:self];
    [self dismissActivePopoverThenPresentNewPopover:popoverController fromBarButtonItem:sender];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self categories] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifierCategoryCell = @"PKCategoryCell";
    // Dequeue a cell:
    PKCategoryCell *cell = (PKCategoryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifierCategoryCell
                                                                                       forIndexPath:indexPath];
    
    if ([[PKSession instance] currentCustomer] && ([[[self categories] objectAtIndex:0] isKindOfClass:[PKCategoryObject class]])) {
        PKCategoryObject *category = [[self categories] objectAtIndex:[indexPath row]];
        [cell setClipsToBounds:YES];
        [cell setupWithCategoryObject:category];
    } else {
        
        // Get the current category:
        PKCategory *category = [[self categories] objectAtIndex:[indexPath row]];
        
        [cell setClipsToBounds:YES];
        [cell setupWithCategory:category];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int rows = 3;
    int spaces = rows - 1;
    int padding = [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing];
    int height = floorf(([collectionView frame].size.height - (spaces * padding)) / rows);
    return CGSizeMake(height, height);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"viewProducts"]) {
        id destinationViewController = [segue destinationViewController];
        if ([destinationViewController isKindOfClass:[PKProductsViewController class]]) {
            [(PKProductsViewController *)destinationViewController setCategory:[self selectedCategory]];
            [self setSelectedCategory:nil];            
            //NSLog(@"Seleted Category Name: %@", [[self selectedCategory] title]);
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Get the selected category:
    PKCategory *category = [[self categories] objectAtIndex:[indexPath row]];
    [self setSelectedCategory:category];
    if ([self selectedCategory]) {
        [self performSegueWithIdentifier:@"viewProducts" sender:nil];
    }
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - PKFeedsTableDelegate

- (void)pkFeedsTableViewController:(PKFeedsTableViewController *)feedsTableViewController didSwitchFeed:(PKFeedConfig *)feedConfig {
    if (feedConfig) {
        [self dismissActivePopover];
    }
}

#pragma mark - PKCatalogueNavigationControllerButtonDelegate Methods

- (void)pkCatalogueNavigationController:(PKCatalogueNavigationController *)catalogueNavigationController didPressButtonType:(PKCatalogueButtonType)buttonType sender:(id)sender {
    // Determine if (and which) product filter button has been pressed:
    int productMode = -1;
    if (buttonType == PKCatalogueButtonTypeNewProducts) {
        productMode = PKProductModeNew;
    } else if (buttonType == PKCatalogueButtonTypeTopProducts) {
        productMode = PKProductModeTop;
    } else if (buttonType == PKCatalogueButtonTypeNewAvailableProducts) {
        productMode = PKProductModeNewAvailable;
    } else if (buttonType == PKCatalogueButtonTypeInStockProducts) {
        productMode = PKProductModeInStock;
    } else if (buttonType == PKCatalogueButtonTypeAddCategory) {
        [self displayAddCategory:sender];
    } else if (buttonType == PKCatalogueButtonTypeCustomerProducts) {
        productMode = PKProductModeCustomerProducts;
    }
    
    // Make sure the product mode has been set to something other than the original value of -1:
    if (productMode != -1) {
        // Display the products view controller and pass the product mode value:
        PKProductsViewController *productsViewController = [PKProductsViewController createWithProducts:nil
                                                                                            productMode:productMode
                                                                                            displayMode:PKProductsDisplayModeMedium];
        [[self navigationController] pushViewController:productsViewController animated:YES];
    }
}

- (void)displayAddCategory:(id)sender {
    __weak PKCategoriesViewController *weakSelf = self;
//    [weakSelf displayCreateCategory:nil];
    if ([sender isKindOfClass:[UIButton class]]) {
        __weak PKCategoriesViewController *weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Custom Category Options", nil)
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        [[alertController popoverPresentationController] setSourceView:[sender superview]];
        [[alertController popoverPresentationController] setSourceRect:[sender frame]];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create New Category", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf displayCreateCategory:nil];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add to Existing Category", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf displaySelectExistingCategories:sender];
        }]];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)displayCreateCategory:(id)sender {
    __weak PKCategoriesViewController *weakSelf = self;
    UIAlertController *alertController = alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Create New Category", nil)
                                                                                               message:@""
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:NSLocalizedString(@"Category Name", @"")];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = [[alertController textFields][0] text];
        [weakSelf addCustomCategoryWithName:name];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)displaySelectExistingCategories:(id)sender {
    __weak PKCategoriesViewController *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:NSLocalizedString(@"Select Category", nil)
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [[alertController popoverPresentationController] setSourceView:[sender superview]];
    [[alertController popoverPresentationController] setSourceRect:[sender frame]];
    
    NSArray<PKCategory *> *categories = [PKCategory customSortedBy:PKCategorySortModeAlphabetically ascending:YES];
    [categories enumerateObjectsUsingBlock:^(PKCategory * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertController addAction:[UIAlertAction actionWithTitle:[category styledTitle] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf displayCustomCategoryOptionsForCategory:category];
        }]];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addCustomCategoryWithName:(NSString *)name {
    [FSThread runOnMain:^{
        [self showHud:NSLocalizedString(@"Creating", nil)];
    }];
    
    __weak PKCategoriesViewController *weakSelf = self;
    [FSThread runInBackground:^{
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        
        PKCategory *category = [PKCategory MR_createEntityInContext:localContext];
        
        NSUUID *uuid = [NSUUID UUID];
        
        PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
        
        [category setCategoryId:[uuid UUIDString]];
        [category setFeedNumber:[feedConfig number]];
        [category setTitle:[name sanitize]];
        [category setSortOrder:@(-1)];
        [category setParent:@(-1)];
        [category setActive:@(YES)];
        [category setTitleClean:[[category title] clean]];
        [category setIsCustom:@(YES)];
        [localContext MR_saveToPersistentStoreAndWait];
        
        [FSThread runOnMain:^{
            [weakSelf hideHud];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Custom Category", nil)
                                                                                     message:NSLocalizedString(@"Your custom category has been created.", nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Products", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf reloadCategories];
                [weakSelf displayCustomCategoryOptionsForCategory:category];
            }];
            [alertController addAction:cancelAction];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }];
    }];
}

- (void)displayCustomCategoryOptionsForCategory:(PKCategory *)category {
    PKCustomCategoryBarMode mode = PKCustomCategoryBarModeExisting;
    
    CGFloat barWidth = [[[self tabBarController] tabBar] width];
    PKCustomCategoryBar *categoryBar = [PKCustomCategoryBar createWithDelegate:self mode:mode];
    [categoryBar setTitle:[category styledTitle]];
    [[categoryBar view] setWidth:barWidth];
    [[categoryBar view] setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [[[self tabBarController] tabBar] addSubview:[categoryBar view]];
    
    [categoryBar setProductButtonsEnabled:NO];
    [[categoryBar view] setBackgroundColor:[UIColor orangeColor]];
    [categoryBar setCategory:category];
    [[PKSession sharedInstance] setCustomCategoryBar:categoryBar];
}

- (void)pkCatalogueNavigationController:(PKCatalogueNavigationController *)catalogueNavigationController
                    didSearchWithParams:(PKSearchParameters *)params
                       andFoundProducts:(NSArray *)products {
    PKProductsSearchViewController *productsSearchViewController = [PKProductsSearchViewController createWithProducts:products productMode:PKProductModeSearch displayMode:PKProductsDisplayModeMedium];
    [[self navigationController] pushViewController:productsSearchViewController animated:YES];
}

#pragma mark - PKBrowseTableViewControllerDelegate Methods

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectPastOrders:(NSString *)title {
    [browseTableViewController dismissViewControllerAnimated:YES completion:^{
        PKProductsViewController *productsViewController = [PKProductsViewController createWithProducts:[PKProduct allProductsForFeedConfig:nil inContext:nil] displayMode:PKProductsDisplayModeMedium];
        productsViewController.category = (PKCategory *)[PKCategoryObject getPastOrderCategory];
        productsViewController.title = @"Past Orders";
        [[self navigationController] pushViewController:productsViewController animated:YES];
    }];
}

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController
                    didSelectFilter:(PKBrowseTableViewControllerFilter)filter {
    [browseTableViewController dismissViewControllerAnimated:YES completion:^{
        if (filter == PKBrowseTableViewControllerFilterAllProducts) {
            PKProductsViewController *productsViewController = [PKProductsViewController createWithProducts:[PKProduct allProductsForFeedConfig:nil inContext:nil] displayMode:PKProductsDisplayModeMedium];
            [[self navigationController] pushViewController:productsViewController animated:YES];
        }
    }];
}

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController
                  didSelectCategory:(PKCategory *)category {
    [browseTableViewController dismissViewControllerAnimated:YES completion:^{
        [self setSelectedCategory:category];
        if ([self selectedCategory]) {
            [self performSegueWithIdentifier:@"viewProducts" sender:nil];
        }
    }];
}

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectSupplier:(NSString *)supplier {
    [browseTableViewController dismissViewControllerAnimated:YES completion:^{
        PKProductsViewController *productsViewController = [PKProductsViewController createWithProducts:[PKProduct productsForSupplier:supplier]
                                                                                            productMode:PKProductModeSupplier
                                                                                            displayMode:PKProductsDisplayModeMedium];
        [[self navigationController] pushViewController:productsViewController animated:YES];
    }];
}

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectBuyer:(NSString *)buyer {
    [browseTableViewController dismissViewControllerAnimated:YES completion:^{
        PKProductsViewController *productsViewController = [PKProductsViewController createWithProducts:[PKProduct productsForBuyer:buyer]
                                                                                            productMode:PKProductModeSupplier
                                                                                            displayMode:PKProductsDisplayModeMedium];
        [[self navigationController] pushViewController:productsViewController animated:YES];
    }];
}

#pragma mark - CustomCategoryBarDelegate Methods

- (void)pkCustomCategoryBarConfirmed:(PKCustomCategoryBar *)customCategoryBar {
    if ([[PKSession sharedInstance] customCategoryBar]) {
        [[[[PKSession sharedInstance] customCategoryBar] view] removeFromSuperview];
        [[PKSession sharedInstance] setCustomCategoryBar:nil];
    }
}

#pragma mark - Memory Management

- (void) dealloc {
    NSLog(@"Dealloc PKCategoriesViewController!");
}

#pragma mark -

@end
