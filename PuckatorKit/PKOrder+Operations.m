//
//  PKOrder+Operations.m
//  Puckator
//
//  Created by Luke Dixon on 08/03/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import "PKOrder+Operations.h"
#import "PKAddress.h"

@implementation PKOrder (Operations)

- (PKAddress *)invoiceAddress {
    if ([[self addressBillingCountry] length] == 0) {
        return nil;
    }
    
    PKAddress *address = [PKAddress create];
    [address setObjectId:0];
    [address setIso:[self addressBillingISO]];
    [address setVat:[self vatNumber]];
    [address setCity:[self addressBillingCity]];
    [address setState:[self addressBillingState]];
    [address setCountry:[self addressBillingCountry]];
    [address setLineOne:[self addressBillingAddressLine1]];
    [address setLineTwo:[self addressBillingAddressLine2]];
    [address setPostcode:[self addressBillingPostcode]];
    [address setCompanyName:[self addressBillingCompanyName]];
    [address setContactName:[self addressBillingContactName]];
    return address;
}

- (PKAddress *)deliveryAddress {
    if ([[self addressDeliveryCountry] length] == 0) {
        return nil;
    }
    
    PKAddress *address = [PKAddress create];
    [address setObjectId:0];
    [address setIso:[self addressDeliveryISO]];
    [address setVat:[self vatNumber]];
    [address setCity:[self addressDeliveryCity]];
    [address setState:[self addressDeliveryState]];
    [address setCountry:[self addressDeliveryCountry]];
    [address setLineOne:[self addressDeliveryAddressLine1]];
    [address setLineTwo:[self addressDeliveryAddressLine2]];
    [address setPostcode:[self addressDeliveryPostcode]];
    [address setCompanyName:[self addressDeliveryCompanyName]];
    [address setContactName:[self addressDeliveryContactName]];
    return address;
}

@end
