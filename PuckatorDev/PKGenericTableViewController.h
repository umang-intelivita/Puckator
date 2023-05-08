//
//  PKGenericTableViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 04/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PKGenericTableTypeSearchScope = 0,
    PKGenericTableTypeSortResultsBy = 1,
    PKGenericTableTypeSortProductsBy = 2,
    PKGenericTableTypeSortTopProductsBy = 3,
    PKGenericTableBasketContextMenu = 4,
    PKGenericTableTypeSortBasketBy = 5
} PKGenericTableType;

@class PKGenericTableViewController;
@protocol PKGenericTableDelegate <NSObject>
@required
- (void) pkGenericTableViewController:(PKGenericTableViewController*)tableViewController didSelectItemId:(int)selectedItemId;
@end

@interface PKGenericTableViewController : UITableViewController <UIActionSheetDelegate>

#pragma mark - Properties

@property (nonatomic, assign) PKGenericTableType type;                          // The type of table view

#pragma mark - Factories

// Create a new instance of the table
+ (instancetype) createWithType:(PKGenericTableType)type delegate:(id<PKGenericTableDelegate>)delegate;
+ (instancetype) createWithType:(PKGenericTableType)type delegate:(id<PKGenericTableDelegate>)delegate selectedItemId:(int)selectedItemId;

@end
