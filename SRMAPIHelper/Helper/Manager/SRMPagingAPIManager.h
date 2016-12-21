//
//  SRMPagingAPIManager.h
//  SRMAPIHelper
//
//  Created by marksong on 12/21/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMBaseAPIManager.h"

/**
 对 Base API Manager 进行翻页功能的扩展，支持翻页的列表 API 可直接继承该类从而无需再单独处理
 翻页的参数。该类重写了[- parameters]方法，返回一个 NSDictionary 类型的值，其中包含每页数量
 和页数两个参数，所以子类在实现[- parameters]方法添加参数时，要注意添加 super 类的返回值。对于
 两个参数真正的键值，需要子类实现[- perPageKey]和[- pageKey]方法来指定，默认实现返回空字符串，
 没有意义。该类还重写了成功响应前的拦截器方法[- shouldPerformSuccessfulCallbackWithContent:]，
 用于更新当前页数的值，子类如果要重写该方法则需要调用 super 的实现。使用时，可以单独设置每页数量，
 可以获取当前页数(但不可修改)，通过方法可以请求指定页数或上一页及下一页的数据。为了灵活的适配 API，
 在该类中并没有对页数的值作任何限制，子类可根据实际情况添加校验。初始化时，每页数量默认为 10，当前
 页数默认为 0，子类可根据实际情况在初始化方法中修改。
 */
@interface SRMPagingAPIManager : SRMBaseAPIManager

/**
 每页数量
 */
@property (nonatomic) NSUInteger perPage;
/**
 当前页数
 */
@property (nonatomic, readonly) NSUInteger currentPage;

/**
 指定每页数量的参数键值
 */
- (NSString *)perPageKey;
/**
 指定请求页数的参数键值
 */
- (NSString *)pageKey;

/**
 请求上一页
 */
- (void)requestLastPage;
- (void)requestLastPageWithSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback;

/**
 请求下一页
 */
- (void)requestNextPage;
- (void)requestNextPageWithSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback;

/**
 请求指定页
 */
- (void)requestPage:(NSUInteger)page;
- (void)requestPage:(NSUInteger)page withSuccessfulCallback:(SRMAPIManagerSuccessfulCallback)successfulCallback failedCallback:(SRMAPIManagerFailedCallback)failedCallback;

@end
