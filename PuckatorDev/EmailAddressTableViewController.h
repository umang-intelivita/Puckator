//
//  EmailAddressTableViewController.h
//  PuckatorDev
//
//  Created by Jamie Chapman on 22/04/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKEmailAddress;
@class EmailAddressTableViewController;
@protocol EmailAddressDelegate <NSObject>
@optional
- (void) emailAddressTableViewController:(EmailAddressTableViewController*)controller
               didUpdateToEmailAddresses:(NSString*)emailAddresses;
@end

@interface EmailAddressTableViewController : UITableViewController

@property (nonatomic, assign) id<EmailAddressDelegate> emailDelegate;
@property (nonatomic, strong) NSString *emailAddresses;

//@property (strong) NSArray *customerEmailAddresses;

+ (instancetype)createWithCurrentEmailAddresses:(NSString *)currentEmailAddresses customerEmailAddresses:(NSArray<PKEmailAddress *> *)customerEmailAddresses agentEmailAddresses:(NSArray<PKEmailAddress *> *)repEmailAddresses;

@end
