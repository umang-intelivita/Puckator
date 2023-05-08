//
//  PKSearchSplitViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 27/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKSearchSplitViewController.h"
#import "PKProductsViewController.h"

@interface PKSearchSplitViewController ()

@end

@implementation PKSearchSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *navController = [[self viewControllers] lastObject];
    PKProductsViewController *productsViewController = (PKProductsViewController*)[[navController viewControllers] firstObject];
    [productsViewController setSearchDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pkProductsViewController:(PKProductsViewController *)controller didSelectProduct:(PKProduct *)product {
    
    //PKProductViewController *controller = [PKProductViewController ]
    //PKProductsViewController *controller = [PKProductsViewController ]
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
