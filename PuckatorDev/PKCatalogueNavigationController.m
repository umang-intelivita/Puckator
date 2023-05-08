//
//  PKCatalogueNavigationController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 03/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCatalogueNavigationController.h"
#import "UIView+FrameHelper.h"
#import "UIFont+Puckator.h"
#import "UITabBarController+Puckator.h"
#import "PKPopoverNavigationController.h"
#import "FSEnterpriseUpdateCheckViewController.h"
#import "UIColor+Puckator.h"
#import "PKCustomersViewController.h"
#import "PKConstant.h"
#import "PKBasket+Operations.h"
#import "PKOrderSyncViewController.h"
#import "PKCustomerViewController.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import "PKAgentEditViewController.h"
#import "PKFeedsTableViewController.h"
#import "PKProductPrice.h"

#define kCatalogueNavigationButtonPadding           10
#define kCatalogueNavigationButtonPaddingOffset     -5

@interface PKCatalogueNavigationController ()

@property (strong, nonatomic) UIButton *buttonNewProducts;
@property (strong, nonatomic) UIButton *buttonNewAvaliableProducts;
@property (strong, nonatomic) UIButton *buttonInStockProducts;
@property (strong, nonatomic) UIButton *buttonTopProducts;
@property (strong, nonatomic) UIButton *buttonTopProductsGlobal;
@property (strong, nonatomic) UIButton *buttonSearch;
@property (strong, nonatomic) UIButton *buttonSort;
@property (strong, nonatomic) UIButton *buttonBrowse;
@property (strong, nonatomic) UIButton *buttonMenu;
@property (strong, nonatomic) UIButton *buttonOrder;
@property (strong, nonatomic) UIButton *buttonNotes;
@property (strong, nonatomic) UIButton *buttonBulkAdd;
@property (strong, nonatomic) UIButton *buttonBack;
@property (strong, nonatomic) UIButton *buttonProductAdd;
@property (strong, nonatomic) UIButton *buttonAddCategory;

// Search:
@property (strong, nonatomic) PKSearchParameters *searchParams;

@end

@implementation PKCatalogueNavigationController

#pragma mark - Helper Methods

- (CGFloat)barHeight {
    return [[self navigationBar] height];
}

- (CGFloat)buttonSize {
    return [self barHeight];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    [self setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBasketStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOrderButtons:) name:kNotificationBasketStatusChanged object:nil];
}

#pragma mark - Overidden Methods

- (void)setButtonDelegate:(id<PKCatalogueNavigationControllerButtonDelegate, PKBrowseTableViewControllerDelegate, PKSearchDelegate, PKGenericTableDelegate>)buttonDelegate {
    _buttonDelegate = buttonDelegate;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addCatalogueNavigationButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Private Methods

- (void)addCatalogueNavigationButtons {
    [self addBrowseNavigationButton];
//    [self addNewProductsNavigationButton];
    [self addNewAvaliableProductsNavigationButton];
//    [self addInStockProductsNavigationButton];
//    [self addTopProductsNavigationButton];
//    [self addTopProductsGlobalNavigationButton];
    [self addSearchNavigationButton];
    [self addSortNavigationButton];
    [self addCategoryAddNavigationButton];
    [self addMenuNavigationButton];
    [self addOrderNavigationButton];
    [self addNotesNavigationButton];
    [self addBulkAddNavigationButton];
//    [self addProductAddNavigationButton];
    [self addBackNavigationButton];
}

- (void)addBackNavigationButton {
    if (![self buttonBack]) {
        [self setButtonBack:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[self buttonBack] setImage:[UIImage imageNamed:@"ToolbarBack"] forState:UIControlStateNormal];
        [[self buttonBack] sizeToFit];
        [[self buttonBack] addTarget:self action:@selector(buttonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonBack] setWidth:40 andHeight:[[self navigationBar] height]];
        [[self navigationBar] addSubview:[self buttonBack]];
    }
}

- (void)addBrowseNavigationButton {
    if (![self buttonBrowse]) {
        [self setButtonBrowse:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[self buttonBrowse] setTitle:NSLocalizedString(@"Browse", nil) forState:UIControlStateNormal];
        [[self buttonBrowse] addTarget:self action:@selector(buttonBrowsePressed:) forControlEvents:UIControlEventTouchUpInside];
        [[[self buttonBrowse] titleLabel] setFont:[UIFont puckatorFontMediumWithSize:17]];
        
        // Show as attributed string
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Browse", nil) attributes:@{NSFontAttributeName:[UIFont puckatorFontMediumWithSize:17], NSForegroundColorAttributeName:[UIColor puckatorGreen]}]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" \u25BC" attributes:@{NSFontAttributeName:[UIFont puckatorFontMediumWithSize:15], NSForegroundColorAttributeName:[UIColor puckatorGreen]}]];
        
        [[self buttonBrowse] setAttributedTitle:attributedString forState:UIControlStateNormal];
        [[self buttonBrowse] sizeToFit];
        [[self buttonBrowse] setHeight:[self buttonSize]];
        [[self buttonBrowse] setX:60];
        [[self navigationBar] addSubview:[self buttonBrowse]];
    }
}

- (void)addMenuNavigationButton {
    if (![self buttonMenu]) {
        [self setButtonMenu:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[self buttonMenu] setTitle:NSLocalizedString(@"Menu", nil) forState:UIControlStateNormal];
        [[self buttonMenu] addTarget:self action:@selector(buttonMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[[self buttonMenu] titleLabel] setFont:[UIFont puckatorFontMediumWithSize:17]];
        [[self buttonMenu] sizeToFit];
        [[self buttonMenu] setHeight:[self buttonSize]];
        [[self buttonMenu] setX:[[self navigationBar] width] - [[self buttonMenu] width] - 20];
        [[self navigationBar] addSubview:[self buttonMenu]];
    }
}

- (void)addNewProductsNavigationButton {
    if (![self buttonNewProducts]) {
        int x = CGRectGetMaxX([[self buttonBrowse] frame]) + kCatalogueNavigationButtonPadding;
        [self setButtonNewProducts:[[UIButton alloc] initWithFrame:CGRectMake(x, 0, [self buttonSize], [self buttonSize])]];
        [[self buttonNewProducts] addTarget:self action:@selector(buttonNewProductsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonNewProducts] setImage:[UIImage imageNamed:@"ToolbarStar"] forState:UIControlStateNormal];
        [[self navigationBar] addSubview:[self buttonNewProducts]];
    }
}

- (void)addNewAvaliableProductsNavigationButton {
    if (![self buttonNewAvaliableProducts]) {
//        int x = CGRectGetMaxX([[self buttonNewProducts] frame]) + kCatalogueNavigationButtonPaddingOffset;
        int x = CGRectGetMaxX([[self buttonBrowse] frame]) + (kCatalogueNavigationButtonPaddingOffset);
        [self setButtonNewAvaliableProducts:[[UIButton alloc] initWithFrame:CGRectMake(x + 10, 0, [self buttonSize], [self buttonSize])]];
        [[self buttonNewAvaliableProducts] addTarget:self action:@selector(buttonNewAvaliableProductsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonNewAvaliableProducts] setImage:[UIImage imageNamed:@"ToolbarDropdown"] forState:UIControlStateNormal];
        [[self navigationBar] addSubview:[self buttonNewAvaliableProducts]];
    }
}

- (void)addInStockProductsNavigationButton {
    if (![self buttonInStockProducts]) {
        int x = CGRectGetMaxX([[self buttonNewAvaliableProducts] frame]) + kCatalogueNavigationButtonPaddingOffset;
        [self setButtonInStockProducts:[[UIButton alloc] initWithFrame:CGRectMake(x, 0, [self buttonSize], [self buttonSize])]];
        [[self buttonInStockProducts] addTarget:self action:@selector(buttonInStockProductsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonInStockProducts] setImage:[UIImage imageNamed:@"ToolbarInStock"] forState:UIControlStateNormal];
        [[self navigationBar] addSubview:[self buttonInStockProducts]];
    }
}

- (void)addTopProductsNavigationButton {
    if (![self buttonTopProducts]) {
        int x = CGRectGetMaxX([[self buttonInStockProducts] frame]) + kCatalogueNavigationButtonPaddingOffset;
        [self setButtonTopProducts:[[UIButton alloc] initWithFrame:CGRectMake(x, 0, [self buttonSize], [self buttonSize])]];
        [[self buttonTopProducts] addTarget:self action:@selector(buttonTopProductsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonTopProducts] setImage:[UIImage imageNamed:@"ToolbarFlag"] forState:UIControlStateNormal];
        [[self navigationBar] addSubview:[self buttonTopProducts]];
    }
}

- (void)addTopProductsGlobalNavigationButton {
    if (![self buttonTopProductsGlobal]) {
        int x = CGRectGetMaxX([[self buttonTopProducts] frame]) + kCatalogueNavigationButtonPaddingOffset;
        [self setButtonTopProductsGlobal:[[UIButton alloc] initWithFrame:CGRectMake(x, 0, [self buttonSize], [self buttonSize])]];
        [[self buttonTopProductsGlobal] addTarget:self action:@selector(buttonTopProductsGlobalPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonTopProductsGlobal] setImage:[UIImage imageNamed:@"ToolbarGlobe"] forState:UIControlStateNormal];
        [[self buttonTopProductsGlobal] setTransform:CGAffineTransformMakeScale(0.75, 0.75)];
        [[self navigationBar] addSubview:[self buttonTopProductsGlobal]];
    }
}

- (void)addSortNavigationButton {
    // Add the notification for displaying the sort menu:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRequestSortMenu object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonSortPressed:) name:kNotificationRequestSortMenu object:nil];
    
    if (![self buttonSort]) {
        int x = CGRectGetMaxX([[self buttonSearch] frame]);
        [self setButtonSort:[[UIButton alloc] initWithFrame:CGRectMake(x, 0, [self buttonSize], [self buttonSize])]];
        [[self buttonSort] addTarget:self action:@selector(buttonSortPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonSort] setImage:[UIImage imageNamed:@"ToolbarSort"] forState:UIControlStateNormal];
        [[self buttonSort] setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        [[self navigationBar] addSubview:[self buttonSort]];
    }
}

- (void)addSearchNavigationButton {
    if (![self buttonSearch]) {
        int x = CGRectGetMaxX([[self buttonNewAvaliableProducts] frame]) + kCatalogueNavigationButtonPaddingOffset;
        [self setButtonSearch:[[UIButton alloc] initWithFrame:CGRectMake(x, 0, [self buttonSize], [self buttonSize])]];
        [[self buttonSearch] addTarget:self action:@selector(buttonSearchPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonSearch] setImage:[UIImage imageNamed:@"ToolbarSearch"] forState:UIControlStateNormal];
        [[self navigationBar] addSubview:[self buttonSearch]];
    }
}

- (void)addCategoryAddNavigationButton {
    if (![self buttonAddCategory]) {
        int x = CGRectGetMaxX([[self buttonSort] frame]) + kCatalogueNavigationButtonPaddingOffset;
        [self setButtonAddCategory:[[UIButton alloc] initWithFrame:CGRectMake(x, 0, [self buttonSize], [self buttonSize])]];
        [[self buttonAddCategory] addTarget:self action:@selector(buttonAddCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonAddCategory] setImage:[UIImage imageNamed:@"ToolbarProductAdd"] forState:UIControlStateNormal];
        [[self navigationBar] addSubview:[self buttonAddCategory]];
    }
}

//PKCatalogueButtonTypeAddCategory


- (void)addNotesNavigationButton {
    if (![self buttonNotes]) {
        int x = CGRectGetMinX([[self buttonOrder] frame]);
        [self setButtonNotes:[[UIButton alloc] initWithFrame:CGRectMake(x - ([self buttonSize] * 1.25f), 0, [self buttonSize], [self buttonSize])]];
        [[self buttonNotes] addTarget:self action:@selector(buttonNotesPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonNotes] setImage:[UIImage imageNamed:@"ToolbarNotes"] forState:UIControlStateNormal];
        [[self buttonNotes] setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        [[self navigationBar] addSubview:[self buttonNotes]];
        [self refreshOrderButtons:nil];
    }
}

- (void)addBulkAddNavigationButton {
    if (![self buttonBulkAdd]) {
        int x = CGRectGetMinX([[self buttonNotes] frame]);
        [self setButtonBulkAdd:[[UIButton alloc] initWithFrame:CGRectMake(x - ([self buttonSize]), 0, [self buttonSize], [self buttonSize])]];
        [[self buttonBulkAdd] addTarget:self action:@selector(buttonBulkAddPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonBulkAdd] setImage:[UIImage imageNamed:@"ToolbarBulkAdd"] forState:UIControlStateNormal];
        [[self navigationBar] addSubview:[self buttonBulkAdd]];
        [self refreshOrderButtons:nil];
    }
}

//- (void)addProductAddNavigationButton {
//    if (![self buttonProductAdd]) {
//        int x = CGRectGetMinX([[self buttonNotes] frame]);
//        [self setButtonProductAdd:[[UIButton alloc] initWithFrame:CGRectMake(x - [self buttonSize], 0, [self buttonSize], [self buttonSize])]];
//        [[self buttonProductAdd] addTarget:self action:@selector(buttonNotesPressed:) forControlEvents:UIControlEventTouchUpInside];
//        [[self buttonProductAdd] setImage:[UIImage imageNamed:@"ToolbarProductAdd"] forState:UIControlStateNormal];
//        [[self navigationBar] addSubview:[self buttonProductAdd]];
//    }
//}

- (void)addOrderNavigationButton {
    if (![self buttonOrder]) {
        [self setButtonOrder:[UIButton buttonWithType:UIButtonTypeCustom]];
        
        UIFont *labelFont = [UIFont puckatorFontMediumWithSize:17];
        [[[self buttonOrder] titleLabel] setFont:labelFont];
        [[[self buttonOrder] titleLabel] setAdjustsFontSizeToFitWidth:YES];
        
        // Determine which title is larger, either 'View Order' or 'New Order'.
        // This is important when sizing the button because in some languages they
        // are the opposite to in English so it caused truncation
        NSString *viewOrder = NSLocalizedString(@"View Order", nil);
        NSString *newOrder = NSLocalizedString(@"New Order", nil);
        CGSize viewOrderSize = [viewOrder sizeWithAttributes:@{NSFontAttributeName : labelFont}];
        CGSize newOrderSize = [newOrder sizeWithAttributes:@{NSFontAttributeName : labelFont}];
        
        if (newOrderSize.width > viewOrderSize.width) {
            [[self buttonOrder] setTitle:newOrder forState:UIControlStateNormal];
            [[self buttonOrder] sizeToFit];
        } else {
            [[self buttonOrder] setTitle:viewOrder forState:UIControlStateNormal];
            [[self buttonOrder] sizeToFit];
            [[self buttonOrder] setTitle:newOrder forState:UIControlStateNormal];
        }
        
        [[self buttonOrder] addTarget:self action:@selector(buttonOrderPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonOrder] setHeight:[self buttonSize]];
        [[self buttonOrder] setX:CGRectGetMinX([[self buttonMenu] frame]) - [[self buttonOrder] width] - kCatalogueNavigationButtonPadding];
        [[self navigationBar] addSubview:[self buttonOrder]];
        [self refreshOrderButtons:nil];
    }
}

- (void)updateButtonDelegateWithButtonType:(PKCatalogueButtonType)buttonType sender:(id)sender {
    if ([[self buttonDelegate] respondsToSelector:@selector(pkCatalogueNavigationController:didPressButtonType:sender:)]) {
        [[self buttonDelegate] pkCatalogueNavigationController:self didPressButtonType:buttonType sender:sender];
    } else if ([[self buttonDelegate] respondsToSelector:@selector(pkCatalogueNavigationController:didPressButtonType:)]) {
        [[self buttonDelegate] pkCatalogueNavigationController:self didPressButtonType:buttonType];
    }
}

- (void)refreshOrderButtons:(NSNotification *)notification {
    PKBasket *basket = nil;
    
    if ([[notification object] isKindOfClass:[PKBasket class]]) {
        basket = (PKBasket *)[notification object];
    } else {
        basket = [PKBasket sessionBasket];
    }
    
    [FSThread runOnMain:^{
        if (basket && [basket status] == PKBasketStatusOpen) {
            [[self buttonOrder] setTitle:NSLocalizedString(@"View Order", nil) forState:UIControlStateNormal];
            [[self buttonNotes] setEnabled:YES];
            [[self buttonBulkAdd] setEnabled:YES];
        } else {
            [[self buttonOrder] setTitle:NSLocalizedString(@"New Order", nil) forState:UIControlStateNormal];
            [[self buttonNotes] setEnabled:NO];
            [[self buttonBulkAdd] setEnabled:NO];
        }
    }];
}

#pragma mark - Event Methods

- (void)buttonBackPressed:(id)sender {
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeBack sender:sender];
}

- (void)buttonBulkAddPressed:(id)sender {
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeBulkAdd sender:sender];
}

- (void)buttonNotesPressed:(id)sender {
    PKNotesViewController *notesViewController = [PKNotesViewController create];
    
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:[notesViewController withNavigationController]];
    [popoverController presentPopoverFromRect:[sender frame]
                                       inView:[sender superview]
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (void)buttonBrowsePressed:(id)sender {
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeBrowse sender:sender];
    
    // Display the browse table view controller:
    PKBrowseTableViewController *browseTableViewController = [PKBrowseTableViewController createWithDelegate:[self buttonDelegate]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:browseTableViewController];
    
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    [popoverController presentPopoverFromRect:[sender frame]
                                       inView:[sender superview]
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (void)buttonNewProductsPressed:(id)sender {
    [self setSearchParams:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(PKSearchParameterTypeDateAdded * -1) forKey:@"PKSortOption"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeNewProducts sender:sender];
}

- (void)buttonNewAvaliableProductsPressed:(id)sender {
    [self setSearchParams:nil];
    
    __weak PKCatalogueNavigationController *weakSelf = self;
    
    NSString *title = NSLocalizedString(@"Product Quick Filters", nil);

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIPopoverPresentationController *popoverController = alertController.popoverPresentationController;
    popoverController.sourceView = sender;
    popoverController.sourceRect = [sender bounds];
    
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"New & Coming Soon", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] setObject:@(PKSearchParameterTypeDateAdded * -1) forKey:@"PKSortOption"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf updateButtonDelegateWithButtonType:PKCatalogueButtonTypeNewProducts sender:sender];
        }];
        action;
    })];
    
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"New Products in Stock", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] setObject:@(PKSearchParameterTypeDateAdded * -1) forKey:@"PKSortOption"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf updateButtonDelegateWithButtonType:PKCatalogueButtonTypeNewAvailableProducts sender:sender];
        }];
        action;
    })];
    
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Top Sellers", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] setObject:@(PKSearchParameterTypeTotalSold * -1) forKey:@"PKSortOption"];
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:kPKUserDefaultsGlobalRanks];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf updateButtonDelegateWithButtonType:PKCatalogueButtonTypeTopProducts sender:sender];
        }];
        action;
    })];
    
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Top Sellers Globally", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] setObject:@(PKSearchParameterTypeTotalSold * -1) forKey:@"PKSortOption"];
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kPKUserDefaultsGlobalRanks];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf updateButtonDelegateWithButtonType:PKCatalogueButtonTypeTopProducts sender:sender];
        }];
        action;
    })];
    
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"In-stock Date", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf buttonInStockProductsPressed:sender];
        }];
        action;
    })];
    
    if ([[PKSession sharedInstance] currentCustomer]) {
        [alertController addAction:({
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Customer Products", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [weakSelf buttonCustomerProductsPressed:sender];
            }];
            action;
        })];
    }
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)buttonCustomerProductsPressed:(id)sender {
    [self setSearchParams:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(PKSearchParameterTypeDateAdded * -1) forKey:@"PKSortOption"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeCustomerProducts sender:sender];
}

- (void)buttonInStockProductsPressed:(id)sender {
    [self setSearchParams:nil];
    
    // Display actionsheet:
    NSString *title = NSLocalizedString(@"In-stock Products", nil);
    NSString *message = NSLocalizedString(@"Find products that will be in-stock by:", nil);;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    [picker setDatePickerMode:UIDatePickerModeDate];
    [picker setY:60];
    
    NSDate *date = [NSDate date];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"PKInStockBy"] isKindOfClass:[NSDate class]]) {
        date = [[NSUserDefaults standardUserDefaults] objectForKey:@"PKInStockBy"];
    }
    [picker setDate:date];
    
    [alertController.view addSubview:picker];
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Find", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSDate *date = [picker date];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"PKInStockBy"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeInStockProducts sender:sender];
        }];
        action;
    })];
    UIPopoverPresentationController *popoverController = alertController.popoverPresentationController;
    popoverController.sourceView = sender;
    popoverController.sourceRect = [sender bounds];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:alertController.view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:330];
    [[alertController view] addConstraint:constraint];
    
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

- (void)buttonTopProductsPressed:(id)sender {
    [self setSearchParams:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(PKSearchParameterTypeTotalSold * -1) forKey:@"PKSortOption"];
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:kPKUserDefaultsGlobalRanks];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeTopProducts sender:sender];
}

- (void)buttonTopProductsGlobalPressed:(id)sender {
    [self setSearchParams:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(PKSearchParameterTypeTotalSold * -1) forKey:@"PKSortOption"];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kPKUserDefaultsGlobalRanks];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeTopProducts sender:sender];
}

- (void)buttonSearchPressed:(id)sender {
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeSearch sender:sender];
    [self displaySearch:sender];
}

- (void)buttonAddCategoryPressed:(id)sender {
    if ([[PKSession sharedInstance] customCategoryBar]) {
        NSString *title = NSLocalizedString(@"Error", nil);
        NSString *message = NSLocalizedString(@"You can't access this option when editing a custom category.", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:^{
        }];
        return;
    }
    
    if ([[PKSession sharedInstance] currentCustomer]) {
        NSString *title = NSLocalizedString(@"Error", nil);
        NSString *message = NSLocalizedString(@"You can't add a custom category while you have an open order.", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:^{
        }];
        return;
    }
    
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeAddCategory sender:sender];
}

- (void)buttonSortPressed:(id)sender {
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeSort sender:sender];
    [self displaySort:sender];
}

- (void)buttonMenuPressed:(id)sender {
    if ([[PKSession sharedInstance] customCategoryBar]) {
        NSString *title = NSLocalizedString(@"Error", nil);
        NSString *message = NSLocalizedString(@"You can't access the menu when editing a custom category.", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:^{
        }];
        return;
    }
    
    [self updateButtonDelegateWithButtonType:PKCatalogueButtonTypeMenu sender:sender];
    [self displayMenu:sender];
}

- (void)buttonOrderPressed:(id)sender {
    if ([[PKSession sharedInstance] customCategoryBar]) {
        NSString *title = NSLocalizedString(@"Error", nil);
        NSString *message = NSLocalizedString(@"You can't start an order when editing a custom category.", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:^{
        }];
        return;
    }
    
    if ([[PKSession sharedInstance] currentCustomer]) {
        [[self tabBarController] setSelectedTab:UITabBarControllerTabOrder];
        return;
    }
    
    // Display the 'trade order' action sheet:
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [[alertController popoverPresentationController] setSourceView:[sender superview]];
    [[alertController popoverPresentationController] setSourceRect:[sender frame]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"This is a show order", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PKSession sharedInstance] setIsShowOrder:YES];
        PKCustomersViewController *customersViewController = [PKCustomersViewController createWithMode:PKCustomersViewControllerModeSelect delegate:self];
        [self presentViewController:[customersViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"This is a normal order", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PKSession sharedInstance] setIsShowOrder:NO];
        PKCustomersViewController *customersViewController = [PKCustomersViewController createWithMode:PKCustomersViewControllerModeSelect delegate:self];
        [self presentViewController:[customersViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
        }];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Display Methods

- (void)displaySearch:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    PKSearchTableViewController *searchTableViewController = (PKSearchTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"searchParameters"];
    [searchTableViewController setSearchDelegate:self];
    [searchTableViewController setSearchParameters:[self searchParams]];
    
    PKPopoverNavigationController *navController = [[PKPopoverNavigationController alloc] initWithRootViewController:searchTableViewController];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    [navController setPopoverReference:popoverController];
    [popoverController presentPopoverFromRect:[sender frame]
                                       inView:[sender superview]
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (void)displaySort:(id)sender {
    PKGenericTableType sortType = PKGenericTableTypeSortProductsBy;
    
    if ([[self buttonDelegate] respondsToSelector:@selector(pkCatalogueNavigationControlRequestsSortType:)]) {
        sortType = [[self buttonDelegate] pkCatalogueNavigationControlRequestsSortType:self];
    }
    
    // Show filters, the last selected filter is saved to NSUserDefaults
    PKGenericTableViewController *filterTableViewController = [PKGenericTableViewController createWithType:sortType
                                                                                                  delegate:self];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:[filterTableViewController withNavigationController]];
    [popoverController presentPopoverFromRect:[[self buttonSort] frame]
                                       inView:[[self buttonSort] superview]
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (void)addDebugProductsAmount:(int)amount {
    NSArray *products = [PKProduct allProductsForFeedConfig:nil inContext:nil];
    PKBasket *basket = [[PKSession sharedInstance] basket];
    [products enumerateObjectsUsingBlock:^(PKProduct *product, NSUInteger idx, BOOL * _Nonnull stop) {
        if (amount > 0 && idx == amount) {
            *stop = YES;
        }
        PKProductPrice *price = [[[product prices] allObjects] firstObject];
        [basket addOrUpdateProduct:product
                          quantity:[price quantity]
                             price:[price value]
                    customPriceSet:YES
                productPriceObject:[[[product prices] allObjects] firstObject]
                       incremental:YES
                           context:nil];
    }];
}

- (void)displayMenu:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [[alertController popoverPresentationController] setSourceView:[sender superview]];
    [[alertController popoverPresentationController] setSourceRect:[sender frame]];
    
    if (kDebugEnableMenu) {
        UIAlertAction *actionCrash = [UIAlertAction actionWithTitle:@"-- Crash --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray *array = [NSArray array];
            [array objectAtIndex:0];
        }];
        [alertController addAction:actionCrash];
        
        UIAlertAction *actionDeleteCustomCategories = [UIAlertAction actionWithTitle:@"-- Delete Custom Categories --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [PKCategory deleteCustomCategories];
        }];
        [alertController addAction:actionDeleteCustomCategories];
        
        if ([[PKSession sharedInstance] basket]) {
            UIAlertAction *action100 = [UIAlertAction actionWithTitle:@"-- Add 100 Products --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addDebugProductsAmount:100];
            }];
            [alertController addAction:action100];
            UIAlertAction *action250 = [UIAlertAction actionWithTitle:@"-- Add 250 Products --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addDebugProductsAmount:250];
            }];
            [alertController addAction:action250];
            UIAlertAction *action500 = [UIAlertAction actionWithTitle:@"-- Add 500 Products --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addDebugProductsAmount:500];
            }];
            [alertController addAction:action500];
            UIAlertAction *action1000 = [UIAlertAction actionWithTitle:@"-- Add 1000 Products --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addDebugProductsAmount:1000];
            }];
            [alertController addAction:action1000];
            UIAlertAction *action2500 = [UIAlertAction actionWithTitle:@"-- Add 2500 Products --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addDebugProductsAmount:2500];
            }];
            [alertController addAction:action2500];
            UIAlertAction *action5000 = [UIAlertAction actionWithTitle:@"-- Add 5000 Products --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addDebugProductsAmount:5000];
            }];
            [alertController addAction:action5000];
            UIAlertAction *actionAll = [UIAlertAction actionWithTitle:@"-- Add All Products --" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addDebugProductsAmount:-1];
            }];
            [alertController addAction:actionAll];
        }
    }

    UIAlertAction *viewCustomers = [UIAlertAction actionWithTitle:NSLocalizedString(@"View Customers", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[self tabBarController] setSelectedTab:UITabBarControllerTabCustomers];
    }];
    [alertController addAction:viewCustomers];
    
    NSArray *recentOrders = [PKBasket recentBasketsForFeedNumber:nil context:nil];
    if ([recentOrders count] != 0) {
        UIAlertAction *recentOrdersAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Recent Orders (%d)", nil), (int)[recentOrders count]] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            PKCustomerViewController *customerViewController = [PKCustomerViewController createWithOrders:recentOrders withOrderType:PKCustomerViewControllerOrderTypeRecent];
            [self presentViewController:[customerViewController withNavigationController] animated:YES completion:^{
            }];
        }];
        [alertController addAction:recentOrdersAction];
    }
    
    NSArray *openBaskets = [PKBasket openBasketsForFeedNumber:nil includeErrored:NO context:nil];
    if ([openBaskets count] != 0) {
        UIAlertAction *openOrders = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Open Orders (%d)", nil), (int)[openBaskets count]] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            PKCustomerViewController *customerViewController = [PKCustomerViewController createWithOrders:openBaskets withOrderType:PKCustomerViewControllerOrderTypeOpen];
            [self presentViewController:[customerViewController withNavigationController] animated:YES completion:^{
            }];
        }];
        [alertController addAction:openOrders];
    }

    UIAlertAction *sync = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sync Catalogue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self displaySyncViewController];
    }];
    [alertController addAction:sync];

    int unsentOrderCount = (int)[[PKOrderSyncViewController orderFilenames] count];
    NSString *ordersInOutbox = [NSString stringWithFormat:@" (📤%d)", unsentOrderCount];
    if(unsentOrderCount == 0) {
        ordersInOutbox = @"";
    }
    UIAlertAction *syncOrders = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Sync Orders & Quotes", nil), ordersInOutbox] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelector:@selector(displayOrderSyncController) withObject:nil afterDelay:1.2];
        //[self displayOrderSyncController];
    }];
    [alertController addAction:syncOrders];
    
    UIAlertAction *settings = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self displayAccountViewController];
        
    }];
    [alertController addAction:settings];
    
    UIAlertAction *language = [UIAlertAction actionWithTitle:NSLocalizedString(@"Change Language", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        PKLanguageSelectController *languageSelectController = [[PKLanguageSelectController alloc] initWithStyle:UITableViewStyleGrouped];
        [self presentViewController:[languageSelectController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
        }];
    }];
    [alertController addAction:language];

    UIAlertAction *update = [UIAlertAction actionWithTitle:NSLocalizedString(@"Check for Update", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self checkForUpdates:nil];
    }];
    [alertController addAction:update];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)displayAccountViewController {
    PKAgentEditViewController *agentViewController = [PKAgentEditViewController create];
    [agentViewController setIsEditMode:YES];
    [self presentViewController:[agentViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
    }];
}

- (void)displaySyncViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:[NSBundle mainBundle]];
    //id viewController = [storyboard instantiateInitialViewController];
    id viewController = [storyboard instantiateViewControllerWithIdentifier:@"SyncController"];
    [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:[viewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
    }];
}

- (void) displayOrderSyncController {
    PKOrderSyncViewController *orderSyncVc = [PKOrderSyncViewController create];
    UINavigationController *navController = [orderSyncVc withNavigationController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[[self viewControllers] lastObject] presentViewController:navController animated:YES completion:nil];
}

#pragma mark - PKGenericTableViewControllerDelegate Methods

- (void)pkGenericTableViewController:(PKGenericTableViewController *)tableViewController didSelectItemId:(int)selectedItemId {
    [tableViewController dismissViewControllerAnimated:YES completion:^{
        if ([[self buttonDelegate] respondsToSelector:@selector(pkGenericTableViewController:didSelectItemId:)]) {
            [[self buttonDelegate] pkGenericTableViewController:tableViewController didSelectItemId:selectedItemId];
        }
    }];
}

#pragma mark - PKSearchDelegate Methods

- (BOOL)pkSearchTableViewController:(PKSearchTableViewController *)searchTableViewController didStartSearchWithParameters:(PKSearchParameters *)params {
    if ([[self buttonDelegate] respondsToSelector:@selector(pkSearchTableViewController:didStartSearchWithParameters:)]) {
        return [[self buttonDelegate] pkSearchTableViewController:searchTableViewController didStartSearchWithParameters:params];
    } else if ([[self buttonDelegate] respondsToSelector:@selector(pkCatalogueNavigationController:didSearchWithParams:andFoundProducts:)]) {
        // Perform the search:
        NSArray *products = [PKProduct resultsForSearchParameters:[self searchParams]];
        
        // Update the products:
        if ([products count] != 0) {
            // Update the ui with products:
            if ([products count] != 0) {
                [searchTableViewController dismissViewControllerAnimated:YES completion:^{
                    [[self buttonDelegate] pkCatalogueNavigationController:self didSearchWithParams:[self searchParams] andFoundProducts:products];
                }];
            }
        }
        
        // Return YES only if some products have been found:
        return [products count] != 0;
    }
    return NO;
}

- (void)pkSearchTableViewController:(PKSearchTableViewController *)searchTableViewController didUpdateSearchParameters:(PKSearchParameters *)params {
    [self setSearchParams:params];
}

#pragma mark - PKCustomerSelectionDelegate Methods

- (void)pkCustomerSelectionDelegateSelectedCustomer:(PKCustomer *)customer andCreatedBasket:(PKBasket *)basket {
    [self dismissViewControllerAnimated:YES completion:^{
        [self refreshOrderButtons:nil];
    }];
}

#pragma mark - UINavigationControllerDelegate Methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL disableButton = NO;
    BOOL customCategory = NO;
    
    if ([[self buttonDelegate] respondsToSelector:@selector(pkCatalogueNavigationControllerShouldDisableSortButton:)]) {
        disableButton = [[self buttonDelegate] pkCatalogueNavigationControllerShouldDisableSortButton:self];
    }
    if ([[self buttonDelegate] respondsToSelector:@selector(pkCatalogueNavigationControllerIsCategoryCustom:)]) {
        customCategory = [[self buttonDelegate] pkCatalogueNavigationControllerIsCategoryCustom:self];
    }
    
    if (customCategory) {
        [[self buttonAddCategory] setImage:[UIImage imageNamed:@"ToolbarProductRemove"] forState:UIControlStateNormal];
    } else {
        [[self buttonAddCategory] setImage:[UIImage imageNamed:@"ToolbarProductAdd"] forState:UIControlStateNormal];
    }
    
    if (disableButton) {
        [[self buttonSort] setEnabled:!disableButton];
        //[[self buttonAddCategory] setEnabled:!disableButton];
    } else {
        if ([viewController isKindOfClass:NSClassFromString(@"PKCategoriesViewController")]) {
            [[self buttonSort] setEnabled:NO];
           // [[self buttonAddCategory] setEnabled:NO];
            [[self buttonBulkAdd] setEnabled:NO];
        } else {
            [[self buttonSort] setEnabled:YES];
            //[[self buttonAddCategory] setEnabled:YES];
            [self refreshOrderButtons:nil];
        }
    }
    
    if ([[self viewControllers] count] == 1) {
        [[self buttonBack] setEnabled:NO];
    } else {
        [[self buttonBack] setEnabled:YES];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)enableSortButton:(BOOL)enable {
    [[self buttonSort] setEnabled:enable];
}

- (void)refreshCustomCategoryButton {
    BOOL customCategory = NO;
    BOOL disableButton = NO;
    if ([[self buttonDelegate] respondsToSelector:@selector(pkCatalogueNavigationControllerIsCategoryCustom:)]) {
        customCategory = [[self buttonDelegate] pkCatalogueNavigationControllerIsCategoryCustom:self];
    }
    if ([[self buttonDelegate] respondsToSelector:@selector(pkCatalogueNavigationControllerShouldDisableSortButton:)]) {
        disableButton = [[self buttonDelegate] pkCatalogueNavigationControllerShouldDisableSortButton:self];
    }
    
    if (customCategory) {
        [[self buttonAddCategory] setImage:[UIImage imageNamed:@"ToolbarProductRemove"] forState:UIControlStateNormal];
    } else {
        [[self buttonAddCategory] setImage:[UIImage imageNamed:@"ToolbarProductAdd"] forState:UIControlStateNormal];
    }
    
    [[self buttonAddCategory] setEnabled:!disableButton];
}

#pragma mark - Updates

- (void) checkForUpdates:(id)sender {
    UINavigationController *updateChecker = [FSEnterpriseUpdateCheckViewController createWithNavController];
    [updateChecker setModalPresentationStyle:UIModalPresentationFormSheet];
    [[[self viewControllers] lastObject] presentViewController:updateChecker animated:YES completion:nil];
}

#pragma mark - Memory Management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

@end
