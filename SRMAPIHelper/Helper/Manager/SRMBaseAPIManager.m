//
// Created by marksong on 12/12/16.
// Copyright (c) 2016 S.R. All rights reserved.
//

#import "SRMBaseAPIManager.h"

NSString * const kSRMAPIManagerErrorDomain = @"com.augmentum.quncrm.api.manager.error";
NSString * const kSRMAPIManagerErrorUserInfoKeyData = @"com.augmentum.quncrm.api.manager.error.data";

@implementation SRMBaseAPIManager

- (SRMAPIManagerRequestMethodType)requestMethodType {
    return SRMAPIManagerRequestMethodTypeGET;
}

@end
