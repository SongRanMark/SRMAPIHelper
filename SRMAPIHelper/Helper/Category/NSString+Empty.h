//
//  NSString+Empty.h
//  Category Demo
//
//  Created by marksong on 3/21/16.
//  Copyright © 2016 SR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Empty)

+ (NSString *)emptyString;
+ (BOOL)isNilOrEmptyString:(NSString *)string;

@end
