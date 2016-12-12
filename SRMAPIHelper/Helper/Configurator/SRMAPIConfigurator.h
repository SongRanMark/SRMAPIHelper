//
// Created by marksong on 12/12/16.
// Copyright (c) 2016 S.R. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRMBaseAPIManager.h"

@protocol SRMAPIManagerParameterProcesser;
@protocol SRMAPIManagerParameterValidator;
@protocol SRMAPIManagerResponseContentValidator;
@protocol SRMAPIManagerErrorMessageProcesser;
@protocol SRMAPIManagerInterceptor;

/**
 请求 API 返回成功响应时，响应内容可转换为的数据类型

 - SRMAPIResponseTypeData: NSData
 - SRMAPIResponseTypeJSON: JSON
 */
typedef NS_ENUM(NSUInteger, SRMAPIResponseType) {
    SRMAPIResponseTypeData,
    SRMAPIResponseTypeJSON
};

/**
 通过该配置器，可以统一实现 API Manager 的一些自定义行为，包括请求前对参数的处理，对参数的校验，
 响应成功时内容的校验以及响应成功或失败的统一处理。
 */
@interface SRMAPIConfigurator : NSObject

/**
 提供给 API Manager 的全局参数处理器。
 */
@property (nonatomic) id<SRMAPIManagerParameterProcesser> parameterProcesser;
/**
 提供给 API Manager 的全局参数校验器。
 */
@property (nonatomic) id<SRMAPIManagerParameterValidator> parameterValidator;
/**
 提供给 API Manager 的全局响应内容校验器。
 */
@property (nonatomic) id<SRMAPIManagerResponseContentValidator> responseContentValidator;
/**
 提供给 API Manager 的全局响应失败错误消息处理器。
 */
@property (nonatomic) id<SRMAPIManagerErrorMessageProcesser> errorMessageProcesser;
/**
 提供给 API Manager 的全局拦截器。
 */
@property (nonatomic) id<SRMAPIManagerInterceptor> interceptor;
/**
 指定响应体数据要解析为的数据类型
 */
@property (nonatomic) SRMAPIResponseType reponseType;
/**
 通过该属性设置 API Manager 默认的域名。
 */
@property (nonatomic) NSString *defaultDomain;
/**
 指定 API Helper 是否开启日志记录
 */
@property (nonatomic) BOOL shouldDebug;

+ (instancetype)sharedInstance;

@end
