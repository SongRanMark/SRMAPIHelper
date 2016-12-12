//
//  SRMAPILogger.h
//  SRMAPIHelper
//
//  Created by marksong on 12/12/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SRMBaseAPIManager;

/**
 打印日志的工具类。
 */
@interface SRMAPILogger : NSObject

@property (nonatomic) BOOL enabled;

+ (instancetype)sharedInstance;
/**
 打印格式化的请求信息日志。

 @param APIManager 发起请求的 API 管理者。
 @param URL        完整的请求 URL。
 @param parameters 请求参数。
 */
- (void)logRequestWithAPIManager:(SRMBaseAPIManager *)APIManager URL:(NSString *)URL parameters:(id)parameters;
/**
 打印格式化的响应信息日志

 @param APIManager 发起请求的 API 管理者。
 @param response   响应头信息。
 @param content    成功响应时的响应体内容。
 @param error      失败响应时的错误信息。
 */
- (void)logResponseWithAPIManager:(SRMBaseAPIManager *)APIManager response:(NSHTTPURLResponse *)response content:(id)content error:(NSError *)error;
/**
 打印格式化的日志信息
 */
- (void)log:(NSString *)format, ...;

@end
