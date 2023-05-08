//
//  PKMiniSearchResultTableViewCell.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKProduct;

@interface PKMiniSearchResultTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelProductTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelProductMetaData;

- (void) setProduct:(PKProduct*)product;

@end
