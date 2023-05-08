//
//  PKBasketItem+UI.m
//  PuckatorDev
//
//  Created by Luke Dixon on 17/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasketItem+UI.h"
#import "PKAttributedString.h"

@implementation PKBasketItem (UI)

- (NSAttributedString *)orderAmountAttributedString {
    if ([[self quantity] intValue] <= 0) {
        return nil;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i ", [[self quantity] intValue]]
                                                                             attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor puckatorDarkGreen]]]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"in order currently", nil)
                                                                             attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor puckatorDarkGray]]]];
    return attributedString;
}

@end