//
//  PKBasketTableViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 14/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasketTableViewController.h"
#import "PKBasketCalculationTableViewCell.h"
#import "PKBasketCreateTableViewCell.h"
#import "PKBasket+Operations.h"
#import "PKBasketItem+Operations.h"
#import "PKProductsViewController.h"
#import "PKConstant.h"
#import "UIColor+Puckator.h"
#import "BasketHeaderView.h"
#import "UIAlertView+Blocks.h"
#import "PKBasketStandardHeaderViewController.h"
#import "PKBasketNotesTableViewCell.h"
#import "PKSearchMiniTableViewController.h"
#import "PKOrder.h"
#import "PKOrderSyncViewController.h"
#import "PKCustomer.h"
#import "PKInvoice.h"

@interface PKBasketTableViewController ()

@property (strong, nonatomic) PKBasket *basket;
@property (strong, nonatomic) PKInvoice *invoice;

@property (strong, nonatomic) NSArray *sortedItems;

@property (strong, nonatomic) UIPopoverController *currentPopoverController;
@property (nonatomic, strong) PKBasketStandardHeaderViewController *standardHeaderViewController;
@property (nonatomic, assign) BOOL isEditingMode;
@property (nonatomic, assign) BOOL isCopyingOrder;
@property (nonatomic, assign) BOOL isMovingOrder;
@property (strong, nonatomic) UIBarButtonItem *buttonEdit;

@end

@implementation PKBasketTableViewController

#pragma mark - Constructors

+ (instancetype)createController {
    return [PKBasketTableViewController createFromStoryboardNamed:@"Main"];
}

+ (instancetype)createWithBasket:(PKBasket *)basket delegate:(id<PKBasketTableViewControllerDelegate>)delegate {
    PKBasketTableViewController *basketTableViewController = [PKBasketTableViewController createController];
    [basketTableViewController setBasket:basket];
    [basketTableViewController setDelegate:delegate];
    return basketTableViewController;
}

+ (instancetype)createWithInvoice:(PKInvoice *)invoice delegate:(id<PKBasketTableViewControllerDelegate>)delegate {
    PKBasketTableViewController *basketTableViewController = [PKBasketTableViewController createController];
    [basketTableViewController setInvoice:invoice];
    [basketTableViewController setDelegate:delegate];
    return basketTableViewController;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Setup notifications:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBasketDidUpdateItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basketUpdated:) name:kNotificationBasketDidUpdateItem object:nil];
    
    // Setup notifications:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBasketStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basketCreated:) name:kNotificationBasketStatusChanged object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the basket:
    if (![self basket] && ![self invoice]) {
        [self setBasket:[PKBasket sessionBasket]];
    }
    
//    [[self tableView] reloadData];
}

- (void)basketCreated:(NSNotification *)notification {
    // Force main thread:
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(basketCreated:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    // Clear the sorted items:
    [self setSortedItems:nil];
    
    if ([[notification object] isKindOfClass:[PKBasket class]]) {
        [self setBasket:[notification object]];
    } else {
        [self setBasket:[PKBasket sessionBasket]];
    }
    
    [self setupNavigationButtons];
    
    // Check the view is on screen:
    if ([self isViewLoaded] && [[self view] window]) {
        [[self tableView] reloadData];
    }
}

- (void)basketUpdated:(NSNotification *)notification {
    [FSThread runOnMain:^{
        // Clear the sorted items array:
        if ([self sortedItems]) {
            [self setSortedItems:nil];
        }
        
        // Increase the current badge value:
        UITabBarItem *tabBarItem = [self tabBarItem];
        int badgeValue = ([[tabBarItem badgeValue] intValue] + 1);
        [tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d", badgeValue]];
        
        // Reload the table view if the view controller is on show:
        if ([self isViewLoaded] && [[self view] window]) {
            [[self tableView] reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setBadgeValue:nil];
    [[self tableView] reloadSectionIndexTitles];
    
    if (![self basket] && ![self invoice]) {
        [self setBasket:[PKBasket sessionBasket]];
    }
    
    [self setupNavigationButtons];

//    [self showHud:NSLocalizedString(@"Loading", nil)];
//    [self itemsAsync:^(NSArray *items) {
//        [self hideHud];
//        [[self tableView] reloadData];
//    }];
    [[self tableView] reloadData];
}

#pragma mark - Overidden Methods

- (UITabBarItem *)tabBarItem {
    int tabIndex = 2;
    UITabBarItem *tabBarItem = nil;
    
    if ([self tabBarController]) {
        if ([[self tabBarController] tabBar]) {
            if ([[[[self tabBarController] tabBar] items] count] > tabIndex) {
                tabBarItem = [[[[self tabBarController] tabBar] items] objectAtIndex:tabIndex];
            }
        }
    }
    
    return tabBarItem;
}

#pragma mark - Private Methods

- (PKBasketTableViewControllerMode)mode {
    if ([self basket]) {
        return PKBasketTableViewControllerModeBasket;
    }
    
    if ([self invoice]) {
        return PKBasketTableViewControllerModeInvoice;
    }
    
    return PKBasketTableViewControllerModeEmpty;
}

- (void)setupNavigationButtons {
    [FSThread runOnMain:^{
        if (![self basket] && ![self invoice]) {
            [self setTitle:NSLocalizedString(@"View Order", nil)];
            UIBarButtonItem *buttonCreateOrder = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New Order", nil)
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(buttonCreateOrderPressed:)];
            [[self navigationItem] setRightBarButtonItems:@[buttonCreateOrder]];
        } else {
            if ([self invoice]) {
                [self setTitle:NSLocalizedString(@"Order Details", nil)];
                
                // Add the open button:
                NSMutableArray *buttons = [NSMutableArray array];
                
                UIBarButtonItem *buttonOpen = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Copy", nil)
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(buttonOpenPressed:)];
                if (buttonOpen) {
                    [buttons addObject:buttonOpen];
                }
                
                [[self navigationItem] setRightBarButtonItems:buttons];
            } else if ([self basket]) {
                if ([[self basket] status] != PKBasketStatusOpen) {
                    [self setTitle:NSLocalizedString(@"Order Details", nil)];
                    
                    // Add the open button:
                    NSMutableArray *buttons = [NSMutableArray array];
                    
                    if ([[[self basket] wasSent] boolValue]) {
                        UIBarButtonItem *buttonOpen = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Copy", nil)
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(buttonOpenPressed:)];
                        if (buttonOpen) {
                            [buttons addObject:buttonOpen];
                        }
                        
                        UIBarButtonItem *buttonResend = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Resend", nil)
                                                                                         style:UIBarButtonItemStylePlain
                                                                                        target:self
                                                                                        action:@selector(buttonResendPressed:)];
                        if (buttonResend) {
                            [buttons addObject:buttonResend];
                        }
                    } else {
                        UIBarButtonItem *buttonOpen = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Open", nil)
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(buttonOpenPressed:)];
                        if (buttonOpen) {
                            [buttons addObject:buttonOpen];
                        }
                        
                        UIBarButtonItem *buttonMove = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Move", nil)
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(buttonMovePressed:)];
                        if (buttonOpen) {
                            [buttons addObject:buttonMove];
                        }
                    }
                    
                    [[self navigationItem] setRightBarButtonItems:buttons];
                } else {
                    if ([PKBasket sessionBasket] == [self basket]) {
                        [self setTitle:NSLocalizedString(@"View Order", nil)];
                        
                        // Create notes button
                        UIBarButtonItem *buttonNotes = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarNotes"]
                                                                                        style:UIBarButtonItemStylePlain
                                                                                       target:self
                                                                                       action:@selector(pressedNotesButton:)];
                        
                        // Add button to go into edit mode
                        if (![self buttonEdit]) {
                            [self setButtonEdit:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil)
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(buttonEditModePressed:)]];
                        }
                        
                        // Add send order button
                        UIBarButtonItem *buttonOptions = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                                       target:self
                                                                                                       action:@selector(buttonSendOrderPressed:)];
                        
                        if ([[self basket] status] == PKBasketStatusOpen) {
                            [[self navigationItem] setRightBarButtonItems:@[buttonOptions, buttonNotes, [self buttonEdit]]];
                        } else {
                            [[self navigationItem] setRightBarButtonItems:@[buttonOptions, buttonNotes]];
                        }
                        
                        // Setup left navigation items:
                        UIBarButtonItem *buttonSort = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarSort"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(buttonSortPressed:)];
                        [[self navigationItem] setLeftBarButtonItem:buttonSort];
                    } else {
                        [self setTitle:NSLocalizedString(@"Open Order", nil)];
                        UIBarButtonItem *buttonOpen = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Open", nil)
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(buttonOpenPressed:)];
                        UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                                        style:UIBarButtonItemStylePlain
                                                                                       target:self
                                                                                       action:@selector(buttonCancelOrderPressed:)];
                        [[self navigationItem] setRightBarButtonItems:@[buttonOpen, buttonClose]];
                    }
                }
            }
        }
        
        // Add a close button if required:
        if (![self tabBarController] && [[[self navigationController] viewControllers] count] == 1) {
            // Add the close button:
            UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(buttonClosePressed:)];
            [[self navigationItem] setLeftBarButtonItem:buttonClose];
        }
    }];
}

- (void)pressedNotesButton:(id)sender {
    PKNotesViewController *notesViewController = [PKNotesViewController create];
    
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:[notesViewController withNavigationController]];
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - Event Methods

- (void)buttonSortPressed:(id)sender {
    PKGenericTableType sortType = PKGenericTableTypeSortBasketBy;
    
    // Show filters, the last selected filter is saved to NSUserDefaults
    PKGenericTableViewController *filterTableViewController = [PKGenericTableViewController createWithType:sortType delegate:self];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:[filterTableViewController withNavigationController]];
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)buttonClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)buttonResendPressed:(id)sender {
    // Serialize to XML and push to server:
    NSString *xml = [[self basket] transformToOrderXmlStringIsQuote:[[self basket] status] == PKBasketStatusQuote];
    [[self basket] saveOrderXml:xml];
    
    // Display the PKOrderSyncViewController:
    [self presentViewController:[[PKOrderSyncViewController create] withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
    }];
}

- (void)buttonCancelOrderPressed:(id)sender {
    [self cancelOrder];
}

- (void)buttonMovePressed:(id)sender {
    // Display customer picker:
    [self setIsMovingOrder:YES];
    PKCustomersViewController *customers = [PKCustomersViewController createWithMode:PKCustomersViewControllerModeCopying delegate:self];
    UINavigationController *navigationController = [customers withNavigationController];
    [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:navigationController animated:YES completion:^{
    }];
}

- (void)buttonOpenPressed:(id)sender {
    if ([self basket] && ([[self basket] status] == PKBasketStatusSaved || [[self basket] status] == PKBasketStatusOpen || [[self basket] status] == PKBasketStatusCancelled)) {
        // Open the basket:
        [[self basket] setStatus:PKBasketStatusOpen shouldSave:YES];
        
        // Update delegate or dismiss the view controller:
        if ([[self delegate] respondsToSelector:@selector(pkBasketTableViewController:didOpenBasket:)]) {
            [[self delegate] pkBasketTableViewController:self didOpenBasket:[self basket]];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    } else {
        __weak PKBasketTableViewController *weakSelf = self;
        NSString *title = NSLocalizedString(@"Copy", nil);
        NSString *message = NSLocalizedString(@"Would you like to copy this order to this account or to another account?", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        [[alertController popoverPresentationController] setBarButtonItem:sender];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"To this account", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            PKCustomer *customer = nil;
            if ([self basket]) {
                customer = [PKCustomer findCustomerWithId:[[self basket] customerId]];
            } else if ([self invoice]) {
                customer = [PKCustomer findCustomerWithSageId:[[self invoice] sageId]];
            }
            
            NSString *currencyCode = nil;
            
            if ([self basket]) {
                currencyCode = [[self basket] currencyCode];
            } else if ([self invoice]) {
                currencyCode = [[self invoice] currencyCode];
            }
            
            [weakSelf copyOrderToCustomer:customer withCurrencyCode:currencyCode];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"To another account", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            // Display customer picker:
            [self setIsCopyingOrder:YES];
            PKCustomersViewController *customers = [PKCustomersViewController createWithMode:PKCustomersViewControllerModeCopying delegate:self];
            UINavigationController *navigationController = [customers withNavigationController];
            [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
            [weakSelf presentViewController:navigationController animated:YES completion:^{
            }];
        }]];
        
        [self presentViewController:alertController animated:YES completion:^{
        }];
    }
    
    
    if ([self basket] && ([[self basket] status] == PKBasketStatusSaved || [[self basket] status] == PKBasketStatusOpen || [[self basket] status] == PKBasketStatusCancelled)) {
        // Open the basket:
        [[self basket] setStatus:PKBasketStatusOpen shouldSave:YES];
        
        // Update delegate or dismiss the view controller:
        if ([[self delegate] respondsToSelector:@selector(pkBasketTableViewController:didOpenBasket:)]) {
            [[self delegate] pkBasketTableViewController:self didOpenBasket:[self basket]];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    } else {
        
    }
}

- (void)moveOrderToCustomer:(PKCustomer *)customer withCurrencyCode:(NSString *)currencyCode {
    if (customer) {
        // Save the current basket if required:
        PKBasket *currentBasket = [PKBasket sessionBasket];
        if (currentBasket) {
            [currentBasket setStatus:PKBasketStatusSaved shouldSave:YES];
            if ([PKBasket clearSessionBasket]) {
                [[PKSession sharedInstance] setCurrentCustomer:nil andCurrencyCode:nil];
            }
        }
        
        // Setup a new customer and basket:
        [[PKSession sharedInstance] setCurrentCustomer:customer andCurrencyCode:currencyCode];
        
        PKBasket *basket = nil;
        if ([self basket]) {
            basket = [[self basket] copyBasketToCustomer:customer currencyCode:currencyCode];
        } else if ([self invoice]) {
            basket = [PKBasket createWithInvoice:[self invoice] customer:customer currencyCode:currencyCode];
        }
        
        if (basket) {
            [PKBasket setSessionBasket:basket];
            [basket save];
        }
        
        // Delete the current basket:
        [[self basket] MR_deleteEntity];
        [self setBasket:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBasketStatusChanged object:nil];
        }];
    } else {
        // The customer hasn't been found:
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"Unable to find the customer", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        [self setModalInPopover:YES];
    }
}

- (void)copyOrderToCustomer:(PKCustomer *)customer withCurrencyCode:(NSString *)currencyCode {
    if (customer) {
        // Save the current basket if required:
        PKBasket *currentBasket = [PKBasket sessionBasket];
        if (currentBasket) {
            [currentBasket setStatus:PKBasketStatusSaved shouldSave:YES];
            if ([PKBasket clearSessionBasket]) {
                [[PKSession sharedInstance] setCurrentCustomer:nil andCurrencyCode:nil];
            }
        }
        
        // Setup a new customer and basket:
        [[PKSession sharedInstance] setCurrentCustomer:customer andCurrencyCode:currencyCode];
        
        PKBasket *basket = nil;
        if ([self basket]) {
            basket = [[self basket] copyBasketToCustomer:customer currencyCode:currencyCode];
        } else if ([self invoice]) {
            basket = [PKBasket createWithInvoice:[self invoice] customer:customer currencyCode:currencyCode];
        }
        
        if (basket) {
            [PKBasket setSessionBasket:basket];
            [basket save];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBasketStatusChanged object:nil];
        }];
    } else {
        // The customer hasn't been found:
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"Unable to find the customer", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        [self setModalInPopover:YES];
    }
}

#pragma mark - Table view data source

- (void)itemsAsync:(FSGetItemsBlock)completion {
    __weak PKBasketTableViewController *weakSelf = self;
    [FSThread runInBackground:^{
        NSArray *items = [weakSelf items];
        if (completion) {
            [FSThread runOnMain:^{
                completion(items);
            }];
        }
    }];
}

- (NSArray *)items {
    if ([self basket]) {
        // Clear down the sorted items if the basket has changed:
        if ([[self sortedItems] count] != [[[self basket] items] count]) {
            [self setSortedItems:nil];
        }
        
//        // Check for large items and return the unordered items:
//        if ([[[[self basket] items] allObjects] count] > 500) {
//            return [[[self basket] items] allObjects];
//        }
        
        if ([[self sortedItems] count] != 0) {
            return [self sortedItems];
        }
        
        // Save the sorted items so they don't have to be sorted each time:
        [self setSortedItems:[[self basket] itemsOrdered]];
        return [self sortedItems];
    } else if ([self invoice]) {
        return [[self invoice] invoiceLines];
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *items = [self items];
    
    if ([items count] != 0) {
        if ([[self basket] status] == PKBasketStatusOpen && ![self invoice]) {
            return 2;
        } else {
            return 3;
        }
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = [self items];
    
    // There is are no basket item to show then display
    // the 'add item' or 'create order' cell:
    if ([items count] == 0) {
        // No items to show:
        return 1;
    } else {
        switch (section) {
            default:
            case 0:
                // Basket items:
                return [items count];
                break;
            case 1:
                // Total cells:
                return 4;
                break;
            case 2:
                // Note cell (if displayed):
                return 1;
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = [self items];
    
    switch ([self mode]) {
        default:
        case PKBasketTableViewControllerModeEmpty: {
            // Setup the create table view cell:
            PKBasketCreateTableViewCell *cell = (PKBasketCreateTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PKBasketCreateTableViewCell" forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
            break;
        }
        case PKBasketTableViewControllerModeInvoice:
        case PKBasketTableViewControllerModeBasket: {
            if ([items count] == 0) {
                PKBasketCreateTableViewCell *cell = (PKBasketCreateTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PKBasketCreateTableViewCell" forIndexPath:indexPath];
                [cell setupCreateItemModeForBasket:[self basket]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            } else if ([indexPath section] == 0) {
                PKBasketItemTableViewCell *cell = (PKBasketItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PKBasketItemTableViewCell" forIndexPath:indexPath];
                [cell setSelectionDelegate:self];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                BOOL canEdit = ([[self basket] status] == PKBasketStatusOpen && [self isEditingMode]);
                id item = [items objectAtIndex:[indexPath row]];
                
                // Setup the cell using either a PKBasketItem or PKInvoiceItem:
                if ([item isKindOfClass:[PKBasketItem class]]) {
                    [cell updateWithBasketItem:item atIndexPath:indexPath editable:canEdit];
                } else if ([item isKindOfClass:[PKInvoiceLine class]]) {
                    [cell updateWithInvoice:[self invoice] invoiceLine:item atIndexPath:indexPath];
                }
                
                return cell;
            } else if ([indexPath section] == 1) {
                PKBasketCalculationTableViewCell *cell = (PKBasketCalculationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PKBasketCalculationTableViewCell" forIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell updateStyleIsButton:NO isHighlighted:NO];
                
                // Only setup a selection delegate for baskets:
                [cell setSelectionDelegate:[self basket] ? self : nil];
                
                switch(indexPath.row) {
                    case 0: {
                        if ([self invoice]) {
                            [cell updateWithTitle:NSLocalizedString(@"Total", nil)
                                            value:[[self invoice] formattedNetTotal]];
                        } else {
                            [cell updateWithTitle:NSLocalizedString(@"Total", nil)
                                            value:[[self basket] totalFormatted]];
                        }
                        
                        break;
                    }
                    case 1: {
                        if ([self invoice]) {
                            [cell updateWithTitle:NSLocalizedString(@"Delivery", nil)
                                            value:[[self invoice] formatPrice:[[self invoice] carrNet]]];
                        } else {
                            [cell updateWithTitle:NSLocalizedString(@"Delivery", nil)
                                            value:[[self basket] formattedPrice:[[self basket] deliveryPrice]]];
                            
                            if ([[self basket] status] == PKBasketStatusOpen) {
                                [cell updateStyleIsButton:[self isEditingMode] isHighlighted:NO];
                            }
                        }
                        break;
                    }
                    case 2: {
                        if ([self invoice]) {
                            NSString *vatRateAsString = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"VAT", nil), [[self invoice] formattedVatRate]];
                            [cell updateWithTitle:vatRateAsString
                                            value:[[self invoice] formatPrice:[[self invoice] vatTotal]]];
                        } else {
                            float vatRate = [[[self basket] vatRate] floatValue];
                            
                            NSString *value = [[self basket] formattedPrice:[[self basket] totalVat]];
                            NSString *vatRateValue = [[NSString stringWithFormat:@"%02.f%%", vatRate] stringByReplacingOccurrencesOfString:@".00" withString:@""];
                            if (vatRate <= 0.f) {
                                vatRateValue = NSLocalizedString(@"N/A", nil);
                                value = @"-";
                            }
                            
                            NSString *vatRateAsString = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"VAT", nil), vatRateValue];
                            [cell updateWithTitle:vatRateAsString value:value];
                        }
                        break;
                    }
                    case 3: {
                        if ([self invoice]) {
                            [cell updateWithTitle:NSLocalizedString(@"Grand Total", nil)
                                            value:[[self invoice] formatPrice:[[self invoice] grandTotal]]];
                        } else {
                            [cell updateWithTitle:NSLocalizedString(@"Grand Total", nil)
                                            value:[[self basket] formattedPrice:[[self basket] grandTotal]]];
                        }
                        [[cell labelRowValue] setTextColor:[UIColor puckatorPrimaryColor]];
                        [cell updateStyleIsButton:NO isHighlighted:YES];
                        break;
                    }
                }
                
                return cell;
            } else if ([indexPath section] == 2) {
                // Display notes:PKBasketNotesTableViewCell
                PKBasketNotesTableViewCell *cell = (PKBasketNotesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PKBasketNotesTableViewCell" forIndexPath:indexPath];
                
                if ([self basket]) {
                    [cell setupWithNotes:[[[[self basket] order] notes] sanitize]];
                } else if ([self invoice]) {
                    //[cell setupWithNotes:@"Notes for invoices coming soon"];
                }
                
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            } else {
                return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            }
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Don't allow row selection for invoices:
    if ([self invoice]) {
        return;
    }
    
    if (![self basket]) {
        [self buttonCreateOrderPressed:nil];
        [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([[[self basket] products] count] == 0) {
        [self pkBasketStandardHeaderViewController:nil didPressSearchButton:YES];
    } else if(indexPath.section == 0) {
        if ([self basket] && [[self basket] status] == PKBasketStatusOpen) {
            PKProductsViewController *productViewController = [PKProductsViewController createWithBasket:[self basket] indexPath:indexPath displayMode:PKProductsDisplayModeLarge];
            [self presentViewController:[productViewController withNavigationController] animated:YES completion:nil];
        }
    } else if(indexPath.section == 1) {
        if ([[self basket] status] == PKBasketStatusOpen) {
            // Only show the delivery num pad if the delivery cell was pressed
            if(indexPath.row == 1) {
                // Show the number pad for editing delivery cost
                PKBasketCalculationTableViewCell *cell = (PKBasketCalculationTableViewCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
                [self displayDeliveryCostPad:[cell buttonValue] fromCell:cell];
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self mode]) {
        default:
        case PKBasketTableViewControllerModeEmpty: {
            return 450;
            break;
        }
        case PKBasketTableViewControllerModeInvoice:
        case PKBasketTableViewControllerModeBasket: {
            if ([[self items] count] == 0) {
                if ([indexPath section] == 0) {
                    return 450;
                } else if ([indexPath section] == 1) {
                    // Create order cell:
                    return 400;
                }
            } else {
                if ([indexPath section] == 0) {
                    // Product cells:
                    return 108;
                } else if ([indexPath section] == 1) {
                    // Summary cells:
                    return 57;
                } else if ([indexPath section] == 2) {
                    // Notes cell:
                    return 200;
                }
            }
            break;
        }
    }
    
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *items = [self items];
    
    switch ([self mode]) {
        default:
        case PKBasketTableViewControllerModeEmpty: {
            return NSLocalizedString(@"Create new order", nil);
            break;
        }
        case PKBasketTableViewControllerModeBasket:
        case PKBasketTableViewControllerModeInvoice: {
            if ([items count] == 0) {
                if (section == 0) {
                    return NSLocalizedString(@"Search for products", nil);
                } else if (section == 1) {
                    return NSLocalizedString(@"Add products to this order", nil);
                }
            } else {
                if (section == 0) {
                    return [[NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Products", nil), (int)[items count]] uppercaseString];
                } else if (section == 1) {
                    return [NSLocalizedString(@"Totals", nil) uppercaseString];
                } else if (section == 2) {
                    return [NSLocalizedString(@"Notes", nil) uppercaseString];
                }
            }
            break;
        }
    }
    
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([self basket] || [self invoice]) {
            if (![self standardHeaderViewController]) {
                [self setStandardHeaderViewController:[[PKBasketStandardHeaderViewController alloc] initWithNibName:@"PKBasketStandardHeaderViewController" bundle:nil]];
                [[self standardHeaderViewController] setDelegate:self];
            }
            
            return [[self standardHeaderViewController] view];
        }
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 150;
    }
    return 20.0f;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PKBasketItem *item = [self basketItemAtIndexPath:indexPath];
        [[self basket] deleteBasketItem:item context:nil];
        [[self tableView] reloadData];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self invoice]) {
        return UITableViewCellEditingStyleNone;
    } else if ([self basket]) {
        if(indexPath.section == 0) {
            return UITableViewCellEditingStyleDelete;
        } else {
            return UITableViewCellEditingStyleNone;
        }
    } else {
        return UITableViewCellEditingStyleNone;
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Item Helpers

- (PKBasketItem *)basketItemAtIndexPath:(NSIndexPath*)indexPath {
    return [[self items] objectAtIndex:[indexPath row]];
}

#pragma mark - Selection Delegate

-(void)pkBasketItemTableViewCell:(UITableViewCell *)cell didSelectInteractionElement:(NSString *)name {
    NSLog(@"Trigger integration for: %@", name);
    
    // Get the index path of the cell
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    if (indexPath) {
        PKBasketItem *basketItem = [self basketItemAtIndexPath:indexPath];
        if (basketItem) {
            if ([name isEqual:@"image"]) {
                [self displayProductForBasketItem:basketItem];
            } else if([name isEqual:@"quantity"]) {
                // Show the the quantity picker ui.
                [self presentKeyPadForBasketItem:basketItem];
            } else if([name isEqual:@"price"]) {
                // Show the the price picker ui.
                [self presentKeyPadForBasketItem:basketItem];
            }
        }
    }
}

- (void)pkBasketItemTableViewCell:(UITableViewCell *)cell didSelectInteractionElement:(id)element name:(NSString *)name {
    // Dimiss the current numeric pad:
    [self dismissKeyPad];
    
    // Get the current basket item:
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    
    if (indexPath) {
        PKBasketItem *basketItem = [self basketItemAtIndexPath:indexPath];
        
        // Setup a PKNumericPad.  **TODO** Hook up basket item with keypad, not sure how this works...?
        PKKeyPadMode keypadMode = PKKeyPadModeQuantity;
        if ([name isEqualToString:@"price"]) {
            keypadMode = PKKeyPadModePrice;
        }
        
        // Create instance of pad
        PKKeyPad *keyPad = [PKKeyPad createWithBasketItem:basketItem mode:keypadMode delegate:self];
        
        // Setup a UIPopoverController, present in centre of the screen rather from a specific view
        [self setCurrentPopoverController:[[UIPopoverController alloc] initWithContentViewController:keyPad]];
        [[self currentPopoverController] presentPopoverFromRect:[element frame]
                                                         inView:cell
                                       permittedArrowDirections:UIPopoverArrowDirectionRight
                                                       animated:YES];
    }
}

- (void)pkBasketCalculationTableViewCell:(UITableViewCell *)cell didSelectInteractionElement:(id)element name:(NSString *)name {
    [self displayDeliveryCostPad:element fromCell:cell];
}

- (void)displayDeliveryCostPad:(UIView*)sender fromCell:(UITableViewCell*)cell {
    // Dismiss the current numeric pad:
    [self dismissKeyPad];
    
    PKKeyPad *keyPad = [PKKeyPad createWithIdentifier:@"delivery" mode:PKKeyPadModeDecimal delegate:self];
    
    // Setup a UIPopoverController, present in centre of the screen rather from a specific view
    [self setCurrentPopoverController:[[UIPopoverController alloc] initWithContentViewController:keyPad]];
    [[self currentPopoverController] presentPopoverFromRect:[sender frame]
                                                     inView:[sender superview]
                                   permittedArrowDirections:UIPopoverArrowDirectionRight
                                                   animated:NO];
}

#pragma mark - Display Methods

- (void)displayProductForBasketItem:(PKBasketItem *)basketItem {
    PKProductsViewController *productsViewController = [PKProductsViewController createWithBasketItem:basketItem displayMode:PKProductsDisplayModeLarge];
    [self presentViewController:[productsViewController withNavigationController] animated:YES completion:^{
    }];
}

#pragma mark - Numeric Key Pad

- (void)presentKeyPadForBasketItem:(PKBasketItem*)basketItem {
    // Dimiss the current numeric pad:
    [self dismissKeyPad];
    
    // Setup a PKNumericPad.  **TODO** Hook up basket item with keypad, not sure how this works...?
    PKKeyPad *keyPad = [PKKeyPad createWithBasketItem:basketItem delegate:self];
    
    // Setup a UIPopoverController, present in centre of the screen rather from a specific view
    [self setCurrentPopoverController:[[UIPopoverController alloc] initWithContentViewController:keyPad]];
    [[self currentPopoverController] presentPopoverFromRect:CGRectMake([self view].frame.size.width/2, [self view].frame.size.height/2, 1, 1)
                                                     inView:[self view]
                                   permittedArrowDirections:0
                                                   animated:YES];
}

- (void)dismissKeyPad {
    if ([self currentPopoverController]) {
        [[self currentPopoverController] dismissPopoverAnimated:NO];
        [self setCurrentPopoverController:nil];
    }
}

- (void)pkKeyPad:(PKKeyPad *)keyPad didEnterValue:(NSNumber *)value {
    [self dismissKeyPad];
    
    if ([[keyPad identifier] isEqualToString:@"delivery"]) {
        [[self basket] setDeliveryPrice:value];
        [[self basket] setDeliveryPriceOverride:@(YES)]; // Forcing this to YES will prevent the automatic price reduction when free shipping requirement is met
        [[self basket] save];
    }
    
    [[self tableView] reloadData];
}

#pragma mark - Event Methods

- (void)buttonSendOrderPressed:(id)sender {
    PKGenericTableViewController *genericTableView = [PKGenericTableViewController createWithType:PKGenericTableBasketContextMenu delegate:self];
    [self setCurrentPopoverController:[[UIPopoverController alloc] initWithContentViewController:[genericTableView withNavigationController]]];
    [[self currentPopoverController] presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)buttonEditModePressed:(id)sender {
    // Toggle the edit mode:
    [self setIsEditingMode:![self isEditingMode]];
    [[self tableView] reloadData];
    
    // Refresh the edit button:
    [[self buttonEdit] setTitle:[self isEditingMode] ? NSLocalizedString(@"Done", nil) : NSLocalizedString(@"Edit", nil)];
}

- (void)buttonCreateOrderPressed:(id)sender {
    [self setIsCopyingOrder:NO];
    PKCustomersViewController *customersViewController = [PKCustomersViewController createWithMode:PKCustomersViewControllerModeSelect delegate:self];
    [self presentViewController:[customersViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
    }];
}

#pragma mark - CustomerViewControllerDelegate Methods

- (void)pkCustomerSelectionDelegateSelectedCustomer:(PKCustomer *)customer andCreatedBasket:(PKBasket *)basket {
    __weak PKBasketTableViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf setBasket:basket];
        [weakSelf setupNavigationButtons];
        [[weakSelf tableView] reloadData];
    }];
}

- (void)pkCustomerSelectionDelegateSelectedCustomer:(PKCustomer *)customer andCurrency:(PKCurrency *)currency {
    __weak PKBasketTableViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if ([weakSelf isCopyingOrder]) {
            [weakSelf setIsCopyingOrder:NO];
            [weakSelf copyOrderToCustomer:customer withCurrencyCode:[currency code]];
        } else if ([weakSelf isMovingOrder]) {
            [weakSelf setIsMovingOrder:NO];
            [weakSelf moveOrderToCustomer:customer withCurrencyCode:[currency code]];
        }
    }];
}

#pragma mark - Memory Management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - General Delegate

-(void)pkGenericTableViewController:(PKGenericTableViewController *)tableViewController didSelectItemId:(int)selectedItemId {
    [tableViewController dismissViewControllerAnimated:NO completion:^{
        if ([tableViewController type] == PKGenericTableTypeSortBasketBy) {
            // Clear the sorted items:
            [self setSortedItems:nil];
            
            // Reload the table view:
            [[self tableView] reloadData];
        } else if ([tableViewController type] == PKGenericTableBasketContextMenu) {
            switch (selectedItemId) {
                case 0: {
                    // Complete order pressed, show order details
                    [self showOrderDetailsAsQuote:NO];
                    break;
                }
                case 1: {
                    // Save order pressed, close ui
                    [self saveOrder];
                    break;
                }
                case 2: {
                    // Save as quote pressed
                    [self showOrderDetailsAsQuote:YES];
                    break;
                }
                case 3: {
                    // Clear order pressed
                    [self clearOrder];
                    break;
                }
                case 4: {
                    // Cancel order pressed
                    [self cancelOrder];
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

#pragma mark - Actions

- (void) showOrderDetailsAsQuote:(BOOL)isQuote {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PKOrderDetailsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"OrderDetails"];
    [viewController setDelegate:self];
    [viewController setIsQuote:isQuote];
    [viewController setBasket:[self basket]];
    [self presentViewController:[viewController withNavigationController] animated:YES completion:nil];
}

- (void) clearOrder {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Clear Order", nil)
                                                                   message:NSLocalizedString(@"Are you sure you want to remove all items from this order?", nil)
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Remove Items", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[self basket] removeAllBasketItems];
        [[self tableView] reloadData];
    }]];
    [[alert popoverPresentationController] setBarButtonItem:[[self navigationItem] rightBarButtonItem]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveOrder {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Save Order", nil)
                                                                   message:NSLocalizedString(@"Are you sure you want to save this order?", nil)
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save Order", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[self basket] setStatus:PKBasketStatusSaved shouldSave:YES];
        [self setBasket:nil];
        
        [[self tableView] reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidSaveOrCancelOrder object:nil];
        
        [self setupNavigationButtons];
    }]];
    [[alert popoverPresentationController] setBarButtonItem:[[self navigationItem] rightBarButtonItem]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cancelOrder {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancel Order", nil)
                                                                   message:NSLocalizedString(@"Are you sure you want to cancel this order?", nil)
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel Order", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // Cancel the basket:
        [[self basket] cancelOrder];
        
        // Clear the session:
        [self setSortedItems:nil];
        [self setBasket:nil];
        
        // Dismiss if required or reload the tableview:
        if (![self tabBarController]) {
            [self buttonClosePressed:nil];
        } else {
            [[self tableView] reloadData];
        }
        
        [self setupNavigationButtons];
    }]];
    [[alert popoverPresentationController] setBarButtonItem:[[self navigationItem] rightBarButtonItem]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Standard Header Delegate(s)

-(void)pkBasketStandardHeaderViewController:(id)headerView didPressSearchButton:(BOOL)didPressSearch {
    UINavigationController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"QuickSearchNav"];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:navController animated:YES completion:NULL];
}

-(void)pkBasketStandardHeaderViewController:(PKBasketStandardHeaderViewController *)headerView didInteractWithElementName:(NSString *)elementName {
    // Clear the custom delivery price override:
    [[self basket] setDeliveryPriceOverride:@(NO)];
    PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    [[self basket] setDeliveryPrice:@([feedConfig defaultDeliveryCostForISO:[[self basket] currencyCode]])];
    
    // The element name will be "wholesale" or "carton":
    if ([elementName isEqualToString:@"carton"]) {
        // Loop the basket items:
        [[self items] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, NSUInteger idx, BOOL *stop) {
            [basketItem applyCartonPrice];
        }];
        [[self tableView] reloadData];
    } else if ([elementName isEqualToString:@"wholesale"]) {
        // Loop the basket items:
        [[self items] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, NSUInteger idx, BOOL *stop) {
            
            
            [basketItem applyWholeDiscount];
        }];
        [[self tableView] reloadData];
    } else if ([elementName isEqualToString:@"midPrice"]) {
        // Loop the basket items:
        [[self items] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, NSUInteger idx, BOOL *stop) {
            [basketItem applyMidPrice];
        }];
        [[self tableView] reloadData];
    } else if ([elementName isEqualToString:@"zeroPrice"]) {
        // Loop the basket items:
        [[self items] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, NSUInteger idx, BOOL *stop) {
            [basketItem applyZeroPrice];
        }];
        
        // Zero the delivery cost:
        [[self basket] setDeliveryPrice:@(0)];
        [[self basket] setDeliveryPriceOverride:@(YES)];
        [[self tableView] reloadData];
    } else if ([elementName isEqualToString:@"displayDiscount"]) {
        NSLog(@"Display Discount");
        
        // Hacked for demo version 29/06/2015:
        __weak PKBasketTableViewController *weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"None", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.0"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"3%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.03"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"5%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.05"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"10%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.10"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"15%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.15"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"20%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.20"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"25%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.25"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"30%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.30"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"33%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.33"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"35%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.35"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"37%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.37"]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"40%", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf applyDiscountRateToBasketItems:[NSDecimalNumber roundString:@"0.40"]];
        }]];
        
        id element = [headerView elementForName:elementName];
        if ([element isKindOfClass:[UIButton class]]) {
            [[alertController popoverPresentationController] setSourceView:[element superview]];
            [[alertController popoverPresentationController] setSourceRect:[element frame]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [[alertController popoverPresentationController] setSourceView:[[headerView view] superview]];
            [[alertController popoverPresentationController] setSourceRect:[[headerView view] frame]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)applyDiscountRateToBasketItems:(NSNumber *)discountRate {
    // Loop the basket items:
    [[self items] enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, NSUInteger idx, BOOL *stop) {
        [basketItem applyDiscountRate:discountRate];
    }];
    
    [[PKSession sharedInstance] setDiscountAmount:discountRate];
    
    [[self tableView] reloadData];
}

-(id)pkBasketStandardHeaderViewController:(PKBasketStandardHeaderViewController *)headerView requestedBasketObject:(BOOL)didRequestBasket {
    if ([self basket]) {
        return [self basket];
    } else if ([self invoice]) {
        return [self invoice];
    } else {
        return nil;
    }
    return [self basket];
}

#pragma mark - Order Details Delegate

-(void)orderDetailsViewController:(PKOrderDetailsViewController *)orderDetails didSentOrder:(BOOL)didSendOrder {
    [self setBasket:[PKBasket sessionBasket]];
    [[self tableView] reloadData];
}

#pragma mark -

@end
