//
//  PKBasketCalculationTableViewCell.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 12/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKBasketCalculationTableViewCell;
@protocol PKBasketCalculatonCellDelegate <NSObject>
- (void) pkBasketCalculationTableViewCell:(UITableViewCell*)cell didSelectInteractionElement:(id)element name:(NSString *)name;
@end

@interface PKBasketCalculationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelRowTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelRowValue;
@property (weak, nonatomic) IBOutlet UIButton *buttonValue;
@property (nonatomic, weak) id<PKBasketCalculatonCellDelegate> selectionDelegate;

- (void)updateWithTitle:(NSString *)title value:(NSString *)value;
- (void) updateStyleIsButton:(BOOL)isButton isHighlighted:(BOOL)isHighlighted;

@end