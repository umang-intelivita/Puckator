//
//  PKCategoryCell.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKCategoryCell.h"
#import "PKCategory+Operations.h"

@interface PKCategoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewMain;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;


@end

@implementation PKCategoryCell

- (void)awakeFromNib {
    // Initialization code
    [self setupUI];
}

#pragma mark - Private Methods

- (void)setupUI {
}

#pragma mark - Public Methods

- (void)setupWithCategory:(PKCategory *)category {
    [[self labelTitle] setText:[category styledTitle]];
    [[self imageViewMain] setImage:[category image]];
    [[self imageViewMain] setBackgroundColor:[UIColor clearColor]];
}

- (void)setupWithCategoryObject:(PKCategoryObject *)category {
    [[self labelTitle] setText:[category title]];
    [[self imageViewMain] setImage:[UIImage imageNamed:@"PKNoImage"]];
    [[self imageViewMain] setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -

@end
