//
//  PKDatePicker.m
//  Puckator
//
//  Created by Luke Dixon on 24/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKDatePickerController.h"
#import <MKFoundationKit/MKFoundationKit.h>

@interface PKDatePickerController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDate *minimumDate;
@property (strong, nonatomic) NSDate *maximumDate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonToday;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonTomorrow;

@end

@implementation PKDatePickerController

#pragma mark - Constructor Methods

+ (instancetype)createWithSelectedDate:(NSDate *)selectedDate
                           minimumDate:(NSDate *)minimumDate
                           maximumDate:(NSDate *)maximumDate
                              delegate:(id<PKDatePickerControllerDelegate>)delegate {
    PKDatePickerController *datePickerController = [[PKDatePickerController alloc] initWithNibName:@"PKDatePickerController" bundle:[NSBundle mainBundle]];
    [datePickerController setDelegate:delegate];
    [datePickerController setSelectedDate:selectedDate];
    [datePickerController setMinimumDate:minimumDate];
    [datePickerController setMaximumDate:maximumDate];
    return datePickerController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(320, 216);
}

#pragma mark - Private Methods

- (void)setupUI {
    [self setTitle:NSLocalizedString(@"Select Date", nil)];
    [[self buttonToday] setTitle:NSLocalizedString(@"Today", nil)];
    [[self buttonTomorrow] setTitle:NSLocalizedString(@"Tomorrow", nil)];
    
    [[self datePicker] setMinimumDate:[self minimumDate]];
    [[self datePicker] setMaximumDate:[self maximumDate]];
    
    if ([self selectedDate]) {
        [[self datePicker] setDate:[self selectedDate]];
    }
    
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonDonePressed:)];
    [[self navigationItem] setRightBarButtonItem:buttonDone];
}

- (void)updateDelegateWithDate:(NSDate *)date isDone:(BOOL)done {
    if ([[self delegate] respondsToSelector:@selector(pkDatePicker:didSelectDate:isDone:)]) {
        [[self delegate] pkDatePicker:self didSelectDate:date isDone:done];
    }
}

#pragma mark - Event Methods

- (IBAction)datePickerChanged:(id)sender {
    [self updateDelegateWithDate:[[self datePicker] date] isDone:NO];
}

- (void)buttonDonePressed:(id)sender {
    [self updateDelegateWithDate:[[self datePicker] date] isDone:YES];
}

- (IBAction)buttonTodayPressed:(id)sender {
    [self updateDelegateWithDate:[NSDate date] isDone:YES];
}

- (IBAction)buttonTomorrowPressed:(id)sender {
    [self updateDelegateWithDate:[[NSDate date] mk_dateByAddingDays:1] isDone:YES];
}

#pragma mark -

@end
