//
//  PKCustomCategoryBar.h
//  Puckator
//
//  Created by Luke Dixon on 01/11/2018.
//  Copyright © 2018 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBaseViewController.h"

@class PKCategory;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PKCustomCategoryBarModeCreate,
    PKCustomCategoryBarModeExisting,
    PKCustomCategoryBarModeRemove
} PKCustomCategoryBarMode;

typedef enum : NSUInteger {
    PKCustomCategoryBarProductModeAdd,
    PKCustomCategoryBarProductModeRemove,
    PKCustomCategoryBarProductModeNone
} PKCustomCategoryBarProductMode;

@class PKCustomCategoryBar;

@protocol PKCustomCategoryBarDelegate<NSObject>

- (void)pkCustomCategoryBarConfirmed:(PKCustomCategoryBar *)customCategoryBar;
- (void)pkCustomCategoryBarCancelled:(PKCustomCategoryBar *)customCategoryBar;
- (void)pkCustomCategoryBarSelectAll:(PKCustomCategoryBar *)customCategoryBar;
- (void)pkCustomCategoryBarSelectNone:(PKCustomCategoryBar *)customCategoryBar;

@end

@interface PKCustomCategoryBar : FSBaseViewController

@property (weak, nonatomic) id<PKCustomCategoryBarDelegate> delegate;
@property PKCustomCategoryBarMode mode;
@property (nonatomic) PKCustomCategoryBarProductMode productMode;
@property (strong) PKCategory *category;

+ (instancetype)createWithDelegate:(id<PKCustomCategoryBarDelegate>)delegate mode:(PKCustomCategoryBarMode)mode;
- (void)setProductButtonsEnabled:(BOOL)enabled;
- (void)addProducts:(NSArray<PKProduct*> *)products;


@end

NS_ASSUME_NONNULL_END
