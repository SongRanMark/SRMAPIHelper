//
//  NSString+Empty.m
//  Category Demo
//
//  Created by marksong on 3/21/16.
//  Copyright © 2016 SR. All rights reserved.
//

#import "NSString+Empty.h"

static NSString *const kEmptyString = @"";

@implementation NSString (Empty)

+ (NSString *)emptyString {
    return kEmptyString;
}

+ (BOOL)isNilOrEmptyString:(NSString *)string {
    if (!string) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimedString = [string stringByTrimmingCharactersInSet:whitespaceAndNewlineCharacterSet];
    
    if ([trimedString isEqualToString:[self emptyString]]) {
        return YES;
    }

    return NO;
}

@end
