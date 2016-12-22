//
//  SRMAPIProxy.m
//  SRMAPIHelper
//
//  Created by marksong on 12/6/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMAPIProxy.h"
#import "SRMAPILogger.h"
#import <AFNetworking/AFNetworking.h>

NSString * const kSRMAPIProxyErrorDomain = @"com.sr.api.proxy.error";
NSString * const kSRMAPIProxyErrorDataKey = @"com.sr.api.proxy.error.data";
static NSTimeInterval kTimeoutInterval = 15;

@interface  SRMAPIProxy ()

@property (nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation SRMAPIProxy

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.responseContentType = SRMAPIProxyResponseContentTypeJSON;
    }

    return self;
}

#pragma mark - Public

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SRMAPIProxy *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });

    return sharedInstance;
}

/**
 作为网络请求代理层对上层 API manager 层的接口，该方法封装了具体的网络请求操作，调用 AFNetworking
 框架实现功能，当要切换其他网络框架或想使用原生网络框架时，只需修改该接口即可。
 */
-(void)requestByMethod:(SRMAPIProxyHTTPMethod)method URL:(NSString *)URL parameterType:(SRMAPIProxyParameterType)parameterType parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval successfulCallback:(SRMAPIProxySuccessfulCallback)successfulCallback failedCallback:(SRMAPIProxyFailedCallback)failedCallback {
    self.sessionManager.requestSerializer = [self requestSerializerByParameterType:parameterType timeoutInterval:timeoutInterval];

    switch (method) {
        case SRMAPIProxyHTTPMethodGet: {
            [self.sessionManager GET:URL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                successfulCallback((NSHTTPURLResponse *) task.response, responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failedCallback((NSHTTPURLResponse *) task.response, [self processedError:error]);
            }];
        }
            break;
        case SRMAPIProxyHTTPMethodPost:
        {
            [self.sessionManager POST:URL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                successfulCallback((NSHTTPURLResponse *) task.response, responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failedCallback((NSHTTPURLResponse *) task.response, [self processedError:error]);
            }];
        }
            break;
        case SRMAPIProxyHTTPMethodPut:
        {
            [self.sessionManager PUT:URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                successfulCallback((NSHTTPURLResponse *) task.response, responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failedCallback((NSHTTPURLResponse *) task.response, [self processedError:error]);
            }];
        }
            break;
        case SRMAPIProxyHTTPMethodDelete:
        {
            [self.sessionManager DELETE:URL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                successfulCallback((NSHTTPURLResponse *) task.response, responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failedCallback((NSHTTPURLResponse *) task.response, [self processedError:error]);
            }];
        }
            break;
    }
}

#pragma mark - Private

- (AFHTTPRequestSerializer *)requestSerializerByParameterType:(SRMAPIProxyParameterType)parameterType timeoutInterval:(NSTimeInterval)timeout {
    AFHTTPRequestSerializer *serializer;
    
    switch (parameterType) {
        case SRMAPIProxyParameterTypeDefault:
            serializer = [AFHTTPRequestSerializer serializer];
            break;
        case SRMAPIProxyParameterTypeJSON:
            serializer = [AFJSONRequestSerializer serializer];
            break;
    }
    
    
    serializer.timeoutInterval = timeout > 0 ? timeout : kTimeoutInterval;
    
    return serializer;
}

/*
 当服务器成功响应，但响应状态码不为 2xx 时，AFNetworking 会以失败回调处理响应，响应内容以 data
 的形式保存在返回的 error 中。处理返回的 error 的意义在于 AFNetworking 并不会对失败的响应内容
 做转换，这里可根据 responseContentType 的设置，尝试将响应内容转换为字符串或 JSON 类型，一般
 这类响应内容包含请求失败的原因，最终提供给业务层便于使用。另外，这类 error 设置为 AFNetworking
 自己的 domain 和 code，为了达到封装和屏蔽的目的，应替换为代理层定义的  domain 和 code
 */
- (NSError *)processedError:(NSError *)error {
    if (![error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
        return error;
    }

    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSDictionary *userInfo;

    if (errorData) {
        id dataObject;

        switch (self.responseContentType) {
            case SRMAPIProxyResponseContentTypeData:
                dataObject = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];

                if (!dataObject) {
                    [[SRMAPILogger sharedInstance] log:@"Failed to parse error content to text"];
                }

                break;
            case SRMAPIProxyResponseContentTypeJSON: {
                NSError *parsingError;
                dataObject = [NSJSONSerialization JSONObjectWithData:errorData options:0 error:&parsingError];

                if (parsingError) {
                    [[SRMAPILogger sharedInstance] log:@"Failed to parse error content as json : %@", parsingError];
                }
            }
                break;
        }

        if (dataObject) {
            userInfo = @{kSRMAPIProxyErrorDataKey:dataObject};
        }
    }

    NSError *proxyError = [NSError errorWithDomain:kSRMAPIProxyErrorDomain code:0 userInfo:userInfo];

    return proxyError;
}

#pragma mark - Setter

/*
 因为对请求的实现使用了 AFNetworking 的便捷方法，所以响应中返回的是 AFNetworking 已解析的内容。
 而 AFNetworking 对响应的解析类型支持 session manager 级别的设置，且由于响应返回的异步性，这
 就使得代理层无法通过接收参数的方式设置针对每一个请求的响应解析类型。代理层只暴露一个 property
 接口 responseContentType 供外部全局统一修改代理层的响应内容解析类型。(后续修改可考虑使用
 AFNetworking 的底层调用，获取响应的原始 data 类型，这样则可根据每一次请求级别的设置，转换为
 不同数据类型的响应内容)
 */
- (void)setResponseContentType:(SRMAPIProxyResponseContentType)responseContentType {
    _responseContentType = responseContentType;

    switch (responseContentType) {
        case SRMAPIProxyResponseContentTypeData:
            self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case SRMAPIProxyResponseContentTypeJSON:
            self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
    }
}

#pragma mark - Getter

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
    }

    return _sessionManager;
}

@end
