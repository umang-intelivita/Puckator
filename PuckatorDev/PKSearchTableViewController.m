//
//  PKSearchTableViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 27/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKSearchTableViewController.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import "PKTranslate.h"
#import "PKPopoverNavigationController.h"
#import "UIButton+AllStates.h"
#import "UIView+Animate.h"
#import "PKSearchParameters.h"

typedef enum {
    SearchCellTypeScope = 0,
    SearchCellTypeCategoryFilter = 1,
    SearchCellTypePrice = 2
} SearchCellType;

@interface PKSearchTableViewController ()
@property (nonatomic, strong) UIButton *buttonSearch;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL willPresentSecondaryInterface;   // Used for enabling/disabling animation
@end

@implementation PKSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Customize the UI
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [[self view] setBackgroundColor:[UIColor puckatorPrimaryColor]];
    [self setTitle:NSLocalizedString(@"Search", nil)];
    
    // Init search params if not already
    if (![self searchParameters]) {
        [self setSearchParameters:[[PKSearchParameters alloc] init]];
    }
    
    // If there is an active category, let us default to that category only!
//    if([[PKSession sharedInstance] selectedCategoryId]) {
//        [[self searchParameters] setFilterCategoryIds:@{[[PKSession sharedInstance] selectedCategoryId]:@(1)}];
//    } else {
//        [[self searchParameters] setFilterCategoryIds:nil];
//    }

}

-(void)viewWillAppear:(BOOL)animated {
    if (![self willPresentSecondaryInterface]) {
        [UIView setAnimationsEnabled:NO];
    }
    [super viewWillAppear:animated];
    [[self searchBar] becomeFirstResponder];
    
    [[[self navigationController] navigationBar] setOpaque:YES];
    [[[self navigationController] navigationBar] setTranslucent:NO];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(400, 330);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView setAnimationsEnabled:YES];
    [[self searchBar] becomeFirstResponder];
    [self setWillPresentSecondaryInterface:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([self willPresentSecondaryInterface]) {
        [UIView setAnimationsEnabled:YES];
    } else {
        [UIView setAnimationsEnabled:NO];
    }
    
    // Update the delegate with any new parameters, this allows us to recreate the UI at a later date with the same params
    if ([self searchDelegate] && [[self searchDelegate] respondsToSelector:@selector(pkSearchTableViewController:didUpdateSearchParameters:)]) {
        [[self searchDelegate] pkSearchTableViewController:self didUpdateSearchParameters:[self searchParameters]];
    }
    
    // Resign the first responder:
    [[self searchBar] resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIView setAnimationsEnabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
    return 92;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    switch ((SearchCellType)indexPath.row) {
        case SearchCellTypeScope: {
            int selectedType = [[self searchParameters] scope];
            [[cell textLabel] setText:NSLocalizedString(@"Search By...", nil)];
            [[cell detailTextLabel] setText:[PKSearchParameters titleForParameterType:selectedType]];
            break;
        }
        case SearchCellTypeCategoryFilter: {
            [[cell textLabel] setText:NSLocalizedString(@"Filter By...", nil)];
            if ([[[self searchParameters] filterCategoryIds] count] == 0) {
                [[cell detailTextLabel] setText:NSLocalizedString(@"All Categories", nil)];
            } else {
                if ([[[self searchParameters] filterCategoryIds] count] == 1) {
                    // If single category selected, get the name...
                    NSString *categoryId = [[[[self searchParameters] filterCategoryIds] allKeys] firstObject];
                    PKCategory *category = [PKCategory categoryForId:categoryId forFeedConfig:[[PKSession sharedInstance] currentFeedConfig] inContext:nil];
                    [[cell detailTextLabel] setText:[NSString stringWithFormat:NSLocalizedString(@"Filtering by %@", @"Used to inform the user which category they're filtering by. E.g. 'Filtering by Clocks"), [category styledTitle]]];
                } else {
                    [[cell detailTextLabel] setText:[NSString stringWithFormat:NSLocalizedString(@"Filtering by %d categories", @"Used to inform the user how many categories they're filtering by. E.g. 'Filtering by 10 categories"),
                                                     [[[self searchParameters] filterCategoryIds] count]]];
                }
            }
            break;
        }
        case SearchCellTypePrice: {
            [[cell textLabel] setText:NSLocalizedString(@"Filter by price...", nil)];
            [[cell detailTextLabel] setText:[PKSearchParameters titleForPriceFilter:[self searchParameters]]];
            break;
        }
        default:
            break;
    }
    
    [[cell textLabel] setFont:[UIFont puckatorContentTitle]];
    [[cell textLabel] setTextColor:[UIColor puckatorPrimaryColor]];
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setFont:[UIFont puckatorContentText]];
    [[cell detailTextLabel] setTextColor:[UIColor lightGrayColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(![self searchBar]) {
        [self setSearchBar:[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)]];
        [[self searchBar] setDelegate:self];
        [[self searchBar] setBackgroundColor:[UIColor whiteColor]];
        [[self searchBar] setBarTintColor:[UIColor whiteColor]];
        [[self searchBar] setTranslucent:NO];
        [[self searchBar] setText:[[self searchParameters] searchText]];
        
        if ([[[self sourceTextField] text] length] >= 1) {
            [[self searchBar] setShowsCancelButton:YES];
            [[self searchBar] setText:[[self sourceTextField] text]];
        } else {
            [[self searchBar] setShowsCancelButton:NO];
        }
        [[self searchBar] becomeFirstResponder];
    }
    
    return [self searchBar];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 54)];
    [footerView setBackgroundColor:[UIColor puckatorPrimaryColor]];
    [footerView setUserInteractionEnabled:YES];
    
    UIButton *buttonSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSearch setBackgroundColor:[UIColor puckatorGreen]];
    [buttonSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[buttonSearch titleLabel] setFont:[UIFont puckatorContentTitle]];
    [buttonSearch setFrame:CGRectMake(0, 0, (footerView.frame.size.width / 3)*2, 40)];
    [buttonSearch setTitle:NSLocalizedString(@"Find Products", nil) forState:UIControlStateNormal];
    [buttonSearch addTarget:self action:@selector(buttonSearchPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[buttonSearch layer] setCornerRadius:5];
    [buttonSearch setClipsToBounds:YES];
    [footerView addSubview:buttonSearch];
    [buttonSearch setCenter:footerView.center];
    [self setButtonSearch:buttonSearch];
    
    return footerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 54;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch ((SearchCellType)indexPath.row) {
        case SearchCellTypeScope: {
            [self setWillPresentSecondaryInterface:YES];
            [[self navigationController] pushViewController:[PKGenericTableViewController createWithType:PKGenericTableTypeSearchScope
                                                                                                delegate:self
                                                                                          selectedItemId:[[self searchParameters] scope]]
                                                   animated:YES];
            break;
        }
        case SearchCellTypeCategoryFilter: {
            // Allow animations
            [self setWillPresentSecondaryInterface:YES];
            
            // Create category list interface
            PKSearchCategoryTableViewController *categoryTableViewController = [[PKSearchCategoryTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [categoryTableViewController setCategoryDelegate:self];
            if([[self searchParameters] filterCategoryIds]) {
                [categoryTableViewController setSelectedCategoryIds:[NSMutableDictionary dictionaryWithDictionary:[[self searchParameters] filterCategoryIds]]];
            }
            
            // Push the category list
            [[self navigationController] pushViewController:categoryTableViewController animated:YES];
            break;
        }
        case SearchCellTypePrice: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Filter by price...", nil) message:NSLocalizedString(@"Please enter the price range you would like to filter by.", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            // Create weak references:
            __weak UIAlertController *weakAlertController = alertController;
            __weak PKSearchTableViewController *weakSelf = self;
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                [textField setPlaceholder:NSLocalizedString(@"Minimal Price (optional)", nil)];
                [textField setKeyboardType:UIKeyboardTypeNumberPad];
                if ([[[weakSelf searchParameters] priceMin] floatValue] > 0) {
                    [textField setText:[NSString stringWithFormat:@"%0.2f", [[[weakSelf searchParameters] priceMin] floatValue]]];
                }
            }];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                [textField setPlaceholder:NSLocalizedString(@"Maximum Price (optional)", nil)];
                [textField setKeyboardType:UIKeyboardTypeNumberPad];
                if ([[[weakSelf searchParameters] priceMax] floatValue] > 0) {
                    [textField setText:[NSString stringWithFormat:@"%0.2f", [[[weakSelf searchParameters] priceMax] floatValue]]];
                }
            }];
            
            UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"Apply", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *textFieldPriceMin = [[weakAlertController textFields] firstObject];
                UITextField *textFieldPriceMax = [[weakAlertController textFields] lastObject];
                
                float minPrice = 0.f;
                float maxPrice = 0.f;
                
                if (textFieldPriceMin) {
                    minPrice = [[textFieldPriceMin text] floatValue];
                }
                
                if (textFieldPriceMax) {
                    maxPrice = [[textFieldPriceMax text] floatValue];
                }
                
                [[weakSelf searchParameters] setPriceMin:[NSNumber numberWithFloat:MIN(minPrice, maxPrice)]];
                [[weakSelf searchParameters] setPriceMax:[NSNumber numberWithFloat:MAX(minPrice, maxPrice)]];
                
                [[weakSelf tableView] reloadData];
            }];
            
            UIAlertAction *actionClear = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[weakSelf searchParameters] setPriceMin:[NSNumber numberWithFloat:0.0f]];
                [[weakSelf searchParameters] setPriceMax:[NSNumber numberWithFloat:0.0f]];
                [[weakSelf tableView] reloadData];
            }];
            
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertController addAction:actionConfirm];
            [alertController addAction:actionClear];
            [alertController addAction:actionCancel];
            [self presentViewController:alertController animated:YES completion:^{
                
            }];
            break;
        }
        default: {
            break;
        }
    }
    
}

#pragma mark - Actions

- (void) buttonSearchPressed:(id)sender {
    // Update the search text
    [[self searchParameters] setSearchText:[[self searchBar] text]];
    
    if ([[self searchDelegate] respondsToSelector:@selector(pkSearchTableViewController:didUpdateSearchParameters:)]) {
        [[self searchDelegate] pkSearchTableViewController:self didUpdateSearchParameters:[self searchParameters]];
    }
    
    // Start the search!
    if ([self searchDelegate] && [[self searchDelegate] respondsToSelector:@selector(pkSearchTableViewController:didStartSearchWithParameters:)]) {
        BOOL productsFound = [[self searchDelegate] pkSearchTableViewController:self didStartSearchWithParameters:[self searchParameters]];
        if (!productsFound) {
            [[self buttonSearch] shake];
            [[self buttonSearch] setBackgroundColor:[UIColor puckatorRankMin]];
            [[self buttonSearch] setTitleForAllStates:NSLocalizedString(@"No Products Found", nil)];
           
            [FSThread afterDelay:1.0f run:^{
                [[self buttonSearch] setBackgroundColor:[UIColor puckatorGreen]];
                [[self buttonSearch] setTitleForAllStates:NSLocalizedString(@"Find Products", nil)];
                
                UITextField * searchText = nil;
                for (UIView *subview in [self searchBar].subviews)
                {
                    NSLog(@"Subview: %@", [subview class]);
                    
                    // we can't check if it is a UITextField because it is a UISearchBarTextField.
                    // Instead we check if the view conforms to UITextInput protocol. This finds
                    // the view we are after.
                    if ([subview conformsToProtocol:@protocol(UITextInput)])
                    {
                        searchText = (UITextField*)subview;
                        break;
                    }
                }
                
                if (searchText != nil) {
                    [searchText selectAll:self];
                }
            } completion:^{
                
            }];
            
            NSLog(@"Products not found");
        }
    } else {
        NSLog(@"Warning!  No delegate attached!");
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([searchBar respondsToSelector:@selector(inputAssistantItem)]) {
        UITextInputAssistantItem *item = [searchBar inputAssistantItem];
        item.leadingBarButtonGroups = @[];
        item.trailingBarButtonGroups = @[];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self buttonSearchPressed:nil];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:@""];
}

#pragma mark - Category Delegate

- (void)pkSearchCategoryTableViewController:(PKSearchCategoryTableViewController *)categoryTableViewController
                        didSelectCategories:(NSDictionary *)selectedCategoryIds {
    
    // Update the search parameters
    [[self searchParameters] setFilterCategoryIds:selectedCategoryIds];
    [[self tableView] reloadData];
    
}

#pragma mark - Generic Table View Delegate

-(void)pkGenericTableViewController:(PKGenericTableViewController *)tableViewController
                    didSelectItemId:(int)selectedItem {
    
    switch ([tableViewController type]) {
        case PKGenericTableTypeSearchScope: {
            [[self searchParameters] setScope:(PKSearchParameterType)selectedItem];
            break;
        }
        case PKGenericTableTypeSortResultsBy: {
            [[self searchParameters] setSortBy:(PKSearchParameterType)selectedItem];
            break;
        }
        default:
            break;
    }
    
    // Reload table view
    [[self tableView] reloadData];
}

@end
