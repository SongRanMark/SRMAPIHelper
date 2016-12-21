//
//  SRMAPIHelperTests.m
//  SRMAPIHelperTests
//
//  Created by marksong on 12/21/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SRMAPIProxy.h"
#import "OHHTTPStubs.h"
#import "OHHTTPStubsResponse+JSON.h"

@interface SRMAPIHelperTests : XCTestCase

@end

@implementation SRMAPIHelperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

- (void)testProxy {
    NSString *URL = @"https://api.example.com/records";
    NSArray *responseJSONObject = @[
                                    @{
                                        @"id":@"1"
                                        },
                                    @{
                                        @"id":@"2"
                                        }
                                    ];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Receive response from proxy."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithJSONObject:responseJSONObject statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodGet URL:URL parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:15 successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [expectation fulfill];
        NSLog(@"%@", content);
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [expectation fulfill];
        NSLog(@"%@", error);
    }];
    
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

@end
