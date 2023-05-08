//
//  PKHistoryCell.h
//  PuckatorDev
//
//  Created by Luke Dixon on 28/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "CTCustomTableViewCell.h"
#import "PKSaleHistory.h"

@interface PKHistoryCell : CTCustomTableViewCell

- (void)setupWithYearToDateSaleHistory:(PKSaleHistory *)yearToDateSaleHistory priorYearToDateSaleHistory:(PKSaleHistory *)priorYearToDateSaleHistory priorTwoYearToDateSaleHistory:(PKSaleHistory *)priorTwoYearToDateSaleHistory;
- (void)setupWithYearToDateHeader:(NSString *)yearToDateHeader priorYearToDateHeader:(NSString *)priorYearToDateHeader priorTwoYearToDateHeader:(NSString *)priorTwoYearToDateHeader;
- (void)setupWithYearToDateTotal:(int)yearToDateTotal priorYearToDateTotal:(int)priorYearToDateTotal priorTwoYearToDateTotal:(int)priorTwoYearToDateTotal;

@end
