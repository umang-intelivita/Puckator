//
//  UIColor+Puckator.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "UIColor+Puckator.h"
#import "PuckatorKit.h"
@implementation UIColor (Puckator)

+ (UIColor *)primaryColor {
    return [UIColor puckatorPrimaryColor];
}

+ (UIColor *)subtitleColor {
    return [UIColor puckatorSubtitleColor];
}

+ (UIColor *)puckatorPrimaryColor {
    return [UIColor colorWithHexString:@"52246c"];
}

+ (UIColor *)puckatorSubtitleColor {
    return [UIColor darkGrayColor];
}

+ (UIColor*)puckatorPrimaryColorAccent {
    return [UIColor colorWithHexString:@"8d62a5"];
}

+ (UIColor*) puckatorLightPurple {
    return [UIColor colorWithHexString:@"a16caa"];
}

+ (UIColor *)puckatorSelectedButtonColor {
    return [UIColor colorWithHexString:@"44bdfa"];
}

+ (UIColor *)puckatorUnselectedButtonColor {
    return [UIColor colorWithHexString:@"414b56"];
}

+ (UIColor *)puckatorBorderColor {
    return [UIColor colorWithHexString:@"e0e2e2"];
}

+ (UIColor *)puckatorCollectionViewBackgroundColor {
    return [UIColor colorWithHexString:@"dadada"];
}

+ (UIColor *)puckatorLightGray {
    return [UIColor colorWithHexString:@"eceeee"];
}

+ (UIColor *)puckatorGray {
    return [UIColor colorWithHexString:@"e0e2e2"];
}

+ (UIColor *)puckatorDarkGray {
    return [UIColor colorWithHexString:@"616a74"];
}

+ (UIColor *)puckatorRankMax {
    return [UIColor colorWithHexString:@"5aab00"];
}

+ (UIColor *)puckatorRankMid {
    return [UIColor colorWithHexString:@"f8c821"];
}

+ (UIColor *)puckatorRankMin {
    return [UIColor colorWithHexString:@"f1572c"];
}

+ (UIColor *)puckatorGreen {
    return [UIColor colorWithHexString:@"96c11f"];
}

+ (UIColor *)puckatorLightBlue {
    return [UIColor colorWithHexString:@"73cafd"];
}

+ (UIColor *)puckatorSeparatorLight {
    return [UIColor colorWithHexString:@"4e5760"];
}

+ (UIColor *)puckatorDarkGreen {
    return [UIColor colorWithHexString:@"419119"];
}

+ (UIColor *)puckatorDarkBlue {
    return [UIColor colorWithHexString:@"323a43"];
}

+ (UIColor *)puckatorDarkerGreen {
    return [UIColor colorWithHexString:@"759618"];
}

+ (UIColor *)puckatorPink {
    return [UIColor colorWithHexString:@"e6007e"];
}

+ (UIColor *)puckatorProductTitle {
    return [UIColor colorWithHexString:@"414b56"];
}

+ (UIColor *)puckatorProductSubtitle {
    return [UIColor colorWithHexString:@"d3d7da"];
}

+ (UIColor *)puckatorSeparator {
    return [UIColor colorWithHexString:@"d0d4d7"];
}

+ (UIColor *)randomColor {
    CGFloat red =  (CGFloat)arc4random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
