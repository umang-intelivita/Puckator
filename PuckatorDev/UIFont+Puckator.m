//
//  UIFont+Puckator.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "UIFont+Puckator.h"

@implementation UIFont (Puckator)

+ (UIFont*) puckatorDescriptionHeader {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:17.0];
}

+ (UIFont*) puckatorDescriptionBold {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:14.0];
}

+ (UIFont*) puckatorDescriptionStandard {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
}

+ (UIFont*) puckatorContentTitle {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:17.0];
}

+ (UIFont*) puckatorContentTitleHeavy {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:17.0];
}

+ (UIFont*) puckatorContentText {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
}

+ (UIFont*) puckatorContentTextBold {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0];
}

+ (UIFont*)puckatorFontStandardWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

+ (UIFont*)puckatorFontMediumWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

+ (UIFont*)puckatorFontBoldWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:size];
}

+ (NSDictionary *)puckatorAttributedFont:(UIFont *)font {
    return [UIFont puckatorAttributedFont:font color:[UIColor blackColor]];
}

+ (NSDictionary *)puckatorAttributedFont:(UIFont *)font color:(UIColor *)color {
    return @{NSFontAttributeName : font,
             NSForegroundColorAttributeName : color};
}

+ (NSAttributedString *)puckatorAttributedStringWithBoldText:(NSString *)boldText standardText:(NSString *)standardText fontSize:(CGFloat)floatSize {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:boldText attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:floatSize] color:[UIColor whiteColor]]]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:standardText attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:floatSize] color:[UIColor whiteColor]]]];
    
    return attributedString;
}

+ (NSAttributedString *)puckatorAttributedStringWithStandardText:(NSString *)standardText boldText:(NSString *)boldText fontSize:(CGFloat)floatSize {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:standardText attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:floatSize] color:[UIColor whiteColor]]]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:boldText attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:floatSize] color:[UIColor whiteColor]]]];
    
    return attributedString;
}

@end

@implementation UILabel (Font)

- (CGFloat)fontSize {
    return [[self font] pointSize];
}

- (void)setPuckatorStandardFont {
    [self setFont:[UIFont puckatorFontStandardWithSize:[self fontSize]]];
}

- (void)setPuckatorMediumFont {
    [self setFont:[UIFont puckatorFontMediumWithSize:[self fontSize]]];
}

- (void)setPuckatorBoldFont {
    [self setFont:[UIFont puckatorFontBoldWithSize:[self fontSize]]];
}

@end