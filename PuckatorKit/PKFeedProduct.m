//
//  PKFeedProduct.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 10/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKFeedProduct.h"
#import <RaptureXML/RXMLElement.h>
#import "FSThread.h"
#import "PKProduct.h"
#import "PKImage.h"
#import "MagicalRecord.h"
#import "PKProduct+Operations.h"
#import "PKImage+Operations.h"
#import "PKTranslate.h"
#import "PKConstant.h"
#import "PKCategory+Operations.h"
#import "PKProductSaleHistory+Operations.h"
#import "PKProductPrice+Operations.h"
#import "RXMLElement+Utilities.h"

@interface PKFeedProduct()
@property (nonatomic, strong) NSMutableArray *existingProducts;
@property (nonatomic, strong) NSMutableArray *existingCategories;
@property (nonatomic, strong) NSManagedObjectContext *localContext;

@property (nonatomic, assign) float rateGbp; // Test var
@end

@implementation PKFeedProduct

#pragma mark - Factories / Constructors

+ (instancetype) createWithUrl:(NSURL*)url andConfig:(PKFeedConfig*)config {
    return [super createWithUrl:url ofType:PKFeedTypeProduct withConfig:config];
}

#pragma mark - Public Methods

- (void)downloadWithDelegate:(id<PKFeedDelegate>)delegate {
    NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Downloading %@...", nil), [PKFeed pluralNameForFeedType:[self type]]];
    [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
    
    [self setDelegate:delegate];
    [super downloadWithDelegate:self];
}

- (void)pkFeedDownload:(PKFeed *)feed success:(BOOL)success filePath:(NSURL *)filePath error:(NSError *)error {
    if (success) {
        // Parse each file
        BOOL isDir = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:[filePath path] isDirectory:&isDir];
        
        // Update progress
        NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Extracting %@...", nil), [PKFeed pluralNameForFeedType:[self type]]];
        [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
        
        // Delete all the images and product prices:
        NSManagedObjectContext *deleteContext = [NSManagedObjectContext MR_contextWithStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
        [PKImage deleteProductImagesForFeedConfig:[self feedConfig] inContext:deleteContext];
        [PKProductPrice deleteProductPricesforFeedConfig:[self feedConfig] inContext:deleteContext];
        [deleteContext MR_saveOnlySelfAndWait];
        
        // Get the existing products:
        [self setLocalContext:[NSManagedObjectContext MR_contextWithStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]]];
        [[self localContext] setUndoManager:nil];
        [self setExistingProducts:[[PKProduct allProductsForFeedConfig:[self feedConfig] inContext:[self localContext]] mutableCopy]];
        
        // Get the existing categories:
        NSPredicate *predicateCategory = [NSPredicate predicateWithFormat:@"feedNumber == %@", [[self feedConfig] number]];
        [self setExistingCategories:[[PKCategory MR_findAllSortedBy:@"sortOrder"
                                                          ascending:YES
                                                      withPredicate:predicateCategory
                                                          inContext:[self localContext]] mutableCopy]];
        
        if (isDir) {
            // Collection of XML files detected, process them all
            __weak PKFeedProduct *weakSelf = self;
            [FSThread runInBackground:^{
                [weakSelf parseFilesAtDirectory:filePath];
            }];
        } else {
            // The target is a file, parse it.
            [self setFilesToParse:[NSMutableArray arrayWithObject:filePath]];
            [self setTotalFilesToParse:1];
            [self parseFileAtPath:filePath];
        }
    } else {
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkFeedFinished:)]) {
            [[self delegate] pkFeedFinished:self];
        }
    }
}

#pragma mark - Private Methods

- (void) parseFilesAtDirectory:(NSURL*)directoryUrl {
    // Update progress
    NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Importing %@...", nil), [PKFeed pluralNameForFeedType:[self type]]];
    [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
    
    // Get a list of files within the directory
    NSError *error = nil;
    NSArray *filesInDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[directoryUrl path] error:&error];
    
    // Scan each file and ensure it has the .xml extension
    NSMutableArray *files = [NSMutableArray array];
    for (NSString *filename in filesInDirectory) {
        if ([filename rangeOfString:@".xml" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [files addObject:filename];
        }
    }
    
    // Next, sort the list of files alphabetically
    [files sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
    
    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    [q setMaxConcurrentOperationCount:1];

    // Next, load each file
    [self setFilesToParse:[NSMutableArray array]];
    
    for (NSString *filename in files) {
        // Forge a URL to the file
        NSURL *chunkUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [directoryUrl path], filename]];
        [[self filesToParse] addObject:chunkUrl];
    }

    // Keep count of the total
    [self setTotalFilesToParse:[[self filesToParse] count]];
    
    // Start the parsing process
    [self parseNextFile];
}

- (void) parseNextFile {
    NSURL *nextFileUrl = [[self filesToParse] firstObject];
    if (nextFileUrl) {
        [FSThread runInBackground:^{
            [self parseFileAtPath:nextFileUrl];
        } withThreadIdentifier:[self threadName]];
    } else {
        // Remove data:
        [self setLocalContext:nil];
        [self setExistingProducts:nil];
        [self setExistingCategories:nil];
        
        // There are no more files to parse, this must be the end!
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkFeedFinished:)]) {
            [[self delegate] pkFeedFinished:self];
        }
    }
}

- (void)parseFileAtPath:(NSURL*)url {
    // Load the data into memory
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // Init XML Parser
    RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
    
    NSManagedObjectContext *localContext = [self localContext];
    [localContext setUndoManager:nil];
    
    // Loop the XML
    NSMutableArray *products = [NSMutableArray arrayWithArray:[rootXML children:@"PRODUCT"]];
    [rootXML iterateElements:products usingBlock:^(RXMLElement *p) {
        NSString *uuid = [[p child:@"ID"] text];
        
        PKProduct *product = nil;
        for (PKProduct *p in [self existingProducts]) {
            if ([[p productId] isEqualToString:uuid]) {
                product = p;
                [[self existingProducts] removeObject:p];
                break;
            }
        }
        
        if (!product) {
            product = [PKProduct MR_createEntityInContext:localContext];
            [product setProductId:uuid];
            [product setFeedNumber:[[self feedConfig] number]];
        }
        
        // Set the values!
        [product ifStringExistsInElement:p forKey:@"TITLE" thenSetValue:@selector(setTitle:)];
        [product ifStringExistsInElement:p forKey:@"DESCRIPTION" thenSetValue:@selector(setDescText:)];
        [product ifStringExistsInElement:p forKey:@"MANUFACTURER" thenSetValue:@selector(setManufacturer:)];
        [product ifStringExistsInElement:p forKey:@"MODEL" thenSetValue:@selector(setModel:)];
        [product ifStringExistsInElement:p forKey:@"BARCODE" thenSetValue:@selector(setBarcode:)];
        [product ifStringExistsInElement:p forKey:@"ORDERED" thenSetValue:@selector(setOrdered:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"STOCKLEVEL" thenSetValue:@selector(setStockLevel:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"AVAILABLE_STOCK" thenSetValue:@selector(setAvailableStock:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"DIMENSION" thenSetValue:@selector(setDimension:)];
        [product ifStringExistsInElement:p forKey:@"MATERIAL" thenSetValue:@selector(setMaterial:)];
        [product ifStringExistsInElement:p forKey:@"BACK_ORDERS" thenSetValue:@selector(setBackOrders:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"TOTAL_SOLD" thenSetValue:@selector(setTotalSold:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"TOTAL_VALUE" thenSetValue:@selector(setTotalValue:) andSaveAsType:PKVariableTypeNSNumber];        
        [product ifStringExistsInElement:p forKey:@"POSITION" thenSetValue:@selector(setPosition:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"VALUE_POSITION" thenSetValue:@selector(setValuePosition:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"VAT" thenSetValue:@selector(setVat:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"MULTIPLES" thenSetValue:@selector(setMultiples:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"MIN_ORDER_QTY" thenSetValue:@selector(setMinOrderQuantity:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"PURCHASE_UNIT" thenSetValue:@selector(setPurchaseUnit:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"INNER" thenSetValue:@selector(setInner:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"CARTON" thenSetValue:@selector(setCarton:) andSaveAsType:PKVariableTypeNSNumber];
        [product ifStringExistsInElement:p forKey:@"DATE_ADDED" thenSetValue:@selector(setDateAdded:) andSaveAsType:PKVariableTypeNSDate];
        [product ifStringExistsInElement:p forKey:@"DATE_AVAILABLE" thenSetValue:@selector(setDateAvailable:) andSaveAsType:PKVariableTypeNSDate];
        
        // Determine the sale history object to save to... We only save to *one* object here for effeciency reasons.  We will provide PKSalesHistory mini-classes for the API.
        PKProductSaleHistory *saleHistory = [product saleHistory];
        if(!saleHistory) {
            saleHistory = [PKProductSaleHistory MR_createEntityInContext:localContext];
        }
        
        // Update prior-year values
        RXMLElement *priorYearSoldElement = [p child:@"PRIOR_YR_QTY_SOLD"];
        for (int i = 1; i <= 12; i++) {
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"setPrior_%d:", i]);
            NSString *key = [NSString stringWithFormat:@"MTH%d", i];
            [saleHistory ifStringExistsInElement:priorYearSoldElement forKey:key thenSetValue:selector andSaveAsType:PKVariableTypeNSNumber];
        }
        
        // Update year-to-date values
        RXMLElement *yearSoldToDateElement = [p child:@"QTY_SOLD"];
        for (int i = 1; i <= 12; i++) {
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"setCurrent_%d:", i]);
            NSString *key = [NSString stringWithFormat:@"MTH%d", i];
            [saleHistory ifStringExistsInElement:yearSoldToDateElement forKey:key thenSetValue:selector andSaveAsType:PKVariableTypeNSNumber];
        }
        
        // Reattach the sale history obj to the product
        [product setSaleHistory:saleHistory];
        
        // Clear down existing category links for this product
        if ([product categories] && [[product categories] count] >= 1) {
            [product removeCategories:[product categories]];
        }
        
        // Next, lets connect up the categories!
        NSArray *categories = [[p child:@"CATEGORIES"] children:@"CATEGORY"];
        for(RXMLElement *cat in categories) {
            NSString *categoryId = [[cat child:@"ID"] text];
            
            PKCategory *category = nil;
            for (PKCategory *c in [self existingCategories]) {
                if ([[c categoryId] isEqualToString:categoryId]) {
                    category = c;
                    break;
                }
            }
            
            if (category) {
                [product addCategoriesObject:category];
            }
        }
        
        // Add some other values (mostly debug stuff)
        [product setFromXmlFile:[[url absoluteString] lastPathComponent]];
        
        // Loop the images
        if (uuid) {
            // Next, lets create new PKImages.
            PKImage *primaryImage = nil;
            NSArray *images = [[p child:@"IMAGES"] children:@"IMAGE"];
            for(RXMLElement *imageElement in images) {
                NSString *file = [[imageElement child:@"FILE"] text];
                
                // Ensure the filename is valid
                if([file length] >= 1) {
                    
                    // Create a new pointer to an image
                    PKImage *image = [PKImage createWithImageId:file
                                                       atDomain:kPuckatorEndpointDefaultImageDomain
                                           forRelatedEntityUuid:uuid
                                      forRelatedEntityClassType:@"Product"
                                                  forFeedConfig:[self feedConfig]
                                                      inContext:localContext];
                    
                    // Inject the order into the object
                    [image ifStringExistsInElement:imageElement forKey:@"ORDER" thenSetValue:@selector(setOrder:) andSaveAsType:PKVariableTypeNSNumber];
                    
                    // Is this the first image?  Set as the primary image if so!
                    if(!primaryImage) {
                        primaryImage = image;
                    }
                    
                    // Associate with product
                    [product addImagesObject:image];
                }
            }
            
            // Do we have at least one image?  If so, lets attach it to the image
            if (primaryImage) {
                [product setMainImage:primaryImage];
            }
        }
        
        // Remove all prices on the product so far...
        if ([product prices] && [[product prices] count] >= 1) {
            [product removePrices:[product prices]];
        }
        
        // Does the product have prices?
        if ([p child:@"PRICES"]) {
            NSArray *prices = [[p child:@"PRICES"] children:@"PRICE"];
            for (RXMLElement *priceElement in prices) {
                // Create a new price
                PKProductPrice *price = [PKProductPrice createWithForProduct:product
                                                               forFeedConfig:[self feedConfig]
                                                                   inContext:localContext];
                
                // Insert values into the price
                [price ifStringExistsInElement:priceElement forKey:@"VALUE" thenSetValue:@selector(setValue:) andSaveAsType:PKVariableTypeNSNumberFloat];
                [price ifStringExistsInElement:priceElement forKey:@"GBP_RATE" thenSetValue:@selector(setRateGBP:) andSaveAsType:PKVariableTypeNSNumberFloat];
                [price ifStringExistsInElement:priceElement forKey:@"EUR_RATE" thenSetValue:@selector(setRateEUR:) andSaveAsType:PKVariableTypeNSNumberFloat];
                [price ifStringExistsInElement:priceElement forKey:@"SEK_RATE" thenSetValue:@selector(setRateSEK:) andSaveAsType:PKVariableTypeNSNumberFloat];
                [price ifStringExistsInElement:priceElement forKey:@"PLN_RATE" thenSetValue:@selector(setRatePLN:) andSaveAsType:PKVariableTypeNSNumberFloat];
                [price ifStringExistsInElement:priceElement forKey:@"DKK_RATE" thenSetValue:@selector(setRateDKK:) andSaveAsType:PKVariableTypeNSNumberFloat];
                [price ifStringExistsInElement:priceElement forKey:@"RMB_RATE" thenSetValue:@selector(setRateRMB:) andSaveAsType:PKVariableTypeNSNumberFloat];
                [price ifStringExistsInElement:priceElement forKey:@"OLD_PRICE" thenSetValue:@selector(setOldPrice:) andSaveAsType:PKVariableTypeNSNumberFloat];
                [price ifStringExistsInElement:priceElement forKey:@"QTY" thenSetValue:@selector(setQuantity:) andSaveAsType:PKVariableTypeNSNumber];
                [price ifStringExistsInElement:priceElement forKey:@"PRICE_TIER" thenSetValue:@selector(setPriceTier:) andSaveAsType:PKVariableTypeNSString];
                
                if([[[price priceTier] uppercaseString] isEqualToString:@"NORMAL"]) {
                    [price setDisplayIndex:@(0)];
                    [product setFirstPrice:[price value]];
                } else if([[[price priceTier] uppercaseString] isEqualToString:@"T1"]) {
                    [price setDisplayIndex:@(1)];
                } else if([[[price priceTier] uppercaseString] isEqualToString:@"T2"]) {
                    [price setDisplayIndex:@(2)];
                } else {
                    [price setDisplayIndex:@(3)];
                }
                
                // Add to the product
                [product addPricesObject:price];
             }
        }
    }];

    [localContext MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
        [[self filesToParse] removeObject:url];
        
        // Calculate percent of import process
        int pagesParsed = [self totalFilesToParse] - [[self filesToParse] count];
        float percentComplete = (float)((float)pagesParsed / (float)[self totalFilesToParse]) * 100.0f;
            
        // Update progress
        if ((int)percentComplete == 0) {
            NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Preparing to save %@ to database", nil),
                                       [PKFeed pluralNameForFeedType:[self type]]];
            [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
        } else {
            NSString *statusMessage = [NSString stringWithFormat:NSLocalizedString(@"Saving %@ to database: %d%%", nil),
                                        [PKFeed pluralNameForFeedType:[self type]], (int)percentComplete];
            [[self feedConfig] updateStatusText:statusMessage withProgressStep:PKProgressStepExtracting];
        }
        
        // Parse the next file in the list...
        [self parseNextFile];
    }];
}

@end