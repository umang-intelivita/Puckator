//
//  PKBasketCalculationTableViewCell.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasketCalculationTableViewCell.h"
#import "UIColor+Puckator.h"

@implementation PKBasketCalculationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) updateStyleIsButton:(BOOL)isButton isHighlighted:(BOOL)isHighlighted {
    int radius = 4;
    if(isButton) {
        [[self buttonValue] setBackgroundColor:[UIColor puckatorPrimaryColor]];
        [[self buttonValue] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [[self buttonValue] setBackgroundColor:[UIColor whiteColor]];
        [[self buttonValue] setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    }
    
    if(isHighlighted) {
        [[self buttonValue] setTitleColor:[UIColor puckatorPink] forState:UIControlStateNormal];
    }
    
    // Update corner radius
    [[[self buttonValue] titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[[self buttonValue] layer] setCornerRadius:radius];
    [[self buttonValue] setClipsToBounds:YES];
    [[self buttonValue] setUserInteractionEnabled:YES];
    [[self buttonValue] addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateWithTitle:(NSString *)title value:(NSString *)value {
    [[self labelRowTitle] setText:title];
    [[self labelRowValue] setText:value];
    [[self buttonValue] setTitle:value forState:UIControlStateNormal];
    //[[self labelRowValue] setTextColor:[UIColor darkTextColor]];
}

- (void) didTapButton:(id)sender {
    if ([self selectionDelegate] && [[self selectionDelegate] respondsToSelector:@selector(pkBasketCalculationTableViewCell:didSelectInteractionElement:name:)]) {
        [[self selectionDelegate] pkBasketCalculationTableViewCell:self didSelectInteractionElement:[self buttonValue] name:@"button"];
    }
}

@end