//
//  UIImage+MimeType.m
//  PuckatorDev
//
//  Created by Luke Dixon on 24/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "UIImage+MimeType.h"
#import <objc/runtime.h>
#import <FCFileManager/FCFileManager.h>

NSString const *imageMimeTypeKey = @"uiimage.mimetype.key";
NSString const *imagePathKey = @"uiimage.mimetype.key";

@implementation UIImage (MimeType)

+ (UIImage *)imageWithMimeTypeAtPath:(NSString *)path {
    if (!path) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    if (!image) {
        // Image must be damaged, remove it:
        if ([FCFileManager isFileItemAtPath:path]) {
            if ([FCFileManager removeItemAtPath:path]) {
                return nil;
            }
        }
    }
    
    [image setMimeTypeFromImageName:path];
    [image setImagePath:path];
    return image;
}

- (void)setMimeType:(UIImageMimeType)mimeType {
    objc_setAssociatedObject(self, &imageMimeTypeKey, @(mimeType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setImagePath:(NSString *)imagePath {
    objc_setAssociatedObject(self, &imagePathKey, imagePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMimeTypeFromImageName:(NSString *)imageName {
    if ([imageName containsString:@".jpg"] || [imageName containsString:@".jpeg"]) {
        [self setMimeType:UIImageMimeTypeJPEG];
    } else if ([imageName containsString:@".gif"]) {
        [self setMimeType:UIImageMimeTypeGIF];
    } else if ([imageName containsString:@".png"]) {
        [self setMimeType:UIImageMimeTypePNG];
    } else if ([imageName containsString:@".tiff"]) {
        [self setMimeType:UIImageMimeTypeTIFF];
    } else {
        [self setMimeType:UIImageMimeTypeUnknown];
    }
}

- (UIImageMimeType)mimeType {
    return [objc_getAssociatedObject(self, &imageMimeTypeKey) intValue];
}

- (NSString *)imagePath {
    return objc_getAssociatedObject(self, &imagePathKey);
}

- (NSURL *)imageUrl {
    return [NSURL fileURLWithPath:[self imagePath]];
}

@end
