//
// Created by marksong on 12/12/16.
// Copyright (c) 2016 S.R. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SRMAPIManagerResponseDelegate;
@protocol SRMAPIManagerParameterProcesser;
@protocol SRMAPIManagerParameterValidator;
@protocol SRMAPIManagerResponseContentValidator;
@protocol SRMAPIManagerErrorMessageProcesser;
@protocol SRMAPIManagerInterceptor;
@class SRMBaseAPIManager;

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

/**
 发送 API 请求时，参数的格式

 - SRMAPIManagerParameterTypeDefault: GET 和 DELETE 请求参数将放入 query 中，POST 和
 PUT 请求的格式为 application/x-www-form-urlencoded
 - SRMAPIManagerParameterTypeJSON:    请求头字段 Content-Type 设为 application/json，
 参数将被解析为 JSON 格式的文本。
 */
typedef NS_ENUM(NSUInteger, SRMAPIManagerParameterType){
    SRMAPIManagerParameterTypeDefault,
    SRMAPIManagerParameterTypeJSON
};

extern NSString * const kSRMAPIManagerErrorDomain;
extern NSString * const kSRMAPIManagerErrorUserInfoKeyData;

/**
 请求 API 成功响应回调 block

 @param manager 发起请求的 API 管理者。
 @param content 响应体内容，根据配置可能是 NSData 或者 JSON 类型。
 */
typedef void(^SRMAPIManagerSuccessfulCallback)(SRMBaseAPIManager *manager, id content);
/**
 请求 API 失败响应回调 block

 @param manager 发起请求的 API 管理者。
 @param error   响应失败的错误信息。
 */
typedef void(^SRMAPIManagerFailedCallback)(SRMBaseAPIManager *manager, NSError *error);

/**
 请求 API 返回失败响应时，代表可能的错误原因的 error code。

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

/**
 所有 API Manager 的基类，实现了发起请求，响应回调等公共逻辑。
 */
@interface SRMBaseAPIManager : NSObject

/**
 提供给业务方的处理响应的委托。
 */
@property (nonatomic, weak) id<SRMAPIManagerResponseDelegate> responseDelegate;
/**
 提供给业务方的在请求前加工处理参数的委托，与配置器中添加的参数处理器遵守相同的协议。配置的参数处理器
 是全局的，所有 Manager 都会执行，而该参数处理器只是针对 Manager 本身的，虽然 Manager 在 parameters
 方法中就有处理参数的机会，但一些想统一设置的外部参数是无法传入的，所以这就是该代理的使用场景，可针对
 各别几个 API 统一添加参数，只要有一个符合该协议的实例就可以了。如果是所有 API 都需要添加的参数，
 例如 token，则直接配置全局处理器更方便。全局处理器会先执行，处理过的参数，会被 Manager 的处理器
 执行。该委托给了业务端在请求前进一步处理参数的机会。
 */
@property (nonatomic, weak) id<SRMAPIManagerParameterProcesser> parameterProcesser;
/**
 供业务方在请求 API 前校验参数的委托。使用场景为，当几个 API 有相同的校验逻辑时，可实现一个校验器
 委托类，在使用 Manager 时，设置该属性。
 */
@property (nonatomic, weak) id<SRMAPIManagerParameterValidator> parameterValidator;
/**
 供业务方在调用响应成功回调前校验响应内容的委托，若校验失败，则调用响应失败回调。使用场景为，当几个
 API 有相同的校验逻辑时，可实现一个校验器委托类，在使用 Manager 时，设置该属性。
 */
@property (nonatomic, weak) id<SRMAPIManagerResponseContentValidator> responseContentValidator;
/**
 供业务方在请求失败时自定义提示消息的委托
 */
@property (nonatomic, weak) id<SRMAPIManagerErrorMessageProcesser> errorMessageProcesser;
/**
 供业务方在执行请求或响应回调前后的拦截器委托
 */
@property (nonatomic, weak) id<SRMAPIManagerInterceptor> interceptor;

/**
 执行请求操作，响应回调触发 SRMAPIManagerResponseDelegate 代理方法。request 方法是触发底层
 网络请求的接口，由基类统一实现，所以 API Manager 子类无法在该方法处设置请求参数。根据代码的书写
 和阅读习惯，设置参数的代码应该跟请求的代码放在一处，所以 API Manager 子类需要自己定义设置参数的
 方法，格式可以统一为 setParametersWith...，在调用 request 方法前，执行设置参数的方法。因为
 每个 API 接收的参数不同，所以这样可以灵活控制用户的输入，并能提示数据类型，如果所要求参数较多，则
 可直接接收一个字典类型，并在注释中标明字段。
 */
- (void)request;
/**
 执行请求操作并同时传入处理成功和失败响应的回调，若回调为空，则执行对应代理方法，否则不执行代理方法。
 虽然 API Manager 同时提供了 block 和代理两种处理响应的方式，但实际使用中建议统一使用一种，
 以便于维护管理，建议使用代理。

 @param successfulCallback 成功响应回调 block
 @param failedCallback     失败响应回调 block
 */
- (void)requestWithSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback;

@end

/**
 对应真正 API 的 Manager 子类通过重写该分类中的方法自定义请求信息。
 */
@interface SRMBaseAPIManager (Override)

/**
 子类重写该方法，返回对应的 HTTP 请求方法类型，默认返回 SRMAPIManagerRequestMethodTypeGET。

 @return HTTP 请求方法类型。
 */
- (SRMAPIManagerRequestMethodType)requestMethodType;
/**
 应用中可能有多个服务端提供 API，子类通过重写该方法返回所请求 API 的服务器域名。该方法默认返回在
 SRMAPIConfigurator 中配置的默认域名。使用者可自己创建域名列表常量文件，在 APIManager 子类中
 使用相关值即可。服务端提供的 API，可能使用 HTTP 或 HTTPS 协议，域名中要包括协议名，
 如“https://api.example.com”。如果你希望将 path 部分的 API 版本信息也写在域名部分，需要在
 最后加反斜线，如“https://api.example.com/v1/”，且在[- path]方法返回值的开始处不能加反斜
 线，否则最终请求的 URL 中 path 部分将以[- path]方法的返回值开始。

 @return API 的服务器域名
 */
- (NSString *)serverDomain;
/**
 子类重写该方法，返回 API 的 path 段内容。若以"/"开始，则会覆盖[- serverDomain]方法中可能添加
 的 path 部分。
 
 @return API 的路径
 */
- (NSString *)path;
/**
 子类重写该方法，指定请求参数的格式，默认返回 SRMAPIManagerParameterTypeDefault

 @return 请求参数的格式类型
 */
- (SRMAPIManagerParameterType)parameterType;
/**
 子类重写该方法，提供请求 API 时的参数，子类可对外提供接口收集参数信息，之后在该方法中对收集到的
 参数进行加工，组装。另外可以添加不需要业务方提供的参数，比如一个 API 某一参数为几种固定的值，在
 客户端将其分为几个不同的 API Manager 提供可能更合理，这时可以在该方法中设置对应的参数的值。默认
 返回 nil。
 
 @return API 参数，因为最终可能转换成请求中不同的格式，所以类型没有限制。
 */
- (id)parameters;
/**
 默认值为 15 秒，子类可通过重写该方法，设置 API 的请求超时时间。

 @return 请求超时时间
 */
- (NSTimeInterval)timeout;
/**
 请求前验证 query 和参数是否合法的方法，如果返回 NO，则不发起请求，响应失败的回调中，错误代码为
 参数错误。如果请求前的拦截器方法返回 NO，则该方法不会执行。默认实现会先调用配置器内全局委托，再
 调用 Manager 自己的委托。如果全局委托返回 NO，则 Manager 的委托方法不会执行。子类可重写该方法
 实现自己的逻辑，如果子类在实现中希望使用基类的实现逻辑，则要手动调用 super 的实现，这样可以使子类
 有机会控制委托类实现的调用时机。

 @param queryItems 当前 URL 中 query 部分转换成的 NSURLQueryItem 的数组。
 @param parameters API Manager 提供的参数。

 @return 指明请求参数是否合法
 */
- (BOOL)isValidQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters;
/**
 当响应状态码为 200 时触发，用于校验响应内容，如果返回 NO，则调用失败响应，错误类型为响应数据格式
 错误。默认实现会先调用配置器内全局委托，再调用 Manager 自己的委托。子类可重写该方法实现自己的
 逻辑，如果子类在实现中希望使用基类的实现逻辑，则要手动调用 super 的实现，这样可以使子类有机会控制
 委托类实现的调用时机。

 @param content 响应体内容，根据配置可能是 NSData 类型或 JSON 类型

 @return 指明响应内容是否合法
 */
- (BOOL)isValidResponseContent:(id)content;
/**
 根据提供的响应信息返回一个合适的错误提示消息。默认实现会先调用配置器内全局委托，再调用 Manager 
 自己的委托。如果两个方法同时处理了同一种响应失败的情况，Manager 的委托会覆盖全局委托。同样，子类
 针对某一错误类型返回的错误消息会覆盖委托的返回值。当发生参数错误时，如果该 API Manager 的参数是
 用户的输入值，可在该方法中设置对应的提示消息，如果为程序内部传入，则不需要自定义信息，只需根据系统
 消息调试即可。

 @param response  代表响应相关信息的 NSHTTPURLResponse 实例
 @param content   响应体内容，根据配置可能是 NSData 类型或 JSON 类型
 @param errorCode 错误类型码

 @return 自定义错误信息，若返回空字符串或 nil，则使用系统定义的标准错误信息(可在
 LocalizableAPIManagerErrorMessage.strings 文件中设置)。
 */
- (NSString *)errorMessageForResponse:(NSHTTPURLResponse *)response content:(id)content errorCode:(SRMAPIManagerResponseErrorCode)errorCode;
/**
 请求前的的拦截方法，如果返回 NO，则不发起请求，但请求后的拦截方法会执行。返回 YES 后会执行验证
 参数的方法，如果验证参数返回 NO，也不会发起请求，但会执行失败响应的处理。默认实现会先调用配置器内
 全局委托，再调用 Manager 自己的委托。如果全局委托返回 NO，则 Manager 的委托方法不会执行。子类
 可重写该方法实现自己的逻辑，如果子类在实现中希望使用基类的实现逻辑，则要手动调用 super 的实现，
 这样可以使子类有机会控制委托类实现的调用时机。

 @param queryItems 当前 URL 中 query 部分转换成的 NSURLQueryItem 的数组。
 @param parameters API Manager 提供的参数。

 @return 指明是否发起请求
 */
- (BOOL)shouldRequestWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters;
/**
 请求后的的拦截方法，默认实现会先调用配置器内全局委托，再调用 Manager 自己的委托。子类可重写该
 方法实现自己的逻辑，如果子类在实现中希望使用基类的实现逻辑，则要手动调用 super 的实现，这样可以
 使子类有机会控制委托类实现的调用时机。

 @param queryItems 当前 URL 中 query 部分转换成的 NSURLQueryItem 的数组。
 @param parameters API Manager 提供的参数。
 */
- (void)afterRequestWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems parameters:(id)parameters;
/**
 执行成功响应回调前的拦截方法，如果返回 NO，则不执行回调，但执行响应后的拦截方法会执行。默认实现会
 先调用配置器内全局委托，再调用 Manager 自己的委托。如果全局委托返回 NO，则 Manager 的委托方法
 不会执行。子类可重写该方法实现自己的逻辑，如果子类在实现中希望使用基类的实现逻辑，则要手动调用 
 super 的实现，这样可以使子类有机会控制委托类实现的调用时机。

 @param content 响应体内容，根据配置可能是 NSData 或者 JSON 类型。

 @return 指明是否执行成功响应回调。
 */
- (BOOL)shouldPerformSuccessfulCallbackWithContent:(id)content;
/**
 执行成功响应后的拦截方法，默认实现会先调用配置器内全局委托，再调用 Manager 自己的委托。子类可重
 写该方法实现自己的逻辑，如果子类在实现中希望使用基类的实现逻辑，则要手动调用 super 的实现，这样
 可以使子类有机会控制委托类实现的调用时机。

 @param content 响应体内容，根据配置可能是 NSData 或者 JSON 类型。
 */
- (void)afterPerformSuccessfulCallbackWithContent:(id)content;
/**
 执行失败响应回调前的拦截方法，如果返回 NO，则不执行回调，但执行响应后的拦截方法会执行。默认实现会
 先调用配置器内全局委托，再调用 Manager 自己的委托。如果全局委托返回 NO，则 Manager 的委托方法
 不会执行。子类可重写该方法实现自己的逻辑，如果子类在实现中希望使用基类的实现逻辑，则要手动调用
 super 的实现，这样可以使子类有机会控制委托类实现的调用时机。

 @param error 响应失败的错误信息。

 @return 指明是否执行失败响应回调。
 */
- (BOOL)shouldPerformFailedCallbackWithError:(NSError *)error;
/**
 执行失败响应后的拦截方法，默认实现会先调用配置器内全局委托，再调用 Manager 自己的委托。子类可重
 写该方法实现自己的逻辑，如果子类在实现中希望使用基类的实现逻辑，则要手动调用 super 的实现，这样
 可以使子类有机会控制委托类实现的调用时机。

 @param error 响应失败的错误信息。
 */
- (void)afterPerformFailedCallbackWithError:(NSError *)error;

@end

/**
 该分类提供了一些与请求错误相关的辅助方法。
 */
@interface SRMBaseAPIManager (Error)

/**
 子类可扩展 SRMAPIManagerResponseErrorCode，建议设为负数值避免与标准错误冲突，之后可使用该
 方法封装错误域为 kSRMAPIManagerErrorDomain 的错误实例。

 @param code    错误代码
 @param message 本地错误描述

 @return 错误域为 kSRMAPIManagerErrorDomain 的错误实例
 */
- (NSError *)errorWithCode:(SRMAPIManagerResponseErrorCode)code message:(NSString *)message;
/**
 通过错误代码，错误描述及错误数据封装错误域为 kSRMAPIManagerErrorDomain 的错误实例。错误数据
 为userInfo 中 kSRMAPIManagerErrorUserInfoKeyData 的值。

 @param code    错误代码
 @param message 本地错误描述
 @param content userInfo 中 kSRMAPIManagerErrorUserInfoKeyData 的值

 @return 错误域为 kSRMAPIManagerErrorDomain 的错误实例
 */
- (NSError *)errorWithCode:(SRMAPIManagerResponseErrorCode)code message:(NSString *)message content:(id)content;
/**
 当子类要提供自定义错误信息时，如不想再单独创建.strings文件，可将字段加入标准错误信息所在的
 LocalizableAPIManagerErrorMessage.strings文件中，之后使用该方法传入 key 值即可。使用者
 如果想修改标准错误信息，可以修改文件中对应字段的值。
 */
- (NSString *)localizedErrorMessageWithKey:(NSString *)key;

@end

/**
 API Manager 响应回调的委托协议。
 */
@protocol SRMAPIManagerResponseDelegate <NSObject>

/**
 返回成功响应时执行，HTTP 响应的状态码不为 200 时，属于失败响应，例如，当请求数据为空，返回状态
 码为 204 时，属于失败响应。

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
 
 @param APIManager 发起请求的 API 管理者。
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
 API Manager 在执行请求或响应回调前后的拦截器委托协议，执行请求或响应回调前的委托方法会返回一个
 BOOL 值，其可以决定是否执行具体的请求或响应回调。
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
