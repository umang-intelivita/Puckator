//
//  UIColor+Puckator.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Puckator)

+ (UIColor*) primaryColor __deprecated_msg("Use puckatorPrimaryColor instead.");
+ (UIColor*) subtitleColor __deprecated_msg("Use puckatorSubtitleColor instead.");

+ (UIColor *)puckatorPrimaryColor;
+ (UIColor*)puckatorPrimaryColorAccent;
+ (UIColor *)puckatorSubtitleColor;
+ (UIColor *)puckatorLightPurple;
+ (UIColor *)puckatorSelectedButtonColor;
+ (UIColor *)puckatorUnselectedButtonColor;
+ (UIColor *)puckatorBorderColor;

+ (UIColor *)puckatorLightGray;
+ (UIColor *)puckatorGray;
+ (UIColor *)puckatorDarkGray;

// Rank colors:
+ (UIColor *)puckatorRankMax;
+ (UIColor *)puckatorRankMid;
+ (UIColor *)puckatorRankMin;

+ (UIColor *)puckatorGreen;
+ (UIColor *)puckatorDarkGreen;
+ (UIColor *)puckatorDarkerGreen;
+ (UIColor *)puckatorPink;

+ (UIColor *)puckatorLightBlue;
+ (UIColor *)puckatorDarkBlue;

+ (UIColor *)randomColor;

+ (UIColor *)puckatorProductTitle;
+ (UIColor *)puckatorProductSubtitle;

+ (UIColor *)puckatorCollectionViewBackgroundColor;

+ (UIColor *)puckatorSeparator;
+ (UIColor *)puckatorSeparatorLight;

@end