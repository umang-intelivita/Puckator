//
//  PKNetworking.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKNetworking.h"
#import <AFNetworking/AFNetworking.h>
#import <FCFileManager/FCFileManager.h>
#import <NSString-Hashes/NSString+Hashes.h>
#import <SSZipArchive/SSZipArchive.h>
#import <RaptureXML/RXMLElement.h>
#import "DDFileReader.h"
#import "NSError+PKError.h"
#import "PKConstant.h"
#import "PKTranslate.h"
#import "PKInstallation.h"
#import "FSThread.h"

@interface PKNetworking()
@property (nonatomic, copy, readwrite) PKNetworkingCompletionBlock completionBlock;
@property (nonatomic, copy, readwrite) PKNetworkingProgressBlock progressBlock;
@property (nonatomic, strong) NSDictionary *options;
@end

@implementation PKNetworking

static void *ProgressObserverContext = &ProgressObserverContext;

- (void) downloadFileAtUrl:(NSURL*)url
               withOptions:(NSDictionary*)options
       withCompletionBlock:(PKNetworkingCompletionBlock)completionBlock {
    [self downloadFileAtUrl:url withOptions:options withProgressBlock:nil withCompletionBlock:completionBlock];
}

- (void) downloadFileAtUrl:(NSURL*)url
               withOptions:(NSDictionary*)options
         withProgressBlock:(PKNetworkingProgressBlock)progressBlock
       withCompletionBlock:(PKNetworkingCompletionBlock)completionBlock {
    // Save a reference to completion block
    [self setCompletionBlock:completionBlock];
    [self setOptions:options];
    [self setProgressBlock:progressBlock];
    
    // Get an instance to the AFNetworking Session Manager
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Create a request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"URL: %@", [url absoluteString]);
    
    NSProgress *progress;
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // Calculate MD5 Hash of this file
        NSString *hash = [[url absoluteString] md5];
        NSString *ext = [[url pathExtension] lowercaseString];
        if ([[url absoluteString] rangeOfString:kPuckatorEndpointData options:NSCaseInsensitiveSearch].location != NSNotFound) {
            ext = @"zip";
        }
        
        if ([[[self options] objectForKey:@"PKFeedFormat"] intValue] == PKFeedFormatZip) {
            ext = @"zip";
        }
        
        // Compute target path
        NSString *path = [FCFileManager pathForTemporaryDirectoryWithPath:[NSString stringWithFormat:@"/%@.%@", hash, ext]];
        
        // Determine if this file already exists in the temp files, if so, delete it first.
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[FCFileManager pathForTemporaryDirectory]]) {
            [FCFileManager createDirectoriesForPath:[FCFileManager pathForTemporaryDirectory]];
        }
        
        NSLog(@"The download path will be: %@", path);
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"downloaded files: %@", response);
        if ([httpResponse statusCode] == 204) {
            [self completionBlock](NO, nil, nil, nil);
        } else {
            if (!error) {
                // Determine the type of file
                if ([[[filePath pathExtension] lowercaseString] rangeOfString:@"zip" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [FSThread runInBackground:^{
                        NSString *filename = [[[[response URL] absoluteString] pathComponents] lastObject];
                        filename = [[filename componentsSeparatedByString:@"?"] firstObject];
                        
                        [self extractArchiveAtPath:filePath forUrl:url filename:filename];
                    }];
                } else {
                    [FSThread runInBackground:^{
                        [self validateXMLPayload:[filePath path]];
                    }];
                }
            } else {
                NSLog(@"Error downloading file, error: %@", error);
                [self completionBlock](NO, nil, nil, [NSError errorWithDescription:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Error downloading file", nil), [error localizedDescription]]
                                                                 andErrorCode:PKErrorFeedDownloadError]);
            }
        }
    }];
    
    
    // TODO: Fix crash:
//    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
    [task resume];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"fractionCompleted"]) {
//        if ([self progressBlock]) {
//            NSProgress *progress = (NSProgress *)object;
//            [self progressBlock](progress.fractionCompleted);
//        }
//    } else {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}

- (void) extractArchiveAtPath:(NSURL*)filePath forUrl:(NSURL*)url filename:(NSString *)filename {
    
    // Create a directory for unarchiving the zip file
    NSString *tempDirectory = [FCFileManager pathForTemporaryDirectoryWithPath:[NSString stringWithFormat:@"/%@_tmp/", [[url absoluteString] md5]]];
    
    NSError *error = nil;
    [FCFileManager removeItemAtPath:tempDirectory error:&error];
    
    if (error) {
        NSLog(@"[%@] - Error: %@", [self class], [error localizedDescription]);
    }
    
    NSLog(@"Zip file: %@", [filePath path]);
    NSLog(@"Will extract to %@", tempDirectory);
    NSLog(@"Real filename is: %@", filename);

    // Unzip files to tmp directory
    if([SSZipArchive unzipFileAtPath:[filePath path] toDestination:tempDirectory]) {
        NSLog(@"Unzip OK...");
        
        // Analyse the contents of the unzip operation
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempDirectory error:nil];
        if([contents count] >= 1) {
            
            // Scan the extracted files for the first .xml file, it is not safe to just assume the first file is valid because it could be "__MACOSX", etc.
            NSString *file = nil;
            for(NSString *f in contents) {
                if([f rangeOfString:@".xml" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                   [f rangeOfString:@".sqlite" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    file = f;
                    break;
                }
            }
            
            // Only continue if a file with the .xml extension was found
            if(file) {
                NSLog(@"Found file: %@", file);
                [self completionBlock](YES, [NSURL fileURLWithPath:tempDirectory], filename, nil);
                //[self validateXMLPayload:[NSString stringWithFormat:@"%@/%@", tempDirectory, file]];
            } else {
                [self completionBlock](NO, nil, nil, [NSError errorWithDescription:NSLocalizedString(@"The zip archive was extracted but did not contain a .xml file!", nil)
                                                                 andErrorCode:PKErrorPayloadDoesNotContainXML]);
            }
        } else {
            NSLog(@"Error! The unzip operation yields zero files.  Either the zip is invalid or something went wrong.");
            [self completionBlock](NO, nil, nil, [NSError errorWithDescription:NSLocalizedString(@"No files were found in the zip archive", nil)
                                                             andErrorCode:PKErrorZeroFilesInZipArchive]);
        }
        
    } else {
        NSLog(@"Error unzipping file!");
        [self completionBlock](NO, nil, nil, [NSError errorWithDescription:NSLocalizedString(@"Error extracting zip archive", nil)
                                                         andErrorCode:PKErrorExtractingZipArchive]);
    }
}

- (void) validateXMLPayload:(NSString*)filePath {
    NSLog(@"Will validate: %@", filePath);
    
    // Are we to skip validation?
    BOOL skipValidation = NO;
    if([[self options] objectForKey:kPkSkipValidateXmlPayload]) {
        skipValidation = [[[self options] objectForKey:kPkSkipValidateXmlPayload] boolValue];
    }
    
    skipValidation = YES;   // #HACK TURN THIS OFF
    
    if (skipValidation) {
        NSLog(@"Skipping validation of... %@", filePath);
        [self completionBlock](YES, [NSURL fileURLWithPath:filePath], nil, nil);
        return;
    }
    
    // Look through the file line-by-line (as apposed to loading a potentially huge XML document into memory, which could cause a crash!)
    // If the first line contains an XML declaration, we will deem this file to be valid (even though the XML document itself could have issues)
    // - as long as the file is XML, that's all we care about at this stage.
    DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:filePath];
    NSString * line = nil;
    
    int i = 0;
    BOOL containsXML = NO;
    while ((line = [reader readLine])) {
        //NSLog(@"read line: %@", line);
        if(i == 0) {
            if([line rangeOfString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                containsXML = YES;
                break;
            }
        }
        i++;
    }
    
    if(containsXML) {
        NSLog(@"Great, the file appears to contain an XML document!");
        [self completionBlock](YES, [NSURL fileURLWithPath:filePath], nil, nil);
    } else {
        NSLog(@"Oh no, the file doesn't seem to be an XML doc!");
        [self completionBlock](NO, nil, nil, [NSError errorWithDescription:NSLocalizedString(@"Payload does not contain an XML document", nil)
                                                         andErrorCode:PKErrorPayloadDoesNotContainXML]);
    }
}

#pragma mark - Utilities

+ (void)checkConnectivityWithCompletionBlock:(PKNetworkingGenericCompletionBlock)completionBlock {
    // Define the content type as JSON
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    [manager GET:kPuckatorEndpointStatus parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Server returned a response
        NSLog(@"response connectivity... %@", responseObject);
        completionBlock(YES, responseObject, nil);
       

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO, nil, error);
    }];
}

+ (void)fetchSyncManifest:(PKNetworkingGenericCompletionBlock)completionBlock {
    // Ensure we have a JWT token before fetching the sync manfiest
    if ([PKInstallation currentInstallationJwt]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        
        // Create the parameters dictionary:
        NSMutableDictionary *parameters = [@{@"jwt_token": [PKInstallation currentInstallationJwt]} mutableCopy];
        [parameters setObject:[PKInstallation deviceModel] forKey:@"device_model"];
        [parameters setObject:[PKInstallation deviceOsVersion] forKey:@"device_os_version"];
        [parameters setObject:[PKInstallation appVersion] forKey:@"app_version"];
        [parameters setObject:[PKInstallation deviceName] forKey:@"device_name"];
        
        [manager GET:kPuckatorEndpointSyncManifest parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Server returned a response
            NSLog(@"fetchSyncManifest... %@", responseObject);
            completionBlock(YES, responseObject, nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completionBlock(NO, nil, error);
        }];
    } else {
        NSString *errorMessage = NSLocalizedString(@"Your client has not been issued a JWT token yet!", @"Used to inform the user they haven't been authenicated yet. JWT stand for JSON Web Token; and does not require translation.");
        NSError *error = [NSError errorWithDescription:errorMessage andErrorCode:kPuckatorErrorCodeMissingJwtToken];
        completionBlock(NO, nil, error);
    }
}

- (void)dealloc {
    NSLog(@"[%@] - Dealloc", [self class]);
}

@end
