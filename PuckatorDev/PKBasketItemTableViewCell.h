//
//  PKBasketItemTableViewCell.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKBasketCalculationTableViewCell;
@protocol PKBasketItemCellDelegate <NSObject>
- (void) pkBasketItemTableViewCell:(UITableViewCell*)cell didSelectInteractionElement:(NSString*)name;
- (void) pkBasketItemTableViewCell:(UITableViewCell*)cell didSelectInteractionElement:(id)element name:(NSString *)name;
@end

@interface PKBasketItemTableViewCell : UITableViewCell

// Delegate
@property (nonatomic, assign) id<PKBasketItemCellDelegate> selectionDelegate;

// Important meta data
@property (weak, nonatomic) IBOutlet UILabel *labelProductTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelMetaData;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelIndex;

// Buttons and values
@property (weak, nonatomic) IBOutlet UIButton *btnQuantity;
@property (weak, nonatomic) IBOutlet UIButton *btnPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelRowTotal;

// Symbols
@property (weak, nonatomic) IBOutlet UILabel *labelX;
@property (weak, nonatomic) IBOutlet UILabel *labelEq;

/**
 *  Updates the cell with information about the product in the basket.
 *
 *  @param basketItem The PKBasketItem item.
 */
- (void)updateWithBasketItem:(PKBasketItem*)basketItem atIndexPath:(NSIndexPath*)indexPath;
- (void)updateWithInvoice:(PKInvoice *)invoice invoiceLine:(PKInvoiceLine *)invoiceLine atIndexPath:(NSIndexPath *)indexPath;
- (void)updateWithBasketItem:(PKBasketItem*)basketItem atIndexPath:(NSIndexPath*)indexPath editable:(BOOL)editable;

@end
