//
//  PKNumericPad.m
//  PuckatorDev
//
//  Created by Luke Dixon on 21/01/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKNumericPad.h"
#import "UIButton+AllStates.h"
#import "UIColor+Puckator.h"
#import <AFSoundManager/AFSoundManager.h>

@interface PKNumericPad ()

@property (weak, nonatomic) IBOutlet UIView *viewKeypadContainer;
@property (weak, nonatomic) IBOutlet UILabel *labelValue;
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UIButton *buttonConfirm;
@property (weak, nonatomic) IBOutlet UILabel *labelPurchaseUnit;
@property (weak, nonatomic) IBOutlet UILabel *labelInner;
@property (weak, nonatomic) IBOutlet UILabel *labelCarton;
@property (weak, nonatomic) PKProduct *product;
@property (assign, nonatomic) int functionValue;
@property (assign, nonatomic) PKNumericPadFunction function;

@end

@implementation PKNumericPad

#pragma mark -

+ (instancetype)createWithProduct:(PKProduct *)product delegate:(id<PKNumericPadDelegate>)delegate {
    PKNumericPad *numberPad = [[PKNumericPad alloc] initWithNibName:@"PKNumericPad" bundle:nil];
    [numberPad setProduct:product];
    [numberPad setDelegate:delegate];
    return numberPad;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(427, 414);
}

#pragma mark - Private Methods

- (int)inputValue {
    return [[[self labelValue] text] intValue];
}

- (void)clearInputValue {
    [[self labelValue] setText:@"0"];
}

- (void)setInputValue:(float)inputValue {
    // Always round up the input value:
    inputValue = ceilf(inputValue);
    
    // Update the UI:
    [[self labelValue] setText:[NSString stringWithFormat:@"%i", (int)inputValue]];
}

- (void)setupView {
    // Hide the clear button:
    [[self buttonClear] setHidden:YES];
    
    // Style the buttons:
    [[self labelValue] setTextColor:[UIColor puckatorPrimaryColor]];
    [[[self viewKeypadContainer] layer] setCornerRadius:5];
    [[self viewKeypadContainer] setBackgroundColor:[[UIColor puckatorPrimaryColor] colorWithAlphaComponent:0.1f]];
    [[[self viewKeypadContainer] subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            if (button != [self buttonClear]) {
                [button setBackgroundColor:[UIColor clearColor]];
                [[button layer] setCornerRadius:[button frame].size.height * 0.5f];
                [[button layer] setBorderWidth:1];
                [[button layer] setBorderColor:[[UIColor puckatorPrimaryColor] CGColor]];
                [button setTitleColorForAllStates:[UIColor puckatorPrimaryColor]];
            }
        }
    }];
    
    [[self buttonClear] setImageRenderingModeForAllStates:UIImageRenderingModeAlwaysTemplate];
    [[self buttonClear] setTintColor:[UIColor puckatorPrimaryColor]];
}

- (void)setupFunction:(PKNumericPadFunction)function {
    // Set the current function:
    [self setFunction:function];
    
    if ([self function] != PKNumericPadFunctionNone) {
        // Save the current value as the function value:
        [self setFunctionValue:[self inputValue]];

        // Clear the current value:
        [self clearInputValue];
        
        // Change the confirm button:
        [[self buttonConfirm] setTitleForAllStates:@"="];
        
        // Change color back to normal
        [[[self buttonConfirm] layer] setBorderColor:[[UIColor puckatorPrimaryColor] CGColor]];
        [[self buttonConfirm] setBackgroundColor:[UIColor clearColor]];
        [[self buttonConfirm] setTitleColor:[UIColor puckatorPrimaryColor] forState:UIControlStateNormal];
    } else {
        // Clear the function value:
        [self setFunctionValue:0];
        
        // Change the confirm button:
        [[self buttonConfirm] setTitleForAllStates:PKLocalizedString(@"Confirm")];
        
        // Highlight with pink to confirm the action
        [[[self buttonConfirm] layer] setBorderColor:[[UIColor puckatorGreen] CGColor]];
        [[self buttonConfirm] setBackgroundColor:[UIColor puckatorGreen]];
        [[self buttonConfirm] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    
    // Play sound - just testing, sorry if this is not where you want the code!
    [[AFSoundManager sharedManager] startPlayingLocalFileWithName:@"SatisfyingClick.wav"
                                                           atPath:nil
                                              withCompletionBlock:nil];
}

- (void)performFunction {
    // Create an output value (set to current input in case the function fails):
    float outputValue = (float)[self inputValue];
    
    // Perform the function:
    switch ([self function]) {
        default:
        case PKNumericPadFunctionNone:
            break;
        case PKNumericPadFunctionAdd:
            outputValue = (float)[self functionValue] + (float)[self inputValue];
            break;
        case PKNumericPadFunctionSubtract:
            outputValue = (float)[self functionValue] - (float)[self inputValue];
            break;
        case PKNumericPadFunctionMultiply:
            outputValue = (float)[self functionValue] * (float)[self inputValue];
            break;
        case PKNumericPadFunctionDivide:
            outputValue = (float)[self functionValue] / (float)[self inputValue];
            break;
    }
    
    // Set the output value:
    [self setInputValue:outputValue];
    
    // Clear the function:
    [self setupFunction:PKNumericPadFunctionNone];
}

#pragma mark - Event Methods

- (IBAction)buttonClearPressed:(id)sender {
    [[self labelValue] setText:@"0"];
    [[self buttonClear] setHidden:YES];
}

- (IBAction)buttonNumberPressed:(id)sender {
    int number = (int)[(UIButton *)sender tag];
    
    NSString *currentValue = nil;
    if ([[[self labelValue] text] intValue] != 0) {
        currentValue = [[self labelValue] text];
    }
    
    if (currentValue) {
        [[self labelValue] setText:[NSString stringWithFormat:@"%@%i", currentValue, number]];
    } else {
        [[self labelValue] setText:[NSString stringWithFormat:@"%i", number]];
    }
    
    if ([[[self labelValue] text] intValue] != 0) {
        [[self buttonClear] setHidden:NO];
    } else {
        [[self buttonClear] setHidden:YES];
    }
    
    // Play sound - just testing, sorry if this is not where you want the code!
    [[AFSoundManager sharedManager] startPlayingLocalFileWithName:@"AirPop.wav"
                                                           atPath:nil
                                              withCompletionBlock:nil];
}

- (IBAction)buttonConfirmPressed:(id)sender {
    // Check for a function:
    if ([self function] == PKNumericPadFunctionNone) {
        // No function therefore update the delegate:
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkNumericPadDidEnterValue:)]) {
            [[self delegate] pkNumericPadDidEnterValue:[self inputValue]];
        }
    } else {
        // There is a function therefore perform the function:
        [self performFunction];
    }
    
    
    // Play sound - just testing, sorry if this is not where you want the code!
    [[AFSoundManager sharedManager] startPlayingLocalFileWithName:@"GlassUp.wav"
                                                           atPath:nil
                                              withCompletionBlock:nil];
}

- (IBAction)buttonAddPressed:(id)sender {
    [self setupFunction:PKNumericPadFunctionAdd];
}

- (IBAction)buttonSubtractPressed:(id)sender {
    [self setupFunction:PKNumericPadFunctionSubtract];
}

- (IBAction)buttonMultiplyPressed:(id)sender {
    [self setupFunction:PKNumericPadFunctionMultiply];
}

- (IBAction)buttonDividePressed:(id)sender {
    [self setupFunction:PKNumericPadFunctionDivide];
}

#pragma mark -

@end