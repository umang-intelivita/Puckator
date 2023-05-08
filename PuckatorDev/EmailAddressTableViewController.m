//
//  EmailAddressTableViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 22/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "EmailAddressTableViewController.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import "PKEmailAddress.h"

@interface EmailAddressTableViewController ()

@property (nonatomic, strong) NSMutableArray *list;

@property (strong) NSMutableArray<PKEmailAddress *> *customEmailAddresses;
@property (strong) NSMutableArray<PKEmailAddress *> *customerEmailAddresses;
@property (strong) NSMutableArray<PKEmailAddress *> *agentEmailAddresses;

@end

@implementation EmailAddressTableViewController

#pragma mark - Constructor Methods

+ (instancetype)createWithCurrentEmailAddresses:(NSString *)currentEmailAddresses
                         customerEmailAddresses:(NSArray<PKEmailAddress *> *)customerEmailAddresses
                            agentEmailAddresses:(NSArray<PKEmailAddress *> *)agentEmailAddresses {
    EmailAddressTableViewController *emailController = [[EmailAddressTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [emailController setEmailAddresses:currentEmailAddresses];
    [emailController setList:[NSMutableArray array]];
    [emailController setCustomEmailAddresses:[NSMutableArray array]];
    [emailController setCustomerEmailAddresses:[customerEmailAddresses mutableCopy]];
    [emailController setAgentEmailAddresses:[agentEmailAddresses mutableCopy]];
    
    return emailController;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Init the list
    [self setList:[[NSMutableArray alloc] init]];
    
    // Create the add button
    UIBarButtonItem *buttonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonAddPressed:)];
    [[self navigationItem] setLeftBarButtonItem:buttonAdd];
    
    // Update title
    [self setTitle:NSLocalizedString(@"E-mail Addresses", nil)];
    [self setPreferredContentSize:CGSizeMake(320, 320)];
    
    // Parse the current emails:
    [self parseCurrentEmailAddresses:[self emailAddresses]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Setup the toolbar items:
    [[self navigationController] setToolbarHidden:NO animated:NO];
    [[[self navigationController] toolbar] setBarStyle:UIBarStyleBlackOpaque];
    [self setToolbarItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonSavePressed:)],
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]]];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    if ([[self list] count] == 0) {
//        [self buttonAddPressed:nil];
//    }
}

#pragma mark - Actions

- (void)buttonSavePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void) buttonAddPressed:(id)sender {
    // Pass nil for add function:
    [self displayEmailAlertWithEmailAddress:nil];
}

#pragma mark - Private Methods

- (void)parseCurrentEmailAddresses:(NSString *)currentEmailAddresses {
    // If e-mail addresses provided, parse the string:
    if ([currentEmailAddresses length] != 0) {
        [[self list] removeAllObjects];
        
        NSArray *components = [[self emailAddresses] componentsSeparatedByString:@";"];
        for (NSString *email in components) {
            NSString *cleanEmail = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([cleanEmail length] >= 1) {
                BOOL emailFound = NO;
                
                // Check if the email is a customer email address:
                for (PKEmailAddress *emailAddress in [self customerEmailAddresses]) {
                    if ([[[emailAddress email] lowercaseString] isEqualToString:cleanEmail]) {
                        [emailAddress setIsSelected:YES];
                        emailFound = YES;
                        break;
                    }
                }
                
                // Check if the email is a rep email address:
                for (PKEmailAddress *emailAddress in [self agentEmailAddresses]) {
                    if ([[[emailAddress email] lowercaseString] isEqualToString:cleanEmail]) {
                        [emailAddress setIsSelected:YES];
                        emailFound = YES;
                        break;
                    }
                }
                
                // If the email hasn't been found then it must be a custom one:
                if (!emailFound) {
                    PKEmailAddress *emailAddress = [PKEmailAddress createWithEmail:cleanEmail type:nil];
                    [emailAddress setIsCustom:YES];
                    [emailAddress setIsSelected:YES];
                    [[self customEmailAddresses] addObject:emailAddress];
                }
                
                [[self list] addObject:cleanEmail];
            }
        }
        
        
        
        [[self tableView] reloadData];
    }
}

- (NSArray *)uniqueCustomerEmailAddresses {
    NSMutableArray *emailAddress = [[self customerEmailAddresses] mutableCopy];
    [emailAddress removeObjectsInArray:[self list]];
    return emailAddress;
}

- (void)addEmailAddress:(NSString *)emailAddress {
    BOOL found = NO;
    int index = 0;
    
    // First look to see if we should update an existing email address:
    if ([emailAddress length] != 0) {
        for (PKEmailAddress *email in [self customEmailAddresses]) {
            if ([[[email email] lowercaseString] isEqualToString:[emailAddress lowercaseString]]) {
                found = YES;
                break;
            }
            index ++;
        }
    }
    
    if (found) {
        // The existing email address has been found therefore update the
        // object in the list array:
        PKEmailAddress *email = [PKEmailAddress createWithEmail:emailAddress type:nil];
        [email setIsSelected:YES];
        [email setIsCustom:YES];
        if (email) {
            [[self customEmailAddresses] replaceObjectAtIndex:index withObject:email];
        }
        
        // Reload the table view and update the delegate:
        [[self tableView] reloadData];
        [self returnEmailAddresses];
    } else {        
        // Add the email address to the list array:
        if ([emailAddress length] != 0) {
            PKEmailAddress *email = [PKEmailAddress createWithEmail:emailAddress type:nil];
            [email setIsSelected:YES];
            [email setIsCustom:YES];
            if (email) {
                [[self customEmailAddresses] addObject:email];
            }
        }
        
        // Reload the table view and update the delegate:
        [[self tableView] reloadData];
        [self returnEmailAddresses];
        
    }
}

- (void)displayEmailAlertWithEmailAddress:(PKEmailAddress *)emailAddress {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:([[emailAddress email] length] == 0) ? NSLocalizedString(@"Enter E-mail Address", nil) : NSLocalizedString(@"Update E-mail Address", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
        [textField setText:[emailAddress email]];
    }];
    
    __weak EmailAddressTableViewController *weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:([[emailAddress email] length] == 0) ? NSLocalizedString(@"Add", nil) : NSLocalizedString(@"Update", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *field = [[alert textFields] firstObject];
        
        if (emailAddress) {
            [emailAddress setEmail:[field text]];
            [weakSelf returnEmailAddresses];
            [[weakSelf tableView] reloadData];
        } else {
            [weakSelf addEmailAddress:[field text]];
        }
        
    }]];
    
    // Show the alert view:
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([[self customEmailAddresses] count] == 0) {
            return nil;
        }
        return NSLocalizedString(@"Custom E-mail Addresses", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Customer E-mail Addresses", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Your E-mail Addresses", nil);
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // Custom email addresses:
        return (int)[[self customEmailAddresses] count];
    } else if (section == 1) {
        // Customer email addresses:
        return (int)[[self customerEmailAddresses] count];
    } else if (section == 2) {
        // Rep email addresses:
        return (int)[[self agentEmailAddresses] count];
    }
    
    // Unknown section:
    return 0;
}

- (PKEmailAddress *)emailAddressForIndexPath:(NSIndexPath *)indexPath {
    PKEmailAddress *emailAddress = nil;
    
    int section = (int)[indexPath section];
    int row = (int)[indexPath row];
    
    if (section == 0) {
        // Custom email addresses:
        if (row < [[self customEmailAddresses] count]) {
            return [[self customEmailAddresses] objectAtIndex:row];
        }
    } else if (section == 1) {
        // Customer email addresses:
        if (row < [[self customerEmailAddresses] count]) {
            return [[self customerEmailAddresses] objectAtIndex:row];
        }
    } else if (section == 2) {
        // Rep email addresses:
        if (row < [[self agentEmailAddresses] count]) {
            return [[self agentEmailAddresses] objectAtIndex:row];
        }
    }
    
    return emailAddress;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture {
    if ([longPressGesture state] == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = (UITableViewCell *)[longPressGesture view];
        NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
        PKEmailAddress *email = [self emailAddressForIndexPath:indexPath];
        NSLog(@"[%@] - Email: %@", [self class], [email email]);
        
        if ([email isCustom]) {
            [self displayEmailAlertWithEmailAddress:email];
        } else {
            NSString *title = NSLocalizedString(@"E-mail Address", nil);
            NSString *message = NSLocalizedString(@"You can't edit this e-mail address because it isn't custom.", nil);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    PKEmailAddress *email = [self emailAddressForIndexPath:indexPath];
    [[cell textLabel] setText:[email email]];
    [[cell detailTextLabel] setText:[email type]];
    
    if ([[cell gestureRecognizers] count] == 0) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [cell addGestureRecognizer:longPressGesture];
    }
    
    if ([email isSelected]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
//    if ([indexPath section] == 0) {
//        NSString *emailAddress = [[self list] objectAtIndex:indexPath.row];
//        [[cell textLabel] setText:emailAddress];
//        [[cell textLabel] setFont:[UIFont puckatorContentText]];
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//    } else if ([indexPath section] == 1) {
//        NSString *emailAddress = [[self uniqueCustomerEmailAddresses] objectAtIndex:indexPath.row];
//        [[cell textLabel] setText:emailAddress];
//        [[cell detailTextLabel] setText:@"Default"];
//        [[cell textLabel] setFont:[UIFont puckatorContentText]];
//    } else {
//        PKAgent *agent = [PKAgent currentAgent];
//        NSString *email = [agent email];
//        [[cell textLabel] setText:email];
//        [[cell textLabel] setFont:[UIFont puckatorContentText]];
//    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([indexPath section] == 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PKEmailAddress *emailAddress = [self emailAddressForIndexPath:indexPath];
    [emailAddress setIsSelected:![emailAddress isSelected]];
    [tableView reloadData];
    
    // Update the delegate:
    [self returnEmailAddresses];
    return;    
    
//    if ([indexPath section] == 0) {
//        if ([indexPath row] < [[self list] count]) {
//            NSString *email = [[self list] objectAtIndex:[indexPath row]];
//            if ([email length] != 0) {
//                [self displayEmailAlertWithEmailAddress:email];
//            }
//        }
//    } else if ([indexPath section] == 1) {
//        if ([indexPath row] < [[self uniqueCustomerEmailAddresses] count]) {
//            NSString *email = [[self uniqueCustomerEmailAddresses] objectAtIndex:[indexPath row]];
//            [self addEmailAddress:email];
//        }
//    } else {
//        PKAgent *agent = [PKAgent currentAgent];
//        NSString *email = [agent email];
//        [self addEmailAddress:email];
//    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PKEmailAddress *emailAddress = [self emailAddressForIndexPath:indexPath];
        [[self customEmailAddresses] removeObject:emailAddress];
        [[self tableView] reloadData];
        [self returnEmailAddresses];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Delegates

- (void)returnEmailAddresses {
    NSMutableString *addresses = [[NSMutableString alloc] initWithString:@""];
    
    // Add the custom email addresses:
    [[self customEmailAddresses] enumerateObjectsUsingBlock:^(PKEmailAddress * _Nonnull emailAddress, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([emailAddress isSelected] && [[emailAddress email] length] != 0) {
            [addresses appendString:[NSString stringWithFormat:@"%@;", [[emailAddress email] lowercaseString]]];
        }
    }];
    
    // Add the customer email addresses:
    [[self customerEmailAddresses] enumerateObjectsUsingBlock:^(PKEmailAddress * _Nonnull emailAddress, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([emailAddress isSelected] && [[emailAddress email] length] != 0) {
            [addresses appendString:[NSString stringWithFormat:@"%@;", [[emailAddress email] lowercaseString]]];
        }
    }];
    
    // Add the agent email addresses:
    [[self agentEmailAddresses] enumerateObjectsUsingBlock:^(PKEmailAddress * _Nonnull emailAddress, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([emailAddress isSelected] && [[emailAddress email] length] != 0) {
            [addresses appendString:[NSString stringWithFormat:@"%@;", [[emailAddress email] lowercaseString]]];
        }
    }];
    
    // Update the delegate:
    if ([self emailDelegate] && [[self emailDelegate] respondsToSelector:@selector(emailAddressTableViewController:didUpdateToEmailAddresses:)]) {
        [[self emailDelegate] emailAddressTableViewController:self didUpdateToEmailAddresses:addresses];
    }
}

@end
