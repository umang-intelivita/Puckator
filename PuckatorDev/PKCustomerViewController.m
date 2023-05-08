//
//  PKCustomerViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 10/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCustomerViewController.h"
#import "PKCustomer.h"
#import "UIView+FrameHelper.h"
#import "PKAddress.h"
#import "PKOrderHistoryCell.h"
#import "PKCustomerDetailCell.h"
#import "PKInvoice.h"
#import "PKBasket+Operations.h"
#import "PKCurrencyViewController.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

@interface PKCustomerViewController ()

@property (strong, nonatomic) NSArray *invoices;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (assign, nonatomic) PKCustomerViewControllerOrderType orderType;
@property (strong, nonatomic) NSDictionary *statusFilterDict;
@property (strong, nonatomic) UIBarButtonItem *buttonFilter;

@end

@implementation PKCustomerViewController

#pragma mark Constructor Methods

+ (instancetype)create {
    PKCustomerViewController *customerViewController = [PKCustomerViewController createFromStoryboardNamed:@"Main"];
    return customerViewController;
}

+ (instancetype)createWithCustomer:(PKCustomer *)customer {
    PKCustomerViewController *viewController = [PKCustomerViewController create];
    [viewController setCustomer:customer];
    return viewController;
}

+ (instancetype)createWithOrders:(NSArray *)orders withOrderType:(PKCustomerViewControllerOrderType)orderType {
    PKCustomerViewController *customerViewController = [PKCustomerViewController createFromStoryboardNamed:@"Main"];
    [customerViewController setInvoices:orders];
    [customerViewController setOrderType:orderType];
    return customerViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self customer]) {
        [self setTitle:[[self customer] companyName]];
    } else {
        if ([self orderType] == PKCustomerViewControllerOrderTypeOpen) {
            [self setTitle:NSLocalizedString(@"Open Orders", nil)];
            
            // Add the cancel all button:
            UIBarButtonItem *buttonCancelAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel All", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonCancelAllBasketsPressed:)];
            [[self navigationItem] setRightBarButtonItem:buttonCancelAll];
        } else if ([self orderType] == PKCustomerViewControllerOrderTypeRecent) {
            [self setTitle:NSLocalizedString(@"Recent Orders", nil)];
        }
    }
    
    [self loadInvoices];
    [self setupUI];
    [[self tableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Overridden Methods

- (void)setCustomer:(PKCustomer *)customer {
    _customer = customer;
}

#pragma mark - Private Methods

- (void)setupUI {
    // Add the new order button:
    if ([self customer]) {
        UIBarButtonItem *buttonNewOrder = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New Order", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonNewOrderPressed:)];
        
//        // Add the filter button:
//        UIBarButtonItem *buttonFilter = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Filter", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonFilterPressed:)];
//        [self setButtonFilter:buttonFilter];
        
//        [[self navigationItem] setRightBarButtonItems:@[buttonNewOrder, buttonFilter]];
        [[self navigationItem] setRightBarButtonItems:@[buttonNewOrder]];
        
        if (![self segmentedControl]) {
            [self setSegmentedControl:[[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Customer Details", nil), NSLocalizedString(@"Orders / Quotes", nil), NSLocalizedString(@"Archived Orders", nil)]]];
            [[self segmentedControl] setFrame:CGRectMake(0, 0, 300, 30)];
            [[self segmentedControl] setSelectedSegmentIndex:0];
            [[self segmentedControl] addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
            [[self segmentedControl] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
            [[self segmentedControl] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
            [[self navigationItem] setTitleView:[self segmentedControl]];
        }
    } else {
//        // Add the filter button:
//        UIBarButtonItem *buttonFilter = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Filter", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonFilterPressed:)];
//        [self setButtonFilter:buttonFilter];
//        [[self navigationItem] setRightBarButtonItem:buttonFilter];
    }
    
    // The close button if required:
    if (![self tabBarController] && [[[self navigationController] viewControllers] count] == 1) {
        UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonClosePressed:)];
        [[self navigationItem] setLeftBarButtonItem:buttonClose];
    }
}

- (BOOL)isViewingCustomerDetails {
    if ([self customer]) {
        return [[self segmentedControl] selectedSegmentIndex] == 0;
    } else {
        return NO;
    }
}

- (BOOL)isViewingAllOrders {
    return [[self segmentedControl] selectedSegmentIndex] == 2;
}

- (BOOL)isViewingOrderHistory {
    if (![self customer]) {
        return YES;
    }
    
    return ![self isViewingCustomerDetails];
}

- (void)loadInvoices {
    // Save the invoices and baskets:
    if ([self customer]) {
        [self showHud:NSLocalizedString(@"Loading", nil) withSubtitle:nil animated:NO interaction:NO];
        [[self segmentedControl] setEnabled:NO];
        
        __weak PKCustomerViewController *weakSelf = self;
        BOOL isViewinngAllOrders = [self isViewingAllOrders];
        [FSThread runInBackground:^{
            if (isViewinngAllOrders) {
                [weakSelf setInvoices:[PKInvoice archivedInvoicesForCustomer:[weakSelf customer]]];
            } else {
                [weakSelf setInvoices:[PKInvoice allInvoicesForCustomer:[weakSelf customer]]];
            }
            
            // Filter the invoices:
            if ([weakSelf statusFilterDict]) {
                NSString *name = [[self statusFilterDict] objectForKey:@"name"];
                NSNumber *status = [[self statusFilterDict] objectForKey:@"status"];
                NSNumber *wasSent = [[self statusFilterDict] objectForKey:@"wasSent"];
                NSString *class = [[self statusFilterDict] objectForKey:@"class"];
                
                [FSThread runOnMain:^{
                    [[weakSelf buttonFilter] setTitle:name];
                }];
                
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
                    return [object isKindOfClass:NSClassFromString(class)];
                }];
                
                NSPredicate *statusPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    if ([evaluatedObject respondsToSelector:@selector(status)]) {
                        int objStatus = (int)[evaluatedObject performSelector:@selector(status)];
                        return  (objStatus == [status intValue]);
                    }
                    
                    return NO;
                }];
                
                NSPredicate *wasSentPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    if ([evaluatedObject respondsToSelector:@selector(wasSent)]) {
                        int objWasSent = (BOOL)[evaluatedObject performSelector:@selector(status)];
                        return  (objWasSent == [wasSent boolValue]);
                    }
                    
                    return NO;
                }];
                
                NSCompoundPredicate *compoundPredicate = nil;
                if (wasSent) {
                    compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, statusPredicate, wasSentPredicate]];
                } else {
                    compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, statusPredicate]];
                }
                
                [weakSelf setInvoices:[[weakSelf invoices] filteredArrayUsingPredicate:compoundPredicate]];
            } else {
                [FSThread runOnMain:^{
                    [[weakSelf buttonFilter] setTitle:NSLocalizedString(@"Filter", nil)];
                }];
            }
            
            [FSThread runOnMain:^{
                [[weakSelf segmentedControl] setEnabled:YES];
        
                // Only reload the table view if the segmented control is showing invoices:
                [[weakSelf tableView] reloadData];
                [weakSelf hideHudAnimated:NO];
            }];
        }];
    }
}

#pragma mark - Event Methods

- (void)buttonFilterPressed:(id)sender {
    NSMutableArray *statusItems = [NSMutableArray array];
    [statusItems addObjectsFromArray:[PKBasket statusItems]];
    [statusItems addObjectsFromArray:[PKInvoice statusItems]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Filter", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [[alertController popoverPresentationController] setBarButtonItem:sender];
    
    if ([self statusFilterDict]) {
        // Add a clear button:
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear Filter", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self setStatusFilterDict:nil];
            [self loadInvoices];
        }];
        [alertController addAction:action];
    }
    
    [statusItems enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [dictionary objectForKey:@"name"];
        NSString *class = [[dictionary objectForKey:@"class"] stringByReplacingOccurrencesOfString:@"PK" withString:@""];
        NSString *actionName = [NSString stringWithFormat:@"%@: %@", class, name];
        
        if ([name length] != 0) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:actionName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"[%@] - Status: %@", [self class], actionName);
                [self setStatusFilterDict:dictionary];
                [self loadInvoices];
            }];
            [alertController addAction:action];
        }
    }];
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

- (void)buttonCancelAllBasketsPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancel Orders?", nil)
                                                                   message:NSLocalizedString(@"Are you sure you want to cancel all open orders? This cannot be undone.", nil)
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel Orders", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // Cancel all the orders (baskets):
        [[self invoices] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PKBasket class]]) {
                PKBasket *basket = (PKBasket *)obj;
                [basket cancelOrder];
            }
        }];
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [[alert popoverPresentationController] setBarButtonItem:[[self navigationItem] rightBarButtonItem]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)buttonNewOrderPressed:(id)sender {
    __weak PKCustomerViewController *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [[alertController popoverPresentationController] setBarButtonItem:sender];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"This is a show order", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PKSession sharedInstance] setIsShowOrder:YES];
        [weakSelf displayOrderOptions];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"This is a normal order", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PKSession sharedInstance] setIsShowOrder:NO];
        [weakSelf displayOrderOptions];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)displayOrderOptions {
    // Check for existing open orders:
    // Get the open baskets:
    NSArray *openBaskets = [PKBasket openBasketsForCustomer:[self customer] feedNumber:nil includeErrored:NO context:nil];
    
    if ([openBaskets count] != 0) {
        RIButtonItem *itemOpenBasket = [RIButtonItem itemWithLabel:NSLocalizedString(@"Continue Order", nil) action:^{
            PKBasket *basket = [openBaskets firstObject];
            [basket setStatus:PKBasketStatusOpen shouldSave:YES];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }];
        
        RIButtonItem *itemNewBasket = [RIButtonItem itemWithLabel:NSLocalizedString(@"New Order", nil) action:^{
            // Cancel all the open baskets for this customer:
            [PKBasket cancelAllOpenBasketsForCustomer:[self customer]];
            
            // Display the currency view controller:
            PKCurrencyViewController *currencyViewController = [PKCurrencyViewController createWithCustomer:[self customer] delegate:self];
            [self presentViewController:[currencyViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
            }];
        }];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Order Found", nil)
                                                            message:NSLocalizedString(@"An open order for this customer has been found, would you like to continue this order?", nil)
                                                   cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", nil)]
                                                   otherButtonItems:itemOpenBasket, itemNewBasket, nil];
        [alertView show];
    } else {
        PKCurrencyViewController *currencyViewController = [PKCurrencyViewController createWithCustomer:[self customer] delegate:self];
        [self presentViewController:[currencyViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
        }];
    }
}

- (void)buttonClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)segmentedControlValueChanged:(id)sender {
    if ([self isViewingOrderHistory] || [self isViewingAllOrders]) {
        [self loadInvoices];
    } else {
        [[self tableView] reloadData];
    }
}

#pragma mark - PKCustomerSelectionDelegate Methods

- (void)pkCustomerSelectionDelegateSelectedCustomer:(PKCustomer *)customer andCreatedBasket:(PKBasket *)basket {
    [self dismissViewControllerAnimated:YES completion:^{
        [[self tabBarController] setSelectedTab:UITabBarControllerTabCatalogue];
    }];
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isViewingCustomerDetails]) {
        return 1;
    } else if ([self isViewingOrderHistory]) {
        return [[self invoices] count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isViewingCustomerDetails]) {
        return [[self view] bounds].size.height;
    } else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isViewingCustomerDetails]) {
        PKCustomerDetailCell *cell = (PKCustomerDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"PKCustomerDetailCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setupWithCustomer:[self customer]];
        return cell;
    } else if ([self isViewingOrderHistory]) {
        PKOrderHistoryCell *cell = (PKOrderHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"PKOrderHistoryCell" forIndexPath:indexPath];
        [cell setupWithInvoiceOrBasket:[[self invoices] objectAtIndex:[indexPath row]]];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isViewingOrderHistory]) {
        id object = [[self invoices] objectAtIndex:[indexPath row]];
        
        if ([object isKindOfClass:[PKInvoice class]]) {
            PKInvoice *invoice = (PKInvoice *)object;
            [self showHud:NSLocalizedString(@"Loading", nil) withSubtitle:nil animated:YES interaction:NO];
            
            PKBasketTableViewController *basketTableViewController = [PKBasketTableViewController createWithInvoice:invoice delegate:self];
            [self presentViewController:[basketTableViewController withNavigationController] animated:YES completion:^{
                [self hideHud];
            }];
        } else if ([object isKindOfClass:[PKBasket class]]) {
            PKBasket *basket = (PKBasket *)object;
            PKBasketTableViewController *basketTableViewController = [PKBasketTableViewController createWithBasket:basket delegate:self];
            
            if ([self tabBarController]) {
                [self presentViewController:[basketTableViewController withNavigationController] animated:YES completion:^{
                }];
            } else {
                [[self navigationController] pushViewController:basketTableViewController animated:YES];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PKBasketTableViewControllerDelegate Methods

- (void)pkBasketTableViewController:(PKBasketTableViewController *)basketTableViewController didOpenBasket:(PKBasket *)basket {
    [basketTableViewController dismissViewControllerAnimated:YES completion:^{
        if (basket) {
            [[self tabBarController] setSelectedTab:UITabBarControllerTabOrder];
        }
    }];
}

#pragma mark -

@end
