//
//  PuckatorKit.h
//  PuckatorKit
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKEnumation.h"
#import <AFNetworking/AFNetworking.h>
#import "NSError+PKError.h"
#import "PKKeyValue.h"
#import <HexColors/HexColor.h>
#import "NSString+Email.h"
#import <MagicalRecord/MagicalRecord.h>

/**
 *  Public Database Entities
 */
#import "PKAgent.h"         // DEPRECATED
#import "PKProduct.h"
#import "PKCategory.h"
#import "PKCategory+Operations.h"
#import "PKProductSaleHistory+Operations.h"
#import "NSManagedObject+Operations.h"
#import "PKSaleHistory.h"
#import "PKBasket.h"
#import "PKBasketItem.h"
#import "PKFeedConfigMeta+Operations.h"
#import "PKRecentCustomer+Operations.h"

/*
 *  Public Headers
 */
#import "PKFeedConfig.h"
#import "PKInstallation.h"
#import "PKTranslate.h"
#import "FSThread.h"
#import "PKJobManager.h"
#import "PKJob.h"
#import "PKSession.h"
#import "PKSearchParameters.h"
#import "PKCurrency.h"

/* 
 * Categories
 */
#import "NSObject+JSON.h"
#import "NSString+Utils.h"
#import "PKProduct+UI.h"

//! Project version number for PuckatorKit.
FOUNDATION_EXPORT double PuckatorKitVersionNumber;

//! Project version string for PuckatorKit.
FOUNDATION_EXPORT const unsigned char PuckatorKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PuckatorKit/PublicHeader.h>


