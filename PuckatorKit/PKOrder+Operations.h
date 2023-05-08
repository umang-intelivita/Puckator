//
//  PKOrder+Operations.h
//  Puckator
//
//  Created by Luke Dixon on 08/03/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import "PKOrder.h"

@class PKAddress;

@interface PKOrder (Operations)

- (PKAddress *)invoiceAddress;
- (PKAddress *)deliveryAddress;

@end
