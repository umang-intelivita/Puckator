//
//  PKCustomerAnnotation.h
//  Puckator
//
//  Created by Luke Dixon on 30/06/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PKCustomer;

@interface PKCustomerAnnotation : NSObject <MKAnnotation>

@property (weak, readonly) PKCustomer *customer;

+ (instancetype)createWithCustomer:(PKCustomer *)customer;

@end
