//
//  ViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 07/11/2014.
//  Copyright (c) 2014 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL showProducts;

@end