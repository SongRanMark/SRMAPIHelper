//
//  NSBundle+Localization.h
//  Category Demo
//
//  Created by marksong on 11/3/16.
//  Copyright © 2016 SR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Localization)

+ (NSString *)localizedStringWithKey:(NSString *)key;
+ (NSString *)localizedStringWithKey:(NSString *)key FromTable:(NSString *)table;

@end
