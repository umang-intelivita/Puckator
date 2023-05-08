//
//  PKDisplayData.h
//  PuckatorDev
//
//  Created by Luke Dixon on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PKDisplayData;

@protocol PKDisplayData <NSObject>

@required
- (PKDisplayData *)displayData;

@end

@interface PKDisplayData : NSObject

@property UIColor *backgroudColor;
@property UIColor *foregroundColor;

#pragma mark - Constructor Methods
+ (instancetype)create;

#pragma mark - Public Methods
- (BOOL)openSection;
- (BOOL)closeSection;
- (BOOL)addTitle:(NSString *)title data:(NSString *)data;
- (BOOL)addTitle:(NSString *)title data:(NSString *)data foregroundRight:(UIColor *)foregroundRight backgroundRight:(UIColor *)backgroundRight;

- (NSArray *)sections;
- (CGFloat)widthPerSectionForWidth:(CGFloat)width;

@end
