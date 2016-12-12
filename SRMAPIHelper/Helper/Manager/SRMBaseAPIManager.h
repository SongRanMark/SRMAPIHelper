//
// Created by marksong on 12/12/16.
// Copyright (c) 2016 S.R. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 API 的 HTTP 请求方法类型。

 - SRMAPIManagerRequestMethodTypeGET:    GET
 - SRMAPIManagerRequestMethodTypePOST:   POST
 - SRMAPIManagerRequestMethodTypePUT:    PUT
 - SRMAPIManagerRequestMethodTypeDELETE: DELETE
 */
typedef NS_ENUM (NSUInteger, SRMAPIManagerRequestMethodType){
    SRMAPIManagerRequestMethodTypeGET,
    SRMAPIManagerRequestMethodTypePOST,
    SRMAPIManagerRequestMethodTypePUT,
    SRMAPIManagerRequestMethodTypeDELETE
};

extern NSString * const kSRMAPIManagerErrorDomain;
extern NSString * const kSRMAPIManagerErrorUserInfoKeyData;

/**
 请求 API 返回失败响应时，可能的代表错误原因的 error code。

 - SRMAPIManagerResponseErrorUnknown:                未知错误。
 - SRMAPIManagerResponseErrorNoContent:              空数据。
 - SRMAPIManagerResponseErrorInvalidParameter:       参数不合法。
 - SRMAPIManagerResponseErrorInvalidResponseContent: 响应内容不合法。
 - SRMAPIManagerResponseErrorNetworkUnreachable:     网络暂不可用。
 - SRMAPIManagerResponseErrorTimeout:                请求超时。
 - SRMAPIManagerResponseErrorClient:                 HTTP 客户端错误。
 - SRMAPIManagerResponseErrorServer:                 HTTP 服务端错误。
 */
typedef NS_ENUM (NSUInteger, SRMAPIManagerResponseErrorCode){
    SRMAPIManagerResponseErrorUnknown,
    SRMAPIManagerResponseErrorNoContent,
    SRMAPIManagerResponseErrorInvalidParameter,
    SRMAPIManagerResponseErrorInvalidResponseContent,
    SRMAPIManagerResponseErrorNetworkUnreachable,
    SRMAPIManagerResponseErrorTimeout,
    SRMAPIManagerResponseErrorClient,
    SRMAPIManagerResponseErrorServer,
};

@interface SRMBaseAPIManager : NSObject

/**
 子类重写该方法，返回对应的 HTTP 请求方法类型，默认返回 SRMAPIManagerRequestMethodTypeGET。

 @return HTTP 请求方法类型。
 */
- (SRMAPIManagerRequestMethodType)requestMethodType;

@end

/**
 API Manager 响应回调的委托协议。
 */
@protocol SRMAPIManagerResponseDelegate <NSObject>

/**
 返回成功响应时执行，HTTP 响应的状态码不为 2xx 时，属于失败响应，另外，当请求数据为空，返回状态
 码为 204 时，也属于失败响应。

 @param APIManager 发起请求的 API 管理者。
 @param content 响应体内容，根据配置可能是 NSData 或者 JSON 类型。
 */
- (void)APIManager:(SRMBaseAPIManager *)APIManager successInRequestingAPIWithContent:(id)content;
/**
 失败的响应错误信息以 kSRMAPIManagerErrorDomain 为域的 NSError 对象形式提供。响应体的内容
 可以通过键值 kSRMAPIManagerErrorDataKey 从 error 的 userInfo 中获取。可根据 error 的 
 code 判断错误的类型。

 @param APIManager 发起请求的 API 管理者。
 @param error   响应失败的错误信息。
 */
- (void)APIManager:(SRMBaseAPIManager *)APIManager failToRequestAPIWithError:(NSError *)error;

@end

/**
 API Manager 请求前处理参数的委托协议。
 */
@protocol SRMAPIManagerParameterProcesser <NSObject>

@optional
/**
 对请求 URL 的 query 部分参数的处理，不管请求的类型是哪一种，这里返回的参数键值对都会放在 query
 部分。
 
 @param APIManager 发起请求的 API 管理者。
 @param queryItems 当前 URL 中 query 部分转换成的 NSURLQueryItem 的数组。
 
 @return 处理后的 NSURLQueryItem 的数组。
 */
- (NSArray<NSURLQueryItem *> *)APIManager:(SRMBaseAPIManager *)APIManager processQueryItems:(NSArray<NSURLQueryItem *> *)queryItems;
/**
 对提供的参数的处理，已通过 path 方法写入的 query 参数不会传入，这部分参数根据请求方法(GET、POST...)
 的不同，以及 Content-Type 的设置，将以不同的形式存入请求。GET 请求仍会放入 query 中，POST 
 请求根据 Content-Type 可能以 json，urlencode 等格式保存到请求体中。
 
 @param APIManager 发起请求的 API 管理者。
 @param parameters API Manager 提供的参数。
 
 @return 处理后的用于 API Manager 的参数。
 */
- (id)APIManager:(SRMBaseAPIManager *)APIManager processParameters:(id)parameters;

@end

/**
 对 API Manager 的 query 和参数进行校验的委托协议。
 */
@protocol SRMAPIManagerParameterValidator <NSObject>

/**
 根据传入的已处理过的 query 和参数，检查请求参数是否合法，若返回 NO，则最终返回失败类型为参数错误
 的失败响应。

 @param APIManager 发起请求的 API 管理者。
 @param queryItems 已处理过的 URL 中 query 部分转换成的 NSURLQueryItem 的数组。
 @param parameters 已处理过的 API Manager 的参数。

 @return 指明参数是否合法
 */
- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager isValidQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters;

@end

/**
 返回成功响应时，对响应内容进行校验的委托协议。
 */
@protocol SRMAPIManagerResponseContentValidator <NSObject>

/**
 根据传入响应体内容，检查内容格式是否合法，若返回 NO，则最终返回失败类型为响应体内容不合法的失败响应。

 @param APIManager APIManager 发起请求的 API 管理者。
 @param content    响应体内容，根据配置可能是 NSData 或者 JSON 类型。

 @return 指明响应内容是否合法
 */
- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager isValidResponseContent:(id)content;

@end

/**
 API Manager 对失败的响应，处理返回的错误消息的委托协议。
 */
@protocol SRMAPIManagerErrorMessageProcesser <NSObject>

/**
 根据提供的响应信息返回自定义错误信息。
 
 @param APIManager APIManager 发起请求的 API 管理者。
 @param response 返回的响应头信息，当失败情况为客户端未成功发起请求，则该值为空。
 @param content 当成功发起请求，但响应状态码为失败的情况时，响应体的内容。其他情况该值可能为空。
 @param errorCode 对应的错误状态码，可根据此判断错误类型。
 
 @return 自定义错误信息，若返回空字符串或 nil，则使用系统定义的标准错误信息(可在
 LocalizableAPIManagerResponseMessage.strings 文件中设置)，所以委托类可只针对某些特殊情况
 定义错误信息，其他情况直接返回 nil 或空字符串即可。
 */
- (NSString *)APIManager:(SRMBaseAPIManager *)APIManager errorMessageForResponse:(NSHTTPURLResponse *)response content:(id)content errorCode:(SRMAPIManagerResponseErrorCode)errorCode;

@end

/**
 API Manager 在执行请求或响应回调前后的拦截器委托协议，执行请求或回调前的委托方法会返回一个 BOOL 
 值，其可以决定是否执行具体的请求或响应回调。
 */
@protocol SRMAPIManagerInterceptor <NSObject>

@optional
/**
 发起请求前的拦截器方法。

 @param APIManager APIManager 发起请求的 API 管理者。
 @param queryItems 已校验的 URL 中 query 部分转换成的 NSURLQueryItem 的数组。
 @param parameters 已校验的 API Manager 的参数。

 @return 指明是否发起请求
 */
- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager shouldRequestWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters;
/**
 发起请求后的拦截器方法。

 @param APIManager APIManager 发起请求的 API 管理者。
 @param queryItems 已校验的 URL 中 query 部分转换成的 NSURLQueryItem 的数组。
 @param parameters 已校验的 API Manager 的参数。
 */
- (void)APIManager:(SRMBaseAPIManager *)APIManager afterRequestWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters;
/**
 执行成功响应回调前的拦截器方法。

 @param APIManager APIManager 发起请求的 API 管理者。
 @param content    响应体内容，根据配置可能是 NSData 或者 JSON 类型。

 @return 指明是否执行成功响应回调。
 */
- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager shouldPerformSuccessfulCallbackWithContent:(id)content;
/**
 执行成功响应回调后的拦截器方法。

 @param APIManager APIManager 发起请求的 API 管理者。
 @param content    响应体内容，根据配置可能是 NSData 或者 JSON 类型。
 */
- (void)APIManager:(SRMBaseAPIManager *)APIManager afterPerformSuccessfulCallbackWithContent:(id)content;
/**
 执行失败响应回调前的拦截器方法。

 @param APIManager APIManager 发起请求的 API 管理者。
 @param error      响应失败的错误信息。

 @return 指明是否执行失败响应回调。
 */
- (BOOL)APIManager:(SRMBaseAPIManager *)APIManager shouldPerformFailedCallbackWithError:(NSError *)error;
/**
 执行失败响应回调后的拦截器方法。

 @param APIManager APIManager 发起请求的 API 管理者。
 @param error      响应失败的错误信息。
 */
- (void)APIManager:(SRMBaseAPIManager *)APIManager afterPerformFailedCallbackWithError:(NSError *)error;

@end
