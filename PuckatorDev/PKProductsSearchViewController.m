//
//  PKProductsSearchViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 27/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductsSearchViewController.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"
#import "PKPopoverNavigationController.h"
#import "PKProduct+Operations.h"
#import "PKCatalogueNavigationController.h"

@interface PKProductsSearchViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textSearchTerm;
@property (nonatomic, strong) PKSearchParameters *searchParameters;
@end

@implementation PKProductsSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Overide stuff
    [[self view] setBackgroundColor:[UIColor puckatorBorderColor]];
    
    // Customize the UI
    [[[self textSearchTerm] layer] setCornerRadius:15];
    [[self textSearchTerm] setTintColor:[UIColor clearColor]];
    [[self textSearchTerm] setFont:[UIFont puckatorContentTitle]];
    [[self textSearchTerm] setTextColor:[UIColor puckatorPrimaryColor]];
    [[self textSearchTerm] setTextAlignment:NSTextAlignmentCenter];
    [[self textSearchTerm] setDelegate:self];
}

+ (instancetype)createWithProducts:(NSArray *)products displayMode:(PKProductsDisplayMode)displayMode {
    PKProductsSearchViewController *productsViewController = [PKProductsSearchViewController createFromStoryboardNamed:@"Main"];
    [productsViewController setDisplayMode:displayMode];
    [productsViewController updateProducts:products];
    return productsViewController;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:NSLocalizedString(@"Search Results", nil)];
    
    if ([self productsCount] == 0) {
        [[self textSearchTerm] becomeFirstResponder];
    }
    
    if ([[self navigationController] isKindOfClass:[PKCatalogueNavigationController class]]) {
        [(PKCatalogueNavigationController *)[self navigationController] setButtonDelegate:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {    
    [textField resignFirstResponder];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    PKSearchTableViewController *searchTableViewController = (PKSearchTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"searchParameters"];
    [searchTableViewController setSourceTextField:textField];
    [searchTableViewController setSearchDelegate:self];
    [searchTableViewController setSearchParameters:[self searchParameters]];
    
    PKPopoverNavigationController *navController = [[PKPopoverNavigationController alloc] initWithRootViewController:searchTableViewController];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    [popoverController setBackgroundColor:[UIColor puckatorPrimaryColor]];
    [popoverController setPopoverContentSize:CGSizeMake(320, 600)];
    [navController setPopoverReference:popoverController];
    
    CGRect rect = [[self textSearchTerm] frame];
    [popoverController presentPopoverFromRect:rect inView:[[self navigationController] navigationBar] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)buttonSearchPressed:(id)sender {
}

- (void) buttonClearPressed:(id)sender {
    [self setSearchParameters:nil];
    [self updateProducts:@[]];
    [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
    [[self textSearchTerm] becomeFirstResponder];
}

- (void) updateProducts:(NSArray *)products {
    // Animate out
    [UIView animateWithDuration:0.2f animations:^{
        [[self collectionView] setAlpha:0.0f];
    } completion:^(BOOL finished) {
         // Update the collection view
         [super updateProducts:products];
         
         // Update the text in the search bar
         [[self textSearchTerm] setText:[[self searchParameters] searchText]];
         
         // Animate back in
         [UIView animateWithDuration:0.2f animations:^{
             [[self collectionView] setAlpha:1.0f];
         } completion:^(BOOL finished) {
             [self updateInterface];
         }];
     }];
}

- (void)updateInterface {
    if ([self productsCount] == 0) {
        [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
    }
}

- (void)pkCatalogueNavigationController:(PKCatalogueNavigationController *)catalogueNavigationController
                    didSearchWithParams:(PKSearchParameters *)params
                       andFoundProducts:(NSArray *)products {
    if ([self isKindOfClass:[PKProductsSearchViewController class]]) {
        [self updateProducts:products];
        [[self collectionView] reloadData];
    }
}

@end