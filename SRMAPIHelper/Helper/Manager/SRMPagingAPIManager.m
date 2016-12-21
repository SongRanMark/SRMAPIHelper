//
//  SRMPagingAPIManager.m
//  SRMAPIHelper
//
//  Created by marksong on 12/21/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMPagingAPIManager.h"
#import "NSString+Empty.h"

static const NSUInteger kDefaultPerPage = 10;
static const NSUInteger kDefaultPage = 0;

@interface SRMPagingAPIManager ()

@property (nonatomic) NSUInteger requestedPage;
@property (nonatomic, readwrite) NSUInteger currentPage;

@end

@implementation SRMPagingAPIManager

#pragma mark - Override

- (instancetype)init
{
    if (self = [super init]) {
        self.perPage = kDefaultPerPage;
        self.currentPage = kDefaultPage;
    }
    
    return self;
}

- (id)parameters {
    return @{
             [self perPageKey] : @(self.perPage),
             [self pageKey] : @(self.requestedPage),
             };
}

- (NSString *)perPageKey {
    return [NSString emptyString];
}

- (NSString *)pageKey {
    return [NSString emptyString];
}

- (BOOL)shouldPerformSuccessfulCallbackWithContent:(id)content {
    self.currentPage = self.requestedPage;
    
    return YES;
}

#pragma mark - Public

- (void)requestLastPage {
    [self requestLastPageWithSuccessfulCallback:nil failedCallback:nil];
}

- (void)requestLastPageWithSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback {
    [self requestPage:self.currentPage - 1 withSuccessfulCallback:successfulCallback failedCallback:failedCallback];
}

- (void)requestNextPage {
    [self requestNextPageWithSuccessfulCallback:nil failedCallback:nil];
}

- (void)requestNextPageWithSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback {
    [self requestPage:self.currentPage + 1 withSuccessfulCallback:successfulCallback failedCallback:failedCallback];
}

- (void)requestPage:(NSUInteger)page {
    [self requestPage:page withSuccessfulCallback:nil failedCallback:nil];
    
}

- (void)requestPage:(NSUInteger)page withSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback {
    self.requestedPage = page;
    [self requestWithSuccessfulCallback:successfulCallback failedCallback:failedCallback];
}

@end
