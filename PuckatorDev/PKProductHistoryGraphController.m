//
//  PKProductHistoryGraphController.m
//  PuckatorDev
//
//  Created by Luke Dixon on 29/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductHistoryGraphController.h"
#import "PKProductHistoryGraph.h"

@interface PKProductHistoryGraphController ()

@property (weak, nonatomic) PKProduct *product;
@property (strong, nonatomic) PKProductHistoryGraph *productHistoryGraph;
@property (nonatomic) PKProductWarehouse warehouse;

@end

@implementation PKProductHistoryGraphController

#pragma mark - Constructor Methods

+ (instancetype)createWithProduct:(PKProduct *)product warehouse:(PKProductWarehouse)warehouse {
    PKProductHistoryGraphController *productHistoryGraphController = [[PKProductHistoryGraphController alloc] initWithNibName:@"PKProductHistoryGraphController" bundle:nil];
    [productHistoryGraphController setProduct:product];
    [productHistoryGraphController setWarehouse:warehouse];
    return productHistoryGraphController;
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self view] setNeedsLayout];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(400, 400);
}

#pragma mark - Private Methods

- (void)setupUI {
    // Setup the graph view:
    if (![self productHistoryGraph]) {
        CGRect graphRect = [[self view] bounds];
        [self setProductHistoryGraph:[PKProductHistoryGraph createWithProduct:[self product] warehouse:[self warehouse] frame:graphRect]];
        [[self view] addSubview:[self productHistoryGraph]];
    }
}

#pragma mark - Public Methods

#pragma mark - Memory Management

#pragma mark -

@end
