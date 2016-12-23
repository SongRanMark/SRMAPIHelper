//
//  SRMAPIManagerTests.m
//  SRMAPIHelper
//
//  Created by marksong on 12/23/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMAPITestCase.h"
#import "SRMExampleAPIManager.h"
#import "SRMExamplePostAPIManager.h"
#import "SRMExamplePutAPIManager.h"
#import "SRMExampleDeleteAPIManager.h"
#import "NSString+Empty.h"

@interface SRMAPIManagerTests : SRMAPITestCase

@end

@implementation SRMAPIManagerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGenerateRequest {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([request.HTTPMethod isEqualToString:@"GET"], @"Wrong request with method");
        NSURL *requestURL = request.URL;
        NSURL *baseURL = [NSURL URLWithString:APIManager.serverDomain];
        NSURL *APIManagerURL = [NSURL URLWithString:APIManager.path relativeToURL:baseURL];
        XCTAssert([requestURL.scheme isEqualToString:APIManagerURL.scheme] && [requestURL.host isEqualToString:APIManagerURL.host] && [requestURL.path isEqualToString:APIManagerURL.path], @"Wrong request with URL");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testPostAPIGenerateRequest {
    SRMBaseAPIManager *APIManager = [SRMExamplePostAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([request.HTTPMethod isEqualToString:@"POST"], @"Wrong request with method");
        NSString *parametersString = [[NSString alloc] initWithData:request.OHHTTPStubs_HTTPBody encoding:NSUTF8StringEncoding];
        XCTAssert([parametersString isEqualToString:@"key1=value1&key2=value2"], @"Wrong request with parameters");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testPutAPIGenerateRequest {
    SRMBaseAPIManager *APIManager = [SRMExamplePutAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([request.HTTPMethod isEqualToString:@"PUT"], @"Wrong request with method");
        NSString *parametersString = [[[NSString alloc] initWithData:request.OHHTTPStubs_HTTPBody encoding:NSUTF8StringEncoding] stringByTrimmingSpace];
        XCTAssert([parametersString isEqualToString:@"{\"key1\":\"value1\",\"key2\":\"value2\"}"], @"Wrong request with parameters");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testDeleteAPIGenerateRequest {
    SRMBaseAPIManager *APIManager = [SRMExampleDeleteAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([request.HTTPMethod isEqualToString:@"DELETE"], @"Wrong request with method");
        XCTAssert([request.URL.query isEqualToString:@"key1=value1&key2=value2"], @"Wrong request with parameters");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

@end
