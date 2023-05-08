//
//  PKSearchMiniProductAddViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 03/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKSearchMiniProductAddViewController.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import "PKBasketItem+UI.h"
#import "PKBasket+Operations.h"

@interface PKSearchMiniProductAddViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelProductTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelStockInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelImages;
@property (weak, nonatomic) IBOutlet UILabel *labelPriceMessage;
@property (weak, nonatomic) IBOutlet UITextView *textViewDesc;
@property (weak, nonatomic) IBOutlet PKQuantityView *viewQuantity;
@property (weak, nonatomic) IBOutlet UILabel *labelBasketAmount;
@property (strong, nonatomic) PKProductImageGallery *productImageGallery;

@end

@implementation PKSearchMiniProductAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:NSLocalizedString(@"Quick Add", nil)];
    
    // Add gesture to imageview
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGallery:)];
    [[self imageViewProduct] addGestureRecognizer:tapGestureRecognizer];
    [[self imageViewProduct] setUserInteractionEnabled:YES];
    
    // Load the product details
    [self loadProduct];
}

- (void)loadProduct {
    // Load title and product code
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] init];
    [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[[self product] title] attributes:@{NSFontAttributeName:[UIFont puckatorContentTitle], NSForegroundColorAttributeName: [UIColor darkTextColor]}]];
    [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", [[self product] model]] attributes:@{NSFontAttributeName:[UIFont puckatorContentTitle], NSForegroundColorAttributeName: [UIColor puckatorSubtitleColor]}]];
    [[self labelProductTitle] setAttributedText:attributedTitle];
    
    // Show desc
    [[self textViewDesc] setText:[[self product] descText]];
    
    // Make a number formatter
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    
    // Load stock
    
    if(![[[PKSession sharedInstance] currentFeedConfig].name isEqualToString:@"UK"]) {
        [[self labelStockInfo] setText:[NSString stringWithFormat:NSLocalizedString(@"There are %@ unit(s) in stock", @"Used to inform the user how many items are in stock for a product. E.g. 'There are 1,203 unit(s) in stock."), [numberFormatter stringFromNumber:[[self product] stockLevelEDC]]]];

    } else {
        [[self labelStockInfo] setText:[NSString stringWithFormat:NSLocalizedString(@"There are %@ unit(s) in stock", @"Used to inform the user how many items are in stock for a product. E.g. 'There are 1,203 unit(s) in stock."), [numberFormatter stringFromNumber:[[self product] stockLevel]]]];
    }
    // Load image
    [[self imageViewProduct] setImage:[[self product] image]];
    [[[self imageViewProduct] layer] setCornerRadius:10];
    [[self imageViewProduct] setClipsToBounds:YES];
    
    // Load qty view
    [[self viewQuantity] setProduct:[self product] andDelegate:self];

    // Load number of images
    int numberOfImages = (int)[[[self product] images] count];
    [[self labelImages] setText:[NSString stringWithFormat:NSLocalizedString(@"%d image(s)", @"Used to inform the user how many images a product has. E.g. '5 image(s)'"), numberOfImages]];
    
    if ([PKBasket sessionBasket]) {
        PKBasketItem *basketItem = [[PKBasket sessionBasket] basketItemForProduct:[self product] context:nil];
        [[self labelBasketAmount] setAttributedText:[basketItem orderAmountAttributedString]];
    }
}

- (void) showGallery:(id)sender {
    if (![self productImageGallery]) {
        [self setProductImageGallery:[PKProductImageGallery createWithDelegate:self]];
    }
    
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] firstObject];
    [[self productImageGallery] displayImages:[[self product] sortedImages] imageIndex:0 onView:mainWindow];
}

#pragma mark - Qty view delegate

-(void)pkQuantityView:(PKQuantityView *)quantityView addedBasketItem:(PKBasketItem *)basketItem {
    NSLog(@"Added to basket!");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Gallery Delegate

-(void)pkProductImageGallery:(PKProductImageGallery *)productImageGallery willCloseAtIndex:(int)index {
    NSLog(@"Gallery closed at index: %d", index);
}

@end
