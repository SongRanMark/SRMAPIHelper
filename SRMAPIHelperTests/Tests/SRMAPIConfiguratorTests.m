//
//  SRMAPIConfiguratorTests.m
//  SRMAPIHelper
//
//  Created by marksong on 12/27/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMAPITestCase.h"
#import "SRMAPIConfigurator.h"
#import "SRMExampleAPIManager.h"

static NSString *const kDataJSONString = @"{\"TestKey\":\"TestValue\"}";

@interface SRMAPIConfiguratorTests : SRMAPITestCase

@end

@implementation SRMAPIConfiguratorTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    [SRMAPIConfigurator sharedInstance].reponseType = SRMAPIResponseTypeJSON;
}

- (void)testResponseTypeData {
    [SRMAPIConfigurator sharedInstance].reponseType = SRMAPIResponseTypeData;
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSData *data = [kDataJSONString dataUsingEncoding:NSUTF8StringEncoding];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert([content isKindOfClass:[NSData class]], @"Configurator set up response type incorrectly.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back successful reponse.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testResponseTypeJSON {
    [SRMAPIConfigurator sharedInstance].reponseType = SRMAPIResponseTypeJSON;
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSData *data = [kDataJSONString dataUsingEncoding:NSUTF8StringEncoding];
        OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:response.httpHeaders];
        headers[@"Content-Type"] = @"application/json";
        response.httpHeaders = headers;
        
        return response;
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert([content isKindOfClass:[NSDictionary class]], @"Configurator set up response type incorrectly.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back successful reponse.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

@end
