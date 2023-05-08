//
//  PKProductHistoryGraph.m
//  PuckatorDev
//
//  Created by Luke Dixon on 29/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductHistoryGraph.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"

@interface PKProductHistoryGraph ()

@property (weak, nonatomic) PKProduct *product;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) GKLineGraph *graph;
@property (strong, nonatomic) UILabel *labelMessage;
@property (nonatomic) PKProductWarehouse warehouse;

@end

@implementation PKProductHistoryGraph

#pragma mark - Constructor Methods

+ (instancetype)createWithProduct:(PKProduct *)product warehouse:(PKProductWarehouse)warehouse frame:(CGRect)frame {
    PKProductHistoryGraph *productHistoryGraph = [[PKProductHistoryGraph alloc] initWithFrame:frame];
    [productHistoryGraph setProduct:product];
    [productHistoryGraph setWarehouse:warehouse];
    [productHistoryGraph setupUI];
    [productHistoryGraph setupData];
    [productHistoryGraph setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    return productHistoryGraph;
}

#pragma mark - Private Methods

- (void)setupUI {
    if (![self graph]) {
        int padding = 10;
        [self setGraph:[[GKLineGraph alloc] initWithFrame:CGRectMake(padding,
                                                                     padding,
                                                                     [self frame].size.width - (padding * 2),
                                                                     [self frame].size.height - (padding * 2))]];
        [[self graph] setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [[self graph] setHidden:YES];
        [[self graph] setDataSource:self];
        [self addSubview:[self graph]];
    }
}

- (void)setupNoDataView {
    // Hide the graph:
    [[self graph] setHidden:YES];
    
    // Setup the message label:
    if (![self labelMessage]) {
        [self setLabelMessage:[[UILabel alloc] initWithFrame:[self bounds]]];
        [[self labelMessage] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [[self labelMessage] setFont:[UIFont puckatorDescriptionHeader]];
        [[self labelMessage] setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:[self labelMessage]];
    }
    
    [[self labelMessage] setText:NSLocalizedString(@"No graph data to display.", nil)];
}

- (void)setupData {
    [self setData:[NSMutableArray array]];
    [self setLabels:[NSMutableArray array]];
    
    NSMutableArray *currentYearData = [NSMutableArray array];
    NSMutableArray *priorYearData = [NSMutableArray array];
    NSMutableArray *priorTwoYearData = [NSMutableArray array];
    
    NSArray *currentYearHistory = [[self product] salesHistoryForType:PKSaleHistoryTypeYearToDate warehouse:[self warehouse]];
    NSArray *priorYearHistory = [[self product] salesHistoryForType:PKSaleHistoryTypePriorYear warehouse:[self warehouse]];
    NSArray *priorTwoYearHistory = [[self product] salesHistoryForType:PKSaleHistoryTypePriorTwoYear warehouse:[self warehouse]];
    
    int currentYearTotal = [[self product] salesHistoryTotalForHistory:currentYearHistory];
    int priorYearTotal = [[self product] salesHistoryTotalForHistory:priorYearHistory];
    int priorTwoYearTotal = [[self product] salesHistoryTotalForHistory:priorTwoYearHistory];
    
    __block int maxValue = 0;
    
    // Only add the current year values if there is data to display:
    if (currentYearTotal != 0) {
        [currentYearHistory enumerateObjectsUsingBlock:^(PKSaleHistory *saleHistory, NSUInteger idx, BOOL *stop) {
            id saleHistoryObj = @([saleHistory value]);
            if (saleHistoryObj) {
                [currentYearData addObject:saleHistoryObj];
            }
            if ([saleHistory value] > maxValue) {
                maxValue = [saleHistory value];
            }
            
            if ([[self labels] count] < 12) {
                NSString *dateString = [saleHistory dateStringWithFormat:PKSaleHistoryDateFormatMonthNameShortOnly];
                if ([dateString length] != 0) {
                    [[self labels] addObject:[dateString substringToIndex:1]];
                }
            }
        }];
        
        if (currentYearData) {
            [[self data] addObject:currentYearData];
        }
    }
    
    // Only add the prior year values if there is data to display:
    if (priorYearTotal != 0) {
        [priorYearHistory enumerateObjectsUsingBlock:^(PKSaleHistory *saleHistory, NSUInteger idx, BOOL *stop) {
            if (@([saleHistory value])) {
                [priorYearData addObject:@([saleHistory value])];
            }
            if ([saleHistory value] > maxValue) {
                maxValue = [saleHistory value];
            }
            
            if ([[self labels] count] < 12) {
                NSString *dateFormatted = [saleHistory dateStringWithFormat:PKSaleHistoryDateFormatMonthNameShortOnly];
                if ([dateFormatted length] != 0) {
                    [[self labels] addObject:[dateFormatted substringToIndex:1]];
                }
            }
        }];
        
        if (priorYearData) {
            [[self data] addObject:priorYearData];
        }
    }
    
    // Only add the prior year values if there is data to display:
    if (priorTwoYearTotal != 0) {
        [priorTwoYearHistory enumerateObjectsUsingBlock:^(PKSaleHistory *saleHistory, NSUInteger idx, BOOL *stop) {
            if (@([saleHistory value])) {
                [priorTwoYearData addObject:@([saleHistory value])];
            }
            if ([saleHistory value] > maxValue) {
                maxValue = [saleHistory value];
            }
            
            if ([[self labels] count] < 12) {
                NSString *dateFormatted = [saleHistory dateStringWithFormat:PKSaleHistoryDateFormatMonthNameShortOnly];
                if ([dateFormatted length] != 0) {
                    [[self labels] addObject:[dateFormatted substringToIndex:1]];
                }
            }
        }];
        
        if (priorTwoYearData) {
            [[self data] addObject:priorTwoYearData];
        }
    }
    
    int labelCountLimit = 10;
    if (maxValue <= labelCountLimit) {
        [[self graph] setValueLabelCount:(maxValue + 1)];
    } else {
        [[self graph] setValueLabelCount:(labelCountLimit + 1)];
    }
    
    [[self graph] setLineWidth:2];
    [[self graph] reset];
    
    // Draw the graph if there is data:
    if ([[self data] count] != 0) {
        [[self graph] setHidden:NO];
        [[self graph] draw];
    } else {
        [self setupNoDataView];
    }
}

#pragma mark - GraphKitDelegate Methods

- (NSInteger)numberOfLines {
    return [[self data] count];
}

- (NSArray *)valuesForLineAtIndex:(NSInteger)index {
    return [[self data] objectAtIndex:index];
}

- (UIColor *)colorForLineAtIndex:(NSInteger)index {
    if (index == 0) {
        return [UIColor puckatorPrimaryColor];
    } else if (index == 1) {
        return [UIColor puckatorRankMax];
    } else {
        return [UIColor puckatorPink];
    }
}

- (NSString *)titleForLineAtIndex:(NSInteger)index {
    return [[self labels] objectAtIndex:index];
}

#pragma mark -

@end
