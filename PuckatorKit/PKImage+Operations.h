//
//  PKImage+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKImage.h"
#import "UIImage+MimeType.h"
#import <UIKit/UIKit.h>

//typedef enum : NSUInteger {
//    PKImageMimeTypeGIF,
//    PKImageMimeTypeJPEG,
//    PKImageMimeTypePNG,
//    PKImageMimeTypeTIFF,
//    PKImageMimeTypeUnknown,
//} PKImageMimeType;

@class PKFeedConfig;

@interface PKImage (Operations)

// Fetches or creates a Image entity with a specific ID
+ (PKImage*) findOrCreateWithImageId:(NSString*)imageName
                            atDomain:(NSString*)domain
                forRelatedEntityUuid:(NSString*)relatedProductUuid
           forRelatedEntityClassType:(NSString*)relatedClassType
                       forFeedConfig:(PKFeedConfig*)feedConfig
                           inContext:(NSManagedObjectContext*)context;

+ (PKImage*) createWithImageId:(NSString*)imageName
                      atDomain:(NSString*)domain
          forRelatedEntityUuid:(NSString*)relatedProductUuid
     forRelatedEntityClassType:(NSString*)relatedClassType
                 forFeedConfig:(PKFeedConfig*)feedConfig
                     inContext:(NSManagedObjectContext*)context;

// Deletes all images associated with a given entity.  The uuid is the unique ID
// of the related entity (i.e. productId / categoryId).  The class type is "Product", "Category", etc.
+ (BOOL) deleteImagesForEntityUuid:(NSString*)relatedToUuid
                ofRelatedClassType:(NSString*)relatedToClassType
                     forFeedConfig:(PKFeedConfig*)feedConfig
                         inContext:(NSManagedObjectContext*)context;

+ (BOOL) deleteImagesForRelatedClassType:(NSString*)relatedToClassType
                           forFeedConfig:(PKFeedConfig*)feedConfig
                               inContext:(NSManagedObjectContext*)context;

+ (BOOL)deleteProductImagesForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteCategoryImagesForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllForRelatedEntityUuid:(NSString*)relatedEntityUuid
               forRelatedEntityClassType:(NSString*)relatedEntityClassType
                           forFeedConfig:(PKFeedConfig*)feedConfig;

- (BOOL)purgeImage;
//- (void)removeCachedImage;
- (UIImage *)image;
- (void)setImageAsyncToImageView:(UIImageView *)imageView;

+ (BOOL)deleteAllThumbs;
+ (BOOL)deleteAllImages;

- (UIImage *)thumb;
- (void)setThumbAsyncToImageView:(UIImageView *)imageView;

#pragma mark - Utils

// Returns the path of an image
- (NSURL *)fileUrlForImage;
- (NSString*) pathForImage;

- (NSString *)debugInfo;
- (NSDate *)dateCreated;
- (NSDate *)dateModified;

@end
