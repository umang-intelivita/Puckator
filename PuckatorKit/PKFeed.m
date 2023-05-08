//
//  PKFeed.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeed.h"
#import "PKNetworking.h"
#import "NSError+PKError.h"
#import "PKFeedManifest.h"
#import "PKFeedSQL.h"
#import "PKConstant.h"
#import "PKTranslate.h"
#import "PKFeedImages.h"

@interface PKFeed()
@end

@implementation PKFeed

+ (id) createWithUrl:(NSURL*)url ofType:(PKFeedType)type withConfig:(PKFeedConfig*)config {
    
    if(!url || type == PKFeedTypeUnknown) {
        assert("Invalid PKFeed, contained no URL or Feed Type!");
    }
    
    // Create instance of a feed and associate url and type
    switch(type) {
        case PKFeedTypeManifest: {
            PKFeedManifest *feed = [[PKFeedManifest alloc] init];
            [feed setUrl:url];
            [feed setType:type];
            [feed setNumber:config.number];
            [feed setFeedConfig:config];
            return feed;
        }
        case PKFeedTypeSQLAccounts: {
            PKFeedSQL *feed = [[PKFeedSQL alloc] init];
            [feed setUrl:url];
            [feed setType:PKFeedTypeSQLAccounts];
            [feed setNumber:config.number];
            [feed setFeedConfig:config];
            return feed;
        }
        case PKFeedTypeSQLData: {
            PKFeedSQL *feed = [[PKFeedSQL alloc] init];
            [feed setUrl:url];
            [feed setType:PKFeedTypeSQLData];
            [feed setNumber:config.number];
            [feed setFeedConfig:config];
            return feed;
        }
        case PKFeedTypeImage: {
            PKFeedImages *feed = [[PKFeedImages alloc] init];
            [feed setUrl:[NSURL URLWithString:@"images://"]];
            [feed setType:PKFeedTypeImage];
            [feed setFeedConfig:config];
            return feed;
        }
        default: {
            PKFeed *feed = [[PKFeed alloc] init];
            [feed setUrl:url];
            [feed setType:type];
            [feed setNumber:config.number];
            [feed setFeedConfig:config];
            return feed;
        }
    }
}

- (void) download:(PKFeedCompletionBlock)completionBlock {
    NSLog(@"[%@] - Starting download of data from the server", [self class]);
    
    // Save a reference to the completion block
    [self setCompletionBlock:completionBlock];
    
    // Ensure a URL and type are available for this feed, if it's a manifest file, do not validate
    if ([self url] && ([self type] != PKFeedTypeUnknown || [self type] == PKFeedTypeManifest)) {
        PKFeedFormat feedFormat = [self feedFormatForUrl:[self url]];
        if (feedFormat != PKFeedFormatUnknown) {
            // Proceed to download the file...
            [self downloadPayloadForFormat:feedFormat];
        } else {
            NSLog(@"Error downloading feed, the Feed Format is unknown.  The Feed Format must be either a .zip/.xml file.");
            [self completionBlock](NO, nil, [NSError errorWithDescription:@"Error downloading feed, the feed format is not known, it must be either a .zip or .xml file."
                                                             andErrorCode:PKErrorFeedFormatIsNotRecognized]);
        }
    } else {
        NSLog(@"Error download feed, either the URL or Feed Type is missing.");
        [self completionBlock](NO, nil, [NSError errorWithDescription:@"Error downloading feed, either the URL or Feed Type is missing."
                                                         andErrorCode:PKErrorFeedUrlOrFeedTypeNotFound]);
    }
}

- (void)downloadWithDelegate:(id<PKFeedDelegate>)delegate {
    NSLog(@"[%@] - Starting download with delegate of data from the server", [self class]);
    [self setDownloadDelegate:delegate];
    NSLog(@"[%@] - Url: %@", [self class], [[self url] absoluteString]);
    
    if ([self url] && ([self type] != PKFeedTypeUnknown || [self type] == PKFeedTypeManifest)) {
        PKFeedFormat feedFormat = [self feedFormatForUrl:[self url]];
        if (feedFormat != PKFeedFormatUnknown) {
            // Proceed to download the file...
            [self downloadPayloadWithDelegateForFormat:feedFormat];
        } else {
            if ([self downloadDelegate] && [[self downloadDelegate] respondsToSelector:@selector(pkFeedDownload:success:filePath:filename:error:)]) {
                NSError *error = [NSError errorWithDescription:@"Error downloading feed, the feed format is not known, it must be either a .zip or .xml file."
                                                  andErrorCode:PKErrorFeedFormatIsNotRecognized];
                [[self downloadDelegate] pkFeedDownload:self success:NO filePath:nil filename:nil error:error];
            }
        }
    } else {
        if ([self downloadDelegate] && [[self downloadDelegate] respondsToSelector:@selector(pkFeedDownload:success:filePath:filename:error:)]) {
            NSError *error = [NSError errorWithDescription:@"Error downloading feed, either the URL or Feed Type is missing."
                                              andErrorCode:PKErrorFeedUrlOrFeedTypeNotFound];
            [[self downloadDelegate] pkFeedDownload:self success:NO filePath:nil filename:nil error:error];
        }
    }
}

- (void)downloadPayloadWithDelegateForFormat:(PKFeedFormat)format {
    // Inject some options if required
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if ([self type] == PKFeedTypeManifest) {
        [options setObject:@(YES) forKey:kPkSkipValidateXmlPayload];
    }
    
    [options setObject:@(format) forKey:@"PKFeedFormat"];

    // Download the file
    PKNetworking *networking = [[PKNetworking alloc] init];
    NSLog(@"URL: %@", [[self url] absoluteString]);
    
    __weak PKFeed *weakSelf = self;
    [networking downloadFileAtUrl:[self url] withOptions:options withProgressBlock:^(float progess) {
        if ([[weakSelf downloadDelegate] respondsToSelector:@selector(pkFeedProgress:progress:)]) {
            [[weakSelf downloadDelegate] pkFeedProgress:weakSelf progress:progess];
        }
    } withCompletionBlock:^(BOOL success, NSURL *filePath, NSString *filename, NSError *error) {
        if ([weakSelf downloadDelegate] && [[weakSelf downloadDelegate] respondsToSelector:@selector(pkFeedDownload:success:filePath:filename:error:)]) {
            [[weakSelf downloadDelegate] pkFeedDownload:weakSelf success:success filePath:filePath filename:filename error:error];
        }
    }];
}

- (void) downloadPayloadForFormat:(PKFeedFormat)format {
    // Inject some options if required
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if ([self type] == PKFeedTypeManifest) {
        [options setObject:@(YES) forKey:kPkSkipValidateXmlPayload];
    }
    
    [options setObject:@(format) forKey:@"PKFeedFormat"];
    
    // Download the file
    PKNetworking *networking = [[PKNetworking alloc] init];
    NSLog(@"URL: %@", [[self url] absoluteString]);
    
    __weak PKFeed *weakSelf = self;
    
    [networking downloadFileAtUrl:[self url] withOptions:options withProgressBlock:^(float progess) {
        if ([[weakSelf downloadDelegate] respondsToSelector:@selector(pkFeedProgress:progress:)]) {
            [[weakSelf downloadDelegate] pkFeedProgress:weakSelf progress:progess];
        }
    } withCompletionBlock:^(BOOL success, NSURL *filePath, NSString *filename, NSError *error) {
        if (success) {
            [weakSelf completionBlock](YES, filePath, nil);
        } else {
            [weakSelf completionBlock](NO, nil, error);
        }
    }];
}

#pragma mark - Utilities

/**
 *  Returns a PKFeedFormat type depending on the extension in a URL
 *
 *  @param url The URL to test
 *
 *  @return Either an XML or Zip file format, or unknown if the test failed
 */
- (PKFeedFormat) feedFormatForUrl:(NSURL*)url {
    // Feed manifest is always XML
    if ([self type] == PKFeedTypeManifest) {
        return PKFeedFormatXML;
    }
    
    if ([[url absoluteString] containsString:@"getAccountsSqlPayload"]) {
        return PKFeedFormatZip;
    } else if([[url pathExtension] rangeOfString:@"zip" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PKFeedFormatZip;
    } else if([[url pathExtension] rangeOfString:@"xml" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PKFeedFormatXML;
    } else if([[url absoluteString] rangeOfString:kPuckatorEndpointData options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PKFeedFormatZip;
    } else {
        return PKFeedFormatUnknown;
    }
}

+ (NSString*) nameForFeedType:(PKFeedType)type {
    switch (type) {
        case PKFeedTypeCustomer:
            return NSLocalizedString(@"Customer", nil);
        case PKFeedTypeOrder:
            return NSLocalizedString(@"Order", nil);
        case PKFeedTypeInvoice:
            return NSLocalizedString(@"Invoice", nil);
        case PKFeedTypeCountry:
            return NSLocalizedString(@"Country", nil);
        case PKFeedTypeManifest:
            return NSLocalizedString(@"Manifest", nil);
        case PKFeedTypeSQLAccounts:
            return NSLocalizedString(@"Accounts", nil);
        case PKFeedTypeSQLData:
            return NSLocalizedString(@"Data", nil);
        case PKFeedTypeImage:
            return NSLocalizedString(@"Image", nil);
        case PKFeedTypeUnknown: {
        default:
            return NSLocalizedString(@"Unknown", nil);
        }
    }
}

+ (NSString*) pluralNameForFeedType:(PKFeedType)type {
    switch (type) {
        case PKFeedTypeCustomer:
            return NSLocalizedString(@"Customers", nil);
        case PKFeedTypeOrder:
            return NSLocalizedString(@"Orders", nil);
        case PKFeedTypeInvoice:
            return NSLocalizedString(@"Invoices", nil);
        case PKFeedTypeCountry:
            return NSLocalizedString(@"Countries", nil);
        case PKFeedTypeManifest:
            return NSLocalizedString(@"Manifest", nil);
        case PKFeedTypeSQLAccounts:
            return NSLocalizedString(@"Accounts", nil);
        case PKFeedTypeSQLData:
            return NSLocalizedString(@"Data", nil);
        case PKFeedTypeImage:
            return NSLocalizedString(@"Images", nil);
        case PKFeedTypeUnknown: {
        default:
            return NSLocalizedString(@"Unknown", nil);
        }
    }
}

+ (NSURL *)tokenizeUrl:(NSString *)url {
    if ([url containsString:@"?"]) {
        url =[NSString stringWithFormat:@"%@&jwt_token=%@", url, [PKInstallation currentInstallationJwt]];
    } else {
        url =[NSString stringWithFormat:@"%@?jwt_token=%@", url, [PKInstallation currentInstallationJwt]];
    }
    
    return [NSURL URLWithString:url];
}

+ (NSURL*) urlFromToken:(NSString*)token {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?jwt_token=%@", kPuckatorEndpointData, token]];
}

// Returns a thread name used for multi-threading purposes
- (NSString*) threadName {
    return [NSString stringWithFormat:@"%@_%@", [PKFeed nameForFeedType:[self type]], [[self feedConfig] uuid]];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ (type: %@, url: %@)", NSStringFromClass([self class]), [PKFeed nameForFeedType:[self type]], [[self url] absoluteString]];
}

- (void)dealloc {
    NSLog(@"[%@] - Dealloc", [self class]);
}

@end
