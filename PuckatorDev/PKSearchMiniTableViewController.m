//
//  PKSearchMiniTableViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKSearchMiniTableViewController.h"
#import "PKMiniSearchResultTableViewCell.h"
#import "PKSearchMiniProductAddViewController.h"

@interface PKSearchMiniTableViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) PKProduct *selectedProduct;

@end

@implementation PKSearchMiniTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Show title for this view
    [[self navigationItem] setTitle:NSLocalizedString(@"Quick Search", nil)];
    
    // Show cancel button
    UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    [[self navigationItem] setLeftBarButtonItem:buttonCancel];
    
    [[self searchBar] setPlaceholder:NSLocalizedString(@"Enter name/product code then press Search", nil)];
}

- (void) cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self searchBar] becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self results] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PKMiniSearchResultTableViewCell *cell = (PKMiniSearchResultTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Product" forIndexPath:indexPath];
    
    if([[self results] count] >= 1) {
        PKProduct *product = [[self results] objectAtIndex:indexPath.row];
        
        // Configure the cell...
        [cell setProduct:product];
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Save reference to the selected product & show next UI
    [self setSelectedProduct:[[self results] objectAtIndex:indexPath.row]];
    [self performSegueWithIdentifier:@"segueMiniSearchShowProduct" sender:self];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue destinationViewController] isKindOfClass:[PKSearchMiniProductAddViewController class]]) {
        PKSearchMiniProductAddViewController *addingInterface = (PKSearchMiniProductAddViewController*)[segue destinationViewController];
        [addingInterface setProduct:[self selectedProduct]];
        [self setSelectedProduct:nil];
    }
}

#pragma mark - Search Bar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search: %@", [searchBar text]);
    
    if([[searchBar text] length] < 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Search is too short!", nil) message:NSLocalizedString(@"Must be at least three characters", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
        [alert show];
    } else {
        [self performSearch:[searchBar text]];
        [[self view] endEditing:YES];
    }
}

- (void) performSearch:(NSString*)searchText {
    PKSearchParameters *params = [[PKSearchParameters alloc] init];
    [params setSearchText:searchText];
    [params setScope:PKSearchParameterTypeSearchByAll];
    [params setSortBy:PKSearchParameterTypeProductCode];
    
    // Filter and reload table view
    [self setResults:[[PKProduct resultsForSearchParameters:params] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"model" ascending:YES]]]];
    [[self tableView] reloadData];
    
    if([[self results] count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No products found", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    
}

@end
