//
//  PKAddressAnnotation.m
//  Puckator
//
//  Created by Luke Dixon on 11/12/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import "PKAddressAnnotation.h"
#import "PKAddress.h"

@implementation PKAddressAnnotation

+ (instancetype)createWithAddress:(PKAddress *)address {
    PKAddressAnnotation *annotation = [[PKAddressAnnotation alloc] init];
    [annotation setAddress:address];
    [annotation setCoordinate:[address coordinate]];
    [annotation setTitle:[address companyName]];
    [annotation setSubtitle:[NSString stringWithFormat:@"%@, %@", [address lineOne], [address postcode]]];
    return annotation;
}

@end
