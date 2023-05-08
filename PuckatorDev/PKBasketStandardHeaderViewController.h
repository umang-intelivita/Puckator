//
//  PKBasketStandardHeaderViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 02/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKBasket;

@class PKBasketStandardHeaderViewController;
@protocol PKBasketStandardDelegate <NSObject>
@optional
- (void) pkBasketStandardHeaderViewController:(PKBasketStandardHeaderViewController*)headerView didPressSearchButton:(BOOL)didPressSearch;
- (void) pkBasketStandardHeaderViewController:(PKBasketStandardHeaderViewController *)headerView didInteractWithElementName:(NSString*)elementName;
- (id) pkBasketStandardHeaderViewController:(PKBasketStandardHeaderViewController *)headerView requestedBasketObject:(BOOL)didRequestBasket;
@end

@interface PKBasketStandardHeaderViewController : UIViewController

@property (nonatomic, weak) id<PKBasketStandardDelegate> delegate;

- (id)elementForName:(NSString *)name;

@end
