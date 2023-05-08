//
//  PKProductImageGallery.m
//  PuckatorDev
//
//  Created by Luke Dixon on 13/02/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductImageGallery.h"
#import "FXBlurView.h"
#import "AppDelegate.h"
#import "PKImage+Operations.h"
#import "UIView+FrameHelper.h"
#import "UIView+Extended.h"
#import "UIScrollView+Extended.h"
#import "UIButton+AllStates.h"
#import "UIColor+RandomColor.h"
#import <NSDate+MK.h>

@interface PKProductImageGallery ()

@property (assign, nonatomic) int index;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) UIView *viewTinter;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) FXBlurView *blurView;
@property (strong, nonatomic) UIButton *buttonClose;

@end

@implementation PKProductImageGallery

#pragma mark - Constructor Methods

+ (instancetype)createWithDelegate:(id<PKProductImageGalleryDelegate>)delegate {
    PKProductImageGallery *productImageGallery = [[PKProductImageGallery alloc] init];
    [productImageGallery setDelegate:delegate];
    return productImageGallery;
}

#pragma mark - Private Methods

- (CGRect)bounds {
    return [[self scrollView] bounds];
}

- (void)setupImageViews {
    __block int index = 0;
    
    // Remove all the existing subview on the scrollview:
    [[self scrollView] removeAllSubviews];
    
    // Display the current images:
    [[self images] enumerateObjectsUsingBlock:^(id imageObj, NSUInteger idx, BOOL *stop) {
        UIImage *image = nil;
        if ([imageObj isKindOfClass:[PKImage class]]) {
//            NSLog(@"[%@] - Image %d: %@", [self class], (int)idx, [(PKImage *)imageObj name]);
            
            image = [(PKImage *)imageObj image];
            
            if (!CGSizeEqualToSize([image size], CGSizeZero)) {
                UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[self bounds]];
                [scrollView setDelegate:self];
                [scrollView setMinimumZoomScale:1.0f];
                [scrollView setMaximumZoomScale:2.0f];
                
                UIView *containerView = [[UIView alloc] initWithFrame:[self bounds]];
                [scrollView setX:index * [self bounds].size.width];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
                [imageView setCenter:CGPointMake([scrollView bounds].size.width * 0.5f,
                                                 [scrollView bounds].size.height * 0.5)];
                [imageView setBackgroundColor:[UIColor whiteColor]];
                
                if ([image mimeType] == UIImageMimeTypeGIF) {
                    [imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:[NSURL fileURLWithPath:[(PKImage *)imageObj pathForImage]]]];
                } else {
                    [imageView setImage:image];
                }
                
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [imageView setUserInteractionEnabled:YES];
                [containerView addSubview:imageView];
                [containerView setFrame:CGRectMake(0, 0, [scrollView bounds].size.width, [scrollView bounds].size.height)];
                [scrollView addSubview:containerView];
                [[self scrollView] addSubview:scrollView];
                
                PKImage *pkImage = (PKImage *)imageObj;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 600, 600, 60)];
                [label setNumberOfLines:0];
                
                
                
                //[label setCenter:CGPointMake(imageView.center.x, label.center.y)];
//                NSString *dateCreatedStr = [[pkImage dateCreated] mk_formattedStringUsingFormat:[NSDate mk_dateFormatYYYYMMDDDashed]];
//                NSString *dateModifiedStr = [[pkImage dateModified] mk_formattedStringUsingFormat:[NSDate mk_dateFormatYYYYMMDDDashed]];
                
                
                [label setText:[NSString stringWithFormat:@"%@\n(Created: %@ - Modified: %@)", [pkImage debugInfo], [[pkImage dateCreated] mk_formattedStringUsingFormat:@"dd-MM-yyyy hh:mm:ss"], [[pkImage dateModified] mk_formattedStringUsingFormat:@"dd-MM-yyyy hh:mm:ss"]]];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.35f]];
                [imageView addSubview:label];
                
                ++index;
            }
        }
    }];
    
    [[self scrollView] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)]];
    
    [[self scrollView] setContentSize:CGSizeMake([[self scrollView] bounds].size.width * index, 0)];
    
    if ([self index] != 0) {
        [[self scrollView] setPage:[self index] animated:NO];
    } else {
        [[self scrollView] setContentOffset:CGPointZero animated:NO];
    }
}

- (void)hide {
    // Update the delegate:
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(pkProductImageGallery:willCloseAtIndex:)]) {
        [[self delegate] pkProductImageGallery:self willCloseAtIndex:[[self scrollView] currentPage]];
    }
    
    // Animate:
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:0.25f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [[self blurView] setAlpha:0.0f];
        [[self viewTinter] setAlpha:0.0f];
        [[self scrollView] setY:[self bounds].size.height];
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];
    } completion:^(BOOL finished) {
        [[self scrollView] removeAllSubviews];
        
        [[self blurView] setUserInteractionEnabled:NO];
        [[self viewTinter] setUserInteractionEnabled:NO];
        [[self scrollView] setUserInteractionEnabled:NO];
    }];
}

- (void)displayOnView:(UIView *)view {
    if (!view) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIViewController *viewController = [[appDelegate window] rootViewController];
        view = [viewController view];
    } else {
        if ([view viewController] && [[view viewController] tabBarController]) {
            view = [[[view viewController] tabBarController] view];
        } else if ([view viewController] && [[view viewController] navigationController]) {
            view = [[[view viewController] navigationController] view];
        }
    }
    
    // Copy the bounds the tab bar view:
    if (![self viewTinter]) {
        [self setViewTinter:[[UIView alloc] initWithFrame:[view bounds]]];
        [[self viewTinter] setBackgroundColor:[UIColor blackColor]];
        [[self viewTinter] setAlpha:0.0f];
        [view addSubview:[self viewTinter]];
    }
    
    // Setup the blur view:
    if (![self blurView]) {
        [self setBlurView:[[FXBlurView alloc] initWithFrame:[view bounds]]];
        [[self blurView] setDynamic:NO];
        [[self blurView] setTintColor:[UIColor darkGrayColor]];
        [[self blurView] setAlpha:0.0f];
        [view addSubview:[self blurView]];
    }
    
    // Setup the scrollview:
    if (![self scrollView]) {
        [self setScrollView:[[UIScrollView alloc] initWithFrame:[view bounds]]];
        [[self scrollView] setPagingEnabled:YES];
        [[self scrollView] setDelegate:self];
        [view addSubview:[self scrollView]];
    }
    
    [[self blurView] setFrame:[view bounds]];
    [[self viewTinter] setFrame:[view bounds]];
    [[self scrollView] setFrame:[view bounds]];
    [[self scrollView] setY:[self bounds].size.height];
    
    [[self blurView] setUserInteractionEnabled:YES];
    [[self viewTinter] setUserInteractionEnabled:YES];
    [[self scrollView] setUserInteractionEnabled:YES];
    
    // Setup the close button:
    if (![self buttonClose]) {
        int buttonSize = 50;
        int padding = 10;
        [self setButtonClose:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[self buttonClose] setImageForAllStates:[UIImage imageNamed:@"icon_close.png"]];
        [[self buttonClose] setFrame:CGRectMake(padding, padding, buttonSize, buttonSize)];
        [[self buttonClose] addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [[self blurView] addSubview:[self buttonClose]];
    }
    
    if (![self pageControl]) {
        [self setPageControl:[[UIPageControl alloc] initWithFrame:CGRectMake(0,
                                                                             [[self blurView] frame].size.height - 40,
                                                                             [[self blurView] frame].size.width,
                                                                             40)]];
        [[self pageControl] addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [[self blurView] addSubview:[self pageControl]];
    }
    
    [self setupImageViews];
    [[self pageControl] setNumberOfPages:[[self images] count]];
    [[self pageControl] setCurrentPage:[self index]];
    
    if ([[self images] count] == 1) {
        [[self pageControl] setHidden:YES];
    } else {
        [[self pageControl] setHidden:NO];
    }
    
    // Animate:
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:0.25f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [[self blurView] setAlpha:1.0f];
        [[self viewTinter] setAlpha:0.5f];
        [[self scrollView] setY:0];
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Public Methods

- (void)displayImages:(NSArray *)images imageIndex:(int)imageIndex onView:(UIView *)view {
    [self setIndex:imageIndex];
    [self setImages:images];
    [self displayOnView:view];
}

- (void)displayImages:(NSArray *)images imageIndex:(int)imageIndex {
    [self setIndex:imageIndex];
    [self setImages:images];
    [self displayOnView:nil];
}

#pragma mark - Event Methods

- (void)imageViewTapped:(UITapGestureRecognizer *)tapGesture {
    [self hide];
}

- (void)pageControlValueChanged:(UIPageControl *)pageControl {
    [[self scrollView] setPage:(int)[pageControl currentPage] animated:NO];
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == [self scrollView]) {
        return nil;
    }
    return [[scrollView subviews] objectAtIndex:0];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == [self scrollView]) {
        if (!decelerate) {
            [self scrollViewSetupPage];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == [self scrollView]) {
        [self scrollViewSetupPage];
    }
}

- (void)scrollViewSetupPage {
    [self setIndex:[[self scrollView] currentPage]];
    [[self pageControl] setCurrentPage:[self index]];
    
    [[[self scrollView] subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = obj;
            [scrollView setZoomScale:1.0f];
        }
    }];
}

#pragma mark -

@end
