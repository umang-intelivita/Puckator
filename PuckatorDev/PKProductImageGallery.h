//
//  PKProductImageGallery.h
//  PuckatorDev
//
//  Created by Luke Dixon on 13/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+animatedGIF.h"

@class PKProductImageGallery;

@protocol PKProductImageGalleryDelegate<NSObject>
- (void)pkProductImageGallery:(PKProductImageGallery *)productImageGallery willCloseAtIndex:(int)index;
@end

@interface PKProductImageGallery : NSObject <UIScrollViewDelegate>

@property (weak, nonatomic) id<PKProductImageGalleryDelegate> delegate;

+ (instancetype)createWithDelegate:(id<PKProductImageGalleryDelegate>)delegate;
- (void)displayImages:(NSArray *)images imageIndex:(int)imageIndex;
- (void)displayImages:(NSArray *)images imageIndex:(int)imageIndex onView:(UIView *)view;

@end