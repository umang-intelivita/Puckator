//
//  NSError+FS.h
//  MyFutureMOT
//
//  Created by Luke Dixon on 21/02/2017.
//  Copyright © 2017 Luke Dixon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (FS)

+ (NSError *)create:(NSString *)description;
+ (NSError *)create:(NSString *)description code:(int)code;

@end
