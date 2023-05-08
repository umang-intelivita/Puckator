//
//  PKCustomCategoryBar.m
//  Puckator
//
//  Created by Luke Dixon on 01/11/2018.
//  Copyright © 2018 57Digital Ltd. All rights reserved.
//

#import "PKCustomCategoryBar.h"
//#import "PKCategory.h"

@interface PKCustomCategoryBar()

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonSelectAll;
@property (weak, nonatomic) IBOutlet UIButton *buttonSelectNone;
@property (weak, nonatomic) IBOutlet UIButton *buttonConfirm;

@end

@implementation PKCustomCategoryBar
@synthesize productMode = _productMode;

+ (instancetype)createWithDelegate:(id<PKCustomCategoryBarDelegate>)delegate mode:(PKCustomCategoryBarMode)mode {
    PKCustomCategoryBar *customCategoryBar = [[PKCustomCategoryBar alloc] initWithNibName:@"PKCustomCategoryBar" bundle:nil];
    [customCategoryBar setDelegate:delegate];
    [customCategoryBar setMode:mode];
    [customCategoryBar setProductMode:PKCustomCategoryBarProductModeNone];
    [[customCategoryBar view] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    return customCategoryBar;
}

- (void)setTitle:(NSString *)title {
    [[self labelTitle] setText:title];
}

#pragma mark - Public Methods

- (void)setProductMode:(PKCustomCategoryBarProductMode)productMode {
    _productMode = productMode;
    
    switch (_productMode) {
        case PKCustomCategoryBarProductModeAdd:
            [[self buttonConfirm] setTitle:NSLocalizedString(@"Add Products", nil) forState:UIControlStateNormal];
            break;
        case PKCustomCategoryBarProductModeRemove:
            [[self buttonConfirm] setTitle:NSLocalizedString(@"Remove Products", nil) forState:UIControlStateNormal];
            break;
        case PKCustomCategoryBarProductModeNone:
            [[self buttonConfirm] setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)setProductButtonsEnabled:(BOOL)enabled {
    [[self buttonSelectAll] setEnabled:enabled];
    [[self buttonSelectNone] setEnabled:enabled];
    
    [[self buttonSelectAll] setAlpha:(enabled ? 1 : 0)];
    [[self buttonSelectNone] setAlpha:(enabled ? 1 : 0)];
}

- (void)addProducts:(NSArray<PKProduct*> *)products {
    if ([self category]) {
        if ([self productMode] == PKCustomCategoryBarProductModeAdd) {
            [products enumerateObjectsUsingBlock:^(PKProduct *product, NSUInteger idx, BOOL * _Nonnull stop) {
                [product addCategoriesObject:[self category]];
                [[self category] addProductsObject:product];
            }];
        } else if ([self productMode] == PKCustomCategoryBarProductModeRemove) {
            [products enumerateObjectsUsingBlock:^(PKProduct *product, NSUInteger idx, BOOL * _Nonnull stop) {
                [product removeCategoriesObject:[self category]];
                [[self category] removeProductsObject:product];
            }];
        }
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - Event Methods

- (IBAction)buttonConfirmPressed:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(pkCustomCategoryBarConfirmed:)]) {
        [[self delegate] pkCustomCategoryBarConfirmed:self];
    }
}

- (IBAction)buttonCancelPressed:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(pkCustomCategoryBarCancelled:)]) {
        [[self delegate] pkCustomCategoryBarCancelled:self];
    }
}

- (IBAction)buttonSelectAllPressed:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(pkCustomCategoryBarSelectAll:)]) {
        [[self delegate] pkCustomCategoryBarSelectAll:self];
    }
}

- (IBAction)buttonSelectNonePressed:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(pkCustomCategoryBarSelectNone:)]) {
        [[self delegate] pkCustomCategoryBarSelectNone:self];
    }
}

#pragma mark -

@end
