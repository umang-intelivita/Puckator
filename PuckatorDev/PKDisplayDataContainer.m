//
//  PKDataDisplayContainer.m
//  PuckatorDev
//
//  Created by Luke Dixon on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKDisplayDataContainer.h"
#import "UIColor+Puckator.h"

@interface PKDisplayDataContainer ()

@property (strong, nonatomic) NSArray *dataDisplayItems;

@end

@implementation PKDisplayDataContainer

#pragma mark - Constructor Methods

- (void)awakeFromNib {
    [self setSectionPadding:0];
    [self setRowPadding:0];
    [self setCellPadding:5];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setSectionPadding:5];
        [self setRowPadding:0];
        [self setCellPadding:5];
        
        [self setBackgroundColor:[UIColor colorWithHexString:@"eceeee"]];
    }
    return self;
}

+ (instancetype)createWithFrame:(CGRect)frame dataDisplayItems:(NSArray *)dataDisplayItems {
    PKDisplayDataContainer *dataDisplayContainer = [[PKDisplayDataContainer alloc] initWithFrame:frame];
    [dataDisplayContainer setDataDisplayItems:dataDisplayItems];
    [dataDisplayContainer setupUI];
    return dataDisplayContainer;
}

#pragma mark - Private Methods

- (void)setupUI {
    CGFloat padding = [self sectionPadding];
    __block CGFloat currentY = padding;
    
    // Remove all the current subviews:
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
    
    [[self dataDisplayItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PKDisplayDataView *displayDataView = [PKDisplayDataView createWithDisplayData:obj
                                                                               origin:CGPointMake(padding, currentY)
                                                                                width:[self bounds].size.width - (padding * 2)
                                                                               height:30
                                                                       leftEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)
                                                                      rightEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)
                                                                  leftLabelEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)
                                                                 rightLabelEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)
                                                                       backgroundLeft:[UIColor colorWithHexString:@"e6e8e9"]
                                                                      backgroundRight:[UIColor colorWithHexString:@"eceeee"]
                                                                       foregroundLeft:[UIColor colorWithHexString:@"868f98"]
                                                                      foregroundRight:[UIColor colorWithHexString:@"414b56"]
                                                                       seperatorColor:[UIColor puckatorSeparator]];
        //[displayDataView setBackgroundColor:[UIColor puckatorLightGray]];
        [self addSubview:displayDataView];
        currentY += ([displayDataView bounds].size.height + padding);
    }];
    
    if (currentY > [self bounds].size.height) {
        [self setContentSize:CGSizeMake(0, currentY)];
    } else {
        [self setContentSize:CGSizeMake(0, [self bounds].size.height + 1)];
    }
}

#pragma mark - Public Methods

- (void)updateDataDisplayItems:(NSArray *)dataDisplayItems {
    [self setDataDisplayItems:dataDisplayItems];
    [self setupUI];
}

#pragma mark -

@end