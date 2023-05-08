//
//  PFFullProductCell.m
//  PuckatorDev
//
//  Created by Luke Dixon on 16/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKProductCellLarge.h"
#import "UIImageView+ImageRenderingMode.h"
#import "UIColor+Puckator.h"
#import "UIButton+AllStates.h"
#import "PKRankIndicator.h"
#import "XHRealTimeBlur.h"
#import "UIScrollView+Extended.h"
#import "UIView+Extended.h"
#import "UIFont+Puckator.h"
#import "PKProductHistoryView.h"
#import "PKProductHistoryGraph.h"
#import "PKImage+Operations.h"
#import "PKProduct+Operations.h"
#import "PKProductPrice.h"
#import "PKProductPrice+Operations.h"
#import "PKProductPricesView.h"
#import "UIView+FrameHelper.h"
#import "UIImageView+ImageRenderingMode.h"
#import "PKProductImageGallery.h"
#import "UIImage+animatedGIF.h"
#import "PKCustomersViewController.h"
#import "PKBasket.h"
#import "PKBasket+Operations.h"
#import "PKBasketItem+Operations.h"
#import "PKBasketItem+UI.h"
#import "PKDisplayDataContainer.h"
#import "UIView+Extended.h"
#import <SoundManager/SoundManager.h>

#define kHistoryCellHeight  32

@interface PKProductCellLarge ()

// UI properties:
@property (weak, nonatomic) IBOutlet UIButton *buttonHistoryEDC;
@property (weak, nonatomic) IBOutlet PKQuantityView *quantityView;
@property (weak, nonatomic) IBOutlet PKRankIndicator *viewRankSellerIcon;
@property (weak, nonatomic) IBOutlet PKRankIndicator *viewRankGrossingIcon;
@property (weak, nonatomic) IBOutlet UIButton *buttonSounds;
@property (weak, nonatomic) IBOutlet UILabel *labelRankSeller;
@property (weak, nonatomic) IBOutlet UILabel *labelRankGrossing;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlImages;
@property (weak, nonatomic) IBOutlet UIView *viewInfoContainer;
@property (weak, nonatomic) IBOutlet UIView *viewQuantityContainer;
@property (weak, nonatomic) IBOutlet UIView *viewQuickQuantityContainer;
@property (weak, nonatomic) IBOutlet UITextField *textFieldQuantity;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewArrow;
@property (weak, nonatomic) IBOutlet UIButton *buttonPhotos;
@property (weak, nonatomic) IBOutlet UIButton *buttonDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonHistory;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImages;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderAmount;
@property (weak, nonatomic) IBOutlet PKDisplayDataContainer *displayDataContainer;
@property (strong, nonatomic) PKProductPricesView *productPricesView;
@property (strong, nonatomic) PKProductImageGallery *productImageGallery;
@property (strong, nonatomic) UITapGestureRecognizer *imageTapGestureRecognizer;

@property (weak, nonatomic) PKProduct *product;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *galleryImages;

@property (strong, nonatomic) UITextView *textViewDescription;
@property (strong, nonatomic) PKProductHistoryView *productHistoryView;

// Pricing:
@property (strong, nonatomic) NSNumber *price;

@end

@implementation PKProductCellLarge

- (void)awakeFromNib {
    // Initialization code:
    [[self contentView] setFrame:[self bounds]];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self setupUI];
}

#pragma mark - Private Methods

- (void)setupUI {
    // Set the image rendering button:
    [self setupSelectedButton:[self buttonPhotos]];
    
    // Round the quantity container views:
    [[[self viewQuantityContainer] layer] setCornerRadius:5];
    [[[self viewQuickQuantityContainer] layer] setCornerRadius:5];
    [[[self textFieldQuantity] layer] setCornerRadius:5];
    
    // Add a border to info view container:
    [[[self viewInfoContainer] layer] setBorderWidth:1];
    [[[self viewInfoContainer] layer] setBorderColor:[[UIColor puckatorBorderColor] CGColor]];
    
    [[self labelOrderAmount] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelOrderAmountTapped:)]];
    [[self labelOrderAmount] setUserInteractionEnabled:YES];
    
    [[self buttonDescription] setTitleForAllStates:NSLocalizedString(@"Description", @"Displayed on the large product view")];
    [[self buttonHistory] setTitleForAllStates:NSLocalizedString(@"History", @"Displayed on the large product view")];
    [[self buttonHistoryEDC] setTitleForAllStates:NSLocalizedString(@"History EDC", @"Displayed on the large product view")];
    [[self buttonPhotos] setTitleForAllStates:NSLocalizedString(@"Photos", @"Displayed on the large product view")];
}

- (void)labelOrderAmountTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    [[[self viewController] tabBarController] setSelectedIndex:2];
}

- (void)centerArrorWithButton:(UIButton *)button {
    [UIView animateWithDuration:0.25f animations:^{
        [[self imageViewArrow] setCenter:CGPointMake([button center].x, [[self imageViewArrow] center].y)];
    } completion:^(BOOL finished) {
    }];
}

- (void)setupSelectedButton:(UIButton *)selectedButton {
    // Remove the selected theme from all buttons:
    [[self buttonPhotos] setTitleAndImageColorForAllStates:[UIColor puckatorUnselectedButtonColor]];
    [[self buttonDescription] setTitleAndImageColorForAllStates:[UIColor puckatorUnselectedButtonColor]];
    [[self buttonHistory] setTitleAndImageColorForAllStates:[UIColor puckatorUnselectedButtonColor]];
    [[self buttonHistoryEDC] setTitleAndImageColorForAllStates:[UIColor puckatorUnselectedButtonColor]];
    
    [selectedButton setTitleAndImageColorForAllStates:[UIColor puckatorSelectedButtonColor]];
}

- (void)updateOrderAmountUI:(PKBasketItem *)basketItem {
    [super updateOrderAmountUI:basketItem];
}

#pragma mark - Public Methods

- (void)setupWithProduct:(PKProduct *)product {
    [self setupWithProduct:product image:nil];
}

- (void)setupWithProduct:(PKProduct *)product image:(UIImage *)image {
    // Stop all sounds:
    [[SoundManager sharedManager] stopAllSounds];
    
    [self setProduct:product];
    
    [[self quantityView] setProduct:[self product] andDelegate:self];
    [[self labelTitle] setNumberOfLines:0];
    [[self labelTitle] setAttributedText:[product attributedTitleIncludeModel:YES includeCategories:YES]];
    
    // Update the rank icons:
    [[self viewRankSellerIcon] setRankValue:[[product position] intValue]];
    [[self viewRankGrossingIcon] setRankValue:[[product valuePosition] intValue]];
    
    // Update the rank labels:
    [[self labelRankSeller] setText:[[self product] topSellerTitle]];
    [[self labelRankGrossing] setText:[[self product] topGrossingTitle]];
    
    // Display the item data:
    [[self displayDataContainer] updateDataDisplayItems:@[[[self product] displayData]]];
    [[self displayDataContainer] setUserInteractionEnabled:YES];
    [[self displayDataContainer] setContentOffset:CGPointZero animated:NO];
    
    // Add the quick quantity container:
    if (![self productPricesView]) {
        [self setProductPricesView:[PKProductPricesView createWithProduct:[self product] delegate:self frame:[[self viewQuickQuantityContainer] bounds]]];
        [[self viewQuickQuantityContainer] addSubview:[self productPricesView]];
    } else {
        [[self productPricesView] updateProduct:[self product]];
    }
    
    [self updateOrderAmountUI:nil];
    
    // Display the photos by default:
    [self loadProductImages:product];
    
    // Display the sounds button:
    [[self buttonSounds] setHidden:[[self product] soundFilenames] == 0];
}

#pragma mark - Sound Methods

- (void)playSoundNamed:(NSString *)soundName {
    [[SoundManager sharedManager] stopAllSounds];
    
    Sound *sound = [Sound soundNamed:soundName];
    if (sound) {
        [sound play];
    }
}

#pragma mark - Event Methods

- (IBAction)buttonSoundsPressed:(id)sender {
    __weak PKProductCellLarge *weakSelf = self;
    NSArray<NSString *> *soundFilenames = [[self product] soundFilenames];
    if ([soundFilenames count] == 1) {
        // Just play the sound:
        [self playSoundNamed:[soundFilenames firstObject]];
    } else if ([soundFilenames count] > 1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        [soundFilenames enumerateObjectsUsingBlock:^(NSString * _Nonnull soundFilename, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([soundFilename length] != 0) {
                NSString *cleanFilename = [[self product] cleanSoundFilename:soundFilename];
                UIAlertAction *action = [UIAlertAction actionWithTitle:cleanFilename style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf playSoundNamed:soundFilename];
                }];
                [alertController addAction:action];
            }
        }];
        
        [[alertController popoverPresentationController] setSourceView:self];
        [[alertController popoverPresentationController] setSourceRect:[[self buttonSounds] frame]];
        [[self viewController] presentViewController:alertController animated:YES completion:^{
            
        }];
    }
}

- (void)imageViewTapped:(UITapGestureRecognizer *)tapGesture {
    if ([[self galleryImages] count] != 0) {
        if (![self productImageGallery]) {
            [self setProductImageGallery:[PKProductImageGallery createWithDelegate:self]];
        }
        [[self productImageGallery] displayImages:[self galleryImages] imageIndex:[[self scrollViewImages] currentPage] onView:self];
    }
}

- (IBAction)buttonPhotosPressed:(id)sender {
    [self displayPhotos];
}

- (IBAction)buttonDescriptionPressed:(id)sender {
    [self displayDescription];
}

- (IBAction)buttonHistoryPressed:(id)sender {
    [self displayHistory];
}

- (IBAction)buttonHistoryEDCPressed:(id)sender {
    [self displayHistoryEDC];
}

- (IBAction)pageControlValueChanged:(id)sender {
    [self scrollViewImages];
    
    if ([[self pageControlImages] currentPage] < [[self scrollViewImages] currentPage]) {
        [[self pageControlImages] setEnabled:NO];
        [[self scrollViewImages] prevPageAnimated:NO];
    } else if ([[self pageControlImages] currentPage] > [[self scrollViewImages] currentPage]) {
        [[self pageControlImages] setEnabled:NO];
        [[self scrollViewImages] nextPageAnimated:NO];
    }
}

#pragma mark - PKProductImageGalleryDelegate Methods

- (void)pkProductImageGallery:(PKProductImageGallery *)productImageGallery willCloseAtIndex:(int)index {
    [[self scrollViewImages] setPage:index animated:NO];
    [self setupPageNumber];
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
    // Return the view that you want to zoom
    //return [[[self scrollViewImages] subviews] firstObject];
    //return [[[self scrollViewImages] subviews] objectAtIndex:[[self scrollViewImages] currentPage]];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scale != 1.0f) {
        [scrollView setPagingEnabled:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == [self scrollViewImages]) {
        [self setupPageNumber];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate && scrollView == [self scrollViewImages]) {
        [self setupPageNumber];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == [self scrollViewImages]) {
        [[self pageControlImages] setEnabled:YES];
    }
}

- (void)setupPageNumber {
    [[self pageControlImages] setCurrentPage:[[self scrollViewImages] currentPage]];
    [[self pageControlImages] setEnabled:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self presentKeyPadFromView:textField];
    return NO;
}

#pragma mark - PKQuantityDelegate Methods

- (void)pkQuantityView:(PKQuantityView *)quantityView addedBasketItem:(PKBasketItem *)basketItem {
    [self updateOrderAmountUI:basketItem];
}

#pragma mark - PKProductPriceViewDelegate Methods

- (void)pkProductPriceView:(PKProductPriceView *)productPriceView wasTappedWithProductPrice:(PKProductPrice *)productPrice {
    [[self quantityView] updateWithProductPrice:productPrice];
}

- (void)pkProductPriceView:(PKProductPriceView *)productPriceView wasTappedWithPrice:(NSNumber *)price quantity:(NSNumber *)quantity {
    [[self quantityView] updatePrice:price quantity:quantity];
}

#pragma mark - Display Info Methods

- (void)hideDisplayViews {
    // Image views:
    [[self pageControlImages] setHidden:YES];
    [[self scrollViewImages] setHidden:YES];
    
    // Description views:
    [[self textViewDescription] setHidden:YES];
    
    // History views:
    [[self productHistoryView] setHidden:YES];
}

- (void)loadProductImages:(PKProduct *)product {
    // Setup the image array:
    if (![self images]) {
        [self setImages:[NSMutableArray array]];
    }
    
    if (![self galleryImages]) {
        [self setGalleryImages:[NSMutableArray array]];
    }
    
    [[self images] removeAllObjects];
    [[self galleryImages] removeAllObjects];
    
    // Load the product images in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (PKImage *productImage in [[self product] sortedImages]) {
            UIImage *image = [productImage image];
            if (image) {
                [[self images] addObject:image];
                
                if (productImage) {
                    [[self galleryImages] addObject:productImage];
                }
            } else {
                NSLog(@"[%@] - Image missing: %@", [self class], [productImage name]);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayPhotos];
        });
    });
}

- (void)displayPhotosAll:(BOOL)all {
    [self centerArrorWithButton:[self buttonPhotos]];
    [self setupSelectedButton:[self buttonPhotos]];
    
    // Hide the other display views:
    [self hideDisplayViews];
    
    [[self scrollViewImages] setHidden:NO];
    [[self scrollViewImages] removeAllSubviews];
    
    // Setup the image tap gesture:
    if (![self imageTapGestureRecognizer]) {
        [self setImageTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)]];
        [[self scrollViewImages] addGestureRecognizer:[self imageTapGestureRecognizer]];
    }
    
    // Display the images:
    if (!all) {
        int idx = 0;
        UIImage *image = [[self images] firstObject];
        if (image) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
            
            if ([image mimeType] == UIImageMimeTypeGIF) {
                [imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:[image imageUrl]]];
            } else {
                [imageView setImage:image];
            }
            
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            [imageView setClipsToBounds:YES];
            
            [imageView setFrame:[[self scrollViewImages] bounds]];
            [imageView setCenter:CGPointMake(([[self scrollViewImages] bounds].size.width * idx) +
                                             ([[self scrollViewImages] bounds].size.width * 0.5f), [imageView center].y)];
            [[self scrollViewImages] addSubview:imageView];
        }
    } else {
        [[self images] enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];

            if ([image mimeType] == UIImageMimeTypeGIF) {
                [imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:[image imageUrl]]];
            } else {
                [imageView setImage:image];
            }

            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            [imageView setClipsToBounds:YES];

            [imageView setFrame:[[self scrollViewImages] bounds]];
            [imageView setCenter:CGPointMake(([[self scrollViewImages] bounds].size.width * idx) +
                                             ([[self scrollViewImages] bounds].size.width * 0.5f), [imageView center].y)];
            [[self scrollViewImages] addSubview:imageView];
        }];
    }
    
    
    
    [[self scrollViewImages] setDelegate:self];
    [[self scrollViewImages] setContentSize:CGSizeMake([[self scrollViewImages] bounds].size.width * [[self images] count], 0)];
    [[self scrollViewImages] setContentOffset:CGPointZero animated:NO];
    [[self scrollViewImages] setPagingEnabled:YES];
    
    // Setup the page control:
    [[self pageControlImages] setNumberOfPages:[[self images] count]];
    if ([[self pageControlImages] numberOfPages] <= 1) {
        [[self pageControlImages] setHidden:YES];
    } else {
        [[self pageControlImages] setHidden:NO];
        [[self pageControlImages] setCurrentPage:0];
    }
}

- (void)displayPhotos {
    [self displayPhotosAll:YES];
}

- (void)displayDescription {
    [self centerArrorWithButton:[self buttonDescription]];
    [self setupSelectedButton:[self buttonDescription]];
    
    [self hideDisplayViews];
    
    // Setup the UITextView for displaying descriptions if required:
    if (![self textViewDescription]) {
        [self setTextViewDescription:[[UITextView alloc] initWithFrame:[[self viewInfoContainer] bounds]]];
        [[self viewInfoContainer] addSubview:[self textViewDescription]];
        [[self textViewDescription] setTextContainerInset:UIEdgeInsetsMake(10, 10, 10, 10)];
        [[self textViewDescription] setEditable:NO];
        [[self textViewDescription] setSelectable:NO];
    }
    
    [[self textViewDescription] setHidden:NO];
    
    NSDictionary *attributesHeader = @{NSForegroundColorAttributeName: [UIColor puckatorPrimaryColor],
                                       NSFontAttributeName: [UIFont puckatorDescriptionHeader]};
    NSDictionary *attributesBold = @{NSForegroundColorAttributeName: [UIColor puckatorPrimaryColor],
                                     NSFontAttributeName: [UIFont puckatorDescriptionBold]};
    NSDictionary *attributesStandard = @{NSForegroundColorAttributeName: [UIColor puckatorPrimaryColor],
                                         NSFontAttributeName: [UIFont puckatorDescriptionStandard]};
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] init];
    if ([[[self product] material] length] != 0 || [[[self product] dimension] length]) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"Product Information", nil)] attributes:attributesHeader]];
        
        if ([[[self product] material] length] != 0) {
            [description appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", NSLocalizedString(@"Material", nil)] attributes:attributesBold]];
            [description appendAttributedString:[[NSAttributedString alloc] initWithString:[[self product] material] attributes:attributesStandard]];
            [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }

        if ([[[self product] dimension] length]) {
            [description appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", NSLocalizedString(@"Dimensions", nil)] attributes:attributesBold]];
            [description appendAttributedString:[[NSAttributedString alloc] initWithString:[[self product] dimension] attributes:attributesStandard]];
        }
        
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    // Add the description:
    if ([[[self product] descText] length] != 0) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n", NSLocalizedString(@"Description", nil)] attributes:attributesHeader]];
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:[[self product] descText] attributes:attributesStandard]];
    }
    
    if ([description length] != 0) {
        [[self textViewDescription] setAttributedText:description];
    } else {
        [[self textViewDescription] setAttributedText:nil];
    }
}

- (void)displayHistory {
    [self centerArrorWithButton:[self buttonHistory]];
    [self setupSelectedButton:[self buttonHistory]];

    [self hideDisplayViews];
    
    // Setup the PKProductHistoryView if required:
    if (![self productHistoryView]) {
        [self setProductHistoryView:[PKProductHistoryView createWithProduct:[self product] frame:[[self viewInfoContainer] bounds]]];
        [[self viewInfoContainer] addSubview:[self productHistoryView]];
    }
    
    [[self productHistoryView] updateWithProduct:[self product] warehouse:PKProductWarehouseUK];
    
    [[self productHistoryView] setHidden:NO];
}

- (void)displayHistoryEDC {
    [self centerArrorWithButton:[self buttonHistoryEDC]];
    [self setupSelectedButton:[self buttonHistoryEDC]];

    [self hideDisplayViews];
    
    // Setup the PKProductHistoryView if required:
    if (![self productHistoryView]) {
        [self setProductHistoryView:[PKProductHistoryView createWithProduct:[self product] frame:[[self viewInfoContainer] bounds]]];
        [[self viewInfoContainer] addSubview:[self productHistoryView]];
    }
    
    [[self productHistoryView] updateWithProduct:[self product] warehouse:PKProductWarehouseEDC];
    
    [[self productHistoryView] setHidden:NO];
}

#pragma mark -

@end
