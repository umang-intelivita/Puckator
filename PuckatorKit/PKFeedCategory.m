//
//  PKFeedCategory.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 19/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKFeedCategory.h"
#import "PKCategory+Operations.h"
#import "NSManagedObject+Operations.h"
#import "PKImage+Operations.h"
#import "PKConstant.h"

@implementation PKFeedCategory

#pragma mark - Factories / Constructors

+ (instancetype) createWithUrl:(NSURL*)url andConfig:(PKFeedConfig*)config {
    return [super createWithUrl:url ofType:PKFeedTypeCategory withConfig:config];
}

#pragma mark - Public Methods

- (void)downloadWithDelegate:(id<PKFeedDelegate>)delegate {
    [self setDelegate:delegate];
    [super downloadWithDelegate:self];
}

- (void) download:(PKFeedCompletionBlock)completionBlock {    
    __weak PKFeedCategory *weakSelf = self;
    
    // Download file from the server
    [super download:^(BOOL success, NSURL *filePath, NSError *error) {
        if (success) {
            // Save a reference to the completion block
            [weakSelf setCompletionBlock:completionBlock];

            NSLog(@"Downloaded categories! %@", filePath);
            
            // Parse each file
            BOOL isDir = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:[filePath path] isDirectory:&isDir];
            
            // Update progress
            NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Extracting %@...", nil), [PKFeed pluralNameForFeedType:[weakSelf type]]];
            [[weakSelf feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
            
            // Peform these parsing operations in the background, this prevents the main thread being blocked
            [FSThread runInBackground:^{
                if (isDir) {
                    // Collection of XML files detected, process them all:
                    [weakSelf parseFilesAtDirectory:filePath];
                }
            }];
        } else {
            if (completionBlock) {
                completionBlock(NO, nil, error);
            }
        }
    }];
}

#pragma mark - Private Methods

- (void)parseFilesAtDirectory:(NSURL*)directoryUrl {
    // Update progress
    NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Importing %@...", nil), [PKFeed pluralNameForFeedType:[self type]]];
    [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
    
    // Get a list of files within the directory
    NSError *error = nil;
    NSArray *filesInDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[directoryUrl path] error:&error];
    
    // Scan each file and ensure it has the .xml extension
    NSMutableArray *files = [NSMutableArray array];
    for (NSString *filename in filesInDirectory) {
        if([filename rangeOfString:@".xml" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [files addObject:filename];
        }
    }
    
    // Next, sort the list of files alphabetically
    [files sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
    
    // Next, load each file
    NSLog(@"Files are %@", files);
    [self setFilesToParse:[NSMutableArray array]];
    for (NSString *filename in files) {
        // Forge a URL to the file
        NSURL *chunkUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [directoryUrl path], filename]];
        [[self filesToParse] addObject:chunkUrl];
    }
    
    // Keep count of the total
    [self setTotalFilesToParse:(int)[[self filesToParse] count]];
    
    // Start the parsing process
    [self parseNextFile];
}

- (void) parseNextFile {
    NSURL *nextFileUrl = [[self filesToParse] firstObject];
    if(nextFileUrl) {
        [FSThread runInBackground:^{
            [self parseFileAtPath:nextFileUrl];
        }];
    } else {
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkFeedFinished:)]) {
            [[self delegate] pkFeedFinished:self];
        }
    }
}

- (void) parseFileAtPath:(NSURL*)url {
    NSLog(@"Loading categories into memory... %@", [url absoluteString]);
    
    // Load the data into memory
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // Init XML Parser
    RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
    
    // Parse the response
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        
        NSMutableArray *products = [NSMutableArray arrayWithArray:[rootXML children:@"CATEGORY"]];
        [rootXML iterateElements:products usingBlock:^(RXMLElement *element) {
            
            // Get the ID of the node from the XML element
            NSString *uuid = [[element child:@"ID"] text];

            // Find or create a category based on the category ID
            PKCategory *category = [PKCategory findOrCreateWithCategoryId:uuid
                                                            forFeedConfig:[self feedConfig]
                                                                inContext:localContext];
            
            // Normalize the category name + remove any diacritics
            NSMutableString *cleanTitle = [NSMutableString stringWithString:[[element child:@"NAME"] text]];
            
            CFMutableStringRef cleanTitleRef = (__bridge CFMutableStringRef)cleanTitle;
            CFStringTransform(cleanTitleRef, nil, kCFStringTransformToLatin, NO);
            CFStringTransform(cleanTitleRef, nil, kCFStringTransformStripCombiningMarks, NO);
            CFStringTrimWhitespace(cleanTitleRef);
            CFStringLowercase(cleanTitleRef,(__bridge CFLocaleRef)[NSLocale localeWithLocaleIdentifier:@"en-US"]);
            
            // Set clean title
            [category setTitleClean:cleanTitle];
            
            // Set the values!
            [category ifStringExistsInElement:element forKey:@"NAME" thenSetValue:@selector(setTitle:)];
            [category ifStringExistsInElement:element forKey:@"SORT_ORDER" thenSetValue:@selector(setSortOrder:) andSaveAsType:PKVariableTypeNSNumber];
            [category ifStringExistsInElement:element forKey:@"PARENT" thenSetValue:@selector(setParent:) andSaveAsType:PKVariableTypeNSNumber];
            [category ifStringExistsInElement:element forKey:@"ACTIVE" thenSetValue:@selector(setActive:) andSaveAsType:PKVariableTypeNSNumberBooleanFromCharacter];
            
            // Create an image for the category, if one exists
            if ([element child:@"IMAGE"]) {
                NSString *imageName = [[[element child:@"IMAGE"] child:@"FILE"] text];
                
                // Create an image
                PKImage *image = [PKImage findOrCreateWithImageId:imageName
                                                         atDomain:kPuckatorEndpointDefaultImageDomain
                                             forRelatedEntityUuid:uuid
                                        forRelatedEntityClassType:@"Category"
                                                    forFeedConfig:[self feedConfig]
                                                        inContext:localContext];
                
                if (image) {
                    [category setMainImage:image];
                } else {
                    [category setMainImage:nil];
                }
            } else {
                [category setMainImage:nil];
            }
        }];
    } completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self filesToParse] removeObject:url];
            
            // Calculate percent of import process
            int pagesParsed = (int)([self totalFilesToParse] - [[self filesToParse] count]);
            float percentComplete = (float)((float)pagesParsed / (float)[self totalFilesToParse]) * 100.0f;
            
            // Update progress
            if ((int)percentComplete == 0) {
                NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Preparing to save %@ to database", nil), [PKFeed pluralNameForFeedType:[self type]]];
                [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
            } else {
                NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Saving %@ to database: %d%%", nil), [PKFeed pluralNameForFeedType:[self type]], (int)percentComplete];
                [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
            }
            
            NSLog(@"New files to parse: %@", [self filesToParse]);
            
            // Parse the next file in the list...
            dispatch_async(dispatch_get_main_queue(), ^{
                [self parseNextFile];
            });
        });
    }];
}

#pragma mark - PKFeedDelegate Methods

- (void)pkFeedDownload:(PKFeed *)feed success:(BOOL)success filePath:(NSURL *)filePath error:(NSError *)error {
    if (success) {
        NSLog(@"Downloaded categories! %@", filePath);
        
        // Parse each file
        BOOL isDir = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:[filePath path] isDirectory:&isDir];
        
        // Update progress
        NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Extracting %@...", nil), [PKFeed pluralNameForFeedType:[self type]]];
        [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
        
        // Peform these parsing operations in the background, this prevents the main thread being blocked
        if (isDir) {
            __weak PKFeedCategory *weakSelf = self;
            [FSThread runInBackground:^{
                // Collection of XML files detected, process them all:
                [weakSelf parseFilesAtDirectory:filePath];
            }];
        }
    } else {
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkFeedFinished:)]) {
            [[self delegate] pkFeedFinished:self];
        }
    }
}

#pragma mark -

@end