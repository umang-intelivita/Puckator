//
//  PKCustomerDetailCell.m
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKCustomerDetailCell.h"
#import "PKDisplayDataView.h"
#import "PKDisplayDataContainer.h"
#import "PKCustomer.h"
#import "PKAddress.h"

@interface PKCustomerDetailCell ()

@property (strong, nonatomic) PKDisplayDataContainer *displayDataContainer;

@end

@implementation PKCustomerDetailCell

- (void)setupWithCustomer:(PKCustomer *)customer {
    if (![self displayDataContainer]) {
        NSMutableArray *dataDisplayItems = [NSMutableArray array];
        PKDisplayData *customerDisplayData = [customer displayData];
        if (customerDisplayData) {
            [dataDisplayItems addObject:customerDisplayData];
        }
        
        [[customer addresses] enumerateObjectsUsingBlock:^(PKAddress *address, NSUInteger idx, BOOL *stop) {
            PKDisplayData *addressDisplayData = [address displayData];
            if (addressDisplayData) {
                [dataDisplayItems addObject:addressDisplayData];
            }
        }];
        
        PKDisplayDataContainer *container = [PKDisplayDataContainer createWithFrame:[self bounds]
                                                                   dataDisplayItems:dataDisplayItems];
        //[container setAlpha:0.0f];
        [container setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:container];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[container]-0-|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(container)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[container]-0-|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(container)]];
        [self setDisplayDataContainer:container];
    }
}

@end
