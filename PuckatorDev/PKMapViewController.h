//
//  PKMapViewViewController.h
//  Puckator
//
//  Created by Luke Dixon on 30/06/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "FSBaseViewController.h"
#import "PKCustomerAnnotation.h"
#import "PKCustomerViewController.h"

@interface PKMapViewController : FSBaseViewController <MKMapViewDelegate>

+ (instancetype)createWithCustomers:(NSArray *)customers;

@end
