//
//  PKFeedImages.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 20/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKFeedImages.h"
#import <MagicalRecord/MagicalRecord.h>
#import "PKImage.h"
#import "FCFileManager.h"
#import "UIImage+Resize.h"
#import "PKConstant.h"

@interface PKFeedImages ()

@property (assign, nonatomic) BOOL isSyncComplete;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSMutableArray *imagesToDownload;
@property (strong, nonatomic) NSMutableArray *imagesToRetry;
@property (strong, nonatomic) NSMutableArray *imagesThatFailed;
@property (assign, nonatomic) BOOL downloadingFailedImages;
@property (strong, nonatomic) NSMutableArray *mainImageFilenames;

@end

@implementation PKFeedImages

#pragma mark - Factories / Constructors

+ (instancetype) createWithUrl:(NSURL*)url andConfig:(PKFeedConfig*)config {
    return [super createWithUrl:url ofType:PKFeedTypeImage withConfig:config];
}

#pragma mark - Public Methods

- (void)downloadWithDelegate:(id<PKFeedDelegate>)delegate {    
    // Update progress
    NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Analysing %@...", @"Used during the sync process to inform the user what process is currently being analysed. E.g. 'Analysing Images'"), [PKFeed pluralNameForFeedType:[self type]]];
    [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
    
    [self setDelegate:delegate];
    
    [FSThread runInBackground:^{
        [self findMissingImages];
    }];
}

+ (NSString *)pathForImageNamed:(NSString *)imageName thumb:(BOOL)thumb {
    if (thumb) {
        return [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/thumbs/%@", imageName]];
    } else {
        return [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/images/%@", imageName]];
    }
}


+ (BOOL)removeImageFilesNamed:(NSString *)imageName {
    if ([imageName length] == 0) {
        return NO;
    }
    
    BOOL deletedImage = NO;
    BOOL deletedThumb = NO;
    
    // Delete the main image:
    NSString *imagePath = [PKFeedImages pathForImageNamed:imageName thumb:NO];
    if ([FCFileManager isFileItemAtPath:imagePath]) {
        deletedImage = [FCFileManager removeItemAtPath:imagePath];
    }
    
    // Delete the thumb image:
    NSString *thumbPath = [PKFeedImages pathForImageNamed:imageName thumb:YES];
    if ([FCFileManager isFileItemAtPath:thumbPath]) {
        deletedThumb = [FCFileManager removeItemAtPath:thumbPath];
    }
    
    return (deletedImage && deletedThumb);
}

#pragma mark - Private Methods

- (void)findMissingImages {
    // Does the images directory exist?  If not, create it
    if (![FCFileManager isDirectoryItemAtPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"/images"]]) {
        [FCFileManager createDirectoriesForPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"images"]];
        NSLog(@"Created images dir: %@", [FCFileManager pathForDocumentsDirectoryWithPath:@"images"]);
    }
    
    if (![FCFileManager isDirectoryItemAtPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"/thumbs"]]) {
        [FCFileManager createDirectoriesForPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"thumbs"]];
        NSLog(@"Created thumbs dir: %@", [FCFileManager pathForDocumentsDirectoryWithPath:@"thumbs"]);
    }
    
    // Get the filenames that are on disk:
    NSManagedObjectContext *context = [NSManagedObjectContext MR_rootSavingContext];
    NSArray *floatingImages = [PKFeedImages imagesNoAssociatedWithProductInDatabaseInContext:context];
    
    if ([floatingImages count] != 0) {
        NSLog(@"[%@] - There are %d images not associated with a product", [self class], (int)[floatingImages count]);
        
        // Delete the floating images:
        [context MR_deleteObjects:floatingImages];
        [context MR_saveOnlySelfAndWait];
    }
    
    NSMutableArray *filenamesOnDisk = [[self filenamesOnDisk] mutableCopy];
    NSMutableArray *imageNames = [[self filenamesInDatabase] mutableCopy];
    [self setMainImageFilenames:[[self mainImageFilenamesInDatabase] mutableCopy]];
    NSLog(@"[%@] - There are %d main images in the database", [self class], (int)[[self mainImageFilenames] count]);
    
    // Remove Already Downloaded files
    NSArray * imageToDownload = [NSArray arrayWithArray:imageNames];
    for (NSString * file in filenamesOnDisk) {
        if ([imageToDownload containsObject:file]) {
            [imageNames removeObject:file];
        }
    }

    
    NSMutableString *body = [NSMutableString string];
    
    [body appendFormat:@"\n\n\nIMAGE REPORT\n\n\n"];
    [body appendFormat:@"\n-----------------------------"];
    [body appendFormat:@"\nFEED NAME: %@ - NUMBER: %@", [[self feedConfig] name], [[self feedConfig] number]];
    [body appendFormat:@"\n-----------------------------"];
    [body appendFormat:@"\n\n\n"];
    [body appendFormat:@"\n-----------------------------"];
    [body appendFormat:@"\nMAIN IMAGES:\n%@", [[self mainImageFilenames] description]];
    [body appendFormat:@"\n-----------------------------"];
    [body appendFormat:@"\n\n\n"];
    [body appendFormat:@"\n-----------------------------"];
    [body appendFormat:@"\nIMAGES ON DISK:\n%@", [filenamesOnDisk description]];
    [body appendFormat:@"\n-----------------------------"];
    [body appendFormat:@"\n\n\n"];
    [body appendFormat:@"\n-----------------------------"];
    [body appendFormat:@"\nIMAGES IN DATABASE:\n%@", [imageNames description]];
    [body appendFormat:@"\n-----------------------------"];
    
    // Don't remove any images if the force download images is enabled:
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"force_image_download"]) {
        // Remove the filenames that are on disk:
        [imageNames removeObjectsInArray:filenamesOnDisk];
        
//        // Disable the force image download flag for the next sync:
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"force_image_download"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // The remaining filenames are the ones that need downloading:
    [self setImagesToDownload:imageNames];
    [self setTotalNumberOfExpectedDownloads:(int)[imageNames count]];
    
    [body appendFormat:@"\n\n\n"];
    [body appendFormat:@"\n-----------------------------"];
    [body appendFormat:@"\nIMAGES TO DOWNLOAD:\n%@", [imageNames description]];
    [body appendFormat:@"\n-----------------------------"];
        
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:body];
    
    if ([[self imagesToDownload] count] != 0) {
        [self downloadImagesBatched];
    } else {
        // Update progress
        [self finishDownloadAndUpdateProgress];
    }
}

- (void) finishDownloadAndUpdateProgress {
    if ([self isSyncComplete]) {
        NSLog(@"[%@] - Sync is already complete", [self class]);
        return;
    }
    
    // Have we finished?
    if ((_numberOfFailedDownloads + _numberOfCompletedDownloads) >= _totalNumberOfExpectedDownloads) {
        [self setIsSyncComplete:YES];
        
        // Update progress
        NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Finishing downloading %@...", @"Used during the sync process to inform the user which process has been downloaded. E.g. 'Finishing downloading Images'"), [PKFeed pluralNameForFeedType:[self type]]];
        [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepFinished];
        
        // Finish process
        [self cleanup];
    } else {
        int remaining = _totalNumberOfExpectedDownloads - (_numberOfCompletedDownloads + _numberOfFailedDownloads);
        NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"%@ remaining %d", @"The name of the item being downloaded (1$) and the number of remaining items ($2). E.g. 'Products remaining 450'"), [PKFeed pluralNameForFeedType:[self type]], remaining];
        [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepDownloading];
    }
}

#pragma mark - Download Methods

- (void) sendRequestForLastModifiedHeadersURL:(NSString *)url {
    /*  send a request for file modification date  */
    NSURLRequest *modReq = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0f];
    [[NSURLConnection alloc] initWithRequest:modReq delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    /*  convert response into an NSHTTPURLResponse,
     call the allHeaderFields property, then get the
     Last-Modified key.
     */
    NSString * last_modified = [NSString stringWithFormat:@"%@", [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Last-Modified"]];
    NSLog(@"Last-Modified: %@", last_modified);
}

- (void)downloadImagesBatched {
    int batchLimit = 100;
    
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    NSMutableArray *requests = [NSMutableArray array];
    
    if (![self imagesToRetry]) {
        [self setImagesToRetry:[NSMutableArray array]];
    }
    
    if (![self imagesThatFailed]) {
        [self setImagesThatFailed:[NSMutableArray array]];
    }
    
    // Determine if we should move onto the images that need retrying:
    
    if ([[self imagesToDownload] count] == 0 && [[self imagesToRetry] count] != 0) {
//        [[self imagesToDownload] addObjectsFromArray:[self imagesToRetry]];
//        [[self imagesToDownload] addObject:[[self imagesToRetry] firstObject]];
        _numberOfFailedDownloads = (int)[[self imagesToRetry] count];
        
        NSMutableArray *missingImages = [NSMutableArray array];
        [[self imagesToRetry] enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL * _Nonnull stop) {
            url = [[url componentsSeparatedByString:@"___ts___"] lastObject];
            if (url) {
                [missingImages addObject:url];
            }
        }];
        
//        NSLog(@"[%@] - Retrying download images: %d\n%@", [self class], (int)[[self imagesToRetry] count], [self imagesToRetry]);
        NSLog(@"[%@] - Missing images: %d\n%@", [self class], (int)[missingImages count], missingImages);
        [[self imagesToRetry] removeAllObjects];
        [self setDownloadingFailedImages:NO];
        [self finishDownloadAndUpdateProgress];
        //NSLog(@"[%@] - Retrying download images: %@", [self class], [self imagesToDownload]);
        return;
    }
//    
//    if ([[self imagesToDownload] count] == 0 && [[self imagesToRetry] count] == 0) {
//        return;
//    }
//    
    __weak __typeof(self)weakSelf = self;
    for (NSString *imageName in [weakSelf imagesToDownload]) {
        //NSString *imageName = [imageData objectForKey:@"name"];
        //int imageOrder = [[imageData objectForKey:@"order"] intValue];
        
        if ([imageName length] == 0) {
            continue;
        }
        
        NSString *urlString = nil;
        
        NSArray *filenameComponents = [imageName componentsSeparatedByString:@"___ts___"];
        NSString *serverImageName = [filenameComponents lastObject];
        
        // Check if it's a failed image:
        if ([weakSelf downloadingFailedImages]) {
            urlString = [NSString stringWithFormat:@"%@/%@", kPuckatorEndpointDefaultImageDomain, serverImageName];
        } else {
            urlString = [NSString stringWithFormat:kPuckatorEndpointTimestampImageDomain, serverImageName, [filenameComponents firstObject]];
        }
                
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 10;
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [op setResponseSerializer:[AFImageResponseSerializer serializer]];
        [op setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            NSLog(@"Expired");
        }];
        
        NSString *path = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/images/%@", imageName]];
        [op setOutputStream:[NSOutputStream outputStreamToFileAtPath:path append:NO]];
        [op setQueuePriority:NSOperationQueuePriorityHigh];
        [op setQualityOfService:NSQualityOfServiceUserInteractive];
        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            
        }];
        
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([operation response].statusCode == 200 && [[[operation response] MIMEType] rangeOfString:@"image/" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                NSError *error = nil;
                if (!error) {
                    NSLog(@"[%@] - Success downloading image from url: %@", [self class], [[[operation response] URL] absoluteString]);
                    ++_numberOfCompletedDownloads;
                    
                    if ([[self mainImageFilenames] containsObject:imageName]) {
                        [weakSelf thumbnailImageNamed:imageName];
                    }
                } else {
                    ++_numberOfFailedDownloads;
                }
            } else {
                NSLog(@"[%@] - Error download file... %@", [self class], [[[operation response] URL] absoluteString]);
                [weakSelf removeImageAtPath:path];
                
                if ([imageName length] != 0 && ![weakSelf downloadingFailedImages]) {
                    if (imageName) {
                        [[weakSelf imagesToRetry] addObject:imageName];
                    }
                } else {
                    if ([[[[operation response] URL] absoluteString] length] != 0) {
                        NSString *urlAbsoluteString = [[[operation response] URL] absoluteString];
                        if (urlAbsoluteString) {
                            [[weakSelf imagesThatFailed] addObject:urlAbsoluteString];
                        }
                    }
                    ++_numberOfFailedDownloads;
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[%@] - Error download file... %@", [self class], error);
            [weakSelf removeImageAtPath:path];
            
            if ([imageName length] != 0 && ![weakSelf downloadingFailedImages]) {
                if (imageName) {
                    [[weakSelf imagesToRetry] addObject:imageName];
                }
            } else {
                if ([[[[operation response] URL] absoluteString] length] != 0) {
                    NSString *urlAbsoluteString = [[[operation response] URL] absoluteString];
                    if (urlAbsoluteString) {
                        [[weakSelf imagesThatFailed] addObject:urlAbsoluteString];
                    }
                }
                ++_numberOfFailedDownloads;
            }
        }];
        
        if (op) {
            [requests addObject:op];
        }
        
        if (imageName) {
            [objectsToRemove addObject:imageName];
        }
        
        if ([requests count] >= batchLimit) {
            break;
        }
    }
    
    // Remove the images:
    //NSLog(@"[%@] Images to download: %d", [self class], (int)[[self imagesToDownload] count]);
    [[self imagesToDownload] removeObjectsInArray:objectsToRemove];
    //NSLog(@"[%@] Images to download: %d", [self class], (int)[[self imagesToDownload] count]);
    
    if ([requests count] != 0) {
        NSArray *batches = [AFURLConnectionOperation batchOfRequestOperations:requests progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            // Update progress
            [weakSelf finishDownloadAndUpdateProgress];
        } completionBlock:^(NSArray *operations) {
            // Finished:
            [weakSelf downloadImagesBatched];
        }];
        
        [[NSOperationQueue mainQueue] setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        [[NSOperationQueue mainQueue] addOperations:batches waitUntilFinished:NO];
    } else {
        if ([[weakSelf imagesThatFailed] count] != 0) {
            NSLog(@"[%@] - Failed Images: %@", [self class], [weakSelf imagesThatFailed]);
        }
        
        if ([[weakSelf imagesToRetry] count] == 0 && [[weakSelf imagesToDownload] count] == 0) {
            // Update progress
            [weakSelf finishDownloadAndUpdateProgress];
        }
    }
}

#pragma mark - Thumbnail Methods

- (void)thumbnailImage:(UIImage *)image named:(NSString *)imageName {
    @autoreleasepool {
        if (!image) {
            NSLog(@"[%@] - Can't thumbnail image as it's missing: %@", [self class], imageName);
            return;
        }
        
        int imageSize = 244 * [[UIScreen mainScreen] scale];
        
        // Save the thumb:
        UIImage *thumb = [image resizedImageToFitInSize:CGSizeMake(imageSize, imageSize) scaleIfSmaller:NO];
        
        if (thumb) {
            NSError *error = nil;
            NSString *thumbPath = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/thumbs/%@", imageName]];
            
            // Remove the old thumb:
            if ([FCFileManager isFileItemAtPath:thumbPath]) {
                [FCFileManager removeItemAtPath:thumbPath error:nil];
            }
            
            // Save the thumbnailed image:
            [FCFileManager writeFileAtPath:thumbPath content:UIImageJPEGRepresentation(thumb, 0.5f) error:&error];
            
            if (error) {
                NSLog(@"[%@] - Error thumbnailing image: %@", [self class], imageName);
                // Remove the old/broken image:
                [FCFileManager removeItemAtPath:thumbPath error:nil];
            }
        }
        
        thumb = nil;
        image = nil;
    }
}

- (void)thumbnailImageNamed:(NSString *)imageName {
    @autoreleasepool {
        NSString *imagePath = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/images/%@", imageName]];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [self thumbnailImage:image named:imageName];
    }
}

#pragma mark - File Storage Clean Up Methods

- (void)removeImageAtPath:(NSString *)imagePath {
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDir]) {
        if (!isDir) {
            if ([FCFileManager removeItemAtPath:imagePath]) {
                NSLog(@"[%@] - File removed at path: %@", [self class], imagePath);
            }
        }
    }
}

- (void)cleanup {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        // Disable the force image download flag for the next sync:
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"force_image_download"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSMutableArray *imagenamesOnDisk = [[self filenamesOnDisk] mutableCopy];
        [imagenamesOnDisk removeObjectsInArray:[self filenamesInDatabase]];
        
        // Find any images that need to be thumbnails:
        NSLog(@"[%@] - Main image count: %d", [self class], (int)[[self mainImageFilenames] count]);
        NSArray *thumbnailFilenames = [self thumbFilenamesOnDisk];
        NSLog(@"[%@] - Thumbnails (%d) on disk:\n%@", [self class], (int)[thumbnailFilenames count], thumbnailFilenames);
        [[self mainImageFilenames] removeObjectsInArray:thumbnailFilenames];
        NSLog(@"[%@] - Main images to thumbnail count: %d", [self class], (int)[[self mainImageFilenames] count]);
        
        // Create the thumbnails:
        [[self mainImageFilenames] enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL * _Nonnull stop) {
            @autoreleasepool {
                [self thumbnailImageNamed:filename];
                
                NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Optimising %@: %d/%d", @"The name of the item being downloaded (1$) and the number of remaining items ($2). E.g. 'Products remaining 450'"), [PKFeed pluralNameForFeedType:[self type]], (idx + 1), (int)[[self mainImageFilenames] count]];
                [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
            }
        }];
        
        // Delete an 'floating' images:
        __block NSString *pathImage = nil;
        __block NSString *pathThumb = nil;
        NSLog(@"[%@] - %d images to remove", [self class], (int)[imagenamesOnDisk count]);
        [imagenamesOnDisk enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                pathImage = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/images/%@", filename]];
                pathThumb = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"/thumbs/%@", filename]];
                
                NSError *error = nil;
                if ([FCFileManager isFileItemAtPath:pathImage]) {
                    [FCFileManager removeItemAtPath:pathImage error:&error];
                }
                
                if (error) {
                    NSLog(@"[%@] - Error: %@", [self class], [error localizedDescription]);
                }
                
                // Reset the error and try to delete the thumb image:
                error = nil;
                if ([FCFileManager isFileItemAtPath:pathThumb]) {
                    [FCFileManager removeItemAtPath:pathThumb error:&error];
                }
                
                if (error) {
                    NSLog(@"[%@] - Error: %@", [self class], [error localizedDescription]);
                }
            }
        }];
        
        // Update the delegate:
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkFeedFinished:)]) {
                [[self delegate] pkFeedFinished:self];
            }
        });
    });
}

#pragma mark - Image Name Utils

- (NSArray *)filenamesInDatabase {
    @autoreleasepool {
        // Query the database for images
        NSFetchRequest *request = [PKImage MR_requestAll];
        [request setResultType:NSDictionaryResultType];
        [request setPropertiesToFetch:@[@"name"]];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [request setReturnsDistinctResults:YES];
        
        // Get a list of files in the database
        NSArray *images = [[NSManagedObjectContext MR_context] executeFetchRequest:request error:nil];
        
        return [images valueForKey:@"name"];
    }
}

- (NSArray *)mainImageFilenamesInDatabase {
    @autoreleasepool {
        // Query the database for images
        NSFetchRequest *request = [PKImage MR_requestAll];
        [request setResultType:NSDictionaryResultType];
        [request setPropertiesToFetch:@[@"name"]];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"order == 0"]];
        [request setReturnsDistinctResults:YES];
        
        // Get a list of files in the database
        NSArray *images = [[NSManagedObjectContext MR_context] executeFetchRequest:request error:nil];
        
        return [images valueForKey:@"name"];
    }
}

+ (NSArray *)imagesNoAssociatedWithProductInDatabaseInContext:(NSManagedObjectContext *)context {
    @autoreleasepool {
        if (!context) {
            context = [NSManagedObjectContext MR_rootSavingContext];
        }
        
        // Query the database for images
//        NSFetchRequest *request = [PKImage MR_requestAll];
//        [PKImage MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"product == nil"]];
//        //[request setResultType:NSManagedObjectResultType];
//        //[request setPropertiesToFetch:@[@"name"]];
//        [request setPredicate:[NSPredicate predicateWithFormat:@"product == nil"]];
//        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
//        [request setReturnsDistinctResults:YES];
//        
//        // Get a list of files in the database
        //        NSArray *images = [[NSManagedObjectContext MR_context] executeFetchRequest:request error:nil];
        //NSArray *allImages = [PKImage MR_findAll];
        
        
//        NSArray *otherImages = [PKImage MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"product == nil"] inContext:context];
//        [otherImages enumerateObjectsUsingBlock:^(PKImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"[%@] - Image relationship: %@", [self class], [image relatedToClass]);
//        }];
        
        NSArray *images = [PKImage MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"product == nil && relatedToClass == 'product'"] inContext:context];
        return images;
    }
}

//+ (NSArray *)imagesNoAssociatedWithProductInDatabase {
//    @autoreleasepool {
//        // Query the database for images
//        NSFetchRequest *request = [PKImage MR_requestAll];
//        [request setResultType:NSManagedObjectResultType];
//        //[request setPropertiesToFetch:@[@"name"]];
//        [request setPredicate:[NSPredicate predicateWithFormat:@"product == nil || p == nil"]];
//        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
//        [request setReturnsDistinctResults:YES];
//        
//        // Get a list of files in the database
//        NSArray *images = [[NSManagedObjectContext MR_context] executeFetchRequest:request error:nil];
//        return images;
//    }
//}

- (NSArray *)filenamesOnDisk {
    @autoreleasepool {
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:[NSURL fileURLWithPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"/images/"]]
                                                      includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey,nil]
                                                                         options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                    errorHandler:nil];
        NSMutableArray *filenames = [NSMutableArray array];
        
        for (NSURL *theURL in dirEnumerator) {
            // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
            NSString *fileName;
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            
            // Retrieve whether a directory. From NSURLIsDirectoryKey, also cached during the enumeration.
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            
            if ([isDirectory boolValue] == NO) {
                if (fileName) {
                    [filenames addObject:fileName];
                }
            }
        }
        
        return filenames;
    }
}

- (NSArray *)thumbFilenamesOnDisk {
    @autoreleasepool {
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:[NSURL fileURLWithPath:[FCFileManager pathForDocumentsDirectoryWithPath:@"/thumbs/"]]
                                                      includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey,nil]
                                                                         options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                    errorHandler:nil];
        NSMutableArray *filenames = [NSMutableArray array];
        
        for (NSURL *theURL in dirEnumerator) {
            // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
            NSString *fileName;
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            
            // Retrieve whether a directory. From NSURLIsDirectoryKey, also cached during the enumeration.
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            
            if([isDirectory boolValue] == NO) {
                if (fileName) {
                    [filenames addObject:fileName];
                }
            }
        }
        
        return filenames;
    }
}

#pragma mark - Memory Management

- (void)dealloc {
    NSLog(@"[%@] - Dealloc", [self class]);
}

#pragma mark -

@end
