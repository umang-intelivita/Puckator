//
//  PKMiniSearchResultTableViewCell.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKMiniSearchResultTableViewCell.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"

@implementation PKMiniSearchResultTableViewCell

- (void)awakeFromNib {
    [[self labelProductTitle] setFont:[UIFont puckatorContentTitle]];
    [[self labelProductTitle] setTextColor:[UIColor darkTextColor]];
    [[self labelProductMetaData] setFont:[UIFont puckatorContentText]];
    [[self labelProductMetaData] setTextColor:[UIColor puckatorSubtitleColor]];
    [[[self imageViewProduct] layer] setCornerRadius:4];
    [[self imageViewProduct] setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setProduct:(PKProduct*)product {
    [[self labelProductTitle] setText:[product title]];
    [[self labelProductMetaData] setText:[product model]];
    [[self imageViewProduct] setImage:[product image]];
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

@end
