//
//  PKProductReusableView.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKProductReusableView.h"

@interface PKProductReusableView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelItemCount;

@end

@implementation PKProductReusableView

- (void)awakeFromNib {
    // Initialization code
}

- (NSString *)reuseIdentifier {
    return @"PKProductReusableView";
}


- (void)setTitle:(NSString *)title {
    [[self labelTitle] setText:title];
}

- (void)setItemCount:(int)itemCount {
    [[self labelItemCount] setText:[NSString stringWithFormat:@"%i items", itemCount]];
}

- (void)setIcon:(UIImage *)icon {
    [[self imageViewIcon] setImage:icon];
}

@end