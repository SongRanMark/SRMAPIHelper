//
//  SRMExampleListAPIManager.m
//  SRMAPIHelper
//
//  Created by marksong on 12/27/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMExampleListAPIManager.h"

@implementation SRMExampleListAPIManager

- (NSString *)serverDomain {
    return @"https://api.example.com/v1";
}

- (NSString *)path {
    return @"list";
}

- (NSString *)perPageKey {
    return @"TestPerPageKey";
}

- (NSString *)pageKey {
    return @"TestPageKey";
}

@end
