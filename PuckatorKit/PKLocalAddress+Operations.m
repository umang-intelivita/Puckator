//
//  PKLocalAddress+Operations.m
//  Puckator
//
//  Created by Luke Dixon on 05/08/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKLocalAddress+Operations.h"
#import "PKAddress.h"

/*
 @property (assign, nonatomic) int objectId;
 @property (strong, nonatomic) NSString *companyName;
 @property (strong, nonatomic) NSString *contactName;
 @property (strong, nonatomic) NSString *vat;
 @property (strong, nonatomic) NSString *lineOne;
 @property (strong, nonatomic) NSString *lineTwo;
 @property (strong, nonatomic) NSString *city;
 @property (strong, nonatomic) NSString *state;
 @property (strong, nonatomic) NSString *postcode;
 @property (strong, nonatomic) NSString *country;
 @property (strong, nonatomic) NSString *iso;
 */

@implementation PKLocalAddress (Operations)

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
                                 context:(NSManagedObjectContext *)localContext {
    __block PKLocalAddress *address = nil;
    //[MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId == %@ AND idx == %@", customerId, idx];
        
        // Attempt to find and update the address first:
        address = [[PKLocalAddress MR_findAllWithPredicate:predicate inContext:localContext] firstObject];
        
        // If no address is found then create a new one:
        if (!address) {
            address = [PKLocalAddress MR_createEntityInContext:localContext];
        }
        
        [address setCustomerId:customerId];
        [address setCompanyName:companyName];
        [address setContactName:contactName];
        [address setLineOne:lineOne];
        [address setLineTwo:lineTwo];
        [address setCity:city];
        [address setState:state];
        [address setCountry:country];
        [address setPostcode:postcode];
        [address setVat:vat];
        [address setIso:iso];
        [address setIdx:idx];
    //}];
    
    return address;
}

- (PKAddress *)toAddress {
    PKAddress *address = [[PKAddress alloc] init];
    [address setObjectId:0];
    [address setCompanyName:[self companyName]];
    [address setContactName:[self contactName]];
    [address setVat:[self vat]];
    [address setLineOne:[self lineOne]];
    [address setLineTwo:[self lineTwo]];
    [address setCity:[self city]];
    [address setState:[self state]];
    [address setPostcode:[self postcode]];
    [address setCountry:[self country]];
    [address setIso:[self iso]];
    return address;
}

@end