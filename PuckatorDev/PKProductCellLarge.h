//
//  PFFullProductCell.h
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKProductCellMedium.h"
#import "PKKeyPad.h"
#import "PKProductPricesView.h"
#import "PKProductImageGallery.h"
#import "PKCustomerSelectionDelegate.h"
#import "PKQuantityView.h"

@class PKProductCellLarge;

@protocol PKProductCellLargeDelegate<NSObject>
- (void)pkProductCellLarge:(PKProductCellLarge *)productCellLarge requestGalleryWithImages:(NSArray *)images;
@end

@interface PKProductCellLarge : PKProductCellMedium <UIScrollViewDelegate, UITextFieldDelegate, PKKeyPadDelegate, PKProductPriceViewDelegate, PKProductImageGalleryDelegate, PKCustomerSelectionDelegate>

@property (weak, nonatomic) id<PKProductCellLargeDelegate> delegate;

@end