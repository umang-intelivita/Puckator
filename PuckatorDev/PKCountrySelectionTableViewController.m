//
//  PKCountrySelectionTableViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 16/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCountrySelectionTableViewController.h"
#import "PKCountry.h"

@interface PKCountrySelectionTableViewController ()
@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, assign) int selectedRowIndex;
@end

@implementation PKCountrySelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:NSLocalizedString(@"Select Country", nil)];
    [self setupData];
}

- (void) setupData {
    [self setCountries:[PKCountry allCountries]];
    
    [[self tableView] reloadData];
    
    // Select the current value
    [self setSelectedRowIndex:-1];
    
    int i = 0;
    for (PKCountry *country in [self countries]) {
        if ([[country name] isEqualToString:[[self textFieldEditing] text]]) {
            _selectedRowIndex = i;
            break;
        }
        i++;
    }
    
    // Scroll to the selected cell
    if([self selectedRowIndex] != -1) {
        [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self selectedRowIndex] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self countries] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    // Get country
    PKCountry *country = [[self countries] objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [[cell textLabel] setText:[country name]];
    
    // Show a checkbox next to the selected row...
    if (indexPath.row == [self selectedRowIndex]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

#pragma mark - Selection

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkCountrySelectionTableViewController:didSelectCountry:)]) {
        if ([indexPath row] < [[self countries] count]) {
            PKCountry *country = [[self countries] objectAtIndex:[indexPath row]];
            [[self selectionDelegate] pkCountrySelectionTableViewController:self didSelectCountry:country];
        } else {
            [[self selectionDelegate] pkCountrySelectionTableViewController:self didSelectCountry:nil];
        }
    }
}

@end
