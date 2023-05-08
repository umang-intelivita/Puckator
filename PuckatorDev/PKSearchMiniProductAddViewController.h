//
//  PKSearchMiniProductAddViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 03/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKQuantityView.h"
#import "PKProductImageGallery.h"

@interface PKSearchMiniProductAddViewController : UIViewController <PKQuantityViewDelegate, PKProductImageGalleryDelegate>

@property (nonatomic, strong) PKProduct *product;

@end
