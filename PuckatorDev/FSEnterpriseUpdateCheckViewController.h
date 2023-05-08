//
//  FSEnterpriseUpdateCheckViewController.h
//
//  Created by Jamie Chapman on 04/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FSEnterpriseUpdateCheckCompletionBlock)(BOOL);

@interface FSEnterpriseUpdateCheckViewController : UIViewController

+ (UINavigationController*) createWithNavController;

// Checks if an update is available on the server
+ (void) checkForUpdates:(FSEnterpriseUpdateCheckCompletionBlock)completionBlock;

@end
