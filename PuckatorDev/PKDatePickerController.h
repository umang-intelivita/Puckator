//
//  PKDatePicker.h
//  Puckator
//
//  Created by Luke Dixon on 24/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKDatePickerController;

@protocol PKDatePickerControllerDelegate<NSObject>
- (void)pkDatePicker:(PKDatePickerController *)datePickerController didSelectDate:(NSDate *)date isDone:(BOOL)done;
@end

@interface PKDatePickerController : UIViewController

+ (instancetype)createWithSelectedDate:(NSDate *)selectedDate
                           minimumDate:(NSDate *)minimumDate
                           maximumDate:(NSDate *)maximumDate
                              delegate:(id<PKDatePickerControllerDelegate>)delegate;

@property (weak, nonatomic) id<PKDatePickerControllerDelegate> delegate;

@end