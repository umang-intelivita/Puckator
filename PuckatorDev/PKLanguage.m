//
//  PKLanguage.m
//  Puckator
//
//  Created by Luke Dixon on 28/09/2015.
//  Copyright © 2015 57Digital Ltd. All rights reserved.
//

#import "PKLanguage.h"

@implementation PKLanguage

+ (instancetype)createWithDictionary:(NSDictionary *)dictionary {
    PKLanguage *language = [[PKLanguage alloc] init];
    [language setTitle:[dictionary objectForKey:@"title"]];
    [language setImageName:[dictionary objectForKey:@"imageName"]];
    [language setCode:[dictionary objectForKey:@"code"]];
    return language;
}

+ (NSArray *)languages {
    NSMutableArray *languages = [NSMutableArray array];
    
    // Open the plist:
    NSArray *languageArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Languages" ofType:@"plist"]];
    [languageArray enumerateObjectsUsingBlock:^(NSDictionary *languageDictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        PKLanguage *language = [PKLanguage createWithDictionary:languageDictionary];
        if (language) {
            [languages addObject:language];
        }
    }];
    
    return languages;
}

+ (NSString *)currentLanguageCode {
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    return [languages firstObject];
}

- (UIImage *)image {
    return [UIImage imageNamed:[self imageName]];
}

@end
