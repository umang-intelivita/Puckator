//
//  PKProduct+UI.h
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PuckatorKit.h"

@interface PKProduct (UI)

#pragma mark - Indictor Methods
- (NSString *)topSellerTitle;
- (NSString *)topGrossingTitle;

- (NSString *)dueDateString;
- (NSString *)nextDueDateFormatted;
- (NSString *)nextDueDateFormattedEDC;

@end
