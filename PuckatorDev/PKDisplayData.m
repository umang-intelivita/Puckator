//
//  PKDisplayData.m
//  PuckatorDev
//
//  Created by Luke Dixon on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKDisplayData.h"

@interface PKDisplayData ()

@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSMutableArray *currentSection;

@end

@implementation PKDisplayData

#pragma mark - Constructor Methods

+ (instancetype)create {
    PKDisplayData *displayData = [[PKDisplayData alloc] init];
    [displayData setSections:[NSMutableArray array]];
    return displayData;
}

#pragma mark - Public Methods

- (BOOL)openSection {
    if ([self currentSection]) {
        [self closeSection];
    }
    
    [self setCurrentSection:[NSMutableArray array]];
    return ([self currentSection] != nil);
}

- (BOOL)closeSection {
    if ([self currentSection]) {
        [_sections addObject:[self currentSection]];
        [self setCurrentSection:nil];
    }
    
    return ([self currentSection] == nil);
}

- (BOOL)addTitle:(NSString *)title data:(NSString *)data {
    return [self addTitle:title data:data foregroundRight:nil backgroundRight:nil];
}

- (BOOL)addTitle:(NSString *)title data:(NSString *)data foregroundRight:(UIColor *)foregroundRight backgroundRight:(UIColor *)backgroundRight {
    if (![self currentSection]) {
        [self openSection];
    }
    
    if ([data length] != 0) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:([title length] != 0 ? title : @"") forKey:@"title"];
        [dictionary setObject:([data length] != 0 ? data : @"") forKey:@"data"];
        
        if (backgroundRight) {
            [dictionary setObject:backgroundRight forKey:@"backgroundRight"];
        }
        
        if (foregroundRight) {
            [dictionary setObject:foregroundRight forKey:@"foregroundRight"];
        }
        
        if (dictionary) {
            [[self currentSection] addObject:dictionary];
        }
        return YES;
    } else {
        return NO;
    }
}

- (CGFloat)widthPerSectionForWidth:(CGFloat)width {
    return width / (CGFloat)[[self sections] count];
}

- (NSArray *)sections {
    return _sections;
}

#pragma mark -

@end
