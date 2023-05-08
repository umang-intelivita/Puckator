//
//  PKGenericTableViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 04/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKGenericTableViewController.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import "PKTranslate.h"
#import "PKSearchParameters.h"
#import "PKConstant.h"

@interface PKGenericTableViewController ()
@property (nonatomic, assign) id<PKGenericTableDelegate> selectionDelegate;     // The delegate used for selections, etc
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) int selectedItemId;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
@end

@implementation PKGenericTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // You can optionally specify a "text" value in each dictionary to override the dynamic titles from PKSearchParameters
    switch ([self type]) {
        case PKGenericTableTypeSearchScope: {
            [self setItems:@[@{@"id" : @(PKSearchParameterTypeSearchByAll)},
                             @{@"id" : @(PKSearchParameterTypeSearchByCodeOnly)},
                             @{@"id" : @(PKSearchParameterTypeSearchByTitleAndDesc)},
                             @{@"id" : @(PKSearchParameterTypeSearchByTitleOnly)}]];
            break;
        }
        case PKGenericTableTypeSortResultsBy: {
            [self setItems:@[@{@"id" : @(PKSearchParameterTypeSortByPopularFirst)},
                             @{@"id" : @(PKSearchParameterTypeSortByBestSellers)}]];
            break;
        }
        case PKGenericTableTypeSortTopProductsBy:
        case PKGenericTableTypeSortProductsBy:
        case PKGenericTableTypeSortBasketBy: {
            [[self navigationItem] setTitle:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Sort By", nil)]];
            
            if ([self type] == PKGenericTableTypeSortProductsBy) {
                [self setItems:@[@{@"id" : @(PKSearchParameterTypeProductCode)},
                                 @{@"id" : @(PKSearchParameterTypePrice)},
                                 @{@"id" : @(PKSearchParameterTypeDateAdded)},
                                 @{@"id" : @(PKSearchParameterTypeTotalSold)},
                                 @{@"id" : @(PKSearchParameterTypeTotalValue)},
                                 @{@"id" : @(PKSearchParameterTypeStockAvailable)}]];
            } else if ([self type] == PKGenericTableTypeSortBasketBy) {
                [self setItems:@[@{@"id" : @(PKSearchParameterTypeProductCode)},
                                 @{@"id" : @(PKSearchParameterTypeProductTitle)},
                                 @{@"id" : @(PKSearchParameterTypeDateAdded)}]];
            } else {
                [self setItems:@[@{@"id" : @(PKSearchParameterTypeTotalSold)},
                                 @{@"id" : @(PKSearchParameterTypeTotalValue)}]];
            }
            
            int currentSelectedItem = (int)[[NSUserDefaults standardUserDefaults] integerForKey:[self userDefaultsKey]];
            if (currentSelectedItem != 0) {
                [self setSelectedItemId:currentSelectedItem];
            }
            
            break;
        }
        case PKGenericTableBasketContextMenu: {
            [[self navigationItem] setTitle:NSLocalizedString(@"Options", nil)];
            
            [self setItems:@[@{@"id" : @(0), @"text": NSLocalizedString(@"Complete Order", nil)},
                             @{@"id" : @(1), @"text": NSLocalizedString(@"Save Order", nil)},
                             @{@"id" : @(2), @"text": NSLocalizedString(@"Save As Quote", nil)},
                             @{@"id" : @(3), @"text": NSLocalizedString(@"Clear Order", nil)},
                             @{@"id" : @(4), @"text": NSLocalizedString(@"Cancel Order", nil)}]];
            break;
        }
        default:
            break;
    }
}

- (CGSize)preferredContentSize {
    switch ([self type]) {
        case PKGenericTableTypeSortProductsBy:
            return CGSizeMake(400, 560);
            break;
        case PKGenericTableTypeSortTopProductsBy:
            return CGSizeMake(400, 510);
            break;
        case PKGenericTableTypeSortBasketBy:
            return CGSizeMake(400, 200);
            break;
        default:
            return CGSizeMake(400, 500);
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Factories

+ (instancetype) createWithType:(PKGenericTableType)type delegate:(id<PKGenericTableDelegate>)delegate {
    return [PKGenericTableViewController createWithType:type delegate:delegate selectedItemId:-1];
}

+ (instancetype) createWithType:(PKGenericTableType)type delegate:(id<PKGenericTableDelegate>)delegate selectedItemId:(int)selectedItemId {
    PKGenericTableViewController *viewController = [[PKGenericTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [viewController setType:type];
    [viewController setSelectionDelegate:delegate];
    [viewController setSelectedItemId:selectedItemId];
    return viewController;
}

#pragma mark - Private Methods

- (NSString *)userDefaultsKey {
    if ([self type] == PKGenericTableTypeSortBasketBy) {
        return @"PKSortOptionBasket";
    } else {
        return @"PKSortOption";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if([self type] == PKGenericTableTypeSortProductsBy) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [[self items] count];
    } else {
        return 6;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return nil;
    } else {
        return @" ";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        
        // Get the item for the index
        NSDictionary *item = [[self items] objectAtIndex:indexPath.row];
        int type = [[item objectForKey:@"id"] intValue];
        
        // Get the title
        NSString *title = @"";
        if([item objectForKey:@"text"]) {
            title = [item objectForKey:@"text"];
        } else {
            title = [PKSearchParameters titleForParameterType:type];
        }

        // Configure the cell...
        [[cell textLabel] setText:title];
        [[cell textLabel] setFont:[UIFont puckatorFontStandardWithSize:17]];
        
        // Do we need to show the selected accessory?
        if ([self type] != PKGenericTableBasketContextMenu) {
            if (type == abs([self selectedItemId])) {
                if([self type] == PKGenericTableTypeSortResultsBy || [self type] == PKGenericTableTypeSortProductsBy || [self type] == PKGenericTableTypeSortBasketBy) {
                    if([self selectedItemId] < 0) {
                        [[cell textLabel] setText:[NSString stringWithFormat:@"%@ (%@)", [[cell textLabel] text], NSLocalizedString(@"Desc", @"The shorthand for descending")]];
                    } else {
                        [[cell textLabel] setText:[NSString stringWithFormat:@"%@ (%@)", [[cell textLabel] text], NSLocalizedString(@"Asc", @"The shorthand for ascending")]];
                    }
                }
                
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [[cell textLabel] setTextColor:[UIColor puckatorPrimaryColor]];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [[cell textLabel] setTextColor:[UIColor puckatorDarkGray]];
            }
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellSwitch"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellSwitch"];
        }
        
        // Configure the cell
        switch ([indexPath row]) {
            case 0: {
                [[cell textLabel] setText:NSLocalizedString(@"Hide out of stock", nil)];
                break;
            }
            case 1: {
                [[cell textLabel] setText:NSLocalizedString(@"Only show available products", nil)];
                break;
            }
            case 2: {
                [[cell textLabel] setText:NSLocalizedString(@"Hide bespoke products", nil)];
                break;
            }
            case 3: {
                [[cell textLabel] setText:NSLocalizedString(@"Show sample products", nil)];
                break;
            }
            case 4: {
                [[cell textLabel] setText:NSLocalizedString(@"Hide TBD products", nil)];
                break;
            }
            case 5: {
                [[cell textLabel] setText:NSLocalizedString(@"Hide products in order view", nil)];
                break;
            }
            default:
                break;
        }
        
        [[cell textLabel] setTextColor:[UIColor puckatorDarkGray]];
        [[cell textLabel] setFont:[UIFont puckatorFontStandardWithSize:17]];
        
        // Configure the switch
        UISwitch *switchSetting = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        [switchSetting setTag:[indexPath row]];
        [switchSetting addTarget:self action:@selector(switchSettingChanged:) forControlEvents:UIControlEventValueChanged];
        [switchSetting setOn:YES];
        
        switch ([indexPath row]) {
            case 0: {
                [switchSetting setOn:[[PKSession sharedInstance] hideOutOfStockProducts]];
                break;
            }
            case 1: {
                [switchSetting setOn:[[PKSession sharedInstance] showAvailableProducts]];
                break;
            }
            case 2: {
                [switchSetting setOn:[[PKSession sharedInstance] hideBespokeProducts]];
                break;
            }
            case 3: {
                [switchSetting setOn:[[PKSession sharedInstance] showSampleProducts]];
                break;
            }
            case 4: {
                [switchSetting setOn:[[PKSession sharedInstance] hideTBDProducts]];
                break;
            }
            case 5: {
                [switchSetting setOn:[[PKSession sharedInstance] hideProductsInOrderView]];
                break;
            }
            default:
                break;
        }
        
        [cell setAccessoryView:switchSetting];
        
        return cell;
    }
}

- (void)switchSettingChanged:(id)sender {
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *switchControl = (UISwitch *)sender;
        
        switch ([switchControl tag]) {
            case 0: {
                [[PKSession sharedInstance] setHideOutOfStockProducts:[switchControl isOn]];
                break;
            }
            case 1: {
                [[PKSession sharedInstance] setShowAvailableProducts:[switchControl isOn]];
                break;
            }
            case 2: {
                [[PKSession sharedInstance] setHideBespokeProducts:[switchControl isOn]];
                break;
            }
            case 3: {
                [[PKSession sharedInstance] setShowSampleProducts:[switchControl isOn]];
                break;
            }
            case 4: {
                [[PKSession sharedInstance] setHideTBDProducts:[switchControl isOn]];
                break;
            }
            case 5: {
                [[PKSession sharedInstance] setHideProductsInOrderView:[switchControl isOn]];
                break;
            }
            default:
                break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFilterChanged object:nil];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // Get the selected item
        NSDictionary *selectedItemDict = [[self items] objectAtIndex:indexPath.row];
        int selectedItem = -1;
        if ([selectedItemDict objectForKey:@"id"]) {
            selectedItem = [[selectedItemDict objectForKey:@"id"] intValue];
        }
        
        if ([self type] == PKGenericTableTypeSortProductsBy) {
            NSDictionary *item = [[self items] objectAtIndex:indexPath.row];
            int type = [[item objectForKey:@"id"] intValue];
            
            int modifier = -1;
            int currentSelectedItem = (int)[[NSUserDefaults standardUserDefaults] integerForKey:[self userDefaultsKey]];
            if (currentSelectedItem <= 0) {
                modifier = 1;
            }
            
            [[NSUserDefaults standardUserDefaults] setInteger:(type * modifier) forKey:[self userDefaultsKey]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if ([self type] == PKGenericTableTypeSortProductsBy ||
            [self type] == PKGenericTableTypeSortTopProductsBy ||
            [self type] == PKGenericTableTypeSortBasketBy) {
            [self setLastSelectedIndexPath:indexPath];
            
            __weak PKGenericTableViewController *weakSelf = self;
            
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"Ascending Order", nil), NSLocalizedString(@"Descending Order", nil), nil];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *actionAscending = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ascending Order", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf buttonSortDirectionPressed:nil ascending:YES];
            }];
            
            UIAlertAction *actionDescending = [UIAlertAction actionWithTitle:NSLocalizedString(@"Descending Order", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf buttonSortDirectionPressed:nil ascending:NO];
            }];
            
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                             style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
            }];
            
            [alertController addAction:actionAscending];
            [alertController addAction:actionDescending];
            [alertController addAction:actionCancel];
            
            UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
            if (cell) {
                [[alertController popoverPresentationController] setSourceRect:[cell frame]];
                [[alertController popoverPresentationController] setSourceView:[self view]];
                [[alertController popoverPresentationController] setPermittedArrowDirections:UIPopoverArrowDirectionUp];
            } else {
                [[alertController popoverPresentationController] setSourceRect:[[self view] frame]];
                [[alertController popoverPresentationController] setSourceView:[self view]];
                [[alertController popoverPresentationController] setPermittedArrowDirections:UIPopoverArrowDirectionLeft];
            }
            
            [self presentViewController:alertController
                               animated:YES
                             completion:nil];
            
            //[action showInView:[self view]];
            return;
        }
        
        // Call the delegate!
        if ([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkGenericTableViewController:didSelectItemId:)]) {
            [[self selectionDelegate] pkGenericTableViewController:self didSelectItemId:selectedItem];
        }
        
        if ([self type] != PKGenericTableTypeSortProductsBy) {
            [[self navigationController] popViewControllerAnimated:YES];
        }
    } else {
        NSLog(@"Selected: %d", (int)indexPath.row);
    }
}

- (void)buttonSortDirectionPressed:(id)sender ascending:(BOOL)ascending {
    NSDictionary *selectedItemDict = [[self items] objectAtIndex:[self lastSelectedIndexPath].row];
    int selectedItem = -1;
    if ([selectedItemDict objectForKey:@"id"]) {
        selectedItem = [[selectedItemDict objectForKey:@"id"] intValue];
    }
    
    NSDictionary *item = [[self items] objectAtIndex:[self lastSelectedIndexPath].row];
    int type = [[item objectForKey:@"id"] intValue];
    
    int modifier = -1;
    if (ascending) {
        modifier = 1;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:modifier*type forKey:[self userDefaultsKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkGenericTableViewController:didSelectItemId:)]) {
        [[self selectionDelegate] pkGenericTableViewController:self didSelectItemId:selectedItem];
    }
}

#pragma mark - Action Sheet Delegate
//
//-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if ([actionSheet cancelButtonIndex] == buttonIndex) {
//        [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
//    } else {
//        NSDictionary *selectedItemDict = [[self items] objectAtIndex:[self lastSelectedIndexPath].row];
//        int selectedItem = -1;
//        if ([selectedItemDict objectForKey:@"id"]) {
//            selectedItem = [[selectedItemDict objectForKey:@"id"] intValue];
//        }
//
//        NSDictionary *item = [[self items] objectAtIndex:[self lastSelectedIndexPath].row];
//        int type = [[item objectForKey:@"id"] intValue];
//
//        int modifier = -1;
//        if (buttonIndex == 0) {
//            modifier = 1;
//        }
//
//        [[NSUserDefaults standardUserDefaults] setInteger:modifier*type forKey:[self userDefaultsKey]];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//        if ([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkGenericTableViewController:didSelectItemId:)]) {
//            [[self selectionDelegate] pkGenericTableViewController:self didSelectItemId:selectedItem];
//        }
//    }
//}

@end
