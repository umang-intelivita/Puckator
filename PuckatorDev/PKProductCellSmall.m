//
//  PKProductCellSmall.m
//  PuckatorDev
//
//  Created by Luke Dixon on 19/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKProductCellSmall.h"
#import "PKKeyPad.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"

@interface PKProductCellSmall ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewMain;
@property (weak, nonatomic) IBOutlet UILabel *labelProductCode;
@property (weak, nonatomic) PKProduct *product;
@property (strong, nonatomic) UIPopoverController *popoverController;

@end

@implementation PKProductCellSmall

- (void)awakeFromNib {
    // Initialization code
    [self setupView];
}

#pragma mark - Private Methods

- (void)setupView {
    [self setClipsToBounds:YES];
}

#pragma mark - PKNumericPad Methods

- (void)presentKeyPadFromView:(UIView *)view {
    if ([self popoverController]) {
        [[self popoverController] dismissPopoverAnimated:NO];
        [self setPopoverController:nil];
    }
    
    // Setup a PKNumericPad:
    PKKeyPad *numericPad = [PKKeyPad createWithProduct:[self product] delegate:self];
    
    // Setup a UIPopoverController:
    [self setPopoverController:[[UIPopoverController alloc] initWithContentViewController:numericPad]];
    [[self popoverController] presentPopoverFromRect:[view frame]
                                              inView:[view superview]
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
}

- (void)dismissNumericPad {
    if ([self popoverController]) {
        [[self popoverController] dismissPopoverAnimated:YES];
        [self setPopoverController:nil];
    }
}

#pragma mark - Public Methods

- (void)setupWithProduct:(PKProduct *)product {
    [self setupWithProduct:product image:nil];
}

- (void)setupWithProduct:(PKProduct *)product image:(UIImage *)image {
    [self setProduct:product];
    //[[self labelProductCode] setText:[product model]];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[product model]
                                                                                        attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:20] color:[UIColor puckatorProductTitle]]];
    //Ghanshyam Change
    if ([[self product] isNewStarProduct] || [[self product] isNewEDCProduct]) {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" ★" attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontBoldWithSize:16] color:[UIColor puckatorRankMid]]]];
    }
    
    [[self labelProductCode] setAttributedText:attributedString];
    
    [[self imageViewMain] setImage:[product thumb]];
    
    //[[product mainImage] setThumbAsyncToImageView:[self imageViewMain]];
    
//    if (image) {
//        [[self imageViewMain] setImage:image];
//    } else {
//        [[self imageViewMain] setImage:[product thumb]];
//    }
}

#pragma mark -

@end
