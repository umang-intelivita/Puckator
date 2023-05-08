//
//  PKCategoryCell.h
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKCategoryObject.h""

@interface PKCategoryCell : UICollectionViewCell

#pragma mark - Public Methods
- (void)setupWithCategory:(PKCategory *)category;
- (void)setupWithCategoryObject:(PKCategoryObject *)category;
@end
