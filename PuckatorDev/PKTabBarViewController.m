//
//  PKTabBarViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 05/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKTabBarViewController.h"
#import "PKActiveFeedView.h"

@interface PKTabBarViewController ()
@property (nonatomic, strong) PKActiveFeedView *activeFeedView;
@end

@implementation PKTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDelegate:self];
    
    // Setup feed switcher
    int width = self.tabBar.bounds.size.width / (float)self.tabBar.items.count;
    [self setActiveFeedView:[[PKActiveFeedView alloc] init]];
    [[[self activeFeedView] view] setFrame:CGRectMake(self.tabBar.bounds.size.width-width, 0, width, 50)];
    [[self tabBar] addSubview:[[self activeFeedView] view]];
    
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if([viewController class] == [UIViewController class]) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
