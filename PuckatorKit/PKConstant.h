//
//  PKConstant.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 08/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#define kPuckatorDisableOrderSync           NO
#define kPuckatorDebugForceSupplierSearch   NO

#define kPkSkipValidateXmlPayload           @"PK_SkipValidateXmlPayload"

#define kPuckatorEndpointStatus             @"https://www.puckator-ipad.net/ipad/api/v57.1?action=status/"
#define kPuckatorEndpointRegistration       @"https://www.puckator-ipad.net/ipad/api/v57.1?action=registerFeed/"
#define kPuckatorEndpointSyncManifest       @"https://www.puckator-ipad.net/ipad/api/v57.1?action=sync/"
#define kPuckatorEndpointAccountsPayload    @"https://www.puckator-ipad.net/ipad/api/v57.1?action=getAccountsSqlPayload"
#define kPuckatorEndpointData               @"https://www.puckator-ipad.net/ipad/chunker/"
#define kPuckatorEndpointDefaultImageDomain     @"https://www.puckator-ipad.net/www/images/"
#define kPuckatorEndpointTimestampImageDomain   @"https://puckator-ipad.net/ipad/images/imageutil/get_latest.php?filename=%@&timestamp=%@"


// Meta Data Groups
#define kPuckatorMetaGroupSqlDates                  @"kPuckatorMetaGroupSqlDates"
#define kPuckatorMetaKeySqlProductsGeneratedDate    @"kPuckatorMetaKeySqlProductsGeneratedDate"
#define kPuckatorMetaKeySqlProductsProcessedDate    @"kPuckatorMetaKeySqlProductsProcessedDate"

#define kPuckatorMetaGroupSqlXmlFiles               @"kPuckatorMetaGroupSqlXmlFiles"
#define kPuckatorMetaKeySqlXmlCustomerFile          @"kPuckatorMetaKeySqlXmlCustomerFile"

// Defaults:
#define kPuckatorNoImageName                        @"PKNoImage.png"

// Notifications
#define kNotificationSyncProgressUpdate                 @"com.57digital.puckator.notification.syncprogressupdate"
#define kNotificationSyncProgressComplete               @"com.57digital.puckator.notification.syncprogresscomplete"
#define kNotificationSyncComplete                       @"com.57digital.puckator.notification.synccomplete"
#define kNotificationFeedDidChange                      @"com.57digital.puckator.notification.feed_did_change"
#define kNotificationBasketDidUpdateItem                @"com.57digital.puckator.notification.basket_did_update_item"
#define kNotificationBasketStatusChanged                @"com.57digital.puckator.notification.basket_status_changed"
#define kNotificationSyncOrderRequest                   @"com.57digital.puckator.notification.sync_order_requested"
#define kNotificationDidChangeCurrency                  @"com.57digital.puckator.notification.did_change_currency"
#define kNotificationDidSaveOrCancelOrder               @"com.57digital.puckator.notification.did_save_or_cancel_order"
#define kNotificationFilterChanged                      @"com.57digital.puckator.notification.filter_changed"
#define kNotificationRequestSortMenu                    @"com.57digital.puckator.notification.request_sort_menu"

#define kNSUserDefaultsFeedNumberKey                    @"com.57digital.puckator.userdefauls.feed_number_key"

#define kPuckatorErrorCode                              5700

#define kPuckatorErrorNetworkProblem                    5701

/* Feed Registration Errors; 57xx range */
#define kPuckatorErrorCodeFeedInvalid                   5711
#define kPuckatorErrorCodeFeedSuspended                 5712
#define kPuckatorErrorCodeFeedLicenseProblem            5713
#define kPuckatorErrorCodeFeedGenericError              5714
#define kPuckatorErrorCodeFeedInvalidDevice             5715
#define kPuckatorErrorCodeFeedInvalidResponse           5716

/* General Network Errors; 58xx range */
#define kPuckatorErrorCodeStatusCheckFailed             5800
#define kPuckatorErrorCodeStatusCheckOfflineMessage     5801

/* Sync Errors; 5900 range */
#define kPuckatorErrorCodeMissingJwtToken               5900

#define kPuckatorWholesaleDiscountPercentage            [NSNumber numberWithFloat:0.35f]

#define kRoundFloatToTwoDecimalPointsOld(float)            floorf(float * 100 + 0.5) / 100
#define kRoundFloatToTwoDecimalPoints(float)            [NSDecimalNumber roundDouble:float]

