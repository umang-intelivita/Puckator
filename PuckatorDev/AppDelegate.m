//
//  AppDelegate.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "PuckatorKit.h"
#import "PKFeed.h"
#import "PKFeedManifest.h"
#import "UIColor+Puckator.h"
#import <FCFileManager/FCFileManager.h>
#import "PKConstant.h"
#import <MagicalRecord/MagicalRecord.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFSoundManager/AFSoundManager.h>
#import "FXBlurView.h"
#import <FMDB/FMDatabase.h>
#import "NSManagedObjectModel+KCOrderedAccessorFix.h"
#import "PKOrderSyncViewController.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import "PKOrderSyncViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "PKOnboardingViewController.h"
#import "FSEnterpriseUpdateCheckViewController.h"
#import "PKImage+Operations.h"
#import "PKBasket+Operations.h"
#import "PKLanguage.h"
#import <MTMigration/MTMigration.h>
#import "PKLocalCustomer.h"
#import "PKLocalCustomer+Operations.h"
#import "PKDeactivatedViewController.h"
#import "PKNetworking.h"
@import Firebase;
@import AppCenter;
@import AppCenterAnalytics;
@import AppCenterCrashes;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Catch any uncaught exceptions:
    NSSetUncaughtExceptionHandler(&HandleExceptions);
    [FIRApp configure];
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        navBarAppearance.backgroundColor = [UIColor puckatorPrimaryColor];
        [navBarAppearance configureWithTransparentBackground];
        navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                 NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0]};

        [UINavigationBar appearance].standardAppearance = navBarAppearance;
        [UINavigationBar appearance].scrollEdgeAppearance = navBarAppearance;
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
        [UINavigationBar appearance].backgroundColor = [UIColor puckatorPrimaryColor];
        [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                             NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0]};
        
        UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
        tabBarAppearance.backgroundColor = [UIColor puckatorPrimaryColor];
        tabBarAppearance.inlineLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor puckatorLightPurple],
                                                                               NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-DemiBold" size:10.0]};
        tabBarAppearance.inlineLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor puckatorGreen],
                                                                                 NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-DemiBold" size:10.0]};
        tabBarAppearance.stackedLayoutAppearance = tabBarAppearance.inlineLayoutAppearance;
        tabBarAppearance.compactInlineLayoutAppearance = tabBarAppearance.inlineLayoutAppearance;
        
        //[tabBarAppearance configureWithDefaultBackground];
        
        [UITabBar appearance].standardAppearance = tabBarAppearance;
        [UITabBar appearance].scrollEdgeAppearance = tabBarAppearance;
        [[UITabBar appearance] setTintColor:[UIColor puckatorLightPurple]];
    } else {
        [[UINavigationBar appearance] setBarTintColor:[UIColor puckatorPrimaryColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                               NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0]}];
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                               NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:16.0]} forState:UIControlStateNormal];
        
        [[UIToolbar appearance] setBarTintColor:[UIColor puckatorPrimaryColor]];
        [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
        
        [[UITabBar appearance] setBarTintColor:[UIColor puckatorPrimaryColor]];
        [[UITabBar appearance] setTintColor:[UIColor puckatorLightPurple]];
        //[[UITabBar appearance] setSelectedImageTintColor:[UIColor puckatorGreen]];
        
        [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UITabBar class]]] setTintColor:[UIColor puckatorLightPurple]];
        
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor puckatorLightPurple],
                                                            NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-DemiBold" size:10.0]}
                                                 forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor puckatorGreen],
                                                            NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-DemiBold" size:10.0]}
                                                 forState:UIControlStateSelected];
        
        [[UITableViewCell appearance] setTintColor:[UIColor puckatorPrimaryColor]];
    }
    
    // Setup core data:
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [[NSManagedObjectModel MR_defaultManagedObjectModel] kc_generateOrderedSetAccessors];
    
    NSLog(@"Document Path: %@", [FCFileManager pathForDocumentsDirectory]);
    
    // Fix the keyboard lag:
    [self fixKeyboardLag];
    
    [MTMigration migrateToBuild:@"1.0.57" block:^{
        // Set the force_image_download flag:
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"force_image_download"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    // Setup notifications:
    [self setupNotifications];
    
    // Override point for customization after application launch:
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    
    // Update the translations of the tab bar items:
    if ([[[self window] rootViewController] isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)[[self window] rootViewController];
        if ([[[tabBarController tabBar] items] count] >= 3) {
            [[[[tabBarController tabBar] items] objectAtIndex:1] setTitle:NSLocalizedString(@"Customers", nil)];
            [[[[tabBarController tabBar] items] objectAtIndex:2] setTitle:NSLocalizedString(@"View Order", nil)];
            //[[[[tabBarController tabBar] items] objectAtIndex:6] setTitle:NSLocalizedString(@"View Order", nil)];
        }
    }
    
    // Perform a check to make sure at least one feed have been
    // configured and syncronised:
    [self checkForConfiguredAndSyncronisedFeeds];
    
    [MSACAppCenter start:@"8d84c263-c565-444b-95e3-34c603ca329b" withServices:@[
      [MSACAnalytics class],
      [MSACCrashes class]
    ]];
     
    return YES;
}

- (void)fixKeyboardLag {
    // Preloads keyboard so there's no lag on initial keyboard appearance:
    UITextField *lagFreeField = [[UITextField alloc] init];
    [[self window] addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
}

- (void)checkForConfiguredAndSyncronisedFeeds {
    BOOL hasConfiguredFeedsAndSyncronised = NO;
    if ([[PKFeedConfig feeds] count] != 0) {
        hasConfiguredFeedsAndSyncronised = YES;
        
        // Validate that at least one feed has been syncronised...
        int numberOfFeedsNotSyncronised = 0;
        for(PKFeedConfig *config in [PKFeedConfig feeds]) {
            if(![config hasSyncronised]) {
                numberOfFeedsNotSyncronised++;
            }
        }
        
        if (numberOfFeedsNotSyncronised == [[PKFeedConfig feeds] count]) {
            hasConfiguredFeedsAndSyncronised = NO;
        }
    }
    
    if (hasConfiguredFeedsAndSyncronised == NO) {
        PKOnboardingViewController *viewController = [[PKOnboardingViewController alloc] init];
        [[self window] setRootViewController:viewController];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Disable auto lock:
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status >= AFNetworkReachabilityStatusReachableViaWWAN) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkOutboxForSync];
                [self checkForAppUpdates];
            });
        }
    }];
    
    __block NSString *customMessage = nil;
    [self checkForImageDeletionCustomMessage:customMessage disableCancel:(customMessage != nil)];
    [self checkOutboxForSync];
    [self checkForAppUpdates];
    [self checkForWipedFeeds];    
    
//    if ([self isCurrentFeedWiped]) {
//        [self resetMainStoryboard];
//    }
}

- (void)checkForWipedFeeds {
    // Load the current feed configs:
    NSArray *currentFeeds = [PKFeedConfig feeds];
    
    // Download the feed manifest:
    [PKNetworking fetchSyncManifest:^(BOOL success, NSDictionary *userInfo, NSError *error) {
        if (success) {
            // Prepare the sync data based on the response
            if ([[userInfo objectForKey:@"success"] boolValue] == YES) {
                // Get the dictionary of feeds returned
                NSDictionary *feeds = [userInfo objectForKey:@"manifest"];
                
                for (NSString *key in feeds) {
                    NSDictionary *feedData = [feeds objectForKey:key];
                    NSDictionary *metaData = [feedData objectForKey:@"meta_data"];
                    BOOL isWiped = [[metaData objectForKey:@"RequiresWipe"] boolValue];
                    
                    NSString *defaultWarehouse = @"UK";
                    if ([[metaData objectForKey:@"DefaultWarehouse"] isKindOfClass:[NSString class]]) {
                        defaultWarehouse = [metaData objectForKey:@"DefaultWarehouse"];
                    }
                    
                    // Update all the current feeds:
                    for (PKFeedConfig *config in currentFeeds) {
                        if ([[[config number] lowercaseString] isEqualToString:[key lowercaseString]]) {
                            [config setIsWiped:@(isWiped)];
                            [config save];
                        }
                    }
                    
                    // Update the current feed config:
                    PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
                    if (feedConfig && [[feedConfig number] isEqualToString:key]) {
                        [feedConfig setIsWiped:@(isWiped)];
                        [feedConfig setDefaultWarehouse:defaultWarehouse];
                        [feedConfig save];
                    }
                }
            }
        }
        
        // Check if the current feed is wiped:
        [FSThread runOnMain:^{
            if ([self isCurrentFeedWiped]) {
                [self resetMainStoryboard];
            }
        }];
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

void HandleExceptions(NSException *exception) {
    NSLog(@"[%@] - The app has encountered an unhandled exception: %@", @"AppDelegate.m", [exception debugDescription]);
    
    // Save any open orders:
    [AppDelegate saveOpenBaskets];
}

#pragma mark - Wipe Check

- (BOOL)isCurrentFeedWiped {
    PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
    return [[feedConfig isWiped] boolValue];
}

#pragma mark - Updates

+ (void)saveOpenBaskets {
    // Get all open baskets:
    NSArray *openBaskets = [PKBasket openBasketsIncludeErrored:YES context:nil];
    if ([openBaskets count] != 0) {
        NSLog(@"[%@] - Open Baskets: %d", [self class], (int)[openBaskets count]);
        
        // Get the first open basket:
        [openBaskets enumerateObjectsUsingBlock:^(PKBasket *basket, NSUInteger idx, BOOL * _Nonnull stop) {
            PKCustomer *customer = [PKCustomer findCustomerWithId:[basket customerId]];
            NSLog(@"[%@] - Basket Customer: %@", [self class], [customer companyName]);
        }];
    }
}

- (void) checkForAppUpdates {
    // Check for app updates
    [FSEnterpriseUpdateCheckViewController checkForUpdates:^(BOOL isUpdatesAvailable) {
        if (isUpdatesAvailable) {
            UINavigationController *navController = [FSEnterpriseUpdateCheckViewController createWithNavController];
            [navController setModalPresentationStyle:UIModalPresentationFormSheet];
            [[[self window] rootViewController] presentViewController:navController animated:YES completion:nil];
        }
    }];
}

#pragma mark - Private Methods

- (void)checkForImageDeletionCustomMessage:(NSString *)customMessage disableCancel:(BOOL)disableCancel {
    if (!customMessage || [customMessage length] == 0) {
        customMessage = NSLocalizedString(@"Are you sure you would like to delete all product images?\n\nYou will need perform a full sync to download the product images again.", nil);
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"delete_product_images"]) {
        RIButtonItem *itemDelete = [RIButtonItem itemWithLabel:@"Delete Images" action:^{
            // Disable the product image delete flag:
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"delete_product_images"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [FSThread runOnMain:^{
                [[[self window] rootViewController] showHud:@"Deleting Images" animated:NO];
            }];
            
            [FSThread runInBackground:^{
                NSLog(@"[%@] - Deleting all images", [self class]);
                if ([PKImage deleteAllImages]) {
                    NSLog(@"[%@] - All images have been deleted", [self class]);
                    NSLog(@"[%@] - Deleting all thumbs", [self class]);
                    if ([PKImage deleteAllThumbs]) {
                        NSLog(@"[%@] - All thumbs have been deleted", [self class]);
                    }
                }
                
                [FSThread runOnMain:^{
                    RIButtonItem *itemReset = [RIButtonItem itemWithLabel:@"Reset App" action:^{
                        [self resetMainStoryboard];
                    }];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Images Deleted"
                                                                        message:@"All product images have been deleted.\n\nYou'll now need to reset the app and perform a full sync in order to download the product images again."
                                                               cancelButtonItem:itemReset
                                                               otherButtonItems:nil];
                    [alertView show];
                    
                    [[[self window] rootViewController] hideHud];
                }];
            }];
        }];
        
        RIButtonItem *itemCancel = nil;
        
        if (!disableCancel) {
            itemCancel = [RIButtonItem itemWithLabel:@"Cancel" action:^{
                // Disable the product image delete flag:
                [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"delete_product_images"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Image Deletion"
                                                            message:customMessage
                                                   cancelButtonItem:itemCancel
                                                   otherButtonItems:itemDelete, nil];
        [alertView show];
    }
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSyncProgressComplete object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationFeedDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetMainStoryboard) name:kNotificationSyncProgressComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetMainStoryboard) name:kNotificationFeedDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performOrderSync) name:kNotificationSyncOrderRequest object:nil];
}

- (void)checkOutboxForSync {
    // Check if we have orders pending in the outbox...
    int unsentOrderCount = (int)[[PKOrderSyncViewController orderFilenames] count];
    if (unsentOrderCount >= 1) {
        RIButtonItem *buttonContinue = [RIButtonItem itemWithLabel:NSLocalizedString(@"Send Now", nil) action:^{
            [self performOrderSync];
        }];
        
        RIButtonItem *buttonLater = [RIButtonItem itemWithLabel:NSLocalizedString(@"Remind Later", nil) action:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You have orders in your outbox that have not been sent yet", nil)
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"Unsent orders: %d", @"Used to inform the user how many order they have to send. E.g. 'Unsent orders: 5'"), unsentOrderCount]
                                               cancelButtonItem:buttonLater
                                               otherButtonItems:buttonContinue, nil];
        [alert show];
    }
}

- (void)performOrderSync {
    PKOrderSyncViewController *orderSyncVc = [PKOrderSyncViewController create];
    UINavigationController *navController = [orderSyncVc withNavigationController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[[self window] rootViewController] presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Notification Methods

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"Notification fired");
}

#pragma mark - App Reset Methods

- (void)resetMainStoryboard {
    // Close the current basket:
    [[PKBasket sessionBasket] cancelOrder];
    [[PKSession sharedInstance] setCurrentFeedConfig:nil];
    [[PKSession sharedInstance] clear];
    
    // Reset the SQL databases:
    [[PKDatabase sharedInstance] restart];
    
    id viewController = nil;
    
    if ([self isCurrentFeedWiped]) {
        viewController = [PKDeactivatedViewController create];
    } else {
        // Setup the main storyboard again:
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        viewController = [storyboard instantiateInitialViewController];
    }
    
    // Play sound
#if !TARGET_IPHONE_SIMULATOR
    [[AFSoundManager sharedManager] startPlayingLocalFileWithName:@"QuickReverse.wav" atPath:nil withCompletionBlock:nil];
#endif
    
    // Animate the transition
    [[self window] setRootViewController:nil];
    [UIView transitionWithView:[self window] duration:1.0f options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        // Do the switch
        BOOL areAnimationsEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [[self window] setRootViewController:viewController];
        [UIView setAnimationsEnabled:areAnimationsEnabled];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -

@end
