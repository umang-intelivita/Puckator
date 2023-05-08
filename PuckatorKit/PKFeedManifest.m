//
//  PKFeedManifest.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 08/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeedManifest.h"
#import <RaptureXML/RXMLElement.h>

@implementation PKFeedManifest

#pragma mark - Factories / Constructors

//+ (instancetype) createWithUrl:(NSURL*)url f {
//    return [super createWithUrl:url ofType:PKFeedTypeManifest forFeedConfig:feedConfig];
//}

#pragma mark - Methods

- (void) download:(PKFeedCompletionBlock)completionBlock {
    
    // Download file from the server
    [super download:^(BOOL success, NSURL *filePath, NSError *error) {
        
        if(success) {
            
            // Save a reference to the completion block
            [self setCompletionBlock:completionBlock];
            
            // Parse the manifest file we just downloaded...
            // we have already validated this is an XML file
            [self parseManifestAtPath:filePath];
            
        } else {
            completionBlock(NO, nil, error);
        }
        
    }];
    
}

#pragma mark - Private Methods

- (void) parseManifestAtPath:(NSURL*)url {
    
    // Load the data into memory
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // Init XML Parser
    RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];

    // Create array of feeds
    [self setFeeds:[NSMutableArray array]];
    [self setConfiguration:[NSMutableDictionary dictionary]];
    
    // Parse the response
    [rootXML iterate:@"result.*" usingBlock:^(RXMLElement *e) {
//        if([e.tag isEqualToString:@"ProductFeedUrl"]) {
//            if([self elementContainsUrl:e]) {
//                [[self feeds] addObject:[PKFeed createWithUrl:[NSURL URLWithString:[e attribute:@"val"]] ofType:PKFeedTypeProduct]];
//            }
//        }
//        else if([e.tag isEqualToString:@"CategoryFeedUrl"]) {
//            if([self elementContainsUrl:e]) {
//                [[self feeds] addObject:[PKFeed createWithUrl:[NSURL URLWithString:[e attribute:@"val"]] ofType:PKFeedTypeCategory]];
//            }
//        }
//        else if([e.tag isEqualToString:@"OrdersFeedUrl"]) {
//            if([self elementContainsUrl:e]) {
//                [[self feeds] addObject:[PKFeed createWithUrl:[NSURL URLWithString:[e attribute:@"val"]] ofType:PKFeedTypeOrder]];
//            }
//        }
//        else if([e.tag isEqualToString:@"InvoiceFeedUrl"]) {
//            if([self elementContainsUrl:e]) {
//                [[self feeds] addObject:[PKFeed createWithUrl:[NSURL URLWithString:[e attribute:@"val"]] ofType:PKFeedTypeInvoice]];
//            }
//        }
//        else if([e.tag isEqualToString:@"CountryCodeFeedUrl"]) {
//            if([self elementContainsUrl:e]) {
//                [[self feeds] addObject:[PKFeed createWithUrl:[NSURL URLWithString:[e attribute:@"val"]] ofType:PKFeedTypeCountry]];
//            }
//        }
//        else if([e.tag isEqualToString:@"CustomerFeedUrl"]) {
//            if([self elementContainsUrl:e]) {
//                [[self feeds] addObject:[PKFeed createWithUrl:[NSURL URLWithString:[e attribute:@"val"]] ofType:PKFeedTypeCustomer]];
//            }
//        }
//        else {
//            [self configuration][e.tag] = [e attribute:@"val"];
//        }
    }];
    
    NSLog(@"Found Feeds %@", [self feeds]);
    NSLog(@"Found Config: %@", [self configuration]);
    
    // Call completion handler
    [self completionBlock](YES, url, nil);
    
}

- (BOOL) elementContainsUrl:(RXMLElement*)e {
    if([[e attribute:@"val"] rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location != NSNotFound ||
       [[e attribute:@"val"] rangeOfString:@"https://" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}
@end
