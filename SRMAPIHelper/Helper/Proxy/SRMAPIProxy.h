//
//  SRMAPIProxy.h
//  SRMAPIHelper
//
//  Created by marksong on 12/6/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSRMAPIProxyErrorDomain;
extern NSString * const kSRMAPIProxyErrorDataKey;

/**
 代理支持的请求方法类型

 - SRMAPIProxyHTTPMethodGet:    Get 方法
 - SRMAPIProxyHTTPMethodPost:   Post 方法
 - SRMAPIProxyHTTPMethodPut:    Put 方法
 - SRMAPIProxyHTTPMethodDelete: Delete 方法
 */
typedef NS_ENUM (NSUInteger, SRMAPIProxyHTTPMethod){
    SRMAPIProxyHTTPMethodGet,
    SRMAPIProxyHTTPMethodPost,
    SRMAPIProxyHTTPMethodPut,
    SRMAPIProxyHTTPMethodDelete
};

/**
 代理发送请求时参数的格式

 - SRMAPIProxyParameterTypeTypeDefault: GET 和 DELETE 方法将参数放入 query 中，POST 
 和 PUT 方法的参数格式为 application/x-www-form-urlencoded
 - SRMAPIProxyParameterTypeTypeJSON:    GET 和 DELETE 方法将参数放入 query 中，POST
 和 PUT 方法的参数格式为 application/json
 */
typedef NS_ENUM(NSUInteger, SRMAPIProxyParameterType){
    SRMAPIProxyParameterTypeDefault,
    SRMAPIProxyParameterTypeJSON
};

/**
 代理返回的响应中响应体内容的数据类型

 - SRMAPIProxyResponseContentTypeData: NSData
 - SRMAPIProxyResponseContentTypeJSON: JSON 格式对应的 NSArray 或 NSDictionary 等类型
 */
typedef NS_ENUM(NSUInteger, SRMAPIProxyResponseContentType) {
    SRMAPIProxyResponseContentTypeData,
    SRMAPIProxyResponseContentTypeJSON
};

/**
 代理请求响应成功的回调 block

 @param response 代表响应相关信息的 NSHTTPURLResponse 实例
 @param content  响应体内容，根据配置可能是 NSData 类型或 JSON 类型
 */
typedef void(^SRMAPIProxySuccessfulCallback)(NSHTTPURLResponse *response, id content);
/**
 代理请求响应失败的回调 block

 @param response 代表响应相关信息的 NSHTTPURLResponse 实例
 @param error    封装失败错误信息的 NSError 实例。若错误原因为应用客户端错误，则 error domain
 为 NSURLErrorDomain，可根据 code 判断错误原因。若返回响应但状态码不为 2xx 时，error domain 
 为 kSRMAPIProxyErrorDomain，在 userInfo 中可根据键 kSRMAPIProxyErrorDataKey获取响应
 内容，内容数据类型根据配置可能是 NSString 类型或 JSON 类型。
 */
typedef void(^SRMAPIProxyFailedCallback)(NSHTTPURLResponse *response, NSError *error);

/**
 对 AFNetworking 框架的调用封装，根据请求方法接收的请求相关信息，调用 AFNetworking 组装请求
 并发起，以回调 block 的形式返回响应。
 */
@interface SRMAPIProxy : NSObject

/**
 指定响应体内容要解析为的数据类型，默认为 SRMAPIProxyResponseContentTypeJSON。
 */
@property (nonatomic) SRMAPIProxyResponseContentType responseContentType;

+ (instancetype)sharedInstance;
/**
 发起一个请求，并在收到响应后执行传入的响应回调 block。

 @param method             请求方法类型
 @param URL                请求 URL
 @param parameterType      请求参数格式
 @param parameters         请求参数
 @param timeoutInterval    请求超时时间
 @param successfulCallback 请求成功时的响应回调
 @param failedCallback     请求失败时的响应回调，当 HTTP 响应的状态码不为 2xx 时，会执行此
 失败的响应回调
 */
- (void)requestByMethod:(SRMAPIProxyHTTPMethod)method URL:(NSString *)URL parameterType:(SRMAPIProxyParameterType)parameterType parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval successfulCallback:(SRMAPIProxySuccessfulCallback)successfulCallback failedCallback:(SRMAPIProxyFailedCallback)failedCallback;

@end
