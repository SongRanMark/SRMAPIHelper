//
//  SRMAPITestCase.m
//  SRMAPIHelper
//
//  Created by marksong on 12/23/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMAPITestCase.h"

static const NSTimeInterval kDefaultTimeout = 15;

@implementation SRMAPITestCase

- (void)tearDown {
    [super tearDown];
    self.expectation = nil;
    [OHHTTPStubs removeAllStubs];
}

- (void)waitForExpectationsWithDefaultTimeout {
    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:nil];
}

@end
