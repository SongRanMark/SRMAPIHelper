//
//  NSBundle+Localization.m
//  Category Demo
//
//  Created by marksong on 11/3/16.
//  Copyright © 2016 SR. All rights reserved.
//

#import "NSBundle+Localization.h"

@implementation NSBundle (Localization)

+ (NSString *)localizedStringWithKey:(NSString *)key {
    return NSLocalizedString(key, nil);
}

+ (NSString *)localizedStringWithKey:(NSString *)key FromTable:(NSString *)table {
    return NSLocalizedStringFromTable(key, table, nil);
}

@end
