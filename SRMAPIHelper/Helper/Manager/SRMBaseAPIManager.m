//
// Created by marksong on 12/12/16.
// Copyright (c) 2016 S.R. All rights reserved.
//

#import "SRMBaseAPIManager.h"
#import "SRMAPIProxy.h"
#import "SRMAPIConfigurator.h"
#import "SRMAPILogger.h"
#import "NSString+Empty.h"
#import "NSBundle+Localization.h"

NSString * const kSRMAPIManagerErrorDomain = @"com.sr.api.manager.error";
NSString * const kSRMAPIManagerErrorUserInfoKeyData = @"com.sr.api.manager.error.data";
static NSTimeInterval kTimeout = 15;
static NSString * const kLocalizedTableName = @"LocalizableAPIManagerErrorMessage";
static NSString * const kLocalizedErrorMessageKeyUnknown = @"Unknown";
static NSString * const kLocalizedErrorMessageKeyNoContent = @"NoContent";
static NSString * const kLocalizedErrorMessageKeyInvalidParameter = @"InvalidParameter";
static NSString * const kLocalizedErrorMessageKeyInvalidResponseContent = @"InvalidResponseContent";
static NSString * const kLocalizedErrorMessageKeyNetworkUnreachable = @"NetworkUnreachable";
static NSString * const kLocalizedErrorMessageKeyTimeout = @"Timeout";
static NSString * const kLocalizedErrorMessageKeyClient = @"Client";
static NSString * const kLocalizedErrorMessageKeyServer = @"Server";

@implementation SRMBaseAPIManager

- (void)request {
    [self requestWithSuccessfulCallback:nil failedCallback:nil];
}

- (void)requestWithSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback {
    SRMAPIProxyHTTPMethod proxyHTTPMethodType = [self proxyHTTPMethodTypeFromManagerType:self.requestMethodType];
    SRMAPIProxyParameterType proxyParameterType = [self proxyParameterTypeFromManagerType:self.parameterType];
    NSURL *baseURL = [NSURL URLWithString:self.serverDomain];
    NSURL *URL = [NSURL URLWithString:self.path relativeToURL:baseURL];
    URL = [self processQueryOfURL:URL];
    id parameters = [self processParameters:self.parameters];
    NSArray *queryItems = [NSURLComponents componentsWithString:URL.absoluteString].queryItems;
    
    if ([self shouldRequestWithQueryItems:queryItems parameters:parameters]) {
        // 在 manager 层记录日志而不是 proxy 层的原因是，除了必要的请求或响应信息，还可以记录
        // 具体的 manager 子类，该内容可方便日志信息的查看。
        [[SRMAPILogger sharedInstance] logRequestWithAPIManager:self URL:URL.absoluteString parameters:parameters];
        
        if (![self isValidQueryItems:queryItems parameters:parameters]) {
            // 因为直接返回参数错误导致的失败响应，不执行异步操作，所以要在参数错误的失败响应前
            // 执行请求后的拦截器方法并 return。
            [self afterRequestWithQueryItems:queryItems parameters:parameters];
            NSString *message = [self localizedErrorMessageWithKey:kLocalizedErrorMessageKeyInvalidParameter];
            NSError *error = [self errorWithCode:SRMAPIManagerResponseErrorInvalidParameter message:message];
            [[SRMAPILogger sharedInstance] logResponseWithAPIManager:self response:nil content:nil error:error];
            [self failToRequestWithResponse:nil error:error callback:failedCallback];
            
            return;
        }
        
        [[SRMAPIProxy sharedInstance] requestByMethod:proxyHTTPMethodType URL:URL.absoluteString parameterType:proxyParameterType parameters:parameters timeoutInterval:self.timeout successfulCallback:^(NSHTTPURLResponse *response, id content) {
            [[SRMAPILogger sharedInstance] logResponseWithAPIManager:self response:response content:content error:nil];
            [self successInRequestingWithResponse:response Content:content successfulCallback:successfulCallback failedCallback:failedCallback];
        } failedCallback:^(NSHTTPURLResponse *response, NSError *error) {
            [[SRMAPILogger sharedInstance] logResponseWithAPIManager:self response:response content:nil error:error];
            [self failToRequestWithResponse:response error:error callback:failedCallback];
        }];
    }
    
    [self afterRequestWithQueryItems:queryItems parameters:parameters];
}

#pragma mark - Private

- (SRMAPIProxyHTTPMethod)proxyHTTPMethodTypeFromManagerType:(SRMAPIManagerRequestMethodType)managerHTTPMethodType {
    SRMAPIProxyHTTPMethod methodType;
    
    switch (managerHTTPMethodType) {
        case SRMAPIManagerRequestMethodTypeGET:
            methodType = SRMAPIProxyHTTPMethodGet;
            break;
        case SRMAPIManagerRequestMethodTypePOST:
            methodType = SRMAPIProxyHTTPMethodPost;
            break;
        case SRMAPIManagerRequestMethodTypePUT:
            methodType = SRMAPIProxyHTTPMethodPut;
            break;
        case SRMAPIManagerRequestMethodTypeDELETE:
            methodType = SRMAPIProxyHTTPMethodDelete;
            break;
    }
    
    return methodType;
}

- (SRMAPIProxyParameterType)proxyParameterTypeFromManagerType:(SRMAPIManagerParameterType)managerParameterType {
    SRMAPIProxyParameterType parameterType;
    
    switch (managerParameterType) {
        case SRMAPIManagerParameterTypeDefault:
            parameterType = SRMAPIProxyParameterTypeDefault;
            break;
        case SRMAPIManagerParameterTypeJSON:
            parameterType = SRMAPIProxyParameterTypeJSON;
            break;
    }
    
    return parameterType;
}

- (id)processParameters:(id)parameters {
    if ([[SRMAPIConfigurator sharedInstance].parameterProcesser respondsToSelector:@selector(APIManager:processParameters:)]) {
        parameters = [[SRMAPIConfigurator sharedInstance].parameterProcesser APIManager:self processParameters:parameters];
    }
    
    if ([self.parameterProcesser respondsToSelector:@selector(APIManager:processParameters:)]) {
        parameters = [self.parameterProcesser APIManager:self processParameters:parameters];
    }
    
    return parameters;
}

- (NSURL *)processQueryOfURL:(NSURL *)URL {
    if ([[SRMAPIConfigurator sharedInstance].parameterProcesser respondsToSelector:@selector(APIManager:processQueryItems:)]) {
        URL = [self processQueryOfURL:URL withProcesser:[SRMAPIConfigurator sharedInstance].parameterProcesser];
    }
    
    if ([self.parameterProcesser respondsToSelector:@selector(APIManager:processQueryItems:)]) {
        URL = [self processQueryOfURL:URL withProcesser:self.parameterProcesser];
    }
    
    return URL;
}

- (NSURL *)processQueryOfURL:(NSURL *)URL withProcesser:(id<SRMAPIManagerParameterProcesser>)processer {
    NSURLComponents *URLComponents = [NSURLComponents componentsWithString:URL.absoluteString];
    NSArray<NSURLQueryItem *> *queryItems = [processer APIManager:self processQueryItems:URLComponents.queryItems];
    URLComponents.queryItems = queryItems;
    
    return [URLComponents URL];
}

- (void)successInRequestingWithResponse:(NSHTTPURLResponse *)response Content:(id)content successfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback {
    switch (response.statusCode) {
        case 200:
            if ([self isValidResponseContent:content]) {
                [self respondWithSuccessfulCallback:successfulCallback Content:content];
            } else {
                NSString *message = [self localizedErrorMessageWithKey:kLocalizedErrorMessageKeyInvalidResponseContent];
                NSError *error = [self errorWithCode:SRMAPIManagerResponseErrorInvalidResponseContent message:message];
                [self failToRequestWithResponse:response error:error callback:failedCallback];
            }
            break;
        case 204:
            [self failToRequestWithResponse:response error:nil callback:failedCallback];
            break;
    }
}

- (void)respondWithSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)callback Content:(id)content {
    if ([self shouldPerformSuccessfulCallbackWithContent:content]) {
        if (callback) {
            callback(self, content);
        } else if ([self.responseDelegate respondsToSelector:@selector(APIManager:successInRequestingAPIWithContent:)]) {
            [self.responseDelegate APIManager:self successInRequestingAPIWithContent:content];
        }
    }
    
    [self afterPerformSuccessfulCallbackWithContent:content];
}

- (void)failToRequestWithResponse:(NSHTTPURLResponse *)response error:(NSError *)error callback:(SRMAPIManagerFailedCallback)callback {
    NSInteger statusCode = response.statusCode;
    NSInteger errorCode = SRMAPIManagerResponseErrorUnknown;
    NSString *errorMessage = [self localizedErrorMessageWithKey:kLocalizedErrorMessageKeyUnknown];
    id  responseContent;
    
    if ([error.domain isEqualToString:kSRMAPIManagerErrorDomain] && (error.code == SRMAPIManagerResponseErrorInvalidParameter || error.code == SRMAPIManagerResponseErrorInvalidResponseContent)) {
        errorCode = error.code;
        errorMessage = error.localizedDescription;
        responseContent = error.userInfo[kSRMAPIManagerErrorUserInfoKeyData];
    }
    
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet:
                errorCode = SRMAPIManagerResponseErrorNetworkUnreachable;
                errorMessage = [self localizedErrorMessageWithKey:kLocalizedErrorMessageKeyNetworkUnreachable];
                break;
            case NSURLErrorTimedOut:
                errorCode = SRMAPIManagerResponseErrorTimeout;
                errorMessage = [self localizedErrorMessageWithKey:kLocalizedErrorMessageKeyTimeout];
                break;
        }
    }
    
    if (statusCode == 204) {
        errorCode = SRMAPIManagerResponseErrorNoContent;
        errorMessage = [self localizedErrorMessageWithKey:kLocalizedErrorMessageKeyNoContent];
    }
    
    if (statusCode >= 400 && statusCode < 500) {
        errorCode = SRMAPIManagerResponseErrorClient;
        errorMessage = [self localizedErrorMessageWithKey:kLocalizedErrorMessageKeyClient];
    }
    
    if (statusCode >= 500) {
        errorCode = SRMAPIManagerResponseErrorServer;
        errorMessage = [self localizedErrorMessageWithKey:kLocalizedErrorMessageKeyServer];
    }
    
    if ([error.domain isEqualToString:kSRMAPIProxyErrorDomain] && error.userInfo[kSRMAPIProxyErrorDataKey]) {
        responseContent = error.userInfo[kSRMAPIProxyErrorDataKey];
    }
    
    NSString *customMessage = [self errorMessageForResponse:response content:responseContent errorCode:errorCode];
    
    if (![NSString isNilOrEmptyString:customMessage]) {
        errorMessage = customMessage;
    }
    
    NSError *processedError = [self errorWithCode:errorCode message:errorMessage content:responseContent];
    [self respondWithFailedCallback:callback Error:processedError];
}

- (void)respondWithFailedCallback:(SRMAPIManagerFailedCallback)callback Error:(NSError *)error {
    if ([self shouldPerformFailedCallbackWithError:error]) {
        if (callback) {
            callback(self, error);
        } else if ([self.responseDelegate respondsToSelector:@selector(APIManager:failToRequestAPIWithError:)]) {
            [self.responseDelegate APIManager:self failToRequestAPIWithError:error];
        }
    }
    
    [self afterPerformFailedCallbackWithError:error];
}

@end

@implementation SRMBaseAPIManager (Override)

- (SRMAPIManagerRequestMethodType)requestMethodType {
    return SRMAPIManagerRequestMethodTypeGET;
}

- (NSString *)serverDomain {
    return [SRMAPIConfigurator sharedInstance].defaultDomain;
}

- (NSString *)path {
    return [NSString emptyString];
}

- (SRMAPIManagerParameterType)parameterType {
    return SRMAPIManagerParameterTypeDefault;
}

- (id)parameters {
    return nil;
}

- (NSTimeInterval)timeout {
    return kTimeout;
}

- (BOOL)isValidQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters {
    if ([[SRMAPIConfigurator sharedInstance].parameterValidator respondsToSelector:@selector(APIManager:isValidQueryItems:parameters:)] && ![[SRMAPIConfigurator sharedInstance].parameterValidator APIManager:self isValidQueryItems:queryItems parameters:parameters]) {
        return NO;
    }
    
    if ([self.parameterValidator respondsToSelector:@selector(APIManager:isValidQueryItems:parameters:)] && ![self.parameterValidator APIManager:self isValidQueryItems:queryItems parameters:parameters]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isValidResponseContent:(id)content {
    if ([[SRMAPIConfigurator sharedInstance].responseContentValidator respondsToSelector:@selector(APIManager:isValidResponseContent:)] && ![[SRMAPIConfigurator sharedInstance].responseContentValidator APIManager:self isValidResponseContent:content]) {
        return NO;
    }
    
    if ([self.responseContentValidator respondsToSelector:@selector(APIManager:isValidResponseContent:)] && ![self.responseContentValidator APIManager:self isValidResponseContent:content]) {
        return NO;
    }
    
    return YES;
}

- (NSString *)errorMessageForResponse:(NSHTTPURLResponse *)response content:(id)content errorCode:(SRMAPIManagerResponseErrorCode)errorCode {
    NSString *message = [NSString emptyString];
    
    if ([[SRMAPIConfigurator sharedInstance].errorMessageProcesser respondsToSelector:@selector(APIManager:errorMessageForResponse:content:errorCode:)]) {
        message = [[SRMAPIConfigurator sharedInstance].errorMessageProcesser APIManager:self errorMessageForResponse:response content:content errorCode:errorCode];
    }
    
    if ([self.errorMessageProcesser respondsToSelector:@selector(APIManager:errorMessageForResponse:content:errorCode:)]) {
        message = [self.errorMessageProcesser APIManager:self errorMessageForResponse:response content:content errorCode:errorCode];
    }
    
    return message;
}

- (BOOL)shouldRequestWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters {
    if ([[SRMAPIConfigurator sharedInstance].interceptor respondsToSelector:@selector(APIManager:shouldRequestWithQueryItems:parameters:)] && ![[SRMAPIConfigurator sharedInstance].interceptor APIManager:self shouldRequestWithQueryItems:queryItems parameters:parameters]) {
        return NO;
    }
    
    if ([self.interceptor respondsToSelector:@selector(APIManager:shouldRequestWithQueryItems:parameters:)] && ![self.interceptor APIManager:self shouldRequestWithQueryItems:queryItems parameters:parameters]) {
        return NO;
    }
    
    return YES;
}

- (void)afterRequestWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters {
    if ([[SRMAPIConfigurator sharedInstance].interceptor respondsToSelector:@selector(APIManager:afterRequestWithQueryItems:parameters:)]) {
        [[SRMAPIConfigurator sharedInstance].interceptor APIManager:self afterRequestWithQueryItems:queryItems parameters:parameters];
    }
    
    if ([self.interceptor respondsToSelector:@selector(APIManager:afterRequestWithQueryItems:parameters:)]) {
        [self.interceptor APIManager:self afterRequestWithQueryItems:queryItems parameters:parameters];
    }
}

- (BOOL)shouldPerformSuccessfulCallbackWithContent:(id)content {
    if ([[SRMAPIConfigurator sharedInstance].interceptor respondsToSelector:@selector(APIManager:shouldPerformSuccessfulCallbackWithContent:)] && ![[SRMAPIConfigurator sharedInstance].interceptor APIManager:self shouldPerformSuccessfulCallbackWithContent:content]) {
        return NO;
    }
    
    if ([self.interceptor respondsToSelector:@selector(APIManager:shouldPerformSuccessfulCallbackWithContent:)] && ![self.interceptor APIManager:self shouldPerformSuccessfulCallbackWithContent:content]) {
        return NO;
    }
    
    return YES;
}

- (void)afterPerformSuccessfulCallbackWithContent:(id)content {
    if ([[SRMAPIConfigurator sharedInstance].interceptor respondsToSelector:@selector(APIManager:afterPerformSuccessfulCallbackWithContent:)]) {
        [[SRMAPIConfigurator sharedInstance].interceptor APIManager:self afterPerformSuccessfulCallbackWithContent:content];
    }
    
    if ([self.interceptor respondsToSelector:@selector(APIManager:afterPerformSuccessfulCallbackWithContent:)]) {
        [self.interceptor APIManager:self afterPerformSuccessfulCallbackWithContent:content];
    }
}

- (BOOL)shouldPerformFailedCallbackWithError:(NSError *)error {
    if ([[SRMAPIConfigurator sharedInstance].interceptor respondsToSelector:@selector(APIManager:shouldPerformFailedCallbackWithError:)] && ![[SRMAPIConfigurator sharedInstance].interceptor APIManager:self shouldPerformFailedCallbackWithError:error]) {
        return NO;
    }
    
    if ([self.interceptor respondsToSelector:@selector(APIManager:shouldPerformFailedCallbackWithError:)] && ![self.interceptor APIManager:self shouldPerformFailedCallbackWithError:error]) {
        return NO;
    }
    
    return YES;
}

- (void)afterPerformFailedCallbackWithError:(NSError *)error {
    if ([[SRMAPIConfigurator sharedInstance].interceptor respondsToSelector:@selector(APIManager:afterPerformFailedCallbackWithError:)]) {
        [[SRMAPIConfigurator sharedInstance].interceptor APIManager:self afterPerformFailedCallbackWithError:error];
    }
    
    if ([self.interceptor respondsToSelector:@selector(APIManager:afterPerformFailedCallbackWithError:)]) {
        [self.interceptor APIManager:self afterPerformFailedCallbackWithError:error];
    }
}

@end

@implementation SRMBaseAPIManager (Error)

- (NSError *)errorWithCode:(SRMAPIManagerResponseErrorCode)code message:(NSString *)message {
    return [self errorWithCode:code message:message content:nil];
}

- (NSError *)errorWithCode:(SRMAPIManagerResponseErrorCode)code message:(NSString *)message content:(id)content {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = message;
    userInfo[kSRMAPIManagerErrorUserInfoKeyData] = content;
    NSError *error = [NSError errorWithDomain:kSRMAPIManagerErrorDomain code:code userInfo:[userInfo copy]];
    
    return error;
}

- (NSString *)localizedErrorMessageWithKey:(NSString *)key {
    return [NSBundle localizedStringWithKey:key FromTable:kLocalizedTableName];
}

@end
