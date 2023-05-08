//
//  PKSyncViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKSyncViewController.h"
#import "PKNetworking.h"
#import "UIAlertView+Puckator.h"
#import "PKConstant.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import <JWT/JWT.h>
#import "PKSyncTableViewCell.h"
#import "FSThread.h"
#import "PKFeedImages.h"
#import "PKFeed.h"
#import "PKFeedSQL.h"

@interface PKSyncViewController ()

@property (weak, nonatomic) IBOutlet UITableView *syncTableView;
@property (nonatomic, strong) NSArray *feeds;
@property (nonatomic, strong) NSArray *downloads;
@property (nonatomic, assign) BOOL didSyncComplete;

@end

@implementation PKSyncViewController

#pragma mark - Constructor Methods

+ (instancetype)createWithOriginType:(PKSyncOriginType)syncOriginType {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:nil];
    PKSyncViewController *syncViewController = (PKSyncViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SyncController"];
    [syncViewController setOrigin:syncOriginType];
    return syncViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Sync", nil)];
    [[self syncTableView] setAlpha:0.0f];
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkConnectivity];
}

- (NSArray *)allFeeds {
    NSMutableArray *feeds = [NSMutableArray array];
    
    [feeds addObjectsFromArray:[self feeds]];
    [feeds addObjectsFromArray:[self downloads]];
    
    return feeds;
}

#pragma mark - Table View Delegate/Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[self feeds] count];
    } else {
        return [[self downloads] count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PKSyncTableViewCell *cell = (PKSyncTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SyncCell" forIndexPath:indexPath];
    
    if ([indexPath section] == 0) {
        PKFeedConfig *feedConfig = nil;
        if (indexPath.row < [[self feeds] count]) {
            feedConfig = [self feeds][indexPath.row];
        }
        
        [cell setFeedConfig:feedConfig];
    } else {
        PKFeedConfig *feedConfig = nil;
        if (indexPath.row < [[self downloads] count]) {
            feedConfig = [self downloads][indexPath.row];
        }
        
        [cell setFeedConfig:feedConfig];
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

#pragma mark - Data

- (void) prepareToSync {
    if ([self didSyncComplete]) {
        return;
    }
    
    // Get the feeds
    [self setFeeds:[PKFeedConfig feeds]];
    
    // Refresh the table
    [[self syncTableView] reloadData];
    
    // Show toolbar
    [[self navigationController] setToolbarHidden:NO animated:YES];
    
    // Start the sync process by downloading the server manifest
    [self startSync];
}

- (void) startSync {
    [[self navigationItem] setHidesBackButton:YES animated:YES];
    
    [self showHud:NSLocalizedString(@"One Moment...", nil) withSubtitle:NSLocalizedString(@"Authorising...", nil)];
    
    // Fetch the manifest from the server
    PKJob *manifestJob = [[PKJobManager sharedInstance] createJobWithTitle:@"Fetching Feed Manifest" forFeedNumber:nil];
    [PKNetworking fetchSyncManifest:^(BOOL success, NSDictionary *userInfo, NSError *error) {
        if (success) {
            NSLog(@"Success! %@", userInfo);
            
            // Prepare the sync data based on the response
            if([[userInfo objectForKey:@"success"] boolValue] == YES) {
                // Get the dictionary of feeds returned
                NSDictionary *feeds = [userInfo objectForKey:@"manifest"];
                NSMutableArray *feedsAvailable = [NSMutableArray array];
                
                for (PKFeedConfig *config in [self feeds]) {
                    for (NSString *key in feeds) {
                        if ([key isEqualToString:[config number]]) {
                            // Update any meta data (for example, currency data) at this point
                            NSDictionary *feedData = [feeds objectForKey:key];
                            NSDictionary *metaData = [feedData objectForKey:@"meta_data"];
                            NSDictionary *feedObject = [metaData objectForKey:@"FeedObject"];
                            
                            if([feedObject objectForKey:@"Currencies"]) {
                                [PKFeedConfigMeta syncroniseCurrenciesWithFeedConfig:config
                                                                          currencies:[[[feedData objectForKey:@"meta_data"] objectForKey:@"FeedObject"] objectForKey:@"Currencies"]
                                                                             context:nil];
                            }
                            
                            // Update actual feed_meta values
                            if ([feedObject objectForKey:@"FeedMetaData"]) {
                                [PKFeedConfigMeta syncroniseFeedMetaDataWithFeedConfig:config
                                                                            currencies:[[[feedData objectForKey:@"meta_data"] objectForKey:@"FeedObject"] objectForKey:@"FeedMetaData"]
                                                                               context:nil];
                            }
                            
                            // Parse the meta data:
                            if (metaData) {
                                // Get the supplier search flag:
                                [config setSupplierSearch:[[metaData objectForKey:@"SupplierSearch"] boolValue]];
                                
                                // Get the solo container URL:
                                NSString *soloContainerUrl = [metaData objectForKey:@"SoloFeedContainer"];
                                if ([soloContainerUrl length] != 0) {
                                    [config setSyncData:@{@"url" : soloContainerUrl}];
                                }
                            }
                                                        
                            [config setType:PKFeedConfigTypeDataFeed];
                            [config setIsWiped:@([[metaData objectForKey:@"RequiresWipe"] intValue])];
                            if ([[metaData objectForKey:@"DefaultWarehouse"] isKindOfClass:[NSString class]]) {
                                [config setDefaultWarehouse:[metaData objectForKey:@"DefaultWarehouse"]];
                            } else {
                                [config setDefaultWarehouse:@"UK"];
                            }
                            
                            if(config.isWiped) {
                                // Save the config:
                                [config save];
                                
                                // Add the config to the feeds array:
                                if (config) {
                                    [feedsAvailable addObject:config];
                                }
                            }
                        }
                    }
                }
                
                // Create a new "feed" for syncing the images
                PKFeedConfig *accounts = [[PKFeedConfig alloc] init];
                [accounts setNumber:@"ACCOUNTS"];
                [accounts setName:NSLocalizedString(@"Accounts", nil)];
                [accounts setUuid:[[NSUUID UUID] UUIDString]];
                [accounts setType:PKFeedConfigTypeSQLDownloader];
                
                // Create a new "feed" for syncing the images
                PKFeedConfig *images = [[PKFeedConfig alloc] init];
                [images setNumber:@"IMAGES"];
                [images setName:NSLocalizedString(@"Images", nil)];
                [images setUuid:[[NSUUID UUID] UUIDString]];
                [images setType:PKFeedConfigTypeImageDownloader];
                
                // Add the 'jobs' to the downloads array:
                [self setDownloads:@[accounts, images]];
                
                // Update job
                [manifestJob completeJob];
                
                // Reset feeds available to the ones returned by the server
                [self setFeeds:feedsAvailable];
                [[self syncTableView] reloadData];
                
                // Fade in the table view
                [UIView animateWithDuration:0.5 animations:^{
                    [[self syncTableView] setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    NSLog(@"Proceed to the next step...");
                    [self prepareDownloads];
                }];
            } else {
                NSLog(@"failed to fetch the sync manifest from the server! %@", userInfo);
                [manifestJob failJobWithErrorMessage:@"Server did not return a successful sync manifest"];
                
                if(userInfo && [userInfo objectForKey:@"message"]) {
                    [self failWithError:[userInfo objectForKey:@"message"]];
                } else {
                    [self failWithError:@"Server did not return a successful sync manifest!"];
                }
            }
        } else {
            NSLog(@"Error! %@", error);
            [manifestJob failJobWithErrorMessage:@"Error connecting to the server!" andError:error];
            [self failWithError:[NSString stringWithFormat:@"Error connecting to the server! %@", [error localizedDescription]]];
        }
    }];
}

- (void) failWithError:(NSString*)errorMessage {
    // Show the back button again
    [[self navigationItem] setHidesBackButton:NO animated:YES];
    
    // Show alert
    [UIAlertView showAlertWithTitle:NSLocalizedString(@"Syncronisation Error", nil) andMessage:errorMessage];
}

- (void) prepareDownloads {
    // Setup a queue of operations for each feed
    for (PKFeedConfig *feedConfig in [self allFeeds]) {
        // Create an array of feed jobs
        [feedConfig setFeedQueue:[NSMutableArray array]];
        
        if ([feedConfig type] == PKFeedConfigTypeDataFeed) {
            [feedConfig setFeedQueue:[NSMutableArray arrayWithObjects:[PKFeedSQL createWithConfig:feedConfig andEndpoint:PKFeedSQLEndpointData], nil]];
        }
        
        if ([feedConfig type] == PKFeedConfigTypeSQLDownloader) {
            [feedConfig setFeedQueue:[NSMutableArray arrayWithObjects:[PKFeedSQL createWithConfig:feedConfig andEndpoint:PKFeedSQLEndpointAccounts], nil]];
        }
        
        // Check if the image download should be skipped:
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"sync_skip_images"]) {
            // Is this an image downloader feed?
            if ([feedConfig type] == PKFeedConfigTypeImageDownloader) {
                PKFeedImages *imagesFeed = [PKFeedImages createWithUrl:[NSURL URLWithString:@"images://"] andConfig:feedConfig];
                [feedConfig setFeedQueue:[NSMutableArray arrayWithObject:imagesFeed]];
            }
        }
        
        // Sort the feeds by order of priority.  This will ensure that items are downloaded/processed in a specific order.
        [[feedConfig feedQueue] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES]]];
        
        // Configure other types of feed here...
        NSLog(@"Feeds to process: %@", [feedConfig feedQueue]);
        
        // Count the total number of feeds to process in this config
        [feedConfig setTotalFeedsEnqueued:(int)[[feedConfig feedQueue] count]];
    }
    
    [self nextDelegateFeed];
}

- (void)pkFeedFinished:(PKFeed *)feed {
    NSLog(@"[%@ Feed] - Finished", [PKFeed nameForFeedType:[feed type]]);
    
    
    
    if ([[PKFeed nameForFeedType:[feed type]] isEqualToString: @"Images"]) {
        
        
        PKFeedConfig *config = [self currentFeed];
        [config setIsSyncFinished:YES];
        [config setHasSyncronised:YES]; // Saves against the config to signify the sync has happened at least once
        [config setDateLastSyncronised:[NSDate date]];
        [config notifyProgressUpdate];
        [config save];
        
    }
    
    
    
    [self nextDelegateFeed];
    
    // Get the current config:
    PKFeedConfig *config = [self currentFeed];
    
    NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Success importing %@...", @"Used during the sync process to inform the user if a process was success during the sync process. E.g. 'Success importing Products'"), [PKFeed pluralNameForFeedType:[feed type]]];
    [[feed feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepFinished];
    
    // Remove the finished feed:
    [[config feedQueue] removeObject:feed];
    
    // Continue the sync:
    [self continueDelegateSync];
}

- (void)continueDelegateSync {
    // Get the current config:
    PKFeedConfig *config = [self currentFeed];
    
    
    if (config) {
        // Get the next feed to download and parse:
        if ([[config feedQueue] count] != 0) {
            PKFeed *feed = [[config feedQueue] firstObject];
            NSLog(@"[%@ Feed] - Starting", [PKFeed nameForFeedType:[feed type]]);
            
            NSLog(@"%@", [PKFeed nameForFeedType:[feed type]]);
            [feed downloadWithDelegate:self];
        } else {
            // There isn't an operation to process therefore move onto the
            // next feed:
            [config setIsSyncFinished:YES];
            [config setHasSyncronised:YES]; // Saves against the config to signify the sync has happened at least once
            [config setDateLastSyncronised:[NSDate date]];
            [config notifyProgressUpdate];
            [config save];
            
            [self nextDelegateFeed];
        }
    } else {
        // Clear temp directory:
        [PKSyncViewController clearTmpDirectory];
        
        // Flag as complete
        [self setDidSyncComplete:YES];
        
        // Inform the system that the sync finished
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncComplete object:nil];
        
        // Show complete UI
        [self performSegueWithIdentifier:@"segueCompleteSync" sender:self];
    }
}

- (void) continueSync {
    // What is the current feed to process?
    PKFeedConfig *config = [self currentFeed];
    if (config) {
        NSLog(@"Current: %@", [config description]);
        
        if ([[config feedQueue] count] != 0) {
            // Get the first operation from the queue:
            PKFeed *currentOperation = [[config feedQueue] firstObject];
            
            // Update progress
            NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Downloading %@...", @"Used during the sync process to inform the user which process is currently being downloaded. E.g. 'Downloading Product...'"), [PKFeed pluralNameForFeedType:currentOperation.type]];
            [[currentOperation feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepDownloading];
            NSLog(@"Current operation: %@", [currentOperation description]);
            
            PKSyncViewController * __weak weakSelf = self;
            
            // Start the actual download operation
            [currentOperation download:^(BOOL success, NSURL *filePath, NSError *error) {
                if (success) {
                    // Update progress
                    NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Success importing %@...", @"Used during the sync process to inform the user if a process was success during the sync process. E.g. 'Success importing Products'"), [PKFeed pluralNameForFeedType:currentOperation.type]];
                    [[currentOperation feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepFinished];
                    
                    NSLog(@"Success downloading feed (%@)! %@", [[currentOperation feedConfig] number], filePath);
                } else {
                    NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Error importing %@...", @"Used during the sync process to inform the user if a process failed during the sync process. E.g. 'Error importing Products'"), [PKFeed pluralNameForFeedType:currentOperation.type]];
                    [[currentOperation feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepFinished];
                    
                    NSLog(@"Error downloading! (%@) %@", [[currentOperation feedConfig] number], error);
                }
                
                // Notify the UI:
                [config notifyProgressUpdate];
                
                // Remove this operation from the queue if too many attempts
                [[config feedQueue] removeObject:currentOperation];
                
                // Next
                [weakSelf continueSync];
            }];
        } else {
            // Looks like all internal operations may have been completed?
            [config setIsSyncFinished:YES];
            [config setHasSyncronised:YES]; // Saves against the config to signify the sync has happened at least once
            [config setDateLastSyncronised:[NSDate date]];
            [config save];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [config notifyProgressUpdate];
            });
            
            // Make the next feed the active feed
            [self nextFeed];
        }
    } else {
        // Clear temp directory:
        [PKSyncViewController clearTmpDirectory];
        
        // Flag as complete
        [self setDidSyncComplete:YES];
        
        // Inform the system that the sync finished
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncComplete object:nil];
        
        // Show complete UI
        [self performSegueWithIdentifier:@"segueCompleteSync" sender:self];
    }
}

+ (void)clearTmpDirectory {
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

- (void) checkConnectivity {
    // Show a HUD
    [self showHud:NSLocalizedString(@"One Moment...", nil) withSubtitle:NSLocalizedString(@"Checking Network", nil)];
    [self performSelector:@selector(_doCheckConnectivity) withObject:nil afterDelay:1.2f];
}

- (void) _doCheckConnectivity {
    // Check for network access
    PKJob *job = [[PKJobManager sharedInstance] createJobWithTitle:@"Checking Connectivity" forFeedNumber:nil];
    [PKNetworking checkConnectivityWithCompletionBlock:^(BOOL success, NSDictionary *userInfo, NSError *error) {
        // Hide HUD
        [self hideHudAnimated:YES];
        
        // Determine if the puckator services are online
        BOOL online = [[userInfo objectForKey:@"success"] boolValue];
        BOOL hasCustomErrorMessage = NO;
        if (!online) {
            if([userInfo objectForKey:@"message"] && [[userInfo objectForKey:@"message"] length] >= 1) {
                error = [NSError errorWithDescription:[userInfo objectForKey:@"message"]
                                         andErrorCode:kPuckatorErrorCodeStatusCheckOfflineMessage];
                hasCustomErrorMessage = YES;
            } else {
                error = [NSError errorWithDescription:NSLocalizedString(@"The Puckator Server appears to be unavailable at this time!", nil)
                                         andErrorCode:kPuckatorErrorCodeStatusCheckFailed];
            }
        }
        
        // Continue with the sync or display an error
        if (success && online) {
            NSLog(@"Yay - the network is reachable!");
            [job completeJob];
            
            [self prepareToSync];
        } else {
            NSLog(@"Oh no, the server is not reachable!  Error %@.", [error localizedDescription]);
            [job failJobWithErrorMessage:@"Server is unreachable" andError:error];
            
            // Create the options for the alert
            RIButtonItem *buttonCancel = [RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", nil) action:^{
                // Go back if we can
                if([self origin] == PKSyncOriginTypeConfiguration) {
                    [[self navigationController] popViewControllerAnimated:YES];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
            }];
            
            RIButtonItem *buttonRetry = [RIButtonItem itemWithLabel:NSLocalizedString(@"Retry", nil) action:^{
                [self checkConnectivity];
            }];
            
            // Create the error message text
            NSMutableString *errorMessage = [[NSMutableString alloc] initWithString:[error localizedDescription]];
            if (!hasCustomErrorMessage) {
                [errorMessage appendFormat:@"\n\n%@", NSLocalizedString(@"Please ensure you are connected to a Wi-Fi or Cellular Network.", nil)];
            }
            
            // Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network is unreachable!", nil)
                                                            message:errorMessage
                                                   cancelButtonItem:buttonCancel
                                                   otherButtonItems:buttonRetry, nil];
            [alert show];
        }
    }];
}

#pragma mark - Sync Based Operations

- (void)nextDelegateFeed {
    for (PKFeedConfig *feedConfig in [self allFeeds]) {
        if ([feedConfig isSyncProcessing] == NO && [feedConfig isSyncFinished] == NO) {
            [feedConfig setIsSyncProcessing:YES];
            [feedConfig notifyProgressUpdate];
            break;
        }
    }
    
    [self continueDelegateSync];
}

- (void)nextFeed {
    for(PKFeedConfig *feedConfig in [self allFeeds]) {
        if([feedConfig isSyncProcessing] == NO && [feedConfig isSyncFinished] == NO) {
            [feedConfig setIsSyncProcessing:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [feedConfig notifyProgressUpdate];
            });
            
            break;
        }
    }
    
    [self continueSync];
}

- (PKFeedConfig*) currentFeed {
    // Find the processing feed sync
    for (PKFeedConfig *feedConfig in [self allFeeds]) {
        if ([feedConfig isSyncProcessing] == YES && [feedConfig isSyncFinished] == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [feedConfig notifyProgressUpdate];
            });
            
            return feedConfig;
        }
    }
    
    // No current feed exists!
    return nil;
}

@end
