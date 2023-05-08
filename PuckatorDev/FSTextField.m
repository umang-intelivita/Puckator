//
//  FSTextField.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "FSTextField.h"

@interface FSTextField()
@property (nonatomic, strong) UIColor *defaultBorderColor;
@end

@implementation FSTextField

-(instancetype)init {
    if(self = [super init]) {
        [self setDefaultBorderColor:[UIColor colorWithCGColor:[[self layer] borderColor]]];
    }
    return self;
}

- (BOOL) isValid {
    if([self required]) {
        
        if([[self text] length] >= 1) {
            [self restyle];
            return YES;
        } else {
            [self restyleForError];
            return NO;
        }
        
    } else {
        [self restyle];
        return YES;
    }
}

- (void) restyleForError {
    [[self layer] setBorderColor:[UIColor redColor].CGColor];
    [[self layer] setBorderWidth:1];
    [[self layer] setCornerRadius:5];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            [self setAlpha:1.0f];
        } completion:NULL];
    }];
}

- (void) restyle {
    [[self layer] setBorderColor:[self defaultBorderColor].CGColor];
    [[self layer] setBorderWidth:0];
}

- (BOOL) becomeFirstResponderIfEmpty {
    
    if([[self text] length] == 0) {
        return [self becomeFirstResponder];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidHideNotification object:nil]; //hack
        return YES;
    }
    
}

@end
