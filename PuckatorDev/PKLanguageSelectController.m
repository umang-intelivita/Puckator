//
//  PKLanguageSelectController.m
//  Puckator
//
//  Created by Luke Dixon on 28/09/2015.
//  Copyright © 2015 57Digital Ltd. All rights reserved.
//

#import "PKLanguageSelectController.h"
#import "PKLanguage.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import "PKBasket+Operations.h"

@interface PKLanguageSelectController ()

@property (strong, nonatomic) NSArray *languages;

@end

@implementation PKLanguageSelectController

#pragma - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the data:
    [self setLanguages:[PKLanguage languages]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the title:
    [self setTitle:NSLocalizedString(@"Select Language", nil)];
    
    // Add a cancel button:
    UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(buttonCancelPressed:)];
    [[self navigationItem] setLeftBarButtonItem:buttonCancel];
}

#pragma mark - Event Methods

- (void)buttonCancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UITableView Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self languages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    // Get the current language:
    PKLanguage *language = [[self languages] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[language title]];
    [[cell imageView] setImage:[language image]];
    
    if ([[PKLanguage currentLanguageCode] isEqualToString:[language code]]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect the cell:
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Setup the new language:
    PKLanguage *language = [[self languages] objectAtIndex:[indexPath row]];
    
    if (![[PKLanguage currentLanguageCode] isEqualToString:[language code]]) {
        // Check if there is currently an order in progress:
        if ([PKBasket sessionBasket]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Order Warning", nil)
                                                                message:NSLocalizedString(@"You can not change your language while an order is in progress.\n\nPlease finish your current order before attempting to change the language.", nil)
                                                       cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"Dismiss", nil)]
                                                       otherButtonItems:nil];
            [alertView show];
        } else {
            // Change the language:
            RIButtonItem *itemConfirm = [RIButtonItem itemWithLabel:NSLocalizedString(@"Change Language & Exit app", nil) action:^{
                NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
                if (![[languages firstObject] isEqualToString:[language code]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:@[[language code]] forKey:@"AppleLanguages"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    exit(0);
                }
            }];
            
            RIButtonItem *itemCancel = [RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", nil) action:^{
            }];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Change Language", nil)
                                                                message:NSLocalizedString(@"The app must be closed and relaunched in order to change the language.", nil)
                                                       cancelButtonItem:itemCancel
                                                       otherButtonItems:itemConfirm, nil];
            [alertView show];
        }
    }
}

#pragma mark -

@end
