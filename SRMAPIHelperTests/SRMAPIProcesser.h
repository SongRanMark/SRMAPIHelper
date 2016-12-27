//
//  SRMAPIProcesser.h
//  SRMAPIHelper
//
//  Created by marksong on 12/26/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SRMBaseAPIManager.h"

@interface SRMAPIProcesser : XCTestCase <SRMAPIManagerParameterProcesser, SRMAPIManagerParameterValidator, SRMAPIManagerResponseContentValidator, SRMAPIManagerErrorMessageProcesser, SRMAPIManagerInterceptor>

@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) BOOL isRequestBeforeInterceptorExecuted;
@property (nonatomic) BOOL isRequestAfterInterceptorExecuted;
@property (nonatomic) BOOL isSuccessfulResponseBeforeInterceptorExecuted;
@property (nonatomic) BOOL isFailedResponseBeforeInterceptorExecuted;

@end
