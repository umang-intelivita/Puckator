//
//  PKOrdersViewController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKOrdersViewController.h"
//#import "M13ProgressViewRing.h"
#import "AppDelegate.h"
#import "APProgressHUD.h"
#import "PKBasket+Operations.h"

@interface PKOrdersViewController ()

@property (strong, nonatomic) PKCustomer *customer;
@property (strong, nonatomic) NSArray *invoices;

@end

@implementation PKOrdersViewController

+ (instancetype)createWithCustomer:(PKCustomer *)customer {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    PKOrdersViewController *ordersViewController = (PKOrdersViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PKOrdersViewController"];
    [ordersViewController setCustomer:customer];
    return ordersViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Orders", nil)];
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self
                                                                                               action:@selector(buttonAddPressed:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [APProgressHUD show:NSLocalizedString(@"Loading", nil) interaction:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [APProgressHUD dismiss];
    
    if (![self invoices]) {
        if ([self customer]) {
            [self setInvoices:[[self customer] invoices]];
        } else {
            [self setInvoices:[PKInvoice allInvoices]];
        }
        [[self tableView] reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Methods

- (void)buttonAddPressed:(id)sender {
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self invoices] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PKOrderCell" forIndexPath:indexPath];
    
    PKInvoice *invoice = [[self invoices] objectAtIndex:[indexPath row]];
    
    // Configure the cell...
    //[[cell textLabel] setText:[NSString stringWithFormat:@"Order %i [coming soon]", (int)([indexPath row] + 1)]];
    [[cell textLabel] setText:[invoice invoiceDate]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
