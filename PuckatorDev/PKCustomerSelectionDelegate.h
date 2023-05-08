//
//  PKCustomerSelectionDelegate.h
//  PuckatorDev
//
//  Created by Luke Dixon on 17/03/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#ifndef PuckatorDev_PKCustomerSelectionDelegate_h
#define PuckatorDev_PKCustomerSelectionDelegate_h

@class PKCustomer;
@class PKBasket;

@protocol PKCustomerSelectionDelegate<NSObject>

@required

- (void)pkCustomerSelectionDelegateSelectedCustomer:(PKCustomer *)customer andCreatedBasket:(PKBasket *)basket;
- (void)pkCustomerSelectionDelegateSelectedCustomer:(PKCustomer *)customer andCurrency:(PKCurrency *)currency;

@end

#endif
