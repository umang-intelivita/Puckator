//
//  PKImage+Operations.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 15/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKImage+Operations.h"
#import "PKFeedConfig.h"
#import <MagicalRecord/MagicalRecord.h>
#import "FCFileManager.h"
#import "UIImage+Resize.h"
#import <objc/runtime.h>
#import "PKConstant.h"
#import "PKFeedImages.h"

//NSString const *pkImageOperationsKeyCachedImage = @"PKImage.operations.key.cachedImage";
//NSString const *pkImageOperationsKeyCachedThumb = @"PKImage.operations.key.cachedThumb";

@implementation PKImage (Operations)

#pragma mark - Cache Methods

//- (void)cacheImage:(UIImage *)image {
////    objc_setAssociatedObject(self, &pkImageOperationsKeyCachedImage, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (UIImage *)cachedImage {
//    return nil;
////    return objc_getAssociatedObject(self, &pkImageOperationsKeyCachedImage);
//}
//
//- (void)removeCachedImage {
//    if ([self cachedImage]) {
//        objc_removeAssociatedObjects([self cachedImage]);
//    }
//}
//
//- (void)cacheThumb:(UIImage *)image {
//    //objc_setAssociatedObject(self, &pkImageOperationsKeyCachedThumb, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (UIImage *)cachedThumb {
//    return nil;
////    return objc_getAssociatedObject(self, &pkImageOperationsKeyCachedThumb);
//}
//
//- (void)removeCachedThumb {
//    if ([self cachedThumb]) {
//        objc_removeAssociatedObjects([self cachedThumb]);
//    }
//}

#pragma mark -

// Fetches or creates a Image entity with a specific ID
+ (PKImage*) findOrCreateWithImageId:(NSString*)imageName
                            atDomain:(NSString*)domain
                forRelatedEntityUuid:(NSString*)relatedProductUuid
           forRelatedEntityClassType:(NSString*)relatedClassType
                       forFeedConfig:(PKFeedConfig*)feedConfig
                           inContext:(NSManagedObjectContext*)context {
    // Create a predicate to find the product within a given feed
    NSPredicate *predicate = [PKImage predicateForImageUuid:relatedProductUuid forClassType:relatedClassType inFeedConfig:feedConfig];
    
    // Execute the search for the product
    //PKImage *image = [PKImage MR_findFirstWithPredicate:predicate inContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([PKImage class]) inManagedObjectContext:context]];
    [request setReturnsObjectsAsFaults:NO];
    [request setPredicate:predicate];
    
    __block PKImage *image = nil;
    [context performBlockAndWait:^{
        image = [[[context persistentStoreCoordinator] executeRequest:request withContext:context error:nil] firstObject];
    }];
    
    
    
//    if ([image isFault]) {
//        [image MR_deleteEntityInContext:context];
//        [context MR_saveToPersistentStoreAndWait];
//        image = nil;
//    }
    
    //NSArray *images = [PKImage MR_findAllWithPredicate:predicate inContext:context];
    
//    if ([image isFault]) {
//        
//        [context MR_deleteObjects:@[image]];
//        [context MR_saveOnlySelfAndWait];
//        image = nil;
//    }
    
    if (!image) {
        image = [PKImage createWithImageId:imageName
                                  atDomain:domain
                      forRelatedEntityUuid:relatedProductUuid
                 forRelatedEntityClassType:relatedClassType
                             forFeedConfig:feedConfig
                                 inContext:context];
    }
    
    return image;
}

+ (PKImage*) createWithImageId:(NSString*)imageName
                            atDomain:(NSString*)domain
                forRelatedEntityUuid:(NSString*)relatedProductUuid
           forRelatedEntityClassType:(NSString*)relatedClassType
                       forFeedConfig:(PKFeedConfig*)feedConfig
                           inContext:(NSManagedObjectContext*)context {
    PKImage *entity = [PKImage MR_createEntityInContext:context];
    [entity setRelatedToUuid:relatedProductUuid];
    [entity setRelatedToClass:[relatedClassType lowercaseString]];
    [entity setDomain:domain];
    [entity setFeedNumber:[feedConfig number]];
    [entity setName:imageName];
    return entity;
}

+ (BOOL)deleteProductImagesForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    return [PKImage deleteImagesForRelatedClassType:@"Product" forFeedConfig:feedConfig inContext:context];
}

+ (BOOL)deleteCategoryImagesForFeedConfig:(PKFeedConfig *)feedConfig inContext:(NSManagedObjectContext *)context {
    return [PKImage deleteImagesForRelatedClassType:@"Category" forFeedConfig:feedConfig inContext:context];
}

+ (BOOL) deleteImagesForRelatedClassType:(NSString*)relatedToClassType
                           forFeedConfig:(PKFeedConfig*)feedConfig
                               inContext:(NSManagedObjectContext*)context {
    return [PKImage MR_deleteAllMatchingPredicate:[PKImage predicateForClassType:relatedToClassType inFeedConfig:feedConfig] inContext:context];
}

+ (BOOL) deleteImagesForEntityUuid:(NSString*)relatedToUuid
                ofRelatedClassType:(NSString*)relatedToClassType
                      forFeedConfig:(PKFeedConfig*)feedConfig
                          inContext:(NSManagedObjectContext*)context {
    NSPredicate *predicate = nil;
    if (relatedToUuid) {
        predicate = [PKImage predicateForImageUuid:relatedToUuid
                                      forClassType:relatedToClassType
                                      inFeedConfig:feedConfig];
    } else {
        predicate = [PKImage predicateForClassType:relatedToClassType
                                      inFeedConfig:feedConfig];
    }
    
   
    return [PKImage MR_deleteAllMatchingPredicate:predicate inContext:context];
}

+ (NSArray *)findAllForRelatedEntityUuid:(NSString*)relatedEntityUuid
               forRelatedEntityClassType:(NSString*)relatedEntityClassType
                           forFeedConfig:(PKFeedConfig*)feedConfig {
    NSPredicate *predicate = [PKImage predicateForImageUuid:relatedEntityUuid
                                               forClassType:relatedEntityClassType
                                               inFeedConfig:feedConfig];
    return [PKImage MR_findAllSortedBy:@"order" ascending:YES withPredicate:predicate];
}

- (UIImage *)image {
    return [self imageReturnPlaceholderIfMissing:YES];
}

- (UIImage *)imageReturnPlaceholderIfMissing:(BOOL)returnPlaceholder {
//    if ([self cachedImage]) {
//        return [self cachedImage];
//    } else {
        NSString *imagePath = [self pathForImage];
        UIImage *image = nil;
        
        //if ([FCFileManager existsItemAtPath:imagePath]) {
        //NSLog(@"File found: %@", imagePath);
        image = [UIImage imageWithMimeTypeAtPath:imagePath];
        //}
        
//        [self cacheImage:image];
    
        if (!image && returnPlaceholder) {
            return [UIImage imageNamed:kPuckatorNoImageName];
        } else {
            return image;
        }
//    }
}

- (BOOL)purgeImage {
    return [PKFeedImages removeImageFilesNamed:[self name]];
//    NSString *imagePath = [self pathForImage];
//    if ([FCFileManager existsItemAtPath:imagePath]) {
//        return ([UIImage imageWithMimeTypeAtPath:imagePath] == nil);
//    } else {
//        return NO;
//    }
}

+ (BOOL)deleteAllThumbs {
    return [FCFileManager removeFilesInDirectoryAtPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"/thumbs"]];
}

+ (BOOL)deleteAllImages {
    [FCFileManager removeFilesInDirectoryAtPath:[FCFileManager pathForLibraryDirectoryWithPath:@"/Caches/com.puckator.Puckator/fsCachedData"]];
    [FCFileManager removeFilesInDirectoryAtPath:[FCFileManager pathForLibraryDirectoryWithPath:@"/Caches/com.57digital.puckator/fsCachedData"]];
    return [FCFileManager removeFilesInDirectoryAtPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"/images"]];
}

- (void)setImageAsyncToImageView:(UIImageView *)imageView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self image];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageView) {
                if (image) {
                    [imageView setImage:image];
                } else {
                    NSLog(@"[%@] - Image missing: %@", [self class], [self name]);
                }
            }
        });
    });
}

- (UIImage *)thumb {
//    if ([self cachedThumb]) {
//        return [self cachedThumb];
//    } else {
        //return [self image];
        NSString *imagePath = [self pathForThumbImage];
        
        UIImage *thumbImage = [UIImage imageWithMimeTypeAtPath:imagePath];
        
        if (!thumbImage) {
            // Create the thumbnail:
            UIImage *image = [self imageReturnPlaceholderIfMissing:YES];
            if (!image) {
                return nil;
            }
            
            int imageSize = 244 * [[UIScreen mainScreen] scale];
            
            // Save the thumb:
            UIImage *thumb = [image resizedImageToFitInSize:CGSizeMake(imageSize, imageSize) scaleIfSmaller:NO];
            NSString *thumbPath = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/thumbs/%@", [self name]]];
            
            if (thumb) {
                NSError *error = nil;
                [FCFileManager writeFileAtPath:thumbPath content:UIImageJPEGRepresentation(thumb, 0.5f) error:&error];
                
                if (error) {
                    NSLog(@"[%@] - Error thumbnailing image: %@", [self class], [self name]);
                }
            }
            
            // Setup the thumb:
            thumb = nil;
            image = nil;
            thumbImage = [UIImage imageWithMimeTypeAtPath:thumbPath];
        }
        
        // Cache the thumb image:
//        [self cacheThumb:thumbImage];
    
        // Return the thumb image:
        return thumbImage;
//    }
}

- (void)setThumbAsyncToImageView:(UIImageView *)imageView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            UIImage *image = [self thumb];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageView) {
                    if (image) {
                        [imageView setImage:image];
                    } else {
                        [imageView setImage:[UIImage imageNamed:@"PKNoImage"]];
                        NSLog(@"[%@] - Image missing: %@", [self class], [self name]);
                    }
                }
            });
        }
    });
}

+ (NSPredicate*)predicateForClassType:(NSString*)classType inFeedConfig:(PKFeedConfig*)feedConfig {
    return [NSPredicate predicateWithFormat:@"relatedToClass = %@ AND feedNumber = %@", [classType lowercaseString], [feedConfig number]];
}

+ (NSPredicate*)predicateForImageUuid:(NSString*)uuid forClassType:(NSString*)classType inFeedConfig:(PKFeedConfig*)feedConfig {
    return [NSPredicate predicateWithFormat:@"relatedToUuid = %@ AND relatedToClass = %@ AND feedNumber = %@", uuid, [classType lowercaseString], [feedConfig number]];
}

#pragma mark - Utils

- (NSURL *)fileUrlForImage {
    NSURL *fileUrl = nil;
    
    @try {
        fileUrl = [NSURL fileURLWithPath:[self pathForImage]];
    }
    @catch (NSException *exception) {
        NSLog(@"[%@] - Error: %@", [self class], [exception description]);
        fileUrl = nil;
    }
    @finally {
    }
    
    return fileUrl;
}

- (NSString*) pathForImage {
    NSString *path = nil;
    
    @try {
        path = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/images/%@", [self name]]];
    }
    @catch (NSException *exception) {
        NSLog(@"[%@] - Error: %@", [self class], [exception description]);
        path = nil;
    }
    @finally {
    }
    
    return path;
}

- (NSString*) pathForThumbImage {
    NSString *path = nil;
    
    @try {
        path = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/thumbs/%@", [self name]]];
    }
    @catch (NSException *exception) {
        NSLog(@"[%@] - Error: %@", [self class], [exception description]);
        path = nil;
    }
    @finally {
    }
    
    return path;
}

- (NSString *)debugInfo {
    NSArray *components = [[self name] componentsSeparatedByString:@"___ts___"];
    if ([components count] == 2) {
        NSString *dateStr = [components firstObject];
        NSString *dateFmt = dateStr;
        if ([dateStr length] == 12) {
            dateFmt = [NSString stringWithFormat:@"%@-%@-%@", [dateStr substringWithRange:NSMakeRange(0, 4)], [dateStr substringWithRange:NSMakeRange(4, 2)], [dateStr substringWithRange:NSMakeRange(6, 2)]];
        }
        return [NSString stringWithFormat:@"%@ : %@", [components lastObject], dateFmt];
    }
    return [self name];
}

- (NSDate *)dateCreated {
    return [FCFileManager creationDateOfItemAtPath:[self pathForImage]];
}

- (NSDate *)dateModified {
    return (NSDate *)[FCFileManager attributeOfItemAtPath:[self pathForImage] forKey:NSFileModificationDate];
}

#pragma mark -

@end
