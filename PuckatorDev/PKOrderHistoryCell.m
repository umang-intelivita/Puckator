//
//  PKOrderHistoryCell.m
//  PuckatorDev
//
//  Created by Luke Dixon on 01/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKOrderHistoryCell.h"
#import "PKInvoice.h"
#import "PKOrder.h"
#import "PKBasket+Operations.h"
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"

#import <MKFoundationKit/MKFoundationKit.h>

@interface PKOrderHistoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelOrderNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderAmount;
@property (weak, nonatomic) IBOutlet UIView *viewOrderStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelCompany;

@end

@implementation PKOrderHistoryCell

- (void)setupWithInvoice:(PKInvoice *)invoice {
    [[self labelOrderAmount] setText:[invoice formattedNetTotal]];
    [[self labelOrderDate] setText:[invoice formattedInvoiceDate]];
    [[self labelOrderNumber] setNumberOfLines:0];
    [[self labelOrderNumber] setAttributedText:[invoice formattedOrderAndCustomerNumber]];
    [[self labelOrderStatus] setText:[invoice statusTitle]];
    [[self labelOrderStatus] setTextColor:[invoice colorForStatus]];
    [[self viewOrderStatus] setBackgroundColor:[[self labelOrderStatus] textColor]];
    [self setupCompanyInfoWithCompanyName:nil orSageId:[invoice sageId] andContactName:[invoice contactNameDefault]];
}

- (void)setupCompanyInfoWithCompanyName:(NSString *)companyName orSageId:(NSString *)sageId andContactName:(NSString *)contactName {
    // Display company info:
    if ([companyName length] == 0 && [sageId length] != 0) {
        PKCustomer *customer = [PKCustomer findCustomerWithSageId:sageId];
        if (customer) {
            companyName = [customer companyName];
        }
    }
    
    // Limit the strings and display them:
    int lengthLimit = 40;
    int lengthLimitContact =  60;    
    companyName = [companyName limitToLength:lengthLimit truncate:YES];
    contactName = [contactName limitToLength:lengthLimitContact truncate:YES];
    
    if ([sageId length] != 0) {
        sageId = [NSString stringWithFormat:@" (%@)", sageId];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    if ([companyName length] != 0) {
        NSAttributedString *companyNameAttributedString = [[NSAttributedString alloc] initWithString:companyName
                                                                                          attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontMediumWithSize:16] color:[UIColor puckatorDarkGray]]];
        if ([companyNameAttributedString length] != 0) {
            [attributedString appendAttributedString:companyNameAttributedString];
        }
        
        if ([sageId length] != 0) {
            NSAttributedString *sageIdAttributedString = [[NSAttributedString alloc] initWithString:sageId
                                                                                   attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:14] color:[UIColor puckatorDarkGray]]];
            if ([sageIdAttributedString length] != 0) {
                [attributedString appendAttributedString:sageIdAttributedString];
            }
        }
    }
        
    // Make sure the contactName and companyName are different before showing them both:
    if ([contactName length] != 0) {
        // Add the new line if required:
        if ([attributedString length] != 0) {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
        }
        
        // Add the contact name:
        NSAttributedString *contactNameAttributedString = [[NSAttributedString alloc] initWithString:contactName
                                                                                          attributes:[UIFont puckatorAttributedFont:[UIFont puckatorFontStandardWithSize:14] color:[UIColor puckatorDarkGray]]];
        
        if ([contactNameAttributedString length] != 0) {
            [attributedString appendAttributedString:contactNameAttributedString];
        }
    }
        
    if ([attributedString length] != 0) {
        [[self labelCompany] setNumberOfLines:0];
        [[self labelCompany] setAttributedText:attributedString];
    } else {
        [[self labelCompany] setText:nil];
    }
}

- (void)setupWithBasket:(PKBasket *)basket {
    [[self labelOrderAmount] setText:[basket totalFormatted]];
    [[self labelOrderStatus] setText:[basket statusName]];
    [[self labelOrderDate] setText:[basket formattedCreatedAt]];
    
    if ([[[basket order] orderRef] length] != 0) {
        [[self labelOrderNumber] setText:[[basket order] orderRef]];
    } else {
        [[self labelOrderNumber] setText:@"N/A"];
    }
    
    switch ([basket status]) {
        default:
        case PKBasketStatusError:
            [[self labelOrderStatus] setTextColor:[UIColor redColor]];
            break;
        case PKBasketStatusOpen:
            [[self labelOrderStatus] setTextColor:[UIColor blackColor]];
            break;
        case PKBasketStatusSaved:
            [[self labelOrderStatus] setTextColor:[UIColor blackColor]];
            break;
        case PKBasketStatusQuote:
            [[self labelOrderStatus] setTextColor:[UIColor grayColor]];
            break;
        case PKBasketStatusComplete:
            if ([[basket wasSent] boolValue]) {
                [[self labelOrderStatus] setTextColor:[UIColor greenColor]];
            } else {
                [[self labelOrderStatus] setTextColor:[UIColor grayColor]];
            }
            break;
        case PKBasketStatusCancelled:
            [[self labelOrderStatus] setTextColor:[UIColor redColor]];
            break;
        case PKBasketStatusOutstanding:
            [[self labelOrderStatus] setTextColor:[UIColor redColor]];
            break;
    }
    
    [[self viewOrderStatus] setBackgroundColor:[[self labelOrderStatus] textColor]];
    
    // Display company info:
    NSString *contactName = [[basket order] addressBillingContactName];
    NSString *companyName = [[basket order] addressBillingCompanyName];
    if ([contactName length] == 0) {
        contactName = [[basket order] addressDeliveryContactName];
    }
    if ([companyName length] == 0) {
        companyName = [[basket order] addressDeliveryCompanyName];
    }
    
    PKCustomer *customer = [PKCustomer findCustomerWithId:[basket customerId]];
    [self setupCompanyInfoWithCompanyName:companyName orSageId:[customer sageId] andContactName:contactName];
}

- (void)setupWithInvoiceOrBasket:(id)object {
    if ([object isKindOfClass:[PKInvoice class]]) {
        [self setupWithInvoice:(PKInvoice *)object];
    } else if ([object isKindOfClass:[PKBasket class]]) {
        [self setupWithBasket:(PKBasket *)object];
    }
}

@end
