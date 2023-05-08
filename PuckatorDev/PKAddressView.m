//
//  PKAddressView.m
//  PuckatorDev
//
//  Created by Luke Dixon on 10/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKAddressView.h"
#import <PuckatorKit/PKAddress.h>

@interface PKAddressView ()

@property (strong, nonatomic) PKAddress *address;

@end

@implementation PKAddressView

+ (instancetype)createWithAddress:(PKAddress *)address frame:(CGRect)frame {
    PKAddressView *addressView = [[PKAddressView alloc] initWithFrame:frame];
    [addressView setAddress:address];
    [addressView setBackgroundColor:[UIColor redColor]];
    [addressView setupUI];
    return addressView;
}

- (void)setupUI {
    NSDictionary *displayData = [[self address] displayData];
    
    NSArray *rightData = [displayData objectForKey:@"right_data"];
    NSArray *leftData = [displayData objectForKey:@"left_data"];
    
    int rightDataWidth = [self bounds].size.width * 0.25f;
    int rightLabelWidth = [self bounds].size.width * 0.25f;
    int leftDataWidth = [self bounds].size.width * 0.25f;
    int leftLabelWidth = [self bounds].size.width * 0.25f;
    int labelHeight = 40;
    int labelPadding = 10;
    
    [rightData enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@: %@", [data objectForKey:@"title"], [data objectForKey:@"data"]);
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, idx * labelHeight, rightDataWidth, labelHeight)];
        [labelTitle setText:[data objectForKey:@"title"]];
        [labelTitle setTextAlignment:NSTextAlignmentRight];
        [self addSubview:labelTitle];
        
        UILabel *labelData = [[UILabel alloc] initWithFrame:CGRectMake(rightDataWidth, idx * labelHeight, rightDataWidth, labelHeight)];
        [labelData setText:[data objectForKey:@"data"]];
        [labelData setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:labelData];
        
        [self setFrame:CGRectMake([self frame].origin.x,
                                  [self frame].origin.y,
                                  [self frame].size.width,
                                  [self frame].size.height + labelHeight)];
    }];
    
    [leftData enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@: %@", [data objectForKey:@"title"], [data objectForKey:@"data"]);
    }];
}

@end