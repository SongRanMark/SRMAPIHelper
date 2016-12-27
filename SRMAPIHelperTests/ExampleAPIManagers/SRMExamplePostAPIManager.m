//
//  SRMExamplePostAPIManager.m
//  SRMAPIHelper
//
//  Created by marksong on 12/23/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMExamplePostAPIManager.h"

@implementation SRMExamplePostAPIManager

- (SRMAPIManagerRequestMethodType)requestMethodType {
    return SRMAPIManagerRequestMethodTypePOST;
}

- (NSString *)serverDomain {
    return @"https://api.example.com/v1";
}

- (NSString *)path {
    return @"test";
}

- (id)parameters {
    return @{
             @"key1" : @"value1",
             @"key2" : @"value2"
             };
}

@end
