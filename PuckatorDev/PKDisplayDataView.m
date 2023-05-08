//
//  PKAddressView.m
//  PuckatorDev
//
//  Created by Luke Dixon on 10/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKDisplayDataView.h"
#import "UIView+FrameHelper.h"
#import "UIFont+Puckator.h"
#import "PKDisplayData.h"

@interface PKDisplayDataView ()

@property (strong, nonatomic) PKDisplayData *displayData;

@property (assign, nonatomic) CGFloat cellPadding;
@property (assign, nonatomic) CGFloat rowPadding;

@property (assign, nonatomic) UIEdgeInsets rightEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets leftEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets rightLabelEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets leftLabelEdgeInsets;
@property (assign, nonatomic) UIColor *separatorColor;

@property (strong, nonatomic) UIColor *backgroundLeft;
@property (strong, nonatomic) UIColor *backgroundRight;
@property (strong, nonatomic) UIColor *foregroundLeft;
@property (strong, nonatomic) UIColor *foregroundRight;

@end

@implementation PKDisplayDataView

#pragma mark - Constructor Methods

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setRightEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self setLeftEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self setRightLabelEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [self setLeftLabelEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [self setSeparatorColor:nil];
    }
    return self;
}

+ (instancetype)createWithDisplayData:(PKDisplayData *)displayData
                               origin:(CGPoint)origin
                                width:(CGFloat)width
                               height:(CGFloat)height
                       leftEdgeInsets:(UIEdgeInsets)leftEdgeInsets
                      rightEdgeInsets:(UIEdgeInsets)rightEdgeInsets
                  leftLabelEdgeInsets:(UIEdgeInsets)leftLabelEdgeInsets
                 rightLabelEdgeInsets:(UIEdgeInsets)rightLabelEdgeInsets
                       backgroundLeft:(UIColor *)backgroundLeft
                      backgroundRight:(UIColor *)backgroundRight
                       foregroundLeft:(UIColor *)foregroundLeft
                      foregroundRight:(UIColor *)foregroundRight
                       seperatorColor:(UIColor *)seperatorColor {
    PKDisplayDataView *displayDataView = [[PKDisplayDataView alloc] initWithFrame:CGRectMake(origin.x,
                                                                                             origin.y,
                                                                                             width,
                                                                                             height)];
    [displayDataView setLeftEdgeInsets:leftEdgeInsets];
    [displayDataView setRightEdgeInsets:rightEdgeInsets];
    [displayDataView setLeftLabelEdgeInsets:leftLabelEdgeInsets];
    [displayDataView setRightLabelEdgeInsets:rightLabelEdgeInsets];
    [displayDataView setBackgroundLeft:backgroundLeft];
    [displayDataView setBackgroundRight:backgroundRight];
    [displayDataView setForegroundLeft:foregroundLeft];
    [displayDataView setForegroundRight:foregroundRight];
    [displayDataView setSeparatorColor:seperatorColor];
    [displayDataView setDisplayData:displayData];
    
    if ([displayData backgroudColor]) {
        [displayDataView setBackgroundRight:[displayData backgroudColor]];
        [displayDataView setForegroundRight:[displayData foregroundColor]];
    }
    
    [displayDataView setupUI];
    return displayDataView;
}

#pragma mark -

- (UIView *)createContainerWithData:(NSArray *)data width:(CGFloat)width {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    
    // Let the title label take up 25% of the container,
    // while the data label should take up 75%:
    CGFloat titleWidth = width * 0.35f;
    CGFloat dataWidth = width * 0.65f;
    int labelHeight = 30;
    
    BOOL displaySeparator = ([self separatorColor] != nil);
    int separatorHeight = displaySeparator ? 1 : 0;
    
    // Setup the labels and display the data:
    __block int currentY = 0;
    [data enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        // SEPARATOR:
        if (displaySeparator) {
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                             currentY,
                                                                             [container bounds].size.width,
                                                                             separatorHeight)];
            [separatorView setBackgroundColor:[self separatorColor]];
            [container addSubview:separatorView];
            
            currentY += [separatorView bounds].size.height;
        }
        
        // LEFT:
        UIView *viewLeft = [[UIView alloc] initWithFrame:CGRectMake([self leftEdgeInsets].left,
                                                                    currentY,
                                                                    titleWidth - ([self leftEdgeInsets].left + [self leftEdgeInsets].right),
                                                                    labelHeight - ([self leftEdgeInsets].top + [self leftEdgeInsets].bottom))];
        [viewLeft setBackgroundColor:[self backgroundLeft]];
        [container addSubview:viewLeft];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake([self leftLabelEdgeInsets].left,
                                                                        [self leftLabelEdgeInsets].top,
                                                                        [viewLeft bounds].size.width - ([self leftLabelEdgeInsets].left + [self leftLabelEdgeInsets].right),
                                                                        [viewLeft bounds].size.height - ([self leftLabelEdgeInsets].top + [self leftLabelEdgeInsets].bottom))];
        NSString *title = [data objectForKey:@"title"];
        if ([title length] != 0) {
            title = [NSString stringWithFormat:@"%@", title];
        }
        
        [labelTitle setText:title];
        [labelTitle setTextAlignment:NSTextAlignmentRight];
        [labelTitle setFont:[UIFont puckatorFontBoldWithSize:14.f]];
        [labelTitle setMinimumScaleFactor:0.25f];
        [labelTitle setAdjustsFontSizeToFitWidth:YES];
        [labelTitle setBackgroundColor:[UIColor clearColor]];
        
        if ([self foregroundLeft]) {
            [labelTitle setTextColor:[self foregroundLeft]];
        }
        
        [viewLeft addSubview:labelTitle];
        
        // RIGHT:
        UIView *viewRight = [[UIView alloc] initWithFrame:CGRectMake([viewLeft width] + [self rightEdgeInsets].left,
                                                                     currentY,
                                                                     dataWidth - ([self rightEdgeInsets].left + [self rightEdgeInsets].right),
                                                                     labelHeight - ([self rightEdgeInsets].top + [self rightEdgeInsets].bottom))];
        [viewRight setBackgroundColor:[self backgroundRight]];
        [container addSubview:viewRight];
        
        UILabel *labelData = [[UILabel alloc] initWithFrame:CGRectMake([self rightLabelEdgeInsets].left,
                                                                       [self rightLabelEdgeInsets].top,
                                                                       [viewRight bounds].size.width - ([self rightLabelEdgeInsets].left + [self rightLabelEdgeInsets].right),
                                                                       [viewRight bounds].size.height - ([self rightLabelEdgeInsets].top + [self rightLabelEdgeInsets].bottom))];
        [labelData setText:[data objectForKey:@"data"]];
        [labelData setTextAlignment:NSTextAlignmentLeft];
        [labelData setFont:[UIFont puckatorFontStandardWithSize:14.f]];
        [labelData setMinimumScaleFactor:0.25f];
        [labelData setAdjustsFontSizeToFitWidth:YES];
        [labelData setBackgroundColor:[self backgroundRight]];
        
        if ([self foregroundRight]) {
            [labelData setTextColor:[self foregroundRight]];
        }
        
        [viewRight addSubview:labelData];
        
        if ([[data objectForKey:@"foregroundRight"] isKindOfClass:[UIColor class]]) {
            [labelData setTextColor:[data objectForKey:@"foregroundRight"]];
        }
        
        if ([[data objectForKey:@"backgroundRight"] isKindOfClass:[UIColor class]]) {
            [labelData setBackgroundColor:[data objectForKey:@"backgroundRight"]];
        }
        
        currentY += [viewLeft bounds].size.height;
    }];
    
    // SEPARATOR:
    if (displaySeparator) {
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                         currentY,
                                                                         [container bounds].size.width,
                                                                         separatorHeight)];
        [separatorView setBackgroundColor:[self separatorColor]];
        [container addSubview:separatorView];
        
        currentY += [separatorView bounds].size.height;
    }
    
    // Update the container frame:
    [container setHeight:currentY];
    
    return container;
}

- (void)setupUI {
    CGFloat containerWidth = [[self displayData] widthPerSectionForWidth:[self bounds].size.width];
    
    __block CGFloat currentX = 0.f;
    [[[self displayData] sections] enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger idx, BOOL *stop) {
        UIView *containerView = [self createContainerWithData:section width:containerWidth];
        [containerView setX:currentX];
        [self addSubview:containerView];
        currentX += [containerView width];
        
        if ([containerView height] > [self height]) {
            [self setHeight:[containerView height]];
        }
    }];
}

@end
