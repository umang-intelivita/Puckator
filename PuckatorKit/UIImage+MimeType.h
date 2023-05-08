//
//  UIImage+MimeType.h
//  PuckatorDev
//
//  Created by Luke Dixon on 24/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UIImageMimeTypeUnknown,
    UIImageMimeTypeGIF,
    UIImageMimeTypeJPEG,
    UIImageMimeTypePNG,
    UIImageMimeTypeTIFF
} UIImageMimeType;

@interface UIImage (MimeType)

+ (UIImage *)imageWithMimeTypeAtPath:(NSString *)path;

- (void)setMimeType:(UIImageMimeType)mimeType;
- (void)setMimeTypeFromImageName:(NSString *)imageName;

- (UIImageMimeType)mimeType;
- (NSString *)imagePath;
- (NSURL *)imageUrl;

@end