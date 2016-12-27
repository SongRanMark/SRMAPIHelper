//
//  SRMAPIProcesser.m
//  SRMAPIHelper
//
//  Created by marksong on 12/26/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMAPIProcesser.h"

@implementation SRMAPIProcesser

#pragma mark - SRMAPIManagerParameterProcesser

- (NSArray<NSURLQueryItem *> *)APIManager:(SRMBaseAPIManager *)APIManager processQueryItems:(NSArray<NSURLQueryItem *> *)queryItems {
    NSMutableArray *processedQueryItems = [NSMutableArray arrayWithArray:queryItems];
    NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:@"extraGlobalQueryKey" value:@"extraGlobalQueryValue"];
    [processedQueryItems addObject:queryItem];
    
    return [processedQueryItems copy];
}

- (id)APIManager:(SRMBaseAPIManager *)APIManager processParameters:(id)parameters {
    return @{@"extraGlobalParameterKey" : @"extraGlobalParameterValue"};
}

#pragma mark - SRMAPIManagerParameterValidator

- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager isValidQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters {
    return NO;
}

#pragma mark - SRMAPIManagerResponseContentValidator

- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager isValidResponseContent:(id)content {
    return NO;
}

#pragma mark - SRMAPIManagerErrorMessageProcesser

- (NSString *)APIManager:(SRMBaseAPIManager *)APIManager errorMessageForResponse:(NSHTTPURLResponse *)response content:(id)content errorCode:(SRMAPIManagerResponseErrorCode)errorCode {
    return @"Test error message.";
}

#pragma mark - SRMAPIManagerInterceptor

- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager shouldRequestWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters {
    self.isRequestBeforeInterceptorExecuted = YES;
    
    return YES;
}

- (void)APIManager:(SRMBaseAPIManager *)APIManager afterRequestWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters {
    self.isRequestAfterInterceptorExecuted = YES;
}

- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager shouldPerformSuccessfulCallbackWithContent:(id)content {
    self.isSuccessfulResponseBeforeInterceptorExecuted = YES;
    
    return NO;
}

- (void)APIManager:(SRMBaseAPIManager *)APIManager afterPerformSuccessfulCallbackWithContent:(id)content {
    [self.expectation fulfill];
    XCTAssert(self.isSuccessfulResponseBeforeInterceptorExecuted, @"Manager should execute global successful response before interceptor.");
}

- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager shouldPerformFailedCallbackWithError:(NSError *)error {
    self.isFailedResponseBeforeInterceptorExecuted = YES;
    
    return NO;
}

- (void)APIManager:(SRMBaseAPIManager *)APIManager afterPerformFailedCallbackWithError:(NSError *)error {
    [self.expectation fulfill];
    XCTAssert(self.isFailedResponseBeforeInterceptorExecuted, @"Manager should execute global failed response before interceptor.");
}

@end
