//
//  FSEnterpriseUpdateCheckViewController.m
//
//  Created by Jamie Chapman on 04/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSEnterpriseUpdateCheckViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MKFoundationKit/MKFoundationKit.h>
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

@interface FSEnterpriseUpdateCheckViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelVersion;

@end

@implementation FSEnterpriseUpdateCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (UINavigationController*) createWithNavController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FSEnterpriseUpdate" bundle:[NSBundle mainBundle]];
    UINavigationController *navController = [storyboard instantiateInitialViewController];
    return navController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self labelVersion] setText:[NSString stringWithFormat:NSLocalizedString(@"You are using version: %@", @"Informs the user of which version of the app they're running. E.g. 'You are using version: 1.0'"), [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Check update and push a UI if available
    [self checkForUpdates];
}

+ (void) checkForUpdates:(FSEnterpriseUpdateCheckCompletionBlock)completionBlock {
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FSEnterpriseUpdate" ofType:@"plist"]];
    NSString *endpointUrlFormat = [settings objectForKey:@"endpoint"];
    NSString *endpointUri = [NSString stringWithFormat:endpointUrlFormat, [[NSBundle mainBundle] mk_version]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [manager GET:endpointUri parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        
        // Parse the response
        BOOL isUpdateAvailable = [[responseObject objectForKey:@"update_available"] boolValue];
        if(isUpdateAvailable) {
            if([responseObject objectForKey:@"detail"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"detail"]
                                                          forKey:@"LatestUpdateAvailable"];
            } else {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LatestUpdateAvailable"];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LatestUpdateAvailable"];
        }
        
        // Serialize update info
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Inform the completion block about the updates
        completionBlock(isUpdateAvailable);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

- (void) checkForUpdates {
    [FSEnterpriseUpdateCheckViewController checkForUpdates:^(BOOL isUpdateAvailable) {
        if (isUpdateAvailable) {
            [self performSegueWithIdentifier:@"SegueAppUpdate" sender:self];
        } else {
            RIButtonItem *itemDismiss = [RIButtonItem itemWithLabel:NSLocalizedString(@"Dismiss", nil) action:^{
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            }];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"App Update", nil)
                                                                message:[NSString stringWithFormat:NSLocalizedString(@"Version: %@\nYour app is up to date.", @"Used to inform the user their app is up to date. E.g. 'Version 1.0 Your app is up to date'"), [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]
                                                       cancelButtonItem:itemDismiss
                                                       otherButtonItems:nil];
            [alertView show];
        }
    }];
}

@end
