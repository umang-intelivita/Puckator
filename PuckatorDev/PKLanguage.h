//
//  PKLanguage.h
//  Puckator
//
//  Created by Luke Dixon on 28/09/2015.
//  Copyright © 2015 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKLanguage : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *imageName;

+ (NSArray *)languages;
- (UIImage *)image;
+ (NSString *)currentLanguageCode;

@end