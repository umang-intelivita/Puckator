//
//  PKFeedsTableViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 09/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeedsTableViewController.h"
#import "PKTranslate.h"
#import "PKFeedTableViewCell.h"
#import "PKFeedEditViewController.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import "UIAlertView+Puckator.h"
#import "PKSyncViewController.h"
#import "PKSession.h"
#import "PKSyncViewController.h"
#import "PKFeedConfigMeta+Operations.h"
#import "PKDatabase.h"
#import <MKFoundationKit/MKFoundationKit.h>
#import "PKConstant.h"

@interface PKFeedsTableViewController ()
@property (nonatomic, strong) NSMutableArray *feeds;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonContinue;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonAdd;

@property (nonatomic, assign) BOOL canEditFeeds;

@end

@implementation PKFeedsTableViewController

+ (instancetype)create {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:[NSBundle mainBundle]];
    if (storyboard) {
        id viewController = [storyboard instantiateViewControllerWithIdentifier:@"PKFeeds"];
        if ([viewController isKindOfClass:[PKFeedsTableViewController class]]) {
            return (PKFeedsTableViewController *)viewController;
        }
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setDefinesPresentationContext:YES];
    
    // Customize tableview
    [[self tableView] setAllowsMultipleSelectionDuringEditing:NO];
    [[self barButtonEdit] setTitle:NSLocalizedString(@"Edit", nil)];
    [[self barButtonContinue] setTitle:NSLocalizedString(@"Start Sync", nil)];
    
    // If the mode is editor, allow editing feeds
    if([self mode] == PKFeedsTableModeEditor) {
        [self setCanEditFeeds:YES];
        [self setTitle:NSLocalizedString(@"My Feeds", nil)];
        
        UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didPressDismiss:)];
        [[self navigationItem] setLeftBarButtonItem:buttonClose];
    } else {
        [self setCanEditFeeds:NO];
        [self setTitle:NSLocalizedString(@"Switch Feeds", nil)];
        
        UIBarButtonItem *buttonSync = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sync", nil) style:UIBarButtonItemStyleDone target:self action:@selector(didPressSync:)];
        [[self navigationItem] setLeftBarButtonItem:buttonSync];
        
        UIBarButtonItem *buttonManageFeeds = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Manage Feeds", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPressManageFeeds:)];
        [[self navigationItem] setRightBarButtonItem:buttonManageFeeds];
        
        // Remove add button
        //[[self navigationItem] setRightBarButtonItem:nil animated:NO];
        
        // Add settings button
        
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL toolbarIsHidden = NO;
    if([self mode] == PKFeedsTableModeSwitcher) {
        toolbarIsHidden = YES;
    }
    
    [[self navigationController] setToolbarHidden:toolbarIsHidden animated:YES];
    
    // Setup feeds
    [self setFeeds:[[NSMutableArray alloc] init]];
    [[self feeds] removeAllObjects];
    [[self feeds] addObjectsFromArray:[PKFeedConfig feeds]];
    [[self tableView] reloadData];
}

-(CGSize)preferredContentSize {
    if([self mode] == PKFeedsTableModeEditor) {
        return CGSizeMake(540, 620);
    } else {
        int rows = (int)[[PKFeedConfig feeds] count];
        return CGSizeMake(540, MAX(250, MIN(500, ((rows+1)*74))));
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(1, [[self feeds] count]);
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([self mode] == PKFeedsTableModeEditor) {
        if([[self feeds] count] == 0) {
            return @"";
        } else {
            return NSLocalizedString(@"Your feeds...", nil);
        }
    } else {
        return NSLocalizedString(@"Select a feed to switch to...", nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PKFeedTableViewCell *cell = (PKFeedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
    
    // Hide button by default, we will show if needed...
    [[cell buttonSwitch] setHidden:YES];
    [[cell labelFeedInfo] setHidden:NO];
    
    if (indexPath.row < [[self feeds] count]) {
        [cell setIsCustomMessageCell:NO];
        [cell setFeedConfiguration:[self feeds][indexPath.row]];
        if ([[cell feedConfiguration] allocatedDeviceIdentifier]) {
            [[cell labelFeedInfo] setText:[[cell feedConfiguration] dateLastSyncFormatted]];
        } else {
            [[cell labelFeedInfo] setText:NSLocalizedString(@"Awaiting Activation", nil)];
        }
        
        // Show error for invalid feed #
        if([[cell feedConfiguration] number]) {
            if([[[cell feedConfiguration] number] length] == 0) {
                [[cell labelFeedNumber] setText:NSLocalizedString(@"Invalid Feed Number", nil)];
                [[cell labelFeedNumber] setTextColor:[UIColor redColor]];
            } else{
                NSMutableString *displayFeedNumber = [[NSMutableString alloc] initWithString:@""];
                [displayFeedNumber appendFormat:@"#%@", [[cell feedConfiguration] number]];
                
                // Has a device ID been allocated?
                if ([[cell feedConfiguration] allocatedDeviceIdentifier]) {
                    [displayFeedNumber appendFormat:@" (%d)", [[[cell feedConfiguration] allocatedDeviceIdentifier] intValue]];
                }
                
                //NSDate *date = [PKDatabase dateForQuery:@"select DATE_GENERATED from FeedMeta" database:PKDatabaseTypeProducts];
                //products_date_processed
                NSDate *dateGenerated = (NSDate *)[[PKFeedConfigMeta feedMetaDataWithFeedConfig:[cell feedConfiguration] group:kPuckatorMetaGroupSqlDates key:kPuckatorMetaKeySqlProductsGeneratedDate] object];
                NSDate *dateProcessed = (NSDate *)[[PKFeedConfigMeta feedMetaDataWithFeedConfig:[cell feedConfiguration] group:kPuckatorMetaGroupSqlDates key:kPuckatorMetaKeySqlProductsProcessedDate] object];
                
                if ([dateGenerated isEqualToDate:dateProcessed]) {
                    [displayFeedNumber appendFormat:@"\n👍 %@ ", [dateGenerated mk_formattedStringUsingFormat:@"dd/MM/yyyy hh:mm:ss"]];
                } else {
                    if (dateGenerated) {
                        //NSLog(@"dateGenerated: %@", dateGenerated);
                        [displayFeedNumber appendFormat:@"\n❗️G:%@", [dateGenerated mk_formattedStringUsingFormat:@"dd/MM/yyyy hh:mm:ss"]];
                    } else {
                        [displayFeedNumber appendFormat:@"\n❗️G:❓"];
                    }
                    
                    if (dateProcessed) {
                        //NSLog(@"dateProcessed: %@", dateProcessed);
                        [displayFeedNumber appendFormat:@" - P:%@", [dateProcessed mk_formattedStringUsingFormat:@"dd/MM/yyyy hh:mm:ss"]];
                    } else {
                        [displayFeedNumber appendFormat:@" - P:❓"];
                    }
                }
                
                [[cell labelFeedNumber] setText:displayFeedNumber];
                [[cell labelFeedNumber] setTextColor:[UIColor darkGrayColor]];
            }
        }
        
        // Show error for missing feed name
        if([[[cell feedConfiguration] name] length] == 0) {
            [[cell labelFeedName] setTextColor:[UIColor lightGrayColor]];
            [[cell labelFeedName] setText:NSLocalizedString(@"Missing Name", nil)];
        } else {
            [[cell labelFeedName] setTextColor:[UIColor darkTextColor]];
        }
        
        // Wiped feed?
        if([[[cell feedConfiguration] isWiped] boolValue] == YES) {
            [[cell labelFeedInfo] setText:NSLocalizedString(@"Access Revoked", nil)];
            [[cell labelFeedInfo] setTextColor:[UIColor redColor]];
        }
        
        if([self mode] == PKFeedsTableModeSwitcher) {
            [[cell buttonSwitch] setHidden:NO];
            [[cell labelFeedInfo] setHidden:YES];
            
            // Customize the switcher button depending on the feed itself
            if([[cell feedConfiguration] hasSyncronised]) {
                [cell enableSwitchButton];
            } else {
                [cell disableSwitchButton];
            }
            
            // Flag this as the active feed
            if([[[[PKSession sharedInstance] currentFeedConfig] uuid] isEqualToString:[[cell feedConfiguration] uuid]]) {
                [cell showActiveButton];
            }
            
            // Add event for switch button
            [[cell buttonSwitch] removeTarget:self action:@selector(buttonSwitchPressed:) forControlEvents:UIControlEventTouchUpInside];
            [[cell buttonSwitch] addTarget:self action:@selector(buttonSwitchPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    } else {
        [cell setMessage:[NSString stringWithFormat:@"%@\n\n%@",
                          NSLocalizedString(@"Setup your first feed", nil),
                          NSLocalizedString(@"Just tap here or press the + button.", nil)]];
        [cell setIsCustomMessageCell:YES];
        [cell setFeedConfiguration:nil];
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self canEditFeeds]) {
        return YES;
    } else {
        return NO;
    }
}

/* Deletion and sorting */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if ([[self feeds] count] >= 1) {
        return [self canEditFeeds];
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && [self canEditFeeds]) {
        [self deleteFeedAtIndex:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self canEditFeeds];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [[self feeds] exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self saveFeeds];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[self feeds] count] >= 1) {
        return 74.0f;
    } else {
        return 148;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PKFeedTableViewCell *cell = (PKFeedTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    switch ([self mode]) {
        case PKFeedsTableModeEditor: {
            if(![cell isCustomMessageCell]) {
                PKFeedConfig *config = [self feeds][indexPath.row];
                [self performSegueWithIdentifier:@"segueEditFeed" sender:config];
            } else {
                PKFeedConfig *config = [PKFeedConfig createWithDictionary:nil];
                [self performSegueWithIdentifier:@"segueEditFeed" sender:config];
            }
            break;
        }
        case PKFeedsTableModeSwitcher: {
            
            break;
        }
        default: {
            break;
        }
    }
    
}

#pragma mark - Actions

- (IBAction)buttonContinuePressed:(id)sender {
    
    // Ensure at least one feed has been added
    if([[self feeds] count] >= 1) {
        
        // Show sync view
        [self performSegueWithIdentifier:@"segueSync" sender:self];
        
    } else {
        [UIAlertView showAlertWithTitle:NSLocalizedString(@"Not enough feeds!", nil)
                             andMessage:NSLocalizedString(@"You must have at least one feed to continue.", nil)];
    }
    
    
}

- (IBAction)buttonAddPressed:(id)sender {
    
    if([self canEditFeeds]) {
        
        // Create a blank UI
        PKFeedConfig *feedConfig = [[PKFeedConfig alloc] init];
        [feedConfig setName:@""];
        [feedConfig setNumber:@""];
        [feedConfig setIconName:@"PKFeedDev.png"];
        [feedConfig save];
        
        // Show the editor UI
        [self performSegueWithIdentifier:@"segueEditFeed" sender:feedConfig];
    } else {
        // Show an error, since this UI does not allow editing.
        [UIAlertView showAlertWithTitle:NSLocalizedString(@"Unable to add feed!", nil)
                             andMessage:NSLocalizedString(@"You must tap the Settings icon to configure feeds!", nil)];
    }
    
}

- (void) buttonSwitchPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil) {
        
        // Switch feed to the selected feed
        PKFeedTableViewCell *cell = (PKFeedTableViewCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
        if (![cell isCustomMessageCell]) {
            // Get the selected config
            PKFeedConfig *config = [self feeds][indexPath.row];
            
            if ([config hasSyncronised]) {
                // Switch feed.  If the user selected the same active feed, the UI will close but no updates will trigger
                [[PKSession sharedInstance] setCurrentFeedConfig:config];
                
                // Call delegate responsible for ending the UI ops
                if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkFeedsTableViewController:didSwitchFeed:)]) {
                    [[self delegate] pkFeedsTableViewController:self didSwitchFeed:config];
                }
            } else {
                RIButtonItem *itemSync = [RIButtonItem itemWithLabel:NSLocalizedString(@"Sync", nil) action:^{
                    // Display sync view controller:
                    PKSyncViewController *syncViewController = [PKSyncViewController createWithOriginType:PKSyncOriginTypePopover];
                    if ([self presentingViewController]) {
                        [[self presentingViewController] presentViewController:[syncViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
                        }];
                    } else {
                        [self presentViewController:[syncViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:^{
                        }];
                    }
                }];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Feed Unavailable", nil)
                                                                    message:NSLocalizedString(@"This feed has never been syncronised, so it is not possible to switch to it right now.", nil)
                                                           cancelButtonItem:[RIButtonItem itemWithLabel:@"Dismiss"]
                                                           otherButtonItems:itemSync, nil];
                [alertView show];
            }
        }

    }
}

#pragma mark - Deletion

- (void) deleteFeedAtIndex:(NSIndexPath *)indexPath {
    PKFeedConfig *feedConfig = [[self feeds] objectAtIndex:[indexPath row]];
    
    if ([[feedConfig number] isEqualToString:[[[PKSession sharedInstance] currentFeedConfig] number]]) {
        // Create buttons
        RIButtonItem *buttonCancel = [RIButtonItem itemWithLabel:NSLocalizedString(@"Dismiss", nil) action:^{
            [[self tableView] reloadData];
        }];
        
        // Create alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Failed", nil)
                                                        message:NSLocalizedString(@"You can not delete your active feed.\n\nIn order to delete this feed you must first activate another feed.", nil)
                                               cancelButtonItem:buttonCancel
                                               otherButtonItems:nil];
        [alert show];
    } else {
        // Create buttons
        RIButtonItem *buttonCancel = [RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", nil)];
        RIButtonItem *buttonDelete = [RIButtonItem itemWithLabel:NSLocalizedString(@"Delete Feed", nil) action:^{
            // Perform the delete operation on this feed
            [[self feeds] removeObjectAtIndex:indexPath.row];
            
            // Animate the deletion if required
            if([[self feeds] count] >= 1) {
                [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [[self tableView] reloadData];
            }
            
            // Commit changes
            [self saveFeeds];
        }];
        
        // Create alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this feed?", nil)
                                                        message:NSLocalizedString(@"All the data you have downloaded (including products, customers and orders) will be permanently deleted from this device.", nil)
                                               cancelButtonItem:buttonCancel
                                               otherButtonItems:buttonDelete, nil];
        [alert show];
    }
    
    return;
    
    
}

#pragma mark - Feed Data

- (void) saveFeeds {
    
    // Save the feeds to the keychain
    [PKFeedConfig saveFeedConfigs:[self feeds]];
    
}

#pragma mark - Actions

- (IBAction)buttonEditToggle:(id)sender {
    [[self tableView] setEditing:![[self tableView] isEditing] animated:YES];
    if([[self tableView] isEditing]) {
        [[self barButtonEdit] setTitle:NSLocalizedString(@"Finish Editing", nil)];
        [[self barButtonContinue] setEnabled:NO];
        [[self barButtonAdd] setEnabled:NO];
    } else {
        [[self barButtonEdit] setTitle:NSLocalizedString(@"Edit", nil)];
        [[self barButtonContinue] setEnabled:YES];
        [[self barButtonAdd] setEnabled:YES];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"segueEditFeed"]) {
        PKFeedEditViewController *editViewController = (PKFeedEditViewController*)[segue destinationViewController];
        [[editViewController formController] setForm:sender];
        return;
    }
    
    if ([[segue identifier] isEqualToString:@"segueSync"]) {
        PKSyncViewController *syncViewController = (PKSyncViewController*)[segue destinationViewController];
        [syncViewController setOrigin:PKSyncOriginTypeConfiguration];
        return;
    }
    
}

#pragma mark - Sync

- (void) didPressSync:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:nil];
    
    PKSyncViewController *syncViewController = (PKSyncViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SyncController"];
    [syncViewController setOrigin:PKSyncOriginTypeConfiguration];
    
    
    UINavigationController *navigationController = [syncViewController withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void) didPressManageFeeds:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:nil];
    
    PKFeedsTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"PKFeeds"];
    [controller setMode:PKFeedsTableModeEditor];
    [self presentViewController:[controller withNavigationControllerWithModalPresentationMode:UIModalPresentationFormSheet] animated:YES completion:nil];
}

- (void) didPressDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Popover version

+ (UIPopoverController*) switchFeedsPopoverFromViewController:(id)sourceViewController {    
    // Load the storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Configuration" bundle:[NSBundle mainBundle]];
    
    // Get the feeds list
    PKFeedsTableViewController *feedsTableViewController = (PKFeedsTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"PKFeeds"];
    [feedsTableViewController setMode:PKFeedsTableModeSwitcher];
    [feedsTableViewController setDelegate:sourceViewController];
    
    // Nest inside a nav controller
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:feedsTableViewController];
    
    // Pass back the popover
    return [[UIPopoverController alloc] initWithContentViewController:navController];
}

@end
