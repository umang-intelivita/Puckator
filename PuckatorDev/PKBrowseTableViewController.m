//
//  PKBrowseTableViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 02/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBrowseTableViewController.h"

@interface PKBrowseTableViewController ()

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *suppliers;
@property (assign, nonatomic) PKBrowseTableViewControllerMode mode;

@end

@implementation PKBrowseTableViewController

+ (instancetype)createWithDelegate:(id<PKBrowseTableViewControllerDelegate>)delegate {
    return [PKBrowseTableViewController createWithMode:PKBrowseTableViewControllerModeCategories delegate:delegate];
}

+ (instancetype)createWithMode:(PKBrowseTableViewControllerMode)mode delegate:(id<PKBrowseTableViewControllerDelegate>)delegate {
    PKBrowseTableViewController *browseTableViewController = [[PKBrowseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [browseTableViewController setDelegate:delegate];
    [browseTableViewController setMode:mode];
    return browseTableViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch ([self mode]) {
        default:
        case PKBrowseTableViewControllerModeCategories:
            [self setCategories:[PKCategory allSortedBy:PKCategorySortModeAlphabetically ascending:YES includeCustom:YES]];
            [self setTitle:NSLocalizedString(@"Browse", nil)];
            break;
        case PKBrowseTableViewControllerModeSuppliers:
            [self setSuppliers:[PKProduct supplierList]];
            [self setTitle:NSLocalizedString(@"Suppliers", nil)];
        break;
        case PKBrowseTableViewControllerModeBuyers:
            [self setSuppliers:[PKProduct buyerList]];
            [self setTitle:NSLocalizedString(@"Buyers", nil)];
        break;
    }
    
    UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonClosePressed:)];
    [[self navigationItem] setLeftBarButtonItem:buttonClose];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[self navigationController] navigationBar] setOpaque:YES];
    [[[self navigationController] navigationBar] setTranslucent:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(setModalInPresentation:)]) {
        [self setModalInPresentation:NO];
    }    
}

#pragma mark - Event Methods

- (void)buttonClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UITableViewDelegate Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        return NSLocalizedString(@"Categories", nil);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch ([self mode]) {
        default:
        case PKBrowseTableViewControllerModeCategories:
            return 2;
            break;
        case PKBrowseTableViewControllerModeSuppliers:
            return 1;
            break;
        case PKBrowseTableViewControllerModeBuyers:
            return 1;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ([self mode]) {
        default:
        case PKBrowseTableViewControllerModeCategories: {
            if (section == 0) {
                if ([[[PKSession sharedInstance] currentFeedConfig] isSuppliersEnabled]) {
                    return [[PKSession instance] currentCustomer] ? 4 : 1;
                }
                return [[PKSession instance] currentCustomer] ? 2 : 1;
            } else if (section == 1) {
                return [[self categories] count];
            } else {
                return 0;
            }
            break;
        }
        case PKBrowseTableViewControllerModeSuppliers: {
            return [[self suppliers] count];
            break;
        }
        case PKBrowseTableViewControllerModeBuyers: {
            return [[self suppliers] count];
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    switch ([self mode]) {
        default:
        case PKBrowseTableViewControllerModeCategories: {
            if ([indexPath section] == 0) {
                if ([indexPath row] == 0) {
                    [[cell textLabel] setText:NSLocalizedString(@"All Products", nil)];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                } else if ([indexPath row] == 1) {
                    if([[PKSession instance] currentCustomer]) {
                        [[cell textLabel] setText:NSLocalizedString(@"Past Orders", nil)];
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

                    } else {
                        [[cell textLabel] setText:NSLocalizedString(@"Suppliers", nil)];
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }
                } else if ([[PKSession instance] currentCustomer] && ([indexPath row] == 2)) {
                    [[cell textLabel] setText:NSLocalizedString(@"Suppliers", nil)];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                } else {
                    [[cell textLabel] setText:NSLocalizedString(@"Buyers", nil)];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
            } else {
                PKCategory *category = [[self categories] objectAtIndex:[indexPath row]];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [[cell textLabel] setText:[category styledTitle]];
            }
            break;
        }
        case PKBrowseTableViewControllerModeSuppliers: {
            NSString *supplier = [[self suppliers] objectAtIndex:[indexPath row]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [[cell textLabel] setText:[supplier capitalizedString]];
            break;
        }
        case PKBrowseTableViewControllerModeBuyers: {
            NSString *supplier = [[self suppliers] objectAtIndex:[indexPath row]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [[cell textLabel] setText:[supplier capitalizedString]];
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([self mode]) {
        default:
        case PKBrowseTableViewControllerModeCategories: {
            if ([indexPath section] == 0) {
                if ([indexPath row] == 0) {
                    if ([[self delegate] respondsToSelector:@selector(pkBrowseTableViewController:didSelectFilter:)]) {
                        [[self delegate] pkBrowseTableViewController:self didSelectFilter:[indexPath row]];
                    }
                } else if ([indexPath row] == 1) {
                    if([[PKSession instance] currentCustomer]) {
                        if ([[self delegate] respondsToSelector:@selector(pkBrowseTableViewController:didSelectPastOrders:)]) {
                            [[self delegate] pkBrowseTableViewController:self didSelectPastOrders:@"Past Orders"];
                        }
                    } else {
                        PKBrowseTableViewController *browseTableViewController = [PKBrowseTableViewController createWithMode:PKBrowseTableViewControllerModeSuppliers delegate:[self delegate]];
                        [[self navigationController] pushViewController:browseTableViewController animated:YES];
                    }
                } else if (([indexPath row] == 2) && [[PKSession instance] currentCustomer]) {
                    PKBrowseTableViewController *browseTableViewController = [PKBrowseTableViewController createWithMode:PKBrowseTableViewControllerModeSuppliers delegate:[self delegate]];
                    [[self navigationController] pushViewController:browseTableViewController animated:YES];
                } else {
                    PKBrowseTableViewController *browseTableViewController = [PKBrowseTableViewController createWithMode:PKBrowseTableViewControllerModeBuyers delegate:[self delegate]];
                    [[self navigationController] pushViewController:browseTableViewController animated:YES];
                }
            } else {
                PKCategory *category = [[self categories] objectAtIndex:[indexPath row]];
                if ([[self delegate] respondsToSelector:@selector(pkBrowseTableViewController:didSelectCategory:)]) {
                    [[self delegate] pkBrowseTableViewController:self didSelectCategory:category];
                }
            }
            break;
        }
        case PKBrowseTableViewControllerModeSuppliers: {
            NSString *supplier = [[self suppliers] objectAtIndex:[indexPath row]];
            if ([[self delegate] respondsToSelector:@selector(pkBrowseTableViewController:didSelectSupplier:)]) {
                [[self delegate] pkBrowseTableViewController:self didSelectSupplier:supplier];
            }
            break;
        }
        case PKBrowseTableViewControllerModeBuyers: {
            NSString *supplier = [[self suppliers] objectAtIndex:[indexPath row]];
            if ([[self delegate] respondsToSelector:@selector(pkBrowseTableViewController:didSelectBuyer:)]) {
                [[self delegate] pkBrowseTableViewController:self didSelectBuyer:supplier];
            }
            break;
        }
    }
}

#pragma mark -

@end
