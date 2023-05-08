//
//  FSTextField.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSTextField : UITextField

@property (nonatomic, assign) IBInspectable BOOL required;

- (BOOL) isValid;
- (BOOL) becomeFirstResponderIfEmpty;

@end
