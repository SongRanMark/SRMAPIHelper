//
// Created by marksong on 12/12/16.
// Copyright (c) 2016 S.R. All rights reserved.
//

#import "SRMAPIConfigurator.h"
#import "SRMAPIProxy.h"
#import "SRMAPILogger.h"

@implementation SRMAPIConfigurator

#pragma mark - Public

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SRMAPIConfigurator *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

#pragma mark - Setter

- (void)setShouldDebug:(BOOL)shouldDebug {
    [SRMAPILogger sharedInstance].enabled = shouldDebug;
}

- (void)setReponseType:(SRMAPIResponseType)reponseType {
    _reponseType = reponseType;
    
    switch (reponseType) {
        case SRMAPIResponseTypeData:
            [SRMAPIProxy sharedInstance].responseContentType = SRMAPIProxyResponseContentTypeData;
            break;
        case SRMAPIResponseTypeJSON:
            [SRMAPIProxy sharedInstance].responseContentType = SRMAPIProxyResponseContentTypeJSON;
            break;
    }
}

#pragma mark - Getter

- (BOOL)shouldDebug {
    return [SRMAPILogger sharedInstance].enabled;
}

@end
