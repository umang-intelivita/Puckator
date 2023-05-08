//
//  PKCurrenciesViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 13/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCurrencyViewController.h"
#import "PKCustomer.h"
#import "PKBasket+Operations.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"
#import "PKConstant.h"
#import <UIAlertView-Blocks/UIActionSheet+Blocks.h>
#import "PKLocalCustomer.h"

#define kCellHeight 80

@interface PKCurrencyViewController ()

@property (strong, nonatomic) PKLocalCustomer *localCustomer;
@property (strong, nonatomic) PKCustomer *customer;
@property (strong, nonatomic) NSArray *currencies;
@property (weak, nonatomic) id<PKCustomerSelectionDelegate>delegate;
@property (assign, nonatomic) BOOL orderCopyMode;

@end

@implementation PKCurrencyViewController

#pragma mark - Constructor Methods

+ (instancetype)createWithCustomer:(PKCustomer *)customer delegate:(id<PKCustomerSelectionDelegate>)delegate {
    return [PKCurrencyViewController createWithCustomer:customer delegate:delegate orderCopyMode:NO];
}

+ (instancetype)createWithCustomer:(PKCustomer *)customer delegate:(id<PKCustomerSelectionDelegate>)delegate orderCopyMode:(BOOL)orderCopyMode {
    PKCurrencyViewController *currencyViewController = [[PKCurrencyViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [currencyViewController setCustomer:customer];
    [currencyViewController setDelegate:delegate];
    [currencyViewController setOrderCopyMode:orderCopyMode];
    [currencyViewController setupUI];
    return currencyViewController;
    
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[[self navigationController] viewControllers] count] == 1) {
        UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonClosePressed:)];
        [[self navigationItem] setLeftBarButtonItem:buttonClose];
    }
}

- (void)buttonClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(540, 600);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[[self customer] currencyId] length] != 0) {
        int currencyId = [[[self customer] currencyId] intValue];
        
        
//        printf("%s", [self currencies].count);
//        printf("%@", [[PKCurrency currencyInfoForCurrencyCode:currencyId] objectForKey:@"symbol"]);
        
        __block BOOL currencyFound = NO;
        [[self currencies] enumerateObjectsUsingBlock:^(PKCurrency *currency, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"CurrencyOne %d", [[currency currentId] intValue]);
            NSLog(@"CurrencyTwo %d", currencyId);
            if ([[currency currentId] intValue] == currencyId) {
                currencyFound = YES;
                *stop = YES;
            }
        }];
         if (!currencyFound) {
            NSString *currencyCode = [[PKCurrency currencyInfoForCurrencyCode:currencyId] objectForKey:@"iso"];
            NSString *currencySymbol = [[PKCurrency currencyInfoForCurrencyCode:currencyId] objectForKey:@"symbol"];
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"The currency for this customer is not supported by your current feed.\n\nPlease either switch to a feed that supports %@ (%@) or setup a new customer using a supported currency.", nil), currencyCode, currencySymbol];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Currency Not Found", nil)
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([[[self navigationController] viewControllers] count] == 1) {
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                } else {
                    [[self navigationController] popViewControllerAnimated:YES];
                }
            }]];
            [self presentViewController:alertController animated:YES completion:^{
            }];
        }
    }
}

#pragma mark - Private Methods

- (void)setupUI {
    // Setup the title:
    [self setTitle:NSLocalizedString(@"Currency", nil)];
    
    // Get currencies from feed
    [self loadCurrencies];
    
    // Reload the table view:
    [[self tableView] reloadData];
}

- (void)loadCurrencies {
    PKFeedConfig *config = [[PKSession sharedInstance] currentFeedConfig];
    if ([self customer] && [[[self customer] currencyId] length] != 0) {
        int currencyId = [[[self customer] currencyId] intValue];
        PKCurrency *currency = [config currencyWithCurrencyId:currencyId];
        if (currency) {
            [self setCurrencies:@[currency]];
        }
    } else {
        [self setCurrencies:[config uniqueCurrencies]];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        [tableView setCellLayoutMarginsFollowReadableWidth:NO];
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self currencies] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Get the currency for this index
    PKCurrency *currency = [[self currencies] objectAtIndex:[indexPath row]];

    NSString *currencyCode = ([currency code] ? [currency code] : @"");
    NSString *currencySymbol = [PKCurrency symbolForCurrencyIsoCode:currencyCode];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:currencySymbol attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-DemiBold" size:40], NSForegroundColorAttributeName:[UIColor puckatorGreen]}]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"   " attributes:nil]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:currencyCode attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-DemiBold" size:20], NSForegroundColorAttributeName:[UIColor darkTextColor], NSBaselineOffsetAttributeName:@(7)}]];
    [[cell textLabel] setAttributedText:attributedString];
    
    // Create an assessory button if needed
    if (![cell accessoryView]) {        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [[button layer] setCornerRadius:4];
        [button setTag:575757];
        [button setBackgroundColor:[UIColor puckatorPrimaryColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[button titleLabel] setFont:[UIFont puckatorContentTextBold]];
        [button setUserInteractionEnabled:NO];
        
        int buttonWidth = 100;
        int buttonHeight = 50;
        int cellWidth = [[self view] bounds].size.width;
        int cellHeight = kCellHeight;
        int padding = (cellHeight - buttonHeight) * 0.5f;
        [button setFrame:CGRectMake(cellWidth - buttonWidth - padding,
                                    padding,
                                    buttonWidth,
                                    buttonHeight)];
        [button setTitle:NSLocalizedString(@"Select", nil) forState:UIControlStateNormal];
        [[cell contentView] addSubview:button];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Select Currency...", nil);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

#pragma mark - UITableViewDelegate Methods

- (void)setCurrency:(PKCurrency *)currency withDiscount:(NSNumber *)discount {
    if ([self orderCopyMode]) {
        if ([[self delegate] respondsToSelector:@selector(pkCustomerSelectionDelegateSelectedCustomer:andCurrency:)]) {
            [[self delegate] pkCustomerSelectionDelegateSelectedCustomer:[self customer] andCurrency:currency];
        }
        return;
    }
    
    [self showHud:NSLocalizedString(@"Creating Order", nil) withSubtitle:nil animated:YES interaction:NO];
    
    [FSThread runInBackground:^{        
        [[PKSession sharedInstance] setDiscountAmount:discount];
        
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkCustomerSelectionDelegateSelectedCustomer:andCreatedBasket:)]) {
            PKBasket *basket = [PKBasket sessionBasket];
            
            // If there is a session basket already save it:
            if (basket) {
                [basket setStatus:PKBasketStatusSaved shouldSave:YES];
                basket = nil;
            }
            
            // Setup the current customer:
            [[PKSession sharedInstance] setCurrentCustomer:[self customer] andCurrencyCode:[[currency code] uppercaseString]];
            
            // Clear all the open baskets for the user:
            [PKBasket cancelAllOpenBasketsForCustomer:[self customer]];
            
            // Setup the basket:
            if (!basket) {
                // Create a basket:
                basket = [PKBasket createSessionBasketForCustomer:[[PKSession sharedInstance] currentCustomer]
                                                       feedNumber:[[[PKSession sharedInstance] currentFeedConfig] number]
                                                          context:nil];
            }
            
            // Set the status of the basket:
            [basket setStatus:PKBasketStatusOpen shouldSave:YES];
            
            // Set the currency on the basket
            if (basket) {
                [basket setCurrencyCode:[currency code]];
                [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
            }
            
            // Update the local customer:
            if ([self customer]) {
                PKLocalCustomer *localCustomer = [[self customer] coreDataCustomer];
                if (localCustomer) {
                    [localCustomer setCurrencyId:[[currency currentId] uppercaseString]];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                }
            }
            
            [FSThread runOnMain:^{
                [self hideHudAnimated:NO];
                
                // Dispatch a notification to inform the system that a currency change occured
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeCurrency object:nil];
                
                // Inform the delegate of the change
                [[self delegate] pkCustomerSelectionDelegateSelectedCustomer:[self customer] andCreatedBasket:basket];
            }];
            
        } else {
            NSLog(@"[%@] - pkCustomerSelectionDelegateSelectedCustomer:andCreatedBasket: delegate methods missing", [self class]);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get the currency code
    PKCurrency *currency = [[self currencies] objectAtIndex:[indexPath row]];
    
    // Hacked for demo version 29/06/2015:
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)[cell viewWithTag:575757];
    
    RIButtonItem *itemNone = [RIButtonItem itemWithLabel:NSLocalizedString(@"-", nil) action:^{
        [self setCurrency:currency withDiscount:@(0)];
    }];
    
    RIButtonItem *item5 = [RIButtonItem itemWithLabel:NSLocalizedString(@"A", nil) action:^{
        [self setCurrency:currency withDiscount:@(5)];
    }];
    
    RIButtonItem *item10 = [RIButtonItem itemWithLabel:NSLocalizedString(@"B", nil) action:^{
        [self setCurrency:currency withDiscount:@(10)];
    }];
    
    RIButtonItem *item15 = [RIButtonItem itemWithLabel:NSLocalizedString(@"C", nil) action:^{
        [self setCurrency:currency withDiscount:@(15)];
    }];
    
    RIButtonItem *item20 = [RIButtonItem itemWithLabel:NSLocalizedString(@"D", nil) action:^{
        [self setCurrency:currency withDiscount:@(20)];
    }];
    
    RIButtonItem *item25 = [RIButtonItem itemWithLabel:NSLocalizedString(@"E", nil) action:^{
        [self setCurrency:currency withDiscount:@(25)];
    }];
    
    RIButtonItem *item30 = [RIButtonItem itemWithLabel:NSLocalizedString(@"F", nil) action:^{
        [self setCurrency:currency withDiscount:@(30)];
    }];
    
    RIButtonItem *item33 = [RIButtonItem itemWithLabel:NSLocalizedString(@"G", nil) action:^{
        [self setCurrency:currency withDiscount:@(33)];
    }];
    
    RIButtonItem *item35 = [RIButtonItem itemWithLabel:NSLocalizedString(@"H", nil) action:^{
        [self setCurrency:currency withDiscount:@(35)];
    }];
    
    RIButtonItem *item37 = [RIButtonItem itemWithLabel:NSLocalizedString(@"I", nil) action:^{
        [self setCurrency:currency withDiscount:@(37)];
    }];
    
    RIButtonItem *item40 = [RIButtonItem itemWithLabel:NSLocalizedString(@"J", nil) action:^{
        [self setCurrency:currency withDiscount:@(40)];
    }];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     cancelButtonItem:nil
                                                destructiveButtonItem:nil
                                                     otherButtonItems:
                                  itemNone,
                                  item5,
                                  item10,
                                  item15,
                                  item20,
                                  item25,
                                  item30,
                                  item33,
                                  item35,
                                  item37,
                                  item40, nil];
    [actionSheet showFromRect:[button frame] inView:[button superview] animated:YES];
}

#pragma mark -

@end
