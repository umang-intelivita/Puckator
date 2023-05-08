//
//  PKAddressAnnotation.h
//  Puckator
//
//  Created by Luke Dixon on 11/12/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>

@class PKAddress;

@interface PKAddressAnnotation : MKPointAnnotation

@property PKAddress *address;

+ (instancetype)createWithAddress:(PKAddress *)address;

@end
