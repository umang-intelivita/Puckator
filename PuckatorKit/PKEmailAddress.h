//
//  PKEmail.h
//  Puckator
//
//  Created by Luke Dixon on 09/01/2018.
//  Copyright © 2018 57Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKEmailAddress : NSObject

@property (strong) NSString *email;
@property (strong) NSString *type;
@property (assign) BOOL isSelected;
@property (assign) BOOL isCustom;

+ (instancetype)createWithEmail:(NSString *)email type:(NSString *)type;

@end
