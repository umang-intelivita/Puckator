//
//  UIFont+Puckator.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Font)

- (CGFloat)fontSize;
- (void)setPuckatorStandardFont;
- (void)setPuckatorMediumFont;
- (void)setPuckatorBoldFont;

@end

@interface UIFont (Puckator)

+ (UIFont*) puckatorContentTitle;
+ (UIFont*) puckatorContentTitleHeavy;  // Heavier version
+ (UIFont*) puckatorContentText;
+ (UIFont*) puckatorContentTextBold; // Same as text, but bold

+ (UIFont*) puckatorDescriptionHeader;
+ (UIFont*) puckatorDescriptionBold;
+ (UIFont*) puckatorDescriptionStandard;

+ (UIFont*)puckatorFontStandardWithSize:(CGFloat)size;
+ (UIFont*)puckatorFontMediumWithSize:(CGFloat)size;
+ (UIFont*)puckatorFontBoldWithSize:(CGFloat)size;

+ (NSDictionary *)puckatorAttributedFont:(UIFont *)font;
+ (NSDictionary *)puckatorAttributedFont:(UIFont *)font color:(UIColor *)color;
+ (NSAttributedString *)puckatorAttributedStringWithBoldText:(NSString *)boldText standardText:(NSString *)standardText fontSize:(CGFloat)floatSize;
+ (NSAttributedString *)puckatorAttributedStringWithStandardText:(NSString *)standardText boldText:(NSString *)boldText fontSize:(CGFloat)floatSize;

@end