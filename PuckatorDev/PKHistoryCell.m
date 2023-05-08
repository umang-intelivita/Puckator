//
//  PKHistoryCell.m
//  PuckatorDev
//
//  Created by Luke Dixon on 28/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKHistoryCell.h"
#import "UIColor+Puckator.h"
#import "UIFont+Puckator.h"

@interface PKHistoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelMonth;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentYear;
@property (weak, nonatomic) IBOutlet UILabel *labelPreviousYear;
@property (weak, nonatomic) IBOutlet UILabel *labelPriorTwoYear;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDifference;
@property (weak, nonatomic) IBOutlet UILabel *labelDifference;

@end

@implementation PKHistoryCell

#pragma mark - Public Methods

- (void)setupWithYearToDateSaleHistory:(PKSaleHistory *)yearToDateSaleHistory priorYearToDateSaleHistory:(PKSaleHistory *)priorYearToDateSaleHistory priorTwoYearToDateSaleHistory:(PKSaleHistory *)priorTwoYearToDateSaleHistory {
    [[self labelMonth] setText:[yearToDateSaleHistory dateStringWithFormat:PKSaleHistoryDateFormatMonthNameShortOnly]];
    [[self labelCurrentYear] setText:[NSString stringWithFormat:@"%i", [yearToDateSaleHistory value]]];
    [[self labelPreviousYear] setText:[NSString stringWithFormat:@"%i", [priorYearToDateSaleHistory value]]];
    [[self labelPriorTwoYear] setText:[NSString stringWithFormat:@"%i", [priorTwoYearToDateSaleHistory value]]];
    [self setupWithDifferenceBetweenYearToDateValue:[yearToDateSaleHistory value] priorYearToDateTotal:[priorYearToDateSaleHistory value]];
}

- (void)setupWithYearToDateHeader:(NSString *)yearToDateHeader priorYearToDateHeader:(NSString *)priorYearToDateHeader priorTwoYearToDateHeader:(NSString *)priorTwoYearToDateHeader {
    [[self labelMonth] setText:nil];
    [[self imageViewDifference] setHidden:YES];
    [[self labelDifference] setHidden:NO];
    [[self labelDifference] setText:NSLocalizedString(@"Diff +/-", nil)];
    [[self labelCurrentYear] setText:yearToDateHeader];
    [[self labelPreviousYear] setText:priorYearToDateHeader];
    [[self labelPriorTwoYear] setText:priorTwoYearToDateHeader];
}

- (void)setupWithYearToDateTotal:(int)yearToDateTotal priorYearToDateTotal:(int)priorYearToDateTotal priorTwoYearToDateTotal:(int)priorTwoYearToDateTotal {
    [[self labelMonth] setText:nil];
    [[self labelCurrentYear] setText:[NSString stringWithFormat:@"%i", yearToDateTotal]];
    [[self labelPreviousYear] setText:[NSString stringWithFormat:@"%i", priorYearToDateTotal]];
    [[self labelPriorTwoYear] setText:[NSString stringWithFormat:@"%i", priorTwoYearToDateTotal]];
    [self setupWithDifferenceBetweenYearToDateValue:yearToDateTotal priorYearToDateTotal:priorYearToDateTotal];
    
    [[self labelCurrentYear] setFont:[UIFont puckatorDescriptionBold]];
    [[self labelPreviousYear] setFont:[UIFont puckatorDescriptionBold]];
    [[self labelPriorTwoYear] setFont:[UIFont puckatorDescriptionBold]];
    
    [[self labelCurrentYear] setPuckatorBoldFont];
    [[self labelPreviousYear] setPuckatorBoldFont];
    [[self labelPriorTwoYear] setPuckatorBoldFont];
    [[self labelDifference] setPuckatorBoldFont];
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self bounds].size.width, 1)];
    [viewLine setBackgroundColor:[UIColor puckatorDarkGray]];
    [viewLine setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self addSubview:viewLine];
}

#pragma mark - Private Methods

- (void)setupWithDifferenceBetweenYearToDateValue:(int)yearToDateValue priorYearToDateTotal:(int)priorYearToDateValue {
    // Setup the UI:
    [[self imageViewDifference] setHidden:NO];
    [[[self imageViewDifference] layer] setCornerRadius:[[self imageViewDifference] bounds].size.height * 0.5f];
    [[self labelDifference] setHidden:NO];
    
    int difference = yearToDateValue - priorYearToDateValue;
    [[self labelDifference] setText:[NSString stringWithFormat:@"%i", difference]];
    
    if (difference == 0) {
        [[self labelDifference] setText:@"-"];
        [[self imageViewDifference] setBackgroundColor:[UIColor puckatorRankMid]];
    } else if (difference > 0) {
        [[self imageViewDifference] setBackgroundColor:[UIColor puckatorRankMax]];
    } else {
        [[self imageViewDifference] setBackgroundColor:[UIColor puckatorRankMin]];
    }
}

#pragma mark -

@end
