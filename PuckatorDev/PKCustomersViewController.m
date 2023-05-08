//
//  CustomersViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKCustomersViewController.h"
#import "PKCustomer.h"
#import "PKCustomerViewController.h"
#import "PKOrdersViewController.h"
#import "APProgressHUD.h"
#import "PKAddressesViewController.h"
#import "PKRecentCustomer+Operations.h"
#import "UIFont+Puckator.h"
#import "PKCurrencyViewController.h"
#import "UIColor+Puckator.h"
#import "UIView+Animate.h"
#import "PKCreateCustomerViewController.h"
#import "PKBasket+Operations.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import <MKMapViewZoom/MKMapView+ZoomLevel.h>

@interface PKCustomersViewController ()

@property (assign, nonatomic) int page;
//@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSArray *recentCustomers;
@property (strong, nonatomic) NSArray *searchResults;

@property (assign, nonatomic) PKCustomersViewControllerMode mode;
@property (strong, nonatomic) PKCustomer *selectedCustomer;
@property (weak, nonatomic) id<PKCustomerSelectionDelegate> delegate;

@property (strong, nonatomic) UISearchController *searchController;

// MapView:
@property MKMapView *mapView;

@end

@implementation PKCustomersViewController

#pragma mark - Constructor Methods

+ (instancetype)createWithMode:(PKCustomersViewControllerMode)mode {
    return [PKCustomersViewController createWithMode:mode delegate:nil];
}

+ (instancetype)createWithMode:(PKCustomersViewControllerMode)mode delegate:(id<PKCustomerSelectionDelegate>)delegate {
    PKCustomersViewController *customersViewController = [PKCustomersViewController createFromStoryboardNamed:@"Main"];
    [customersViewController setMode:mode];
    [customersViewController setDelegate:delegate];
    return customersViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Customers", nil)];
    
    // Setup the search controller:
    [self setSearchController:[[UISearchController alloc] initWithSearchResultsController:nil]];
    [[self searchController] setSearchResultsUpdater:self];
    [[self searchController] setDelegate:self];
    [[self searchController] setDimsBackgroundDuringPresentation:NO];
    [[self searchController] setHidesNavigationBarDuringPresentation:NO];
    [[[self searchController] searchBar] setDelegate:self];
    [[[self searchController] searchBar] setScopeButtonTitles:@[NSLocalizedString(@"Company", nil),
                                      NSLocalizedString(@"Sage", nil),
                                      NSLocalizedString(@"Contact", nil),
                                      NSLocalizedString(@"Town", nil),
                                      NSLocalizedString(@"Postcode", nil)]];
    [[[self searchController] searchBar] layoutSubviews];
    [[[self searchController] searchBar] setShowsScopeBar:YES];
    [[[self searchController] searchBar] setShowsCancelButton:NO animated:NO];
    [[[self searchController] searchBar] sizeToFit];
    
    [[self tableView] setTableHeaderView:[[self searchController] searchBar]];
    [self setDefinesPresentationContext:YES];
    // ---
   
    if (![self tabBarController]) {
        //[self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    NSMutableArray *barButtons = [NSMutableArray array];
    if (![self tabBarController]) {
        UIBarButtonItem *buttonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(buttonAddPressed:)];
        [barButtons addObject:buttonAdd];
    } else {
        // Add the map button:
        UIBarButtonItem *buttonMap = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarMap"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(buttonMapPressed:)];
        [barButtons addObject:buttonMap];
    }    
    
    if ([barButtons count] != 0) {
        [[self navigationItem] setRightBarButtonItems:barButtons];
    }
}

- (BOOL)prefersStatusBarHidden {
    if ([self tabBarController]) {
        return NO;
    } else {
        return YES;
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (CGSize)preferredContentSize {
    return CGSizeMake(540, 600);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self customer]) {
        [self displayCurrencyViewControllerForCustomer:[self customer]];
    }
    
    // Fix hidden table view:
    //[[self tableView] setY:56];
    //[[self tableView] setHeight:[[self view] height]-56];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[self searchController] searchBar] layoutSubviews];
    [[[self searchController] searchBar] setShowsScopeBar:YES];
    [[[self searchController] searchBar] setShowsCancelButton:NO animated:NO];
    [[[self searchController] searchBar] sizeToFit];
    
    // Setup the customers:
    [self setRecentCustomers:[PKRecentCustomer all]];
    
    if (![self tabBarController]) {
        UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonClosePressed:)];
        [[self navigationItem] setLeftBarButtonItem:buttonClose];
    }
    
    if ([[self tableView] respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        [[self tableView] setCellLayoutMarginsFollowReadableWidth:NO];
    }
    
    // Fix hidden table view:
    [[self tableView] setY:56];
    [[self tableView] setHeight:[[self view] height]-56];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:NO];
}

#pragma mark - Private Methods

- (BOOL)isSearching {
    return [[[[self searchController] searchBar] text] length] != 0;
}

#pragma mark - Overidden Methods

- (void)setRecentCustomers:(NSArray *)recentCustomers {
    _recentCustomers = recentCustomers;
    [[self tableView] reloadData];
}

#pragma mark - Event Methods

- (void)buttonMapPressed:(id)sender {
    // Display the map view controller:
    PKMapViewController *mapViewController = [PKMapViewController createWithCustomers:nil];
    
    if (![self tabBarController]) {
        // Modal, therefore push:
        [[self navigationController] pushViewController:mapViewController animated:YES];
    } else {
        [[self navigationController] pushViewController:mapViewController animated:YES];
//        // Not modal, therefore present:
//        [self presentViewController:[mapViewController withNavigationController] animated:YES completion:^{
//        }];
    }
}

- (void)buttonClosePressed:(id)sender {
    if ([self presentedViewController]) {
        [[self presentedViewController] dismissViewControllerAnimated:NO completion:^{
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

- (void)buttonAddPressed:(id)sender {
    // Display the new customer UI:
    [self performSegueWithIdentifier:@"segueCreateCustomer" sender:self];
}

#pragma mark - Table view data source

- (NSArray *)customersForTableView:(UITableView *)tableView {
//    if ([[self searchResults] count] != 0) {
//    } else {
//    }
//
    if ([self isSearching]) {
        return [self searchResults];
    } else {
        return [self recentCustomers];
    }
    
    
//    if (tableView == [self tableView]) {
//        return [self recentCustomers];
//    } else {
//        return [self searchResults];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        [tableView setCellLayoutMarginsFollowReadableWidth:NO];
    }
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self customersForTableView:tableView] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self isSearching]) {
        return [NSString stringWithFormat:@"%@ (%d):", NSLocalizedString(@"Search Results", nil), (int)[[self customersForTableView:tableView] count]];
    } else {
        return [NSString stringWithFormat:@"%@ (%d):", NSLocalizedString(@"My Recent Customers", nil), (int)[[self customersForTableView:tableView] count]];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        [tableView setCellLayoutMarginsFollowReadableWidth:NO];
    }
    
    [tableView setBackgroundColor:[UIColor whiteColor]];
    
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:@"PKCustomerCell"];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if ([indexPath row] < [[self customersForTableView:tableView] count]) {
        PKCustomer *customer = [[self customersForTableView:tableView] objectAtIndex:[indexPath row]];
        [[cell textLabel] setNumberOfLines:0];
        
        UIColor *colorTitle = [UIColor puckatorProductTitle];
        UIColor *colorDarkGray = [UIColor puckatorDarkGray];
        
        if ([customer isOverCreditLimit]) {
            [cell setBackgroundColor:[UIColor colorWithHexString:@"#c0392b"]];
            colorTitle = [UIColor whiteColor];
            colorDarkGray = [UIColor whiteColor];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
        
        // Setup the attributed string for company name and feed name:
        NSString *companyName = [[customer companyName] sanitize];
        NSString *sageId = [[customer sageId] sanitize];
        NSString *feedName = [[customer cleanFeedName] sanitize];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        if ([companyName length] != 0) {
            NSDictionary *attributes = [UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:colorTitle];
            NSAttributedString *companyNameAttributedString = [[NSAttributedString alloc] initWithString:companyName attributes:attributes];
            if ([companyNameAttributedString length] != 0) {
                [attributedString appendAttributedString:companyNameAttributedString];
            }
            
            if ([sageId length] != 0) {
                NSDictionary *attributes = [UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:14] color:colorDarkGray];
                NSAttributedString *sageIdAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", sageId] attributes:attributes];
                if ([sageIdAttributedString length] != 0) {
                    [attributedString appendAttributedString:sageIdAttributedString];
                }
            }
        }
        
        if ([feedName length] != 0) {
            NSDictionary *attributes = [UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:14] color:colorDarkGray];
            NSAttributedString *feedNameAttributedString = [[NSAttributedString alloc] initWithString:feedName attributes:attributes];
            if ([feedNameAttributedString length] != 0) {
                // Add a new line:
                if ([attributedString length] != 0) {
                    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
                }
                
                [attributedString appendAttributedString:feedNameAttributedString];
            }
        }
        
        if ([attributedString length] != 0) {
            [[cell textLabel] setAttributedText:attributedString];
        } else {
            [[cell textLabel] setText:companyName];
        }
        // ---
        
        if ([customer isCoreDataObject]) {
            [[cell imageView] setImage:[UIImage imageNamed:@"TabCustomerCreate"]];
        } else {
            [[cell imageView] setImage:nil];
        }
        
        if([customer dateLastSelected]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [[cell detailTextLabel] setText:[dateFormatter stringFromDate:[customer dateLastSelected]]];
        } else {
            [[cell detailTextLabel] setText:@""];
        }
        
//        [cell setBackgroundColor:[UIColor whiteColor]];
        return cell;
    } else {
        [cell setBackgroundColor:[UIColor whiteColor]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Fetch the currently selected customer:
    NSArray *customers = [self customersForTableView:tableView];
    if ([customers count] != 0 && indexPath.row < [customers count]) {
        PKCustomer *customer = [customers objectAtIndex:[indexPath row]];
        [self setSelectedCustomer:customer];
        
        // Display the correct view controller based on the mode:
        switch ([self mode]) {
            case PKCustomersViewControllerModeView: {
                [self performSegueWithIdentifier:@"segueViewCustomer" sender:self];
                break;
            }
            case PKCustomersViewControllerModeSelect: {
                // Get the open baskets:
                NSArray *openBaskets = [PKBasket openBasketsForCustomer:customer feedNumber:nil includeErrored:NO context:nil];
                
                if ([openBaskets count] != 0) {
                    NSLog(@"Open Basket Count: %d", (int)[openBaskets count]);
                    
                    RIButtonItem *itemOpenBasket = [RIButtonItem itemWithLabel:NSLocalizedString(@"Continue Order", nil) action:^{
                        PKBasket *basket = [openBaskets firstObject];
                        [basket setStatus:PKBasketStatusOpen shouldSave:YES];
                        [self dismissViewControllerAnimated:YES completion:^{
                        }];
                    }];
                    
                    RIButtonItem *itemNewBasket = [RIButtonItem itemWithLabel:NSLocalizedString(@"New Order", nil) action:^{
                        // Cancel all the open baskets for this customer:
                        [PKBasket cancelAllOpenBasketsForCustomer:customer];
                        
                        // Display the currency view controller:
                        [self displayCurrencyViewControllerForCustomer:customer];
                    }];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Order Found", nil)
                                                                        message:NSLocalizedString(@"An open order for this customer has been found, would you like to continue this order?", nil)
                                                               cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", nil)]
                                                               otherButtonItems:itemOpenBasket, itemNewBasket, nil];
                    [alertView show];
                } else {
                    [self displayCurrencyViewControllerForCustomer:customer];
                }
                break;
            }
            case PKCustomersViewControllerModeCopying: {
                [self displayCurrencyViewControllerForCustomer:customer];
                break;
            }
        }
        
    }
}

#pragma mark - UISearchBarDelegate Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [[searchController searchBar] text];
    NSLog(@"Search: %@", searchString);
}

- (void)presentSearchController:(UISearchController *)searchController {
//    NSLog(@"Present Search Controller");
//    [self presentViewController:searchController animated:YES completion:^{
//        
//    }];
}

- (void)searchForCustomersWithSearchBar:(UISearchBar *)searchBar {
    [self setSearchResults:[PKCustomer findCustomersWithScope:[searchBar selectedScopeButtonIndex] searchText:[searchBar text]]];    
    [[self tableView] reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    if ([[searchBar scopeButtonTitles] count] == 0) {
//        [searchBar setScopeButtonTitles:@[NSLocalizedString(@"Company", nil),
//                                          NSLocalizedString(@"Sage", nil),
//                                          NSLocalizedString(@"Contact", nil),
//                                          NSLocalizedString(@"Town", nil),
//                                          NSLocalizedString(@"Postcode", nil)]];
//        [searchBar setTintColor:[UIColor puckatorPrimaryColor]];
//    }
    

    //    [[[self searchController] searchBar] setScopeButtonTitles:@[
    //        NSLocalizedString(@"Company", nil),
    //        NSLocalizedString(@"Sage", nil),
    //        NSLocalizedString(@"Contact", nil),
    //        NSLocalizedString(@"Town", nil),
    //        NSLocalizedString(@"Postcode", nil)]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] >= 3) {
        [self searchForCustomersWithSearchBar:searchBar];
    } else if ([searchText length] == 0) {
        [self setSearchResults:nil];
        [[self tableView] reloadData];
    } else {
        [self setSearchResults:[NSArray array]];
        [[self tableView] reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([[searchBar text] length] == 0) {
        [self setSearchResults:nil];
        [[self tableView] reloadData];
    } else {
        [self searchForCustomersWithSearchBar:searchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setSearchResults:nil];
    [[self tableView] reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchForCustomersWithSearchBar:searchBar];
    
//    if ([[searchBar text] length] < 3) {
//        [searchBar shake];
//    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self searchForCustomersWithSearchBar:searchBar];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    UISearchBar *searchBar = [searchController searchBar];
    if ([[searchBar scopeButtonTitles] count] == 0) {
        [searchBar setScopeButtonTitles:@[NSLocalizedString(@"Company", nil),
                                          NSLocalizedString(@"Sage", nil),
                                          NSLocalizedString(@"Contact", nil),
                                          NSLocalizedString(@"Town", nil),
                                          NSLocalizedString(@"Postcode", nil)]];
        [searchBar layoutSubviews];
        [searchBar setShowsScopeBar:YES];
        [searchBar sizeToFit];
        //[searchBar setTintColor:[UIColor puckatorPrimaryColor]];
    }
}

//- (void)viewDidLayoutSubviews {
//    [[[self searchController] searchBar] sizeToFit];
//}

#pragma mark - Segue Methods

- (void)displayCurrencyViewControllerForCustomer:(PKCustomer *)customer {
    [FSThread runOnMain:^{
        if (customer) {
            [self setSelectedCustomer:customer];
            PKCurrencyViewController *currencyViewController = [PKCurrencyViewController createWithCustomer:customer delegate:[self delegate] orderCopyMode:([self mode] == PKCustomersViewControllerModeCopying)];
            [[self navigationController] pushViewController:currencyViewController animated:YES];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Fetch the currently selected customer:
    if ([[segue identifier] isEqualToString:@"segueViewCustomer"]) {
        PKCustomerViewController *customerViewController =  (PKCustomerViewController *)[segue destinationViewController];
        [customerViewController setCustomer:[self selectedCustomer]];
    } else if ([[segue identifier] isEqualToString:@"segueCreateCustomer"]) {
        PKCreateCustomerViewController *createCustomerViewController = (PKCreateCustomerViewController *)[segue destinationViewController];
        [createCustomerViewController setDelegate:[self delegate]];
    }
}

#pragma mark - MKMapViewDelegate Methods

#pragma mark -

@end
