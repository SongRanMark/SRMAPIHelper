//
//  SRMAPIProxyTests.m
//  SRMAPIHelper
//
//  Created by marksong on 12/22/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SRMAPIProxy.h"
#import "OHHTTPStubs.h"
#import "OHHTTPStubsResponse+JSON.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "NSString+Empty.h"

static const NSTimeInterval kDefaultTimeout = 15;

@interface SRMAPIProxyTests : XCTestCase

@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) NSURL *URL;

@end

@implementation SRMAPIProxyTests

- (void)setUp {
    [super setUp];
    self.URL = [NSURL URLWithString:@"https://api.example.com/test"];
}

- (void)tearDown {
    [super tearDown];
    self.expectation = nil;
    [OHHTTPStubs removeAllStubs];
    [SRMAPIProxy sharedInstance].responseContentType = SRMAPIProxyResponseContentTypeJSON;
}

- (void)waitForExpectationsWithDefaultTimeout {
    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:nil];
}

- (void)testGenerateRequest {
    NSTimeInterval timeout = kDefaultTimeout;
    NSString *parameterKey = @"parameterKey";
    NSString *parameterValue = @"parameterValue";
    NSDictionary *parameters = @{parameterKey : parameterValue};
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([request.URL.host isEqualToString:self.URL.host] && [request.URL.path isEqualToString:self.URL.path], @"Wrong request with URL");
        XCTAssert(request.timeoutInterval == timeout, @"Wrong request with timeout");
        NSArray<NSURLQueryItem *> *queryItems = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES].queryItems;
        XCTAssert(queryItems.count == 1 && [queryItems[0].name isEqualToString:parameterKey] && [queryItems[0].value isEqualToString:parameterValue], @"Wrong request with parameter format");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodGet URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:parameters timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:nil];
}

- (void)testGenerateGetRequest {
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([request.HTTPMethod isEqualToString:@"GET"], @"Wrong request with method");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodGet URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGeneratePostRequest {
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([request.HTTPMethod isEqualToString:@"POST"], @"Wrong request with method");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodPost URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGeneratePutRequest {
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([request.HTTPMethod isEqualToString:@"PUT"], @"Wrong request with method");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodPut URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGenerateDeleteRequest {
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSLog(@"%@", request.allHTTPHeaderFields);
        XCTAssert([request.HTTPMethod isEqualToString:@"DELETE"], @"Wrong request with method");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodDelete URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGeneratePostRequestWithDefaultTypeParameter {
    NSDictionary *parameters = @{@"parameterKey" : @"parameterValue"};
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([[request valueForHTTPHeaderField:@"Content-Type"] isEqualToString:@"application/x-www-form-urlencoded"], @"Wrong request with parameter format");
        NSString *httpBodyString = [[[NSString alloc] initWithData:request.OHHTTPStubs_HTTPBody encoding:NSUTF8StringEncoding] stringByTrimmingSpace];
        XCTAssert([httpBodyString isEqualToString:@"parameterKey=parameterValue"], @"Wrong request with parameter format");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodPost URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:parameters timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGeneratePostRequestWithJSONTypeParameter {
    NSDictionary *parameters = @{@"parameterKey" : @"parameterValue"};
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssert([[request valueForHTTPHeaderField:@"Content-Type"] isEqualToString:@"application/json"], @"Wrong request with parameter format");
        NSString *httpBodyString = [[[NSString alloc] initWithData:request.OHHTTPStubs_HTTPBody encoding:NSUTF8StringEncoding] stringByTrimmingSpace];
        XCTAssert([httpBodyString isEqualToString:@"{\"parameterKey\":\"parameterValue\"}"], @"Wrong request with parameter format");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodPost URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeJSON parameters:parameters timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testParseContentAsDataInSuccessfullResponse {
    NSDictionary *content = @{@"key":@"value"};
    [SRMAPIProxy sharedInstance].responseContentType = SRMAPIProxyResponseContentTypeData;
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithJSONObject:content statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodGet URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
        XCTAssert([content isKindOfClass:[NSData class]], @"Type of response content should be data");
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Should not execute error callback for successful response.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testParseContentAsJSONObjectInSuccessfullResponse {
    NSDictionary *content = @{@"key":@"value"};
    [SRMAPIProxy sharedInstance].responseContentType = SRMAPIProxyResponseContentTypeJSON;
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithJSONObject:content statusCode:200 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodGet URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
        XCTAssert([content isKindOfClass:[NSDictionary class]], @"Type of response content should be JSON");
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Should not execute error callback for successful response.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testParseContentAsStringInHTTPErrorResponse {
    NSDictionary *content = @{@"key":@"value"};
    [SRMAPIProxy sharedInstance].responseContentType = SRMAPIProxyResponseContentTypeData;
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithJSONObject:content statusCode:422 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodGet URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Should not execute successful callback for HTTP error response.");
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
        XCTAssert([error.domain isEqualToString:kSRMAPIProxyErrorDomain], @"HTTP error should belong to proxy domain");
        XCTAssert([error.userInfo[kSRMAPIProxyErrorDataKey] isKindOfClass:[NSString class]], @"Type of error content should be string");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testParseContentAsJSONObjectInHTTPErrorResponse {
    NSDictionary *content = @{@"key":@"value"};
    [SRMAPIProxy sharedInstance].responseContentType = SRMAPIProxyResponseContentTypeJSON;
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithJSONObject:content statusCode:422 headers:nil];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodGet URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Should not execute successful callback for HTTP error response.");
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
        XCTAssert([error.domain isEqualToString:kSRMAPIProxyErrorDomain], @"HTTP error should belong to proxy domain");
        XCTAssert([error.userInfo[kSRMAPIProxyErrorDataKey] isKindOfClass:[NSObject class]], @"Type of error content should be JSON");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testResponseWithClientError {
    self.expectation = [self expectationWithDescription:@"Receive response."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
        
        return [OHHTTPStubsResponse responseWithError:error];
    }];
    
    [[SRMAPIProxy sharedInstance] requestByMethod:SRMAPIProxyHTTPMethodGet URL:self.URL.absoluteString parameterType:SRMAPIProxyParameterTypeDefault parameters:nil timeoutInterval:kDefaultTimeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Should not execute successful callback for error response.");
    } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
        [self.expectation fulfill];
        XCTAssert([error.domain isEqualToString:NSURLErrorDomain], @"Client error should belong to system domain");
        XCTAssert(error.code == NSURLErrorNotConnectedToInternet, @"Proxy should not process client error");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

@end
