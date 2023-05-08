//
//  PKProductsViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKProductsViewController.h"
#import "PKProductReusableView.h"
#import "UIColor+Puckator.h"
#import "UIViewController+Controller.h"
#import "UIImageView+ImageRenderingMode.h"
#import "UIScrollView+Extended.h"
#import "PKBasketTableViewController.h"
#import "PKPopoverNavigationController.h"
#import "PKBasket+Operations.h"
#import "PKBasketItem+Operations.h"
#import "PKConstant.h"
#import "PKProductsLayout.h"
#import "PKProductsSearchViewController.h"
#import "PKProduct+Operations.h"
#import "PKProductPrice.h"
#import "PKProductPrice+Operations.h"
#import "APProgressHUD.h"
#import "UIViewController+HUD.h"
#import "UIView+FrameHelper.h"

// Cell imports:
#import "PKProductCellSmall.h"
#import "PKProductCellMedium.h"
#import "PKProductCellLarge.h"
#import "PKProductCellEmpty.h"
//#import "Kickflip.h"

#define kPKProductsViewControllerFooterHeight   30

@interface PKProductsViewController ()

//@property (strong, nonatomic) PKCategory *category;
@property (strong, nonatomic) NSMutableArray *productImages;

// Layouts:
@property (strong, nonatomic) UICollectionViewFlowLayout *layoutSmall;
@property (strong, nonatomic) PKProductsLayout *layoutMedium;
@property (strong, nonatomic) UICollectionViewFlowLayout *layoutLarge;

@property (strong, nonatomic) UILabel *labelFooter;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSArray *transitionIndexPaths;

@property (assign, nonatomic) float scale;
@property (assign, nonatomic) BOOL isDisplayingFromBasket;

@property (assign, nonatomic) PKProductMode productMode;

@property (assign, nonatomic) BOOL productsAlreadySorted;
@property (assign, nonatomic) BOOL productsAlreadyFiltered;

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSArray *filteredProducts;

// Custom categories:
@property (strong, nonatomic) PKCategory *customCategory;
@property (strong, nonatomic) NSMutableArray *selectedProducts;
@property (weak, nonatomic) IBOutlet UIView *viewCustomCategory;
@property (strong, nonatomic) PKCustomCategoryBar *customCategoryBar;

@end

@implementation PKProductsViewController
@synthesize products = _products;
@synthesize displayMode = _displayMode;
//@synthesize category = _category;

#pragma mark - Constructor Methods

+ (instancetype)createWithProducts:(NSArray *)products productMode:(PKProductMode)productMode displayMode:(PKProductsDisplayMode)displayMode {
    PKProductsViewController *productsViewController = [PKProductsViewController createFromStoryboardNamed:@"Main"];
    [productsViewController setDisplayMode:displayMode];
    [productsViewController setProducts:products];
    [productsViewController setProductMode:productMode];
    return productsViewController;
}

+ (instancetype)createWithBasket:(PKBasket *)basket indexPath:(NSIndexPath *)indexPath displayMode:(PKProductsDisplayMode)displayMode {
    PKProductsViewController *productsViewController = [PKProductsViewController createFromStoryboardNamed:@"Main"];
    [productsViewController setDisplayMode:displayMode];
    
    // Load the products from the basket:
    NSMutableArray *products = [NSMutableArray array];
    NSArray *basketItems = [basket itemsOrdered];
    [basketItems enumerateObjectsUsingBlock:^(PKBasketItem *basketItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([basketItem respondsToSelector:@selector(product)]) {
            PKProduct *product = [basketItem product];
            if (product) {
                [products addObject:product];
            }
        }
    }];
    
    [productsViewController setProducts:products];
    [productsViewController setIsDisplayingFromBasket:YES];
    [productsViewController setIndexPath:indexPath];
    return productsViewController;
}

+ (instancetype)createWithBasketItem:(PKBasketItem *)basketItem displayMode:(PKProductsDisplayMode)displayMode {
    PKProductsViewController *productsViewController = [PKProductsViewController createFromStoryboardNamed:@"Main"];
    [productsViewController setDisplayMode:displayMode];
    if ([basketItem respondsToSelector:@selector(product)]) {
        [productsViewController setProducts:@[[basketItem product]]];
    }
    [productsViewController setIsDisplayingFromBasket:YES];
    return productsViewController;
}

+ (instancetype)createWithProduct:(PKProduct *)product displayMode:(PKProductsDisplayMode)displayMode {
    PKProductsViewController *productsViewController = [PKProductsViewController createFromStoryboardNamed:@"Main"];
    [productsViewController setDisplayMode:displayMode];
    [productsViewController setProducts:@[product]];
    return productsViewController;
}

+ (instancetype)createWithProducts:(NSArray *)products displayMode:(PKProductsDisplayMode)displayMode {
    PKProductsViewController *productsViewController = [PKProductsViewController createFromStoryboardNamed:@"Main"];
    [productsViewController setDisplayMode:displayMode];
    [productsViewController setProducts:products];
    return productsViewController;
}

+ (instancetype)createWithDisplayMode:(PKProductsDisplayMode)displayMode indexPath:(NSIndexPath *)indexPath {
    PKProductsViewController *productsViewController = [PKProductsViewController createFromStoryboardNamed:@"Main"];
    [productsViewController setDisplayMode:displayMode];
    [productsViewController setIndexPath:indexPath];
    return productsViewController;
}

+ (instancetype)createWithProductMode:(PKProductMode)productMode displayMode:(PKProductsDisplayMode)displayMode {
    PKProductsViewController *productsViewController = [PKProductsViewController createFromStoryboardNamed:@"Main"];
    [productsViewController setDisplayMode:displayMode];
    [productsViewController setProductMode:productMode];
    return productsViewController;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib {
    [self setDisplayMode:PKProductsDisplayModeMedium];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [[self collectionView] setMultipleTouchEnabled:NO];
    [[self collectionView] setDecelerationRate:UIScrollViewDecelerationRateNormal];
    
    if (@available(iOS 11.0, *)) {
        [[self collectionView] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
    }
    
    // Register for notifications:
    [self registerNotifications];
    
    // The medium layout is the one from the storyboard:
    [self setLayoutSmall:(UICollectionViewFlowLayout *)[[self collectionView] collectionViewLayout]];
    //[self setLayoutMedium:(UICollectionViewFlowLayout *)[[self collectionView] collectionViewLayout]];
    [self setLayoutMedium:[[PKProductsLayout alloc] init]];
    
    // Setup the large layout:
    [self setLayoutLarge:[[UICollectionViewFlowLayout alloc] init]];
    [[self layoutLarge] setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [[self layoutLarge] setMinimumInteritemSpacing:0];
    [[self layoutLarge] setMinimumLineSpacing:0];
    CGSize itemSize = CGSizeMake([[self collectionView] bounds].size.width,
                                 [[self collectionView] bounds].size.height - kPKProductsViewControllerFooterHeight);
    [[self layoutLarge] setItemSize:itemSize];
    [[self layoutLarge] setSectionInset:UIEdgeInsetsMake(0, 0, kPKProductsViewControllerFooterHeight, 0)];
    
    switch ([self displayMode]) {
        default:
        case PKProductsDisplayModeSmall: {
            [[self collectionView] setCollectionViewLayout:[self layoutSmall] animated:NO];
            [[self collectionView] setPagingEnabled:NO];
            break;
        }
        case PKProductsDisplayModeMedium: {
            [[self collectionView] setCollectionViewLayout:[self layoutMedium] animated:NO];
            [[self collectionView] setPagingEnabled:YES];
            break;
        }
        case PKProductsDisplayModeLarge: {
            [[self collectionView] setCollectionViewLayout:[self layoutLarge] animated:NO];
            [[self collectionView] setPagingEnabled:YES];
            break;
        }
    }
    
    // Register cell classes
    [self registerCellNibs];
    [self setupGestures];
    [self addSearchBox];
    
    // Setup the collection view style:
    [self setClearsSelectionOnViewWillAppear:YES];
    [[self collectionView] setBackgroundColor:[UIColor puckatorCollectionViewBackgroundColor]];
    [[self collectionView] setOpaque:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self displayMode] == PKProductsDisplayModeLarge) {
        [[[self navigationController] interactivePopGestureRecognizer] setEnabled:NO];
    }
    
    [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self displayMode] == PKProductsDisplayModeLarge) {
        [[[self navigationController] interactivePopGestureRecognizer] setEnabled:YES];
    }
    
    
    // Clear selected category
//    if([self productMode] == PKProductModeCategory) {
//        if([self category]) {
//            [[PKSession sharedInstance] setSelectedCategoryId:nil];
//        }
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[self navigationController] isKindOfClass:[PKCatalogueNavigationController class]]) {
        [(PKCatalogueNavigationController *)[self navigationController] setButtonDelegate:self];
    }
    
    [[self navigationItem] setHidesBackButton:YES animated:YES];
    
    // Setup the basket title:
    [self refreshBasketButton];
    
    // Setup the title:
    if (![self isSearch] && [[self title] length] == 0) {
        [self setTitle:NSLocalizedString(@"Products", nil)];
    }
        
    // Setup all the products if required:
    if ([self dataSource] && [[self dataSource] respondsToSelector:@selector(pkProductsViewControllerRequestsProducts:)]) {
        [self setProducts:[[self dataSource] pkProductsViewControllerRequestsProducts:self]];
    } else {
        [self setupProducts];
    }
    
    // Setup the UI once the products have been set up:
    [self setupUI];
    
    // Setup the custom category bar:
    if ([[PKSession sharedInstance] customCategoryBar]) {
        [[[PKSession sharedInstance] customCategoryBar] setDelegate:self];
        [[[PKSession sharedInstance] customCategoryBar] setProductButtonsEnabled:YES];
        [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeAdd];
        
        if ([[[PKSession sharedInstance] customCategoryBar] category] == [self category]) {
            [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeRemove];
        }
    }
}

- (void)setupProducts {
    
    // Save selected category
    if([self productMode] == PKProductModeCategory) {
        if([self category]) {
            [[PKSession sharedInstance] setSelectedCategoryId:[[self category] categoryId]];
        }
    }
    
    switch ([self productMode]) {
        default:
        case PKProductModeCategory: {
            if( [self.category.title isEqualToString:@"Past Order"]) {
                self.title = @"Past Orders";
                [self displayPastOrdersProducts];
            } else {
                if ([self category]) {
                    [self setProducts:[[self category] productsSortBy:PKCategorySortModeAlphabetically ascending:YES]];
                    [self setTitle:[[self category] styledTitle]];
                }
            }
            break;
        }
        case PKProductModeNew: {
            [self displayNewProducts];
            break;
        }
        case PKProductModeTop: {
            [self displayTopSellingProducts];
            break;
        }
        case PKProductModeNewAvailable: {
            [self displayNewAvaliableProducts];
            break;
        }
        case PKProductModeInStock: {
            [self displayInStockProducts];
            break;
        }
        case PKProductModeCustomerProducts: {
            [self displayCustomerProducts];
            break;
        }
    }
}

#pragma mark - Private Methods

- (void)filterChanged:(NSNotification *)notification {
    // Clear the products already filtered flag:
    [self setProductsAlreadyFiltered:NO];
    
    // Reload the collection view:
    [FSThread runOnMain:^{
        [self basketDidUpdateItem:notification];
    }];
    
    // Update the page and number of products:
    [self updatePage];
}

- (void)refreshBasketButton {
    if ([self displayMode] == PKProductsDisplayModeLarge) {
        //[[self collectionView] reloadData];
    }
}

- (void)scrollCollectionViewToIndexPath:(NSIndexPath *)indexPath scrollPosition:(UICollectionViewScrollPosition)scrollPosition {
    int numberOfSections = (int)[[self collectionView] numberOfSections];
    if ([indexPath section] < numberOfSections) {
        int numberOfItems = (int)[[self collectionView] numberOfItemsInSection:[indexPath section]];
        if ([indexPath row] < numberOfItems) {
            [[self collectionView] scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:NO];
        }
    }
}

- (void)setupUI {
    // Determine if we need to scroll to an index path or not:
    if ([[self indexPath] row] != 0 && [[self indexPath] section] == 0 && [[self indexPath] row] < [[self products] count]) {
        [self scrollCollectionViewToIndexPath:[self indexPath] scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
    
    if ([self displayMode] == PKProductsDisplayModeLarge) {
        if (![self labelFooter]) {
            [self setLabelFooter:[[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                           [[self view] bounds].size.height - kPKProductsViewControllerFooterHeight,
                                                                           [[self view] bounds].size.width,
                                                                           kPKProductsViewControllerFooterHeight)]];
            [[self labelFooter] setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
            [[self labelFooter] setBackgroundColor:[UIColor puckatorDarkGray]];
            [[self labelFooter] setTextAlignment:NSTextAlignmentCenter];
            [[self labelFooter] setTextColor:[UIColor whiteColor]];
            [[self labelFooter] setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:14]];
            [[self collectionView] addSubview:[self labelFooter]];
        }
        
        [[self labelFooter] setHidden:NO];
        [self updatePage];
    } else {
        [[self labelFooter] setHidden:YES];
    }
    
    if ([self isDisplayingFromBasket]) {
        [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonDonePressed:)]];
    }
        
    [self scrollViewDidScroll:[self collectionView]];
}

- (BOOL)isSearch {
    return [NSStringFromClass([self class]) isEqualToString:@"PKProductsSearchViewController"];
}

- (void)setupGestures {
    if ([[[self view] gestureRecognizers] count] == 0) {
        UIPinchGestureRecognizer *pinchInGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewPinched:)];
        [[self view] addGestureRecognizer:pinchInGestureRecognizer];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewLongPressed:)];
        [[self view] addGestureRecognizer:longPressGestureRecognizer];
    }
}

- (void)registerCellNibs {
    // Small cell:
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKProductCellSmall" bundle:[NSBundle mainBundle]]
            forCellWithReuseIdentifier:@"PKProductCellSmall"];
    
    // Medium cell:
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKProductCellMedium" bundle:[NSBundle mainBundle]]
            forCellWithReuseIdentifier:@"PKProductCellMedium"];
    
    // Large cell:
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKProductCellLarge" bundle:[NSBundle mainBundle]]
            forCellWithReuseIdentifier:@"PKProductCellLarge"];
    
    // Empty cell:
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKProductCellEmpty" bundle:[NSBundle mainBundle]]
            forCellWithReuseIdentifier:@"PKProductCellEmpty"];
    
    // Supplementary view:
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKProductReusableView" bundle:[NSBundle mainBundle]]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"PKProductReusableView"];
}

- (void)displayEmptyState {
}

- (PKProduct *)productAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [indexPath row] < [[self products] count]) {
        return [[self products] objectAtIndex:[indexPath row]];
    } else {
        return nil;
    }
}

#pragma mark - Notification Methods

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBasketStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basketStatusChanged:) name:kNotificationBasketStatusChanged object:nil];
    
    // Register for did update item changes:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDidSaveOrCancelOrder object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basketUpdated:) name:kNotificationDidSaveOrCancelOrder object:nil];
    
    // Register for did update item changes:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBasketDidUpdateItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basketDidUpdateItem:) name:kNotificationBasketDidUpdateItem object:nil];
    
    // Add observer for currency changes:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDidChangeCurrency object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCurrency:) name:kNotificationDidChangeCurrency object:nil];
    
    // Add observer for filter changes:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationFilterChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterChanged:) name:kNotificationFilterChanged object:nil];
}

- (void)basketStatusChanged:(NSNotification *)notification {
    [FSThread runOnMain:^{
        [self setProducts:_products];
        [[self collectionView] reloadData];        
    }];
}

- (void)basketDidUpdateItem:(NSNotification *)notification {
    // Check if this view controller is onscreen or not:
    if (self.isViewLoaded && self.view.window) {
        [self setProducts:_products];
        [[self collectionView] reloadData];
        [self viewWillLayoutSubviews];
    } else {
        [self setProducts:_products];
        [[self collectionView] reloadData];
        [self refreshBasketButton];
    }
}

#pragma mark - Public Methods

- (void) updateProducts:(NSArray*)products {
    __weak PKProductsViewController *weakSelf = self;
    [FSThread runOnMain:^{
        [weakSelf setProducts:products];
        [[weakSelf collectionView] setContentOffset:CGPointZero animated:NO];
        [[weakSelf collectionView] reloadData];
        [weakSelf updatePage];
    }];
}

- (int) productsCount {
    return (int)[[self products] count];
}

#pragma mark - Overridden Methods

- (void)setDisplayMode:(PKProductsDisplayMode)displayMode {
    @try {
        NSIndexPath *indexPath = nil;
        
        if (_displayMode == PKProductsDisplayModeLarge) {
            indexPath = [[[self collectionView] indexPathsForVisibleItems] firstObject];
        }
        
        if (_displayMode != displayMode) {
            _displayMode = displayMode;
            
            switch ([self displayMode]) {
                case PKProductsDisplayModeSmall: {
                    [[self collectionView] setCollectionViewLayout:[self layoutSmall] animated:NO];
                    [[self collectionView] setPagingEnabled:NO];
                    break;
                }
                case PKProductsDisplayModeMedium: {
                    [[self collectionView] setCollectionViewLayout:[self layoutMedium] animated:NO];
                    [[self collectionView] setPagingEnabled:YES];
                    break;
                }
                case PKProductsDisplayModeLarge: {
                    [[self collectionView] setCollectionViewLayout:[self layoutLarge] animated:NO];
                    [[self collectionView] setPagingEnabled:YES];
                    break;
                }
            }
            
            [self setupUI];
            [[self collectionView] reloadData];
            
            // Center on the correct page when going from large to medium:
            if (indexPath && [self displayMode] == PKProductsDisplayModeMedium) {
                int modulus = [indexPath row] % 4;
                int indexRow = (int)([indexPath row] - modulus);
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
                [self scrollCollectionViewToIndexPath:indexPath scrollPosition:UICollectionViewScrollPositionLeft];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)setProductMode:(PKProductMode)productMode {
    
    _productMode = productMode;
    
    // Determine if the sort menu button should be shown or not:
    if ([[self navigationController] isKindOfClass:[PKCatalogueNavigationController class]]) {
        PKCatalogueNavigationController *navigationController = (PKCatalogueNavigationController *)[self navigationController];
        if (productMode == PKProductModeNew || productMode == PKProductModeNewAvailable) {
            [navigationController enableSortButton:NO];
        } else {
            [navigationController enableSortButton:YES];
        }
    }
    
    if (_productMode == PKProductModeSearch) {
        [self setTitle:NSLocalizedString(@"Search Results", nil)];
    }
    
    if (_productMode != PKProductModeCategory) {
        //[self setCategory:nil];
        //[self setCustomCategory:nil];
        
        PKCatalogueNavigationController *navigationController = (PKCatalogueNavigationController *)[self navigationController];
        [navigationController refreshCustomCategoryButton];
    }
}

//- (void)setCategory:(PKCategory *)category {
//    _category = category;
//}

- (NSArray *)products {
    // If we are displaying the basket item then just return the products
    // without filtering them:
    if ([self isDisplayingFromBasket]) {
        return _products;
    }
    
    // Filter the products:
    if (![self productsAlreadyFiltered]) {
        [self setFilteredProducts:[PKProduct filterProducts:_products stockFilterEnabled:([self productMode] != PKProductModeNew) bespokeFilterEnabled:YES]];
        [self setProductsAlreadyFiltered:YES];
    }
    
    if ([self filteredProducts]) {
        return [self filteredProducts];
    }
    
    return _products;
    
//    // Return the sorted and filtered products:
//    return [self filteredProducts];
}

- (void)setProducts:(NSArray *)products {
    // Clear the filtered products:
    [self setFilteredProducts:nil];
    [self setProductsAlreadyFiltered:NO];
    
    if (products == nil) {
        _products = nil;
        [self.collectionView reloadData];
        return;
    }
    
    // Sort the products:
    if ([self productMode] != PKProductModeNew && [self productMode] != PKProductModeNewAvailable) {
        _products = [PKProduct sortProducts:products];
    } else {
        _products = products;
    }

    _products = [self filterInBasketItem: _products];
    // Load the product images:
//    [_products enumerateObjectsUsingBlock:^(PKProduct *product, NSUInteger idx, BOOL *stop) {
//        [product thumb];
//    }];
    
//    // Setup the product images:
//    if ([self displayMode] != PKProductsDisplayModeLarge) {
//        [self setProductImages:[NSMutableArray array]];
//    }
}

- (NSArray *)filterInBasketItem:(NSArray *)productArray {
    NSMutableArray * tempArray = [NSMutableArray arrayWithArray:productArray];
    if ([[PKSession sharedInstance] hideProductsInOrderView]) {
        NSSet *items = [PKBasket sessionBasket].items;
        for (PKBasketItem * item in items) {
            for (PKProduct * product in productArray) {
                if ([item.productUuid isEqualToString:product.productId]) {
                    [tempArray removeObject:product];
                }
            }
        }
    }
    return tempArray;
}

#pragma mark - Event Methods

- (void)buttonBackPressed:(id)sender {
    if ([self displayMode] == PKProductsDisplayModeLarge) {
        [self setDisplayMode:PKProductsDisplayModeMedium];
    } else {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)buttonDonePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)viewLongPressed:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if ([longPressGestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if ([self productMode] == PKProductModeNew || [self productMode] == PKProductModeNewAvailable) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedString(@"Sorting isn't avaliable when viewing new products.\n\nProducts are automatically ordered by date added.", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRequestSortMenu object:nil];
        }
    }
}

- (PKProductsDisplayMode)displayMode {
    if ([[PKSession sharedInstance] customCategoryBar]) {
        return PKProductsDisplayModeSmall;
    }
    return _displayMode;
}

- (void)viewPinched:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
//    if ([pinchGestureRecognizer state] == UIGestureRecognizerStateEnded) {
//        [self setScale:1.0f];
//    }
//    
//    if ([pinchGestureRecognizer state] == UIGestureRecognizerStateBegan) {
//        [self setScale:1.0f];
//    }
    
    if ([pinchGestureRecognizer state] == UIGestureRecognizerStateRecognized) {
        if ([self displayMode] == PKProductsDisplayModeLarge) {
            [self setDisplayMode:PKProductsDisplayModeMedium];
        } else if ([self displayMode] == PKProductsDisplayModeMedium) {
            [self setDisplayMode:PKProductsDisplayModeSmall];
        } else if ([self displayMode] == PKProductsDisplayModeSmall) {
            [self setDisplayMode:PKProductsDisplayModeMedium];
            [[self collectionView] setCollectionViewLayout:[self layoutMedium] animated:NO];
            [[self collectionView] setPagingEnabled:YES];
            
            // Scroll to an actual page:
            [[[self collectionView] indexPathsForVisibleItems] enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                if ([indexPath row] % 4 == 0) {
                    [self scrollCollectionViewToIndexPath:indexPath scrollPosition:UICollectionViewScrollPositionLeft];
                    *stop = YES;
                }
            }];
            
            [[self collectionView] reloadData];
            [self setScale:[pinchGestureRecognizer scale]];
        }
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([[self products] count] == 0) {
        return 1;
    } else {
        return [[self products] count];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    if ([self displayMode] == PKProductsDisplayModeLarge) {
        return UIEdgeInsetsMake(0, 0, kPKProductsViewControllerFooterHeight, 0);
    } else {
        if ([self displayMode] == PKProductsDisplayModeMedium) {
            return UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            return UIEdgeInsetsZero;
        }
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)sizeForCellAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView {
    if ([[self products] count] == 0) {
        return CGSizeMake([collectionView bounds].size.width,
                          [collectionView bounds].size.height);
    } else {
        switch ([self displayMode]) {
            case PKProductsDisplayModeSmall: {
                int rows = 3;
                int cols = 4;
                int vertSpaces = rows - 1;
                int hozSpaces = cols - 1;
                int padding = [(UICollectionViewFlowLayout *)[[self collectionView] collectionViewLayout] minimumLineSpacing];
                int height = floorf(([collectionView frame].size.height - (vertSpaces * padding)) / rows);
                int width = floorf(([collectionView frame].size.width - (hozSpaces * padding)) / cols);
                return CGSizeMake(width, height);
                break;
            }
            default:
            case PKProductsDisplayModeMedium: {
                int rows = 2;
                int cols = 2;
                int vertSpaces = rows - 1;
                int hozSpaces = cols - 1;
                int padding = [(UICollectionViewFlowLayout *)[[self collectionView] collectionViewLayout] minimumLineSpacing];
                int height = floorf(([collectionView frame].size.height - (vertSpaces * padding)) / rows);
                int width = floorf(([collectionView frame].size.width - (hozSpaces * padding)) / cols);
                return CGSizeMake(width, height);
                break;
            }
            case PKProductsDisplayModeLarge: {
                float width = [collectionView bounds].size.width;
                width -= ([[self layoutLarge] sectionInset].left + [[self layoutLarge] sectionInset].right);
                width -= ([[self collectionView] contentInset].left + [[self collectionView] contentInset].right);
                
                float height = [collectionView bounds].size.height;
                height -= ([[self layoutLarge] sectionInset].top + [[self layoutLarge] sectionInset].bottom);
                height -= ([[self collectionView] contentInset].top + [[self collectionView] contentInset].bottom);
                
                CGSize itemSize = CGSizeMake(width, height);  
                [[self layoutLarge] setItemSize:itemSize];
                return [[self layoutLarge] itemSize];
                break;
            }
        }
    }
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self sizeForCellAtIndexPath:indexPath inCollectionView:collectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self products] count] == 0) {
        static NSString *identifier = @"PKProductCellEmpty";
        
        // Dequeue a cell:
        PKProductCellEmpty *cell = (PKProductCellEmpty *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                   forIndexPath:indexPath];
        [cell setClipsToBounds:YES];
        return cell;
    } else {
        // Configure the cell
        switch ([self displayMode]) {
            default:
            case PKProductsDisplayModeSmall: {
                static NSString *identifier = @"PKProductCellSmall";
                
                // Dequeue a cell:
                PKProductCellSmall *cell = (PKProductCellSmall *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                           forIndexPath:indexPath];
                PKProduct *product = [self productAtIndexPath:indexPath];
                [cell setupWithProduct:product];
                
                if ([[PKSession sharedInstance] customCategoryBar]) {
                    if ([[self selectedProducts] containsObject:product]) {
                        [cell setAlpha:1.0f];
                        [cell setBackgroundColor:[UIColor puckatorLightPurple]];
                    } else {
                        [cell setAlpha:0.25f];
                        [cell setBackgroundColor:[UIColor colorWithHexString:@"E7EAEA"]];
                    }
                } else {
                    [cell setAlpha:1.0f];
                    [cell setBackgroundColor:[UIColor colorWithHexString:@"E7EAEA"]];
                }
                
                return cell;
                break;
            }
            case PKProductsDisplayModeMedium:{
                static NSString *identifier = @"PKProductCellMedium";
                
                // Dequeue a cell:
                PKProductCellMedium *cell = (PKProductCellMedium *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                             forIndexPath:indexPath];
                [cell setupWithProduct:[self productAtIndexPath:indexPath] image:nil];
                return cell;
                break;
            }
            case PKProductsDisplayModeLarge: {
                static NSString *identifier = @"PKProductCellLarge";
                
                // Dequeue a cell:
                PKProductCellLarge *cell = (PKProductCellLarge *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                           forIndexPath:indexPath];
                PKProduct *product = [self productAtIndexPath:indexPath];
//                NSLog(@"[%@] - Price: %.4f", [product price])
                [cell setupWithProduct:product];
                return cell;
                break;
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[PKSession sharedInstance] customCategoryBar]) {
        if (![self selectedProducts]) {
            [self setSelectedProducts:[NSMutableArray array]];
        }
        
        PKProduct *product = [self productAtIndexPath:indexPath];
        if ([[self selectedProducts] containsObject:product]) {
            [[self selectedProducts] removeObject:product];
        } else {
            if (product) {
                [[self selectedProducts] addObject:product];
            }
        }
        
        [[self collectionView] reloadData];
        
        [self refreshCustomCategoryBar];
    } else {
        if ([[self products] count] != 0 && [self displayMode] != PKProductsDisplayModeLarge) {
            [self setDisplayMode:PKProductsDisplayModeLarge];
            [self scrollCollectionViewToIndexPath:indexPath scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
    }
}

- (void)displayProductsViewControllerWithIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    PKProductsViewController *productsViewController = [PKProductsViewController createWithDisplayMode:PKProductsDisplayModeLarge
                                                                                             indexPath:indexPath];
    [productsViewController setDelegate:self];
    [productsViewController setDataSource:self];
    [[self navigationController] pushViewController:productsViewController animated:animated];
}

#pragma mark - UICollectionViewDelegate Methods

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Offset the footer:
    [[self labelFooter] setFrame:CGRectMake(scrollView.contentOffset.x,
                                            [[self labelFooter] frame].origin.y,
                                            [[self labelFooter] frame].size.width,
                                            [[self labelFooter] frame].size.height)];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updatePage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updatePage];
}

- (void)updatePage {
    // Determine the current index path being displayed:
    CGPoint point = CGPointMake([[self collectionView] contentOffset].x + ([[self collectionView] bounds].size.width * 0.5f),
                                [[self collectionView] contentOffset].y + ([[self collectionView] bounds].size.height * 0.5f));
    [self setIndexPath:[[self collectionView] indexPathForItemAtPoint:point]];
    
    // Display the current page:
    int currentPage = [(UICollectionView *)[self collectionView] currentPage];
    [[self labelFooter] setText:[NSString stringWithFormat:NSLocalizedString(@"#%i of %i results", @"Displays the number of products for a search. E.g. #1 of 20 results."), (currentPage + 1), (int)[[self products] count]]];
    
    // Update the delegate if required:
    if ([self displayMode] == PKProductsDisplayModeLarge) {
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkProductsViewController:didMoveToPage:)]) {
            [[self delegate] pkProductsViewController:self didMoveToPage:currentPage];
        }
        
        if ([self viewDidAppearCalled] && [self delegate] && [[self delegate] respondsToSelector:@selector(pkProductsViewController:didMoveToIndexPath:)]) {
            [[self delegate] pkProductsViewController:self didMoveToIndexPath:[self indexPath]];
        }
    }
}

#pragma mark - PKProductsViewControllerDelegate Methods

- (void)pkProductsViewController:(PKProductsViewController *)controller didMoveToIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - PKProductsViewControllerDataSource Methods

- (NSArray *)pkProductsViewControllerRequestsProducts:(PKProductsViewController *)controller {
    return [self products];
}

-(NSArray *)pkProductsViewControllerFilterProducts:(PKProductsViewController *)controller {
    int selectedSortFilter = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PKSortOption"] intValue];
    
    BOOL isAscending = YES;
    NSString *key = @"title";
    
    if(selectedSortFilter <= 0) {
        isAscending = NO;
    }
    
    PKProductWarehouse warehouse = [[[PKSession sharedInstance] currentFeedConfig] warehouse];
    
    int sortFilter = abs(selectedSortFilter);
    switch (sortFilter) {
        case PKSearchParameterTypeProductCode: {
            key = @"model";
            break;
        }
        case PKSearchParameterTypePrice: {
            key = @"firstPrice";
            break;
        }
        case PKSearchParameterTypeTotalSold: {
            key = @"totalSold";
            break;
        }
        case PKSearchParameterTypeTotalValue: {
            key = @"totalValue";
            break;
        }
        case PKSearchParameterTypeStockAvailable: {
            switch (warehouse) {
                default:
                case PKProductWarehouseUK:
                    key = @"stockLevel";
                    break;
                case PKProductWarehouseEDC:
                    key = @"stockLevelEDC";
                    break;
            }
            break;
        }
        case PKSearchParameterTypeDateAdded: {
            key = @"dateAdded";
            break;
        }
        default: {
            key = @"model";
            break;
        }
    }
    
    NSArray *sortedResults = [[self products] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:key ascending:isAscending]]];
    [self updateProducts:sortedResults];
    return sortedResults;
}

#pragma mark - PKGenericTableViewControllerDelegate Methods

-(void)pkGenericTableViewController:(PKGenericTableViewController *)tableViewController didSelectItemId:(int)selectedItemId {
    [tableViewController dismissViewControllerAnimated:NO completion:^{
    }];
    
    // Force the resorting of the products:
    [self setProducts:[self products]];
    
    // Reload the collection view data:
    [[self collectionView] reloadData];
}

#pragma mark - PKCustomerSelectionDelegate Methods

- (void)pkCustomerSelectionDelegateSelectedCustomer:(PKCustomer *)customer andCreatedBasket:(PKBasket *)basket {
    [self dismissViewControllerAnimated:YES completion:^{
        [self refreshBasketButton];
    }];
}

#pragma mark - PKBasket Methods

- (void)basketUpdated:(NSNotification *)notification {
    if (![PKBasket sessionBasket]) {
        [[self collectionView] reloadData];
    }
}

#pragma mark - Currency Changes

- (void)didChangeCurrency:(NSNotification *)notification {
    [[self collectionView] reloadData];
}

#pragma mark - Product Display Methods

- (void)displayTopSellingProducts {
//    if ([[self products] count] == 0 || [self productMode] != PKProductModeTop) {
        [self setProductMode:PKProductModeTop];
        [self setProducts:[PKProduct topSellingProductsForFeedConfig:[[PKSession sharedInstance] currentFeedConfig] inContext:nil]];
        [self setTitle:NSLocalizedString(@"Top Sellers", nil)];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kPKUserDefaultsGlobalRanks] boolValue]) {
        [self setTitle:NSLocalizedString(@"Top Sellers Globally", nil)];
    }
    
        [[self collectionView] setContentOffset:CGPointZero animated:NO];
        [[self collectionView] reloadData];
//    }
}

- (void)displayTopGrossingProducts {
    if ([[self products] count] == 0 || [self productMode] != PKProductModeTop) {
        [self setProductMode:PKProductModeTop];
        [self setProducts:[PKProduct topGrossingProductsForFeedConfig:[[PKSession sharedInstance] currentFeedConfig] inContext:nil]];
        [self setTitle:NSLocalizedString(@"Top Grossing", nil)];
        [[self collectionView] setContentOffset:CGPointZero animated:NO];
        [[self collectionView] reloadData];
    }
}

- (void)displayNewProducts {
    if ([[self products] count] == 0 || [self productMode] != PKProductModeNew) {
        [self setProductMode:PKProductModeNew];
        
        if ([[[PKSession sharedInstance] currentFeedConfig] warehouse] == PKProductWarehouseUK) {
            [self setProducts:[PKProduct newProductsForFeedConfig:[[PKSession sharedInstance] currentFeedConfig] inContext:nil]];
        } else {
            [self setProducts:[PKProduct newEDCProductsForFeedConfig:[[PKSession sharedInstance] currentFeedConfig] inContext:nil]];
        }
        
        for (PKProduct *product in [self products]) {
            if ([[product model] isEqualToString:@"TUSSMUG315"]) {
                NSLog(@"Found!");
            }
        }
        
        [self setTitle:NSLocalizedString(@"New & Coming Soon", nil)];
        [[self collectionView] setContentOffset:CGPointZero animated:NO];
        [[self collectionView] reloadData];
    }
}

- (void)displayAddCategory:(id)sender {
    if ([[[self category] isCustom] boolValue]) {
        // Display delete options:
        if ([sender isKindOfClass:[UIButton class]]) {
            __weak PKProductsViewController *weakSelf = self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Custom Category Options", nil)
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            [[alertController popoverPresentationController] setSourceView:[sender superview]];
            [[alertController popoverPresentationController] setSourceRect:[sender frame]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Category", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete Category", nil)
                                                                                         message:NSLocalizedString(@"Are you sure you want to delete this category?", nil)
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf deleteCustomCategory];
                }];
                [alertController addAction:confirmAction];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }]];
            
            if ([[[self category] products] count] != 0) {
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Edit Products", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf displayCustomCategoryOptionsForCategory:[self category]];
                }]];
            }
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    } else {
        if ([[self products] count] == 0) {
        } else {
            if ([sender isKindOfClass:[UIButton class]]) {
                __weak PKProductsViewController *weakSelf = self;
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Custom Category Options", nil)
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
                [[alertController popoverPresentationController] setSourceView:[sender superview]];
                [[alertController popoverPresentationController] setSourceRect:[sender frame]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create New Category", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf displayCreateCategory:nil];
                }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add to Existing Category", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf displaySelectExistingCategories:sender];
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

- (void)displayCreateCategory:(id)sender {
    __weak PKProductsViewController *weakSelf = self;
    UIAlertController *alertController = alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Create New Category", nil)
                                                                                               message:@""
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:NSLocalizedString(@"Category Name", @"")];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = [[alertController textFields][0] text];
        [weakSelf addCustomCategoryWithName:name];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)displaySelectExistingCategories:(id)sender {
    __weak PKProductsViewController *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Category", nil)
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    [[alertController popoverPresentationController] setSourceView:[sender superview]];
    [[alertController popoverPresentationController] setSourceRect:[sender frame]];
    
    NSArray<PKCategory *> *categories = [PKCategory customSortedBy:PKCategorySortModeAlphabetically ascending:YES];
    [categories enumerateObjectsUsingBlock:^(PKCategory * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertController addAction:[UIAlertAction actionWithTitle:[category styledTitle] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf displayCustomCategoryOptionsForCategory:category];
        }]];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)displayCustomCategoryOptionsForCategory:(PKCategory *)category {
    PKCustomCategoryBarMode mode = PKCustomCategoryBarModeExisting;
    
    CGFloat barWidth = [[[self tabBarController] tabBar] width];
    PKCustomCategoryBar *categoryBar = [PKCustomCategoryBar createWithDelegate:self mode:mode];
    [categoryBar setTitle:[category styledTitle]];
    [[categoryBar view] setWidth:barWidth];
    [[categoryBar view] setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [[[self tabBarController] tabBar] addSubview:[categoryBar view]];
    
    [categoryBar setProductButtonsEnabled:NO];
    [[categoryBar view] setBackgroundColor:[UIColor orangeColor]];
    [categoryBar setCategory:category];
    [[PKSession sharedInstance] setCustomCategoryBar:categoryBar];
    
    [self setDisplayMode:PKProductsDisplayModeSmall];
    
    if ([[[PKSession sharedInstance] customCategoryBar] category] == [self category]) {
        [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeRemove];
    } else {
        [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeAdd];
    }
    [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeNone];
    [[[PKSession sharedInstance] customCategoryBar] setProductButtonsEnabled:YES];
}

//- (void)displayCustomCategoryOptionsForCategory:(PKCategory *)category {
//    [self setSelectedProducts:[NSMutableArray array]];
//
//    if ([[category isCustom] boolValue]) {
//        [self setCustomCategory:category];
//    } else {
//        [self setCustomCategory:nil];
//    }
//
//    if (![self customCategory]) {
//        [[[self customCategoryBar] view] removeFromSuperview];
//        [self setCustomCategoryBar:nil];
//        [[self collectionView] reloadData];
//        return;
//    }
//
//    [self setDisplayMode:PKProductsDisplayModeSmall];
//
//    PKCustomCategoryBarMode mode = PKCustomCategoryBarModeExisting;
//    if ([self category] == [self customCategory]) {
//        mode = PKCustomCategoryBarModeRemove;
//    }
//
//    PKCustomCategoryBar *categoryBar = [PKCustomCategoryBar createWithDelegate:self mode:mode];
//    [categoryBar setTitle:[[self customCategory] styledTitle]];
//    [[categoryBar view] setWidth:[[[self navigationController] navigationBar] width]];
//    [[[self navigationController] navigationBar] addSubview:[categoryBar view]];
//    [[categoryBar view] setBackgroundColor:[UIColor puckatorPrimaryColor]];
//    [self setCustomCategoryBar:categoryBar];
//}

- (void)addCustomCategoryWithName:(NSString *)name {
    [FSThread runOnMain:^{
        [self showHud:NSLocalizedString(@"Creating", nil)];
    }];
    
    __weak PKProductsViewController *weakSelf = self;
    [FSThread runInBackground:^{
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        
        PKCategory *category = [PKCategory MR_createEntityInContext:localContext];
        
        NSUUID *uuid = [NSUUID UUID];
        
        PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
        
        [category setCategoryId:[uuid UUIDString]];
        [category setFeedNumber:[feedConfig number]];
        [category setTitle:[name sanitize]];
        [category setSortOrder:@(-1)];
        [category setParent:@(-1)];
        [category setActive:@(YES)];
        [category setTitleClean:[[category title] clean]];
        [category setIsCustom:@(YES)];
        
//        [[weakSelf products] enumerateObjectsUsingBlock:^(PKProduct *product, NSUInteger idx, BOOL * _Nonnull stop) {
//            [product addCategoriesObject:category];
//            [category addProductsObject:product];
//        }];
        
        [localContext MR_saveToPersistentStoreAndWait];
        
        [FSThread runOnMain:^{
            [weakSelf hideHud];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Custom Category", nil)
                                                                                     message:NSLocalizedString(@"Your custom category has been created.", nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Products", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf displayCustomCategoryOptionsForCategory:category];
            }];
            [alertController addAction:cancelAction];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }];
    }];
}

- (void)deleteCustomCategory {
    if ([[[self category] isCustom] boolValue]) {
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [[self category] MR_deleteEntityInContext:localContext];
        [localContext MR_saveToPersistentStoreAndWait];
        
        __weak PKProductsViewController *weakSelf = self;
        [FSThread runOnMain:^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Custom Category", nil)
                                                                                     message:NSLocalizedString(@"Your custom category has been deleted.", nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [[weakSelf navigationController] popViewControllerAnimated:YES];
            }];
            [alertController addAction:cancelAction];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }];
    }
}

- (void)displayNewAvaliableProducts {
    if ([[self products] count] == 0 || [self productMode] != PKProductModeNewAvailable) {
        [self setProductMode:PKProductModeNewAvailable];
        [self setProducts:[PKProduct newAvailableProductsForFeedConfig:[[PKSession sharedInstance] currentFeedConfig] inContext:nil]];
        [self setTitle:NSLocalizedString(@"New Products in stock", nil)];
        [[self collectionView] setContentOffset:CGPointZero animated:NO];
        [[self collectionView] reloadData];
    }
}

- (void)displayInStockProducts {
    //if ([[self products] count] == 0) {
        [self setProductMode:PKProductModeInStock];
        
        // Get the date from the session:
        NSDate *date = nil;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"PKInStockBy"] isKindOfClass:[NSDate class]]) {
            date = [[NSUserDefaults standardUserDefaults] objectForKey:@"PKInStockBy"];
        }
        
        [self setProducts:[PKProduct inStockProductsByDate:date inCategory:[self category] forFeedConfig:[[PKSession sharedInstance] currentFeedConfig] inContext:nil]];
        [self setTitle:NSLocalizedString(@"Product In-Stock", nil)];
        [[self collectionView] setContentOffset:CGPointZero animated:NO];
        [[self collectionView] reloadData];
    //}
}

- (void)displayPastOrdersProducts {
    [self showHud:NSLocalizedString(@"Loading", nil) animated:NO];
    [FSThread runOnMain:^{
    [self setProductMode:PKProductModeCustomerProducts];
    [self setProducts:[PKProduct customerPastOrderProductsForCustomer:[[PKSession sharedInstance] currentCustomer] forFeedConfig:nil inContext:nil]];
        [self setTitle:NSLocalizedString(@"Past Orders", nil)];
        [[self collectionView] setContentOffset:CGPointZero animated:NO];
        [[self collectionView] reloadData];
        [self hideHud];
    }];
}

- (void)displayCustomerProducts {
    [self showHud:NSLocalizedString(@"Loading", nil) animated:NO];
    [FSThread runOnMain:^{
    [self setProductMode:PKProductModeCustomerProducts];
    [self setProducts:[PKProduct customerProductsForCustomer:[[PKSession sharedInstance] currentCustomer] forFeedConfig:nil inContext:nil]];
        [self setTitle:NSLocalizedString(@"Customer Products", nil)];
        [[self collectionView] setContentOffset:CGPointZero animated:NO];
        [[self collectionView] reloadData];
        [self hideHud];
    }];
}

- (void)displayAllProducts {
    [self setProductMode:PKProductModeCategory];
    [self setProducts:[PKProduct allProductsForFeedConfig:[[PKSession sharedInstance] currentFeedConfig] inContext:nil]];
    [self setTitle:NSLocalizedString(@"All Products", nil)];
    [[self collectionView] setContentOffset:CGPointZero animated:NO];
    [[self collectionView] reloadData];
}

#pragma mark - Bulk Product Add Methods

- (void)bulkAddRequested {
    // Display a confirmation alert:
    NSArray *products = [self products];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to add %d products to your basket?\n\nThis will replace any matching products with the base quantity and price.\n\nWARNING: This might be slow for large orders.", nil), (int)[products count]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Bulk Add", nil)
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    __weak PKProductsViewController *weakSelf = self;
    NSString *confirmTitle = [NSString stringWithFormat:NSLocalizedString(@"Add all products (%i)", nil), (int)[products count]];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showHud:NSLocalizedString(@"Loading", nil) withSubtitle:nil animated:NO interaction:NO];
        [weakSelf performSelector:@selector(bulkAddProducts:) withObject:products afterDelay:0.5f];
    }];
    [alertController addAction:actionConfirm];
    
    NSPredicate *predicate = [[NSPredicate alloc] init];
    PKProductWarehouse warehouse = [[[PKSession sharedInstance] currentFeedConfig] warehouse];
    switch (warehouse) {
        default:
        case PKProductWarehouseUK:
            predicate = [NSPredicate predicateWithFormat:@"availableStock > %i", 0];
            break;
        case PKProductWarehouseEDC:
            predicate = [NSPredicate predicateWithFormat:@"availableStockEDC > %i", 0];
            break;
    }
    
    NSArray *instockProducts = [products filteredArrayUsingPredicate:predicate];
    NSString *instockTitle = [NSString stringWithFormat:NSLocalizedString(@"Add Available Stock Products (%i)", nil), (int)[instockProducts count]];
    UIAlertAction *actionConfirmInStock = [UIAlertAction actionWithTitle:instockTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showHud:NSLocalizedString(@"Loading", nil) withSubtitle:nil animated:NO interaction:NO];
        [weakSelf performSelector:@selector(bulkAddProducts:) withObject:instockProducts afterDelay:0.5f];
    }];
    [alertController addAction:actionConfirmInStock];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)bulkAddProducts:(NSArray *)products {
    [products enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PKProduct class]]) {
            PKProduct *product = (PKProduct *)obj;
            PKProductPrice *productPrice = [product priceForQuantity:[NSNumber numberWithInt:1]];
            [[[PKSession sharedInstance] basket] addOrUpdateProduct:product
                                                           quantity:[productPrice quantity]
                                                              price:[productPrice priceWithCurrentFxRate]
                                                     customPriceSet:NO
                                                 productPriceObject:productPrice
                                                        incremental:NO
                                                            context:nil
                                                           skipSave:YES];
        }
    }];
    
    [[[PKSession sharedInstance] basket] save];
    
    // Hide the HUD:
    [FSThread runOnMain:^{
        [self hideHudAnimated:NO];
    }];
}

#pragma mark - PKCatalogueNavigationControllerButtonDelegate Methods

- (BOOL)pkCatalogueNavigationControllerShouldDisableSortButton:(PKCatalogueNavigationController *)catalogueNavigationController {
    return ([self productMode] == PKProductModeNew || [self productMode] == PKProductModeNewAvailable);
}

- (BOOL)pkCatalogueNavigationControllerIsCategoryCustom:(PKCatalogueNavigationController *)catalogueNavigationController {
    return [[[self category] isCustom] boolValue];
}

- (PKGenericTableType)pkCatalogueNavigationControlRequestsSortType:(PKCatalogueNavigationController *)catalogueNavigationController {
    if ([self productMode] == PKProductModeTop) {
        return PKGenericTableTypeSortTopProductsBy;
    } else {
        return PKGenericTableTypeSortProductsBy;
    }
}

- (void)pkCatalogueNavigationController:(PKCatalogueNavigationController *)catalogueNavigationController
                     didPressButtonType:(PKCatalogueButtonType)buttonType
                                 sender:(id)sender {
    if (buttonType == PKCatalogueButtonTypeBack) {
        [self buttonBackPressed:nil];
    } else {
        if (buttonType == PKCatalogueButtonTypeTopProducts) {
            [self displayTopSellingProducts];
        } else if (buttonType == PKCatalogueButtonTypeNewProducts) {
            [self displayNewProducts];
        } else if (buttonType == PKCatalogueButtonTypeNewAvailableProducts) {
            [self displayNewAvaliableProducts];
        } else if (buttonType == PKCatalogueButtonTypeInStockProducts) {
            [self displayInStockProducts];
        } else if (buttonType == PKCatalogueButtonTypeBulkAdd) {
            [self bulkAddRequested];
        } else if (buttonType == PKCatalogueButtonTypeAddCategory) {
            [self displayAddCategory:sender];
        } else if (buttonType == PKCatalogueButtonTypeCustomerProducts) {
            [self displayCustomerProducts];
        }
    }
}

- (void)pkCatalogueNavigationController:(PKCatalogueNavigationController *)catalogueNavigationController
                    didSearchWithParams:(PKSearchParameters *)params
                       andFoundProducts:(NSArray *)products {
    [self setProductMode:PKProductModeSearch];
    [self updateProducts:products];
}

#pragma mark - PKBrowseTableViewController Delegate

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectSupplier:(NSString *)supplier {
    __weak PKProductsViewController *weakSelf = self;
    [browseTableViewController dismissViewControllerAnimated:YES completion:^{
        [weakSelf setProductMode:PKProductModeSupplier];
        [weakSelf setCategory:nil];
        [weakSelf setCustomCategory:nil];
        [weakSelf setProducts:[PKProduct productsForSupplier:supplier]];
        [weakSelf setTitle:supplier];
        [[weakSelf collectionView] setContentOffset:CGPointZero animated:NO];
        [[weakSelf collectionView] reloadData];
        
        PKCatalogueNavigationController *navigationController = (PKCatalogueNavigationController *)[weakSelf navigationController];
        [navigationController refreshCustomCategoryButton];
    }];
}

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectBuyer:(NSString *)buyer {
    __weak PKProductsViewController *weakSelf = self;
    [browseTableViewController dismissViewControllerAnimated:YES completion:^{
        [weakSelf setProductMode:PKProductModeSupplier];
        [weakSelf setCategory:nil];
        [weakSelf setCustomCategory:nil];
        [weakSelf setProducts:[PKProduct productsForBuyer:buyer]];
        [weakSelf setTitle:buyer];
        [[weakSelf collectionView] setContentOffset:CGPointZero animated:NO];
        [[weakSelf collectionView] reloadData];
        
        PKCatalogueNavigationController *navigationController = (PKCatalogueNavigationController *)[weakSelf navigationController];
        [navigationController refreshCustomCategoryButton];
    }];
}

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectCategory:(PKCategory *)category {
    __weak PKProductsViewController *weakSelf = self;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf setProductMode:PKProductModeCategory];
        [weakSelf setCategory:category];
        [weakSelf setCustomCategory:nil];
        [weakSelf setProducts:[category productsSortBy:PKCategorySortModeAlphabetically ascending:YES]];
        [weakSelf setTitle:[category styledTitle]];
        [[weakSelf collectionView] setContentOffset:CGPointZero animated:NO];
        [[weakSelf collectionView] reloadData];
        
        PKCatalogueNavigationController *navigationController = (PKCatalogueNavigationController *)[weakSelf navigationController];
        [navigationController refreshCustomCategoryButton];
    }];
}

- (void)pkBrowseTableViewController:(PKBrowseTableViewController *)browseTableViewController didSelectFilter:(PKBrowseTableViewControllerFilter)filter {
    [self dismissViewControllerAnimated:YES completion:^{
        if (filter == PKBrowseTableViewControllerFilterNewProducts) {
            [self displayNewProducts];
        } else if (filter == PKBrowseTableViewControllerFilterTopSellers) {
            [self displayTopSellingProducts];
        } else if (filter == PKBrowseTableViewControllerFilterTopGrossing) {
            [self displayTopGrossingProducts];
        } else if (filter == PKBrowseTableViewControllerFilterAllProducts) {
            [self displayAllProducts];
        }
    }];
}

#pragma mark - PKCustomCategoryBarDelegate Methods

- (void)refreshCustomCategoryBar {
    if ([[self selectedProducts] count] == 0) {
        [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeNone];
    } else {
        if ([[[PKSession sharedInstance] customCategoryBar] category] == [self category]) {
            [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeRemove];
        } else {
            [[[PKSession sharedInstance] customCategoryBar] setProductMode:PKCustomCategoryBarProductModeAdd];
        }
    }
}

- (void)pkCustomCategoryBarConfirmed:(PKCustomCategoryBar *)customCategoryBar {
    if ([[self selectedProducts] count] == 0) {
        if ([[PKSession sharedInstance] customCategoryBar]) {
            [[[[PKSession sharedInstance] customCategoryBar] view] removeFromSuperview];
            [[PKSession sharedInstance] setCustomCategoryBar:nil];
            
            [self setDisplayMode:PKProductsDisplayModeMedium];
            [[self collectionView] reloadData];
        }
        return;
    }
    
    if ([[PKSession sharedInstance] customCategoryBar]) {
        [[[PKSession sharedInstance] customCategoryBar] addProducts:[self selectedProducts]];
        
        // Display confirmation alert:
        __weak PKProductsViewController *weakSelf = self;
        
        NSString *message = NSLocalizedString(@"The products have been added.", nil);
        
        if ([[[PKSession sharedInstance] customCategoryBar] productMode] == PKCustomCategoryBarProductModeRemove) {
            message = NSLocalizedString(@"The products have been removed.", nil);
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[[self customCategory] styledTitle]
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if ([weakSelf category] == [[[PKSession sharedInstance] customCategoryBar] category]) {
                [weakSelf setProducts:[[weakSelf category] productsSortBy:PKCategorySortModeAlphabetically ascending:YES]];
            }
            [weakSelf pkCustomCategoryBarCancelled:[self customCategoryBar]];
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        [[self selectedProducts] removeAllObjects];
        [self refreshCustomCategoryBar];
    }
}

- (void)pkCustomCategoryBarCancelled:(PKCustomCategoryBar *)customCategoryBar {
    [self setCustomCategory:nil];
    [self setSelectedProducts:nil];
    [[[self customCategoryBar] view] removeFromSuperview];
    [self setCustomCategoryBar:nil];
    [self setDisplayMode:PKProductsDisplayModeMedium];
    [[self collectionView] reloadData];
}

- (void)pkCustomCategoryBarSelectAll:(PKCustomCategoryBar *)customCategoryBar {
    if (![self selectedProducts]) {
        [self setSelectedProducts:[NSMutableArray array]];
    }
    [[self selectedProducts] removeAllObjects];
    [[self selectedProducts] addObjectsFromArray:[self products]];
    [[self collectionView] reloadData];
    
}

- (void)pkCustomCategoryBarSelectNone:(PKCustomCategoryBar *)customCategoryBar {
    if (![self selectedProducts]) {
        [self setSelectedProducts:[NSMutableArray array]];
    }
    [[self selectedProducts] removeAllObjects];
    [[self collectionView] reloadData];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self setProducts:nil];
    [self setCategory:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"[%@] - Dealloc", [self class]);
}

#pragma mark -

@end
