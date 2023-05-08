//
//  PKProductsLayout.m
//  PuckatorDev
//
//  Created by Luke Dixon on 20/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKProductsLayout.h"

#define kPadding   10

@implementation PKProductsLayout

- (instancetype)init {
    if (self = [super init]) {
        [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger pages = ceil(rect.origin.x / [[self collectionView] bounds].size.width);
    pages = (pages + 1);
    
    float overage = (pages * kPadding);
    
    //NSLog(@"Pages: %d", (int)pages);
    
    NSArray* arr = [super layoutAttributesForElementsInRect:CGRectMake(rect.origin.x - overage, rect.origin.y - overage, rect.size.width + (overage * 2), rect.size.height + (overage * 2))];
    for (UICollectionViewLayoutAttributes* atts in arr) {
        if (nil == atts.representedElementKind) {
            NSIndexPath* ip = atts.indexPath;
            atts.frame = [self layoutAttributesForItemAtIndexPath:ip].frame;
        }
    }
    return arr;
}

-(CGSize) collectionViewContentSize {
    NSInteger itemCount = [[self collectionView] numberOfItemsInSection:0];
    NSInteger pages = ceil(itemCount / 4.f);
    
    return CGSizeMake([[self collectionView] bounds].size.width * pages, 0);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* atts = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (indexPath.item == 0) // degenerate case 1, first item of section
        return atts;
    
    CGFloat prevMaxY = 0;
    CGFloat prevMinY = 0;
    
    if ([indexPath row] > 1) {
        NSIndexPath* ipPrev = [NSIndexPath indexPathForItem:indexPath.item-2 inSection:indexPath.section];
        
        if (ipPrev && [ipPrev isKindOfClass:[NSIndexPath class]]) {
            NSIndexPath* ipPrev = [NSIndexPath indexPathForItem:indexPath.item-2 inSection:indexPath.section];
            CGRect prevFrame = [self layoutAttributesForItemAtIndexPath:ipPrev].frame;
            
            prevMaxY = CGRectGetMaxX(prevFrame);
            prevMinY = CGRectGetMinX(prevFrame);
            
            if ([indexPath row] % 4 == 0 || ([indexPath row] - 1) % 4 == 0) {
                CGRect f = atts.frame;
                f.origin.x = prevMaxY;
                atts.frame = f;
                return atts;
            } else {
                prevMaxY += kPadding;
            }
        }
    }

    if (atts.frame.origin.x <= prevMinY) { // degenerate case 2, first item of line
        //rightPrev = fPrev.origin.x + fPrev.size.width;
        return atts;
    }
    
    CGRect f = atts.frame;
    f.origin.x = prevMaxY;
    atts.frame = f;
    return atts;
}

@end