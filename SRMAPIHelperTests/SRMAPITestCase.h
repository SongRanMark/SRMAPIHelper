//
//  SRMAPITestCase.h
//  SRMAPIHelper
//
//  Created by marksong on 12/23/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OHHTTPStubs.h"
#import "OHHTTPStubsResponse+JSON.h"
#import "NSURLRequest+HTTPBodyTesting.h"

@interface SRMAPITestCase : XCTestCase

@property (nonatomic) XCTestExpectation *expectation;

- (void)waitForExpectationsWithDefaultTimeout;

@end
