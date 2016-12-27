//
//  SRMAPIManagerTests.m
//  SRMAPIHelper
//
//  Created by marksong on 12/23/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMAPITestCase.h"
#import "SRMAPIConfigurator.h"
#import "SRMExampleAPIManager.h"
#import "SRMExampleGetAPIManager.h"
#import "SRMExamplePostAPIManager.h"
#import "SRMExamplePutAPIManager.h"
#import "SRMExampleDeleteAPIManager.h"
#import "SRMAPIProcesser.h"
#import "NSString+Empty.h"

@interface SRMAPIManagerTests : SRMAPITestCase <SRMAPIManagerParameterProcesser, SRMAPIManagerParameterValidator, SRMAPIManagerResponseContentValidator, SRMAPIManagerResponseDelegate, SRMAPIManagerErrorMessageProcesser, SRMAPIManagerInterceptor>

@property (nonatomic) BOOL isRequestBeforeInterceptorExecuted;
@property (nonatomic) BOOL isRequestAfterInterceptorExecuted;
@property (nonatomic) BOOL isSuccessfulResponseBeforeInterceptorExecuted;
@property (nonatomic) BOOL isFailedResponseBeforeInterceptorExecuted;
@property (nonatomic) SRMBaseAPIManager *forbiddenAPIManager;

@end

@implementation SRMAPIManagerTests

- (void)setUp {
    [super setUp];
    [SRMAPIConfigurator sharedInstance].parameterProcesser = nil;
    [SRMAPIConfigurator sharedInstance].parameterValidator = nil;
    [SRMAPIConfigurator sharedInstance].responseContentValidator = nil;
    [SRMAPIConfigurator sharedInstance].errorMessageProcesser = nil;
    [SRMAPIConfigurator sharedInstance].interceptor = nil;
}

- (void)tearDown {
    [super tearDown];
    self.forbiddenAPIManager = nil;
    [SRMAPIConfigurator sharedInstance].parameterProcesser = nil;
    [SRMAPIConfigurator sharedInstance].parameterValidator = nil;
    [SRMAPIConfigurator sharedInstance].responseContentValidator = nil;
    [SRMAPIConfigurator sharedInstance].errorMessageProcesser = nil;
    [SRMAPIConfigurator sharedInstance].interceptor = nil;
}

- (void)testGetAPIGenerateRequest {
    SRMBaseAPIManager *APIManager = [SRMExampleGetAPIManager new];
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

#pragma mark - Response Handler Test Case

- (void)testProcessUnreachableNetworkErrorResponse {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
        
        return [OHHTTPStubsResponse responseWithError:error];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back unreachable network error reponse.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorNetworkUnreachable, @"Manager should back unreachable network error reponse.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testProcessRequestTimeoutErrorResponse {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
        
        return [OHHTTPStubsResponse responseWithError:error];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back timeout error reponse.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorTimeout, @"Manager should back timeout error reponse.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testProcessNoContentResponse {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:204 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back no content error reponse.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorNoContent, @"Manager should back no content error reponse.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testProcessHTTPClientResponse {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:422 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back HTTP client error reponse.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorClient, @"Manager should back HTTP client error reponse.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testProcessServerResponse {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:500 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back server error reponse.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorServer, @"Manager should back server error reponse.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testProcessErrorResponseWithContent {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    NSString *errorDataKey = @"message";
    NSString *errorDataValue = @"Test error response data.";
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString *dataJSONString = [NSString stringWithFormat:@"{\"%@\":\"%@\"}", errorDataKey, errorDataValue];
        NSData *data = [dataJSONString dataUsingEncoding:NSUTF8StringEncoding];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:422 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back error reponse with content.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        NSDictionary *errorData = error.userInfo[kSRMAPIManagerErrorUserInfoKeyData];
        XCTAssert([errorData[errorDataKey] isEqualToString:errorDataValue], @"Manager should back error reponse with content.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testProcessSuccessfulResponseWithDelegateCallback {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    APIManager.responseDelegate = self;
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager request];    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testProcessErrorResponseWithDelegateCallback {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    APIManager.responseDelegate = self;
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:422 headers:nil];
    }];
    
    [APIManager request];
    [self waitForExpectationsWithDefaultTimeout];
}

#pragma mark - Processor Test Case

- (void)testParameterProcesser {
    [SRMAPIConfigurator sharedInstance].parameterProcesser = [SRMAPIProcesser new];
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    APIManager.parameterProcesser = self;
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
        NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
        
        [URLComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull queryItem, NSUInteger idx, BOOL * _Nonnull stop) {
            queryDictionary[queryItem.name] = queryItem.value;
        }];
        
        BOOL flag = [queryDictionary.allKeys containsObject:@"extraParameterKey"]
        && [queryDictionary.allValues containsObject:@"extraParameterValue"]
        && [queryDictionary.allKeys containsObject:@"extraGlobalQueryKey"]
        && [queryDictionary.allValues containsObject:@"extraGlobalQueryValue"]
        && [queryDictionary.allKeys containsObject:@"extraQueryKey"]
        && [queryDictionary.allValues containsObject:@"extraQueryValue"]
        && [queryDictionary.allKeys containsObject:@"extraGlobalParameterKey"]
        && [queryDictionary.allValues containsObject:@"extraGlobalParameterValue"];
        XCTAssert(flag, @"Request API with error about processing parameters");
        
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

- (void)testManagerParameterValidator {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    APIManager.parameterValidator = self;
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager parameter validator dose not work.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorInvalidParameter, @"Manager parameter validator dose not work.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGlobalParameterValidator {
    [SRMAPIConfigurator sharedInstance].parameterValidator = [SRMAPIProcesser new];
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Global parameter validator dose not work.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorInvalidParameter, @"Global parameter validator dose not work.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testManagerResponseContentValidator {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    APIManager.responseContentValidator = self;
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager response content validator dose not work.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorInvalidResponseContent, @"Manager response content validator dose not work.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGlobalResponseContentValidator {
    [SRMAPIConfigurator sharedInstance].responseContentValidator = [SRMAPIProcesser new];
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Global response content validator dose not work.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert(error.code == SRMAPIManagerResponseErrorInvalidResponseContent, @"Global response content validator dose not work.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testManagerResponseErrorMessageProcessor {
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    APIManager.errorMessageProcesser = self;
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:422 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back error reponse with custom message generated by manager processor.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert([error.localizedDescription isEqualToString:@"Test error message."], @"Manager should back error reponse with custom message generated by manager processor.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGlobalResponseErrorMessageProcessor {
    [SRMAPIConfigurator sharedInstance].errorMessageProcesser = [SRMAPIProcesser new];
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:422 headers:nil];
    }];
    
    [APIManager requestWithSuccessfulCallback:^(SRMBaseAPIManager *manager, id content) {
        [self.expectation fulfill];
        XCTAssert(NO, @"Manager should back error reponse with custom message generated by global processor.");
    } failedCallback:^(SRMBaseAPIManager *manager, NSError *error) {
        [self.expectation fulfill];
        XCTAssert([error.localizedDescription isEqualToString:@"Test error message."], @"Manager should back error reponse with custom message generated by global processor.");
    }];
    
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testRequestInterceptor {
    SRMAPIProcesser *globalInterceptor = [SRMAPIProcesser new];
    globalInterceptor.isRequestBeforeInterceptorExecuted = NO;
    globalInterceptor.isRequestAfterInterceptorExecuted = NO;
    [SRMAPIConfigurator sharedInstance].interceptor = globalInterceptor;
    self.isRequestBeforeInterceptorExecuted = NO;
    self.isRequestAfterInterceptorExecuted = NO;
    SRMBaseAPIManager *APIManager = [SRMExampleGetAPIManager new];
    self.forbiddenAPIManager = APIManager;
    APIManager.interceptor = self;
    [APIManager request];
    XCTAssert(globalInterceptor.isRequestBeforeInterceptorExecuted, @"Manager should execute global request before interceptor.");
    XCTAssert(globalInterceptor.isRequestAfterInterceptorExecuted, @"Manager should execute global request after interceptor.");
    XCTAssert(self.isRequestBeforeInterceptorExecuted, @"Manager should execute request before interceptor.");
    XCTAssert(self.isRequestAfterInterceptorExecuted, @"Manager should execute request after interceptor.");
}

- (void)testManagerSuccessfulResponseInterceptor {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    self.isSuccessfulResponseBeforeInterceptorExecuted = NO;
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    APIManager.interceptor = self;
    [APIManager request];
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGlobalSuccessfulResponseInterceptor {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    SRMAPIProcesser *globalInterceptor = [SRMAPIProcesser new];
    globalInterceptor.isSuccessfulResponseBeforeInterceptorExecuted = NO;
    globalInterceptor.expectation = self.expectation;
    [SRMAPIConfigurator sharedInstance].interceptor = globalInterceptor;
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    [APIManager request];
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testManagerFailedResponseInterceptor {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:422 headers:nil];
    }];
    
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    self.isFailedResponseBeforeInterceptorExecuted = NO;
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    APIManager.interceptor = self;
    [APIManager request];
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testGlobalFailedResponseInterceptor {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:422 headers:nil];
    }];
    
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    SRMAPIProcesser *globalInterceptor = [SRMAPIProcesser new];
    globalInterceptor.isFailedResponseBeforeInterceptorExecuted = NO;
    globalInterceptor.expectation = self.expectation;
    [SRMAPIConfigurator sharedInstance].interceptor = globalInterceptor;
    SRMBaseAPIManager *APIManager = [SRMExampleAPIManager new];
    [APIManager request];
    [self waitForExpectationsWithDefaultTimeout];
}

#pragma mark - SRMAPIManagerResponseDelegate

- (void)APIManager:(SRMBaseAPIManager *)APIManager successInRequestingAPIWithContent:(id)content {
    [self.expectation fulfill];
}

- (void)APIManager:(SRMBaseAPIManager *)APIManager failToRequestAPIWithError:(NSError *)error {
    [self.expectation fulfill];
}

#pragma mark - SRMAPIManagerParameterProcesser

- (NSArray<NSURLQueryItem *> *)APIManager:(SRMBaseAPIManager *)APIManager processQueryItems:(NSArray<NSURLQueryItem *> *)queryItems {
    NSMutableArray *processedQueryItems = [NSMutableArray arrayWithArray:queryItems];
    NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:@"extraQueryKey" value:@"extraQueryValue"];
    [processedQueryItems addObject:queryItem];
    
    return [processedQueryItems copy];
}

- (id)APIManager:(SRMBaseAPIManager *)APIManager processParameters:(id)parameters {
    NSMutableDictionary *processedParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    processedParameters[@"extraParameterKey"] = @"extraParameterValue";
    
    return [processedParameters copy];
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
    
    if (APIManager == self.forbiddenAPIManager) {
        return NO;
    }
    
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
    XCTAssert(self.isSuccessfulResponseBeforeInterceptorExecuted, @"Manager should execute successful response before interceptor.");
}

- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager shouldPerformFailedCallbackWithError:(NSError *)error {
    self.isFailedResponseBeforeInterceptorExecuted = YES;
    
    return NO;
}

- (void)APIManager:(SRMBaseAPIManager *)APIManager afterPerformFailedCallbackWithError:(NSError *)error {
    [self.expectation fulfill];
    XCTAssert(self.isFailedResponseBeforeInterceptorExecuted, @"Manager should execute failed response before interceptor.");
}

@end
