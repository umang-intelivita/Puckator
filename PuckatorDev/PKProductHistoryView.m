//
//  PKProductHistoryView.m
//  PuckatorDev
//
//  Created by Luke Dixon on 28/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductHistoryView.h"
#import "PKHistoryCell.h"
#import "PKProductHistoryGraphController.h"
#import "UIButton+AllStates.h"
#import "UIColor+Puckator.h"

@interface PKProductHistoryView ()

// UI:
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *buttonGraph;

// Properties:
@property (weak, nonatomic) PKProduct *product;
@property (nonatomic) PKProductWarehouse warehouse;

@end

@implementation PKProductHistoryView

#pragma mark - Constructor Methods

+ (instancetype)createWithProduct:(PKProduct *)product frame:(CGRect)frame {
    NSLog(@"Frame: %@", NSStringFromCGRect(frame));
    PKProductHistoryView *productHistoryView = [[PKProductHistoryView alloc] initWithFrame:frame];
    [productHistoryView setProduct:product];
    [productHistoryView setupUI];
    return productHistoryView;
}

#pragma mark - Private Methods

- (void)setupUI {
    int buttonSize = [self headerHeight];
    
    // Setup the table view:
    if (![self tableView]) {
        CGRect frame = CGRectMake(0,
                                  0,
                                  [self frame].size.width,
                                  [self frame].size.height);
        [self setTableView:[[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped]];
        [[self tableView] setBackgroundColor:[UIColor redColor]];
        [[self tableView] setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)]];
        [[self tableView] setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)]];
        [[self tableView] setContentInset:UIEdgeInsetsZero];
        [[self tableView] setDelegate:self];
        [[self tableView] setDataSource:self];
        [[self tableView] setBackgroundColor:[UIColor clearColor]];
        [[self tableView] setSeparatorColor:[UIColor clearColor]];
        [[self tableView] setScrollEnabled:NO];
//        [[self tableView] setCenter:CGPointMake([self bounds].size.width * 0.5f,
//                                                [self bounds].size.height * 0.5f)];
        [self addSubview:[self tableView]];
    }
    
    // Setup the graph button:
    if (![self buttonGraph]) {
        [self setButtonGraph:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[self buttonGraph] setImageForAllStates:[UIImage imageNamed:@"910-graph-toolbar.png"]];
        [[self buttonGraph] setImageRenderingModeForAllStates:UIImageRenderingModeAlwaysTemplate];
        [[self buttonGraph] setTintColor:[UIColor blackColor]];
        [[self buttonGraph] addTarget:self action:@selector(buttonGraphPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self buttonGraph] sizeToFit];
        [[self buttonGraph] setFrame:CGRectMake([self tableView].bounds.size.width - buttonSize,
                                                0,
                                                buttonSize,
                                                buttonSize)];
        [[self tableView] addSubview:[self buttonGraph]];
    }
}

- (int)headerHeight {
    return [self bounds].size.height - ([self cellHeight] * 13);
}

- (int)cellHeight {
    int numberOfMonths = 12;
    int extraRows = 2;
    int maxRows = numberOfMonths + extraRows;
    float cellHeight = (float)[self bounds].size.height / (float)maxRows;
    return floorf(cellHeight);
}

#pragma mark - Public Methods

- (void)updateWithProduct:(PKProduct *)product warehouse:(PKProductWarehouse)warehouse {
    [self setWarehouse:warehouse];
    [self setProduct:product];
    [[self tableView] reloadData];
    [[self tableView] setContentOffset:CGPointZero animated:NO];
}

#pragma mark - Event Methods

- (void)buttonGraphPressed:(UIButton *)sender {
    PKProductHistoryGraphController *productHistoryGraphController = [PKProductHistoryGraphController createWithProduct:[self product] warehouse:[self warehouse]];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:productHistoryGraphController];
    [popoverController presentPopoverFromRect:[sender frame]
                                       inView:[self superview]
                     permittedArrowDirections:UIPopoverArrowDirectionLeft
                                     animated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == [self tableView]) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == [self tableView]) {
        return 14;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == [self tableView]) {
        PKHistoryCell *cell = (PKHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"PKHistoryCell"];
        if (cell == nil ) {
            cell = [PKHistoryCell create];
        }
        
        if ([indexPath row] == 0) {
            [cell setupWithYearToDateHeader:[[self product] yearNameForHistoryType:PKSaleHistoryTypeYearToDate]
                      priorYearToDateHeader:[[self product] yearNameForHistoryType:PKSaleHistoryTypePriorYear]
                   priorTwoYearToDateHeader:[[self product] yearNameForHistoryType:PKSaleHistoryTypePriorTwoYear]];
        } else if ([indexPath row] <= [[[self product] salesHistoryForType:PKSaleHistoryTypeYearToDate warehouse:[self warehouse]] count]) {
            [cell setupWithYearToDateSaleHistory:[[[self product] salesHistoryForType:PKSaleHistoryTypeYearToDate
                                                                            warehouse:[self warehouse]] objectAtIndex:[indexPath row] - 1]
                      priorYearToDateSaleHistory:[[[self product] salesHistoryForType:PKSaleHistoryTypePriorYear
                                                                            warehouse:[self warehouse]] objectAtIndex:[indexPath row] - 1]
                   priorTwoYearToDateSaleHistory:[[[self product] salesHistoryForType:PKSaleHistoryTypePriorTwoYear
                                                                            warehouse:[self warehouse]] objectAtIndex:[indexPath row] -1]];
        } else {
            [cell setupWithYearToDateTotal:[[self product] salesHistoryTotalForType:PKSaleHistoryTypeYearToDate warehouse:[self warehouse]]
                      priorYearToDateTotal:[[self product] salesHistoryTotalForType:PKSaleHistoryTypePriorYear warehouse:[self warehouse]]
                   priorTwoYearToDateTotal:[[self product] salesHistoryTotalForType:PKSaleHistoryTypePriorTwoYear warehouse:[self warehouse]]];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([indexPath row] == 0) {
            [cell setBackgroundColor:[UIColor whiteColor]];
        } else if ([indexPath row] % 2 != 0) {
            [cell setBackgroundColor:[UIColor puckatorLightGray]];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        return [self headerHeight];
    } else {
        return [self cellHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        return [self headerHeight];
    } else {
        return [self cellHeight];
    }
}

#pragma mark - UITableViewDelegate Methods

#pragma mark - Memory Management

- (void)dealloc {
    if ([self tableView]) {
        [[self tableView] setDelegate:nil];
        [[self tableView] setDataSource:nil];
    }
}

#pragma mark -

@end
