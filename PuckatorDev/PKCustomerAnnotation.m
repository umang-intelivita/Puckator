//
//  PKCustomerAnnotation.m
//  Puckator
//
//  Created by Luke Dixon on 30/06/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import "PKCustomerAnnotation.h"
#import "PKCustomer.h"

@interface PKCustomerAnnotation ()

@property (weak) PKCustomer *customer;

@end

@implementation PKCustomerAnnotation

+ (instancetype)createWithCustomer:(PKCustomer *)customer {
    // Check the customer is valid:
    if (![customer isKindOfClass:[PKCustomer class]]) {
        return nil;
    }
    
    PKCustomerAnnotation *annotation = [[PKCustomerAnnotation alloc] init];
    [annotation setCustomer:customer];
    return annotation;
}

- (NSString *)title {
    return [[self customer] companyName];
}

- (NSString *)subtitle {
    return @"";
//    return NSLocalizedString(@"Tap for options...", nil);
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(53.38297, -1.4659);
}

@end
