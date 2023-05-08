//
//  PKProductReusableView.h
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKProductReusableView : UICollectionReusableView

- (void)setTitle:(NSString *)title;
- (void)setItemCount:(int)itemCount;
- (void)setIcon:(UIImage *)icon;

@end