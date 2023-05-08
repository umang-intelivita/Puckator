//
//  PKSearchCategoryTableViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 27/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKSearchCategoryTableViewController.h"
#import "PKCategory+Operations.h"
#import "UIFont+Puckator.h"

@interface PKSearchCategoryTableViewController ()
@property (nonatomic, strong) NSArray *categories;
@end

@implementation PKSearchCategoryTableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the categories
    [self setCategories:[PKCategory allSortedBy:PKCategorySortModeAlphabetically ascending:YES includeCustom:YES]];
    
    // Add the reset button:
    UIBarButtonItem *buttonReset = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonResetPressed:)];
    [[self navigationItem] setRightBarButtonItem:buttonReset];
    
    // Extend the popover
    //[self setPreferredContentSize:CGSizeMake(400, 600)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Inform the previous UI of the category selections:
    if ([self categoryDelegate] && [[self categoryDelegate] respondsToSelector:@selector(pkSearchCategoryTableViewController:didSelectCategories:)]) {
        [[self categoryDelegate] pkSearchCategoryTableViewController:self didSelectCategories:[self selectedCategoryIds]];
    }
}

- (CGSize)preferredContentSize {
    return CGSizeMake(400, 600);
}

#pragma mark - Event Methods

- (void)buttonResetPressed:(id)sender {
    [self setSelectedCategoryIds:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self categories] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if(indexPath.row == 0) {
        [[cell textLabel] setText:NSLocalizedString(@"All Categories", nil)];
        [[cell textLabel] setFont:[UIFont puckatorContentTitleHeavy]];
        
        if(![self selectedCategoryIds] || [[self selectedCategoryIds] count] == 0) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        [[cell imageView] setImage:nil];
        
    } else {
        
        // Get the category
        PKCategory *category = [[self categories] objectAtIndex:indexPath.row - 1];
    
        // Configure the cell...
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [category styledTitle]]];
        [[cell textLabel] setFont:[UIFont puckatorContentTitle]];
        
        if([self isCategorySelected:category]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        [[cell imageView] setImage:[category image]];
    }

    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([[[self selectedCategoryIds] allKeys] count] == 0) {
        return NSLocalizedString(@"No categories selected", nil);
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"Selected %d categories", @"Used to inform the user how many categories they have selected to filter by. E.g. 'Selected 5 categories'"), [[[self selectedCategoryIds] allKeys] count]];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        
        // Clear all selections
        [self setSelectedCategoryIds:nil];
        
    } else {
    
        // Get the category object + add/remove
        PKCategory *category = [[self categories] objectAtIndex:indexPath.row - 1];
        if([self isCategorySelected:category]) {
            [self deselectCategory:category];
        } else {
            [self selectCategory:category];
        }
    }
    
    // Reload the cell
    //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView reloadData];
}

- (BOOL) isCategorySelected:(PKCategory*)category {
    if(![self selectedCategoryIds]) {
        return NO;
    }
    if([[self selectedCategoryIds] objectForKey:[category categoryId]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void) selectCategory:(PKCategory*)category {
    
    // Init selected category ID's if not done so already
    if(![self selectedCategoryIds]) {
        [self setSelectedCategoryIds:[NSMutableDictionary dictionary]];
    }
    
    // Insert the ID into the dictionary
    [[self selectedCategoryIds] setObject:@(YES) forKey:[category categoryId]];
    
    //[[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
}

- (void) deselectCategory:(PKCategory*)category {
    [[self selectedCategoryIds] removeObjectForKey:[category categoryId]];
    //[[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
}

- (void) clearSelections {
    [[self selectedCategoryIds] removeAllObjects];
}

@end
