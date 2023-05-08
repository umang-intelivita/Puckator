//
//  PKEnumation.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

/**
 *  An enumation of feed types
 */
typedef NS_ENUM(NSUInteger, PKFeedType) {
    /**
     *  Unsupported feed type
     */
    PKFeedTypeUnknown   = 0,
    /**
     *  The Customer Feed
     */
    PKFeedTypeCustomer  = 3,
    /**
     *  The Orders Feed
     */
    PKFeedTypeOrder     = 4,
    /**
     *  The Invoice Feed
     */
    PKFeedTypeInvoice   = 5,
    /**
     *  The Country Feed
     */
    PKFeedTypeCountry   = 6,
    /**
     *  The main feed manifest
     */
    PKFeedTypeManifest  = 7,
    /**
     *  The image download operation (not technically a "Feed" as such)
     */
    PKFeedTypeSQLData  = 99997, // always process last, don't set anything higher than this!
    /**
     *  The image download operation (not technically a "Feed" as such)
     */
    PKFeedTypeSQLAccounts  = 99998, // always process last, don't set anything higher than this!
    /**
     *  The image download operation (not technically a "Feed" as such)
     */
    PKFeedTypeImage  = 99999 // always process last, don't set anything higher than this!
    
};

/**
 *  An enumation of feed format types, for example Zip or XML.
 */
typedef NS_ENUM(NSUInteger, PKFeedFormat) {
    /**
     *  An unsupported format
     */
    PKFeedFormatUnknown   = 0,
    /**
     *  XML File Format
     */
    PKFeedFormatXML     = 1,
    /**
     *  Compressed Zip Archive containing an XML document
     */
    PKFeedFormatZip     = 2
};


/**
 *  An enumation of error codes
 */
typedef NS_ENUM(NSUInteger, PKError) {
    PKErrorUnknown = 0,
    PKErrorFeedFormatIsNotRecognized    = 1000,
    PKErrorFeedUrlOrFeedTypeNotFound    = 1001,
    PKErrorFeedDownloadError            = 1002,
    PKErrorExtractingZipArchive         = 1003,
    PKErrorZeroFilesInZipArchive        = 1004,
    PKErrorPayloadDoesNotContainXML     = 1005
};

