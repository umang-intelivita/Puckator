//
//  PKRecentCustomer+Operations.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 18/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PuckatorKit.h"
#import "PKRecentCustomer.h"
@class PKCustomer;

@interface PKRecentCustomer (Operations)

+ (BOOL) addCustomer:(PKCustomer*)customer context:(NSManagedObjectContext*)context;
+ (BOOL) removeCustomer:(PKCustomer*)customer context:(NSManagedObjectContext*)context;
+ (void) clearCustomersIncludingPinned:(BOOL)deletedPinned context:(NSManagedObjectContext*)context;
+ (NSArray*) all;
- (BOOL) pin;
- (BOOL) unpin;
- (BOOL) togglePin;

@end
