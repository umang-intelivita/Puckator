//
//  FSCollectionViewFlowLayout.m
//  PuckatorDev
//
//  Created by Luke Dixon on 15/12/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import "PKCollectionViewFlowLayout.h"

@implementation PKCollectionViewFlowLayout

- (void)awakeFromNib {
    self.itemSize = CGSizeMake(250.0, 250.0);
    self.minimumInteritemSpacing = 10.0;
    self.minimumLineSpacing = 10.0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    [super awakeFromNib];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat proposedContentOffsetCenterX = proposedContentOffset.x + self.collectionView.bounds.size.width * 0.5f;
    CGRect proposedRect = self.collectionView.bounds;
    
    UICollectionViewLayoutAttributes* candidateAttributes;
    for (UICollectionViewLayoutAttributes* attributes in [self layoutAttributesForElementsInRect:proposedRect]) {
        // == Skip comparison with non-cell items (headers and footers) == //
        if (attributes.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }
        
        // == First time in the loop == //
        if (!candidateAttributes) {
            candidateAttributes = attributes;
            continue;
        }
        
        if (fabsf(attributes.center.x - proposedContentOffsetCenterX) < fabsf(candidateAttributes.center.x - proposedContentOffsetCenterX)) {
            candidateAttributes = attributes;
        }
    }
    
    return CGPointMake(candidateAttributes.center.x - self.collectionView.bounds.size.width * 0.5f, proposedContentOffset.y);
}

@end
