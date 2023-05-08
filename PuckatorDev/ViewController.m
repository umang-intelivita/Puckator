//
//  ViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "ViewController.h"
#import "PKZoomTransitioningDelegate.h"
#import "PKProductsViewController.h"
#import "PKProductReusableView.h"

@interface ViewController ()

@property (strong, nonatomic) PKZoomTransitioningDelegate *transitioningDelegate;
@property (assign, nonatomic) int section;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKCategoryCell"
                                                      bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PKCategoryCell"];
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKProductCell"
                                                      bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PKProductCell"];
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PKProductReusableView" bundle:[NSBundle mainBundle]]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"PKProductReusableView"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:NSLocalizedString(@"Categories", nil)];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sync", nil)
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(buttonLoginPressed:)]];
}

- (void)buttonLoginPressed:(id)sender {
    // Show sync interface
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:[NSBundle mainBundle]];
    id viewController = [storyboard instantiateInitialViewController];
    [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:viewController animated:YES completion:^{
        NSLog(@"View Controller Did Appear!");
    }];
}

- (void) switchFeeds:(id)sender {
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PKWallpaper2.png"]]];
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 50;
}

//- (CGSize) collectionView:(UICollectionView *)collectionView
//                   layout:(UICollectionViewLayout *)collectionViewLayout
//referenceSizeForHeaderInSection:(NSInteger)section {
//    //return CGSizeZero;
//    //return CGSizeMake(60.0f, 30.0f);
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifierCategoryCell = @"PKCategoryCell";
    static NSString *identifierProductCell = @"PKProductCell";
    
    // Dequeue a cell:
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self showProducts] ? identifierProductCell : identifierCategoryCell
                                                                           forIndexPath:indexPath];
    [cell setClipsToBounds:YES];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Get the selected collection view cell:
    [self setSection:(int)[indexPath row]];
    [[self navigationController] setDelegate:self];
    [self performSegueWithIdentifier:@"viewProducts" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PKProductsViewController *productViewController = (PKProductsViewController *)[segue destinationViewController];
    [productViewController setUseLayoutToLayoutNavigationTransitions:YES];
    //[productViewController setTransitioningDelegate:[self transitioningDelegate]];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    //return;
    //[[self collectionView] reloadData];
    if ([viewController isKindOfClass:[PKProductsViewController class]]) {
        PKProductsViewController *productsViewController = (PKProductsViewController*)viewController;
        productsViewController.collectionView.dataSource = productsViewController;
        productsViewController.collectionView.delegate = productsViewController;
        [productsViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self section]] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        //[dvc.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }
    else if (viewController == self){
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self section] inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                    withReuseIdentifier:@"PKProductReusableView"
                                                                                           forIndexPath:indexPath];
        if (reusableview == nil) {
            reusableview = [[PKProductReusableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        }
        return reusableview;
        
    }
    return nil;
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

}

#pragma mark -

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
