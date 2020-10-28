//
//  HttpRequestHeader.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/8/6.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResult.h"
#import <ReactiveObjC/RACEXTScope.h>

#pragma mark -
///=============================================================================
/// @name
///=============================================================================

NS_ASSUME_NONNULL_BEGIN

@class GTask<T>;
@class GTaskResult<T>;
@class HttpRequest;

#pragma mark - HTTP_CONFIG_DELEGATE
///=============================================================================
/// @name HTTP_CONFIG_DELEGATE
///=============================================================================

typedef NSDictionary<HttpResultKey, NSString *> HttpResultMapper;

@protocol HttpRequestConfigDelegate <NSObject>
///> 配置: 请求域名 
- (NSString *)requestBaseUrl;
@optional
///> 配置: 全局请求头 
- (NSDictionary *)requestHeaders;
- (GTask<GTaskResult<NSDictionary *> *> *)requestHeadersTask;
- (NSString *)handleRequestUrl:(NSString *)url;
///> 配置: 超时时间(默认为60) 
- (NSTimeInterval)requestTimeout;
///> 配置: 最大并发量, 默认为6 
- (NSInteger)requestMaxConcurrent;
///> 配置: HttpResult 转换 
- (HttpResultMapper *)resultCustomPropertyMapper;
///> 配置: HttpResult 转换 
- (NSDictionary *)prettyHeadersPrint:(NSDictionary *)pre;
///> 配置: HttpResult 拦截器 
- (GTask<GTaskResult *> *)requestCompleteInterceptor:(id)response;
@end

#pragma mark - HTTP_METHOD
///=============================================================================
/// @name HTTP_METHOD
///=============================================================================

///> 请求: 方法类型 
typedef NS_ENUM(NSInteger, HttpMethod) {
    HttpMethodGet = 0,
    HttpMethodPost,
    HttpMethodHead,
    HttpMethodPut,
    HttpMethodDelete,
    HttpMethodPatch
};

///> 请求: 请求解析器类型 
typedef NS_ENUM(NSInteger, HttpRequestType) {
    HttpRequestTypeHTTP = 0,
    HttpRequestTypeJSON,
    HttpRequestTypePlist
};

///> 请求: 请求返回解析器类型 
typedef NS_OPTIONS(NSUInteger, HttpResponseType){
    HttpResponseTypeHTTP      = (1 << 0),
    HttpResponseTypeJSON      = (1 << 1),
    HttpResponseTypeXMLParser = (1 << 2),
    HttpResponseTypePlist     = (1 << 3),
    HttpResponseTypeImage     = (1 << 4)
};

///> 请求: 结果类型 
typedef NS_ENUM(NSInteger, HttpResultType) {
    HttpResultTypeSuccess = 0,
    HttpResultTypeNoNet,
};

typedef NS_ENUM(NSInteger, HttpCachePolicy) {
    ///> 协议策略 
    HttpUseProtocolCachePolicy           = 0,
    ///> 忽略缓存数据 
    HttpReloadIgnoringCacheData          = 1,
    ///> 使用缓存数据, 忽略其过期时间 
    HttpReturnCacheDataElseLoad          = 2,
    ///> 只使用缓存数据, 如果不存在cache, 请求失败 
    HttpReturnCacheDataDontLoad          = 3,
    HttpReloadIgnoringLocalAndRemoteData = 4, // Unimplemented
    HttpReloadRevalidatingCacheData      = 5  // Unimplemented
};



NS_ASSUME_NONNULL_END
