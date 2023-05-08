//
//  PKProductCellSmall.h
//  PuckatorDev
//
//  Created by Luke Dixon on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKKeyPad.h"
#import "PKImage+Operations.h"

@interface PKProductCellSmall : UICollectionViewCell <PKKeyPadDelegate>

- (void)setupWithProduct:(PKProduct *)product;
- (void)setupWithProduct:(PKProduct *)product image:(UIImage *)image;
- (void)setupWithProduct:(PKProduct *)product image:(UIImage *)image indexPath:(NSIndexPath *)indexPath;

- (void)presentKeyPadFromView:(UIView *)view;
- (void)dismissNumericPad;

@end