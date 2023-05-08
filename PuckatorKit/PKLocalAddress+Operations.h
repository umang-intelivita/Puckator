//
//  PKLocalAddress+Operations.h
//  Puckator
//
//  Created by Luke Dixon on 05/08/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKLocalAddress.h"

@class PKAddress;

@interface PKLocalAddress (Operations)

+ (PKLocalAddress *)createWithCustomerId:(NSString *)customerId
                             companyName:(NSString *)companyName
                             contactName:(NSString *)contactName
                                 lineOne:(NSString *)lineOne
                                 lineTwo:(NSString *)lineTwo
                                    city:(NSString *)city
                                   state:(NSString *)state
                                 country:(NSString *)country
                                postcode:(NSString *)postcode
                                     vat:(NSString *)vat
                                     iso:(NSString *)iso
                                     idx:(NSNumber *)idx
                                 context:(NSManagedObjectContext *)localContext;
- (PKAddress *)toAddress;

@end