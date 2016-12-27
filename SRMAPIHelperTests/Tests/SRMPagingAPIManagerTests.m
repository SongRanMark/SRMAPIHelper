//
//  SRMPagingAPIManagerTests.m
//  SRMAPIHelper
//
//  Created by marksong on 12/27/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMAPITestCase.h"
#import "SRMExampleListAPIManager.h"

@interface SRMPagingAPIManagerTests : SRMAPITestCase <SRMAPIManagerResponseDelegate>

@property (nonatomic) SRMPagingAPIManager *specifiedPageAPIManager;
@property (nonatomic) SRMPagingAPIManager *nextPageAPIManager;
@property (nonatomic) SRMPagingAPIManager *lastPageAPIManager;

@end

@implementation SRMPagingAPIManagerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    self.specifiedPageAPIManager = nil;
    self.nextPageAPIManager = nil;
    self.lastPageAPIManager = nil;
}

- (void)testSpecifiedPageRequest {
    self.specifiedPageAPIManager = [SRMExampleListAPIManager new];
    self.specifiedPageAPIManager.responseDelegate = self;
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
        NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
        
        [URLComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull queryItem, NSUInteger idx, BOOL * _Nonnull stop) {
            queryDictionary[queryItem.name] = queryItem.value;
        }];
        
        XCTAssert([queryDictionary.allKeys containsObject:@"TestPerPageKey"] && [queryDictionary[@"TestPageKey"] integerValue] == 1, @"Set up parameter page number incorrectly.");
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    [self.specifiedPageAPIManager requestPage:1];
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testNextPageRequest {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    self.nextPageAPIManager = [SRMExampleListAPIManager new];
    self.nextPageAPIManager.responseDelegate = self;
    [self.nextPageAPIManager requestNextPage];
    [self waitForExpectationsWithDefaultTimeout];
}

- (void)testLastPageRequest {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
    
    self.expectation = [self expectationWithDescription:@"Receive response from example API."];
    self.lastPageAPIManager = [SRMExampleListAPIManager new];
    self.lastPageAPIManager.responseDelegate = self;
    [self.lastPageAPIManager requestLastPage];
    [self waitForExpectationsWithDefaultTimeout];
}

#pragma mark - SRMAPIManagerResponseDelegate

- (void)APIManager:(SRMBaseAPIManager *)APIManager successInRequestingAPIWithContent:(id)content {
    [self.expectation fulfill];
    
    if (APIManager == self.specifiedPageAPIManager) {
        XCTAssert(self.specifiedPageAPIManager.currentPage == 1, @"Set up manager current page number incorrectly.");
    } else if (APIManager == self.nextPageAPIManager) {
        XCTAssert(self.nextPageAPIManager.currentPage == 1, @"Set up manager current page number incorrectly.");
    } else if (APIManager == self.lastPageAPIManager) {
        XCTAssert(self.lastPageAPIManager.currentPage == -1, @"Set up manager current page number incorrectly.");
    }
}

- (void)APIManager:(SRMBaseAPIManager *)APIManager failToRequestAPIWithError:(NSError *)error {
    [self.expectation fulfill];
    XCTAssert(NO, @"Manager should back successful reponse.");
}

@end
