//
//  HttpRequest.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/7/16.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "HttpResult.h"
#import "HttpRequestHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AFMultipartFormData;

/*!
 * 网络请求库
 */
@interface HttpRequest<T, E> : NSObject

+ (BOOL)reachable;

#pragma mark -
///=============================================================================
/// @name
///=============================================================================

+ (instancetype)request;
+ (instancetype)jsonRequest;
+ (instancetype)plistRequest;
+ (instancetype)xmlRequest;
+ (instancetype)imgRequest;

#pragma mark - Task
///=============================================================================
/// @name Task
///=============================================================================
/*!
 * 请求: 开始
 */
- (GTask<HttpResult<T, E> *> *)task;
/*!
 * 请求: 取消
 */
- (void)cancel;

#pragma mark - Properties
///=============================================================================
/// @name Properties
///=============================================================================
///> 请求: 类型HttpMethod 
@property (nonatomic, assign) HttpMethod sMethod;
///> 请求: request类型HttpMethod 
@property (nonatomic, assign) HttpRequestType sRequestType;
///> 请求: response类型HttpMethod 
@property (nonatomic, assign) HttpResponseType sResponseType;
///> 请求: 路径(可含http or 不含) 
@property (nonatomic, strong) NSString *sUrlString;
///> 请求: 请求参数 
@property (nonatomic, strong) id sParams;
///> 请求: 上传数据 
@property (nonatomic, copy) void (^sFormData)(id<AFMultipartFormData> formData);
///> 请求: 上传进度 
@property (nonatomic, copy) void (^sUpload)(NSProgress *progress);
///> 请求: 下载进度 
@property (nonatomic, copy) void (^sDownload)(NSProgress *progress);
///> 请求: 超时时间 
@property (nonatomic, assign) NSTimeInterval sTimeout;
///> 请求: 参数 
@property (nonatomic, strong) NSDictionary *sHeaders;
///> 请求: 请求次数(默认为1) 
@property (nonatomic, assign) NSInteger sTryCount;
///> 请求: 请求转换参数 
@property (nonatomic, strong) Class sDataTransform;
///> 请求: 请求结果额外数据转换参数 
@property (nonatomic, strong) Class sExtraDataTransform;
///> 请求: 配置文件 
@property (nonatomic, weak) id<HttpRequestConfigDelegate> sConfig;
///> 请求: 是否处理结果 
@property (nonatomic, assign) BOOL needHandleData;
///> 请求: 缓存策略 
@property (nonatomic, assign) HttpCachePolicy cachePolicy;

#pragma mark - Promise Like
///=============================================================================
/// @name Promise Like
///=============================================================================
///> @brief Promise Like. 
- (HttpRequest *(^)(HttpMethod type))method;
- (HttpRequest *(^)(HttpRequestType type))requestType;
- (HttpRequest *(^)(HttpResponseType type))responseType;
- (HttpRequest *(^)(HttpCachePolicy policy))policy;
- (HttpRequest *(^)(NSString *urlString))urlString;
- (HttpRequest *(^)(id param))params;
- (HttpRequest *(^)(void (^nullable)(id<AFMultipartFormData> formData)))formData;
- (HttpRequest *(^)(void (^nullable)(NSProgress *)))downloadProgress;
- (HttpRequest *(^)(void (^nullable)(NSProgress *)))uploadProgress;
- (HttpRequest *(^)(NSTimeInterval timeout))timeout;
- (HttpRequest *(^)(NSDictionary *headers))headers;
- (HttpRequest *(^)(NSInteger count))tryCount;
- (HttpRequest *(^)(Class cls))dataTransform;
- (HttpRequest *(^)(Class cls))extraDataTransform;
- (HttpRequest *(^)(BOOL need))handleData;
- (HttpRequest *(^)(id<HttpRequestConfigDelegate> config))config;

@end

NS_ASSUME_NONNULL_END
