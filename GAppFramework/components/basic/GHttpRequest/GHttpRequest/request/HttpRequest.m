//
//  HttpRequest.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/7/16.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "HttpRequest.h"
#import <YYKit/NSObject+YYModel.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking.h>
#import <GTask/GTaskResult.h>
#import <GTask/GTask+Fwd.h>

#if __has_include(<GLogger/Logger.h>)
#ifndef LOG_LEVEL
    #define LOG_LEVEL LogLevelEnvironment
#endif
#import <GLogger/Logger.h>
#else
#ifndef LOGE
#define LOGE(A, ...)
#endif
#ifndef LOGW
#define LOGW(A, ...)
#endif
#ifndef LOGI
#define LOGI(A, ...)
#endif
#ifndef LOGD
#define LOGD(A, ...)
#endif
#ifndef LOGV
#define LOGV(A, ...)
#endif
#ifndef LOGT
#define LOGT(...)
#endif
#ifndef LOGTES
#define LOGTES(A, B, ...)
#endif
#endif

#define HttpJSONTypes        @[@"application/json", @"text/json", @"text/javascript", @"application/x-javascript", @"application/javascript"]
#define HttpImageTypes       @[@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap"]
#define ResponseIsJSON(rsp)  [HttpJSONTypes containsObject:[rsp MIMEType]]
#define ResponseIsImage(rsp) [HttpImageTypes containsObject:[rsp MIMEType]]
#define ResponseIsText(rsp)  [[rsp MIMEType] hasPrefix:@"text/"]

#define JSONDeserializationOptions ((NSJSONReadingOptions)(NSJSONReadingAllowFragments | NSJSONReadingMutableContainers))

static NSString * const kHttpRequestConfig = @"HttpConfig";

@interface HttpRequestManager : NSObject
/// 请求: 配置文件
@property (nonatomic, strong) id<HttpRequestConfigDelegate> config;
/// 请求队列
@property (nonatomic, strong) NSOperationQueue *queue;
/// 请求列表
@property (nonatomic, strong) NSMutableArray<HttpRequest *> *requests;
@end
@implementation HttpRequestManager

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================
+ (instancetype)instance {
    static HttpRequestManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HttpRequestManager new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        if (NSClassFromString(kHttpRequestConfig)) {
            LOGI(@"[Request] => Config: %@.", kHttpRequestConfig);
            _config = [NSClassFromString(kHttpRequestConfig) new];
        } else {
            LOGW(@"请配置%@库文件", kHttpRequestConfig);
            _config = [NSClassFromString(@"HttpDefaultConfig") new];
        }
        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = [_config respondsToSelector:@selector(requestMaxConcurrent)] ? [_config requestMaxConcurrent]:6;
        _requests = @[].mutableCopy;
    }
    return self;
}
@end

@interface HttpRequest()
@end

@implementation HttpRequest

+ (BOOL)reachable {
    return [AFNetworkReachabilityManager manager].reachable;
}

+ (instancetype)request {
    HttpRequest *request = [HttpRequest new];
    request.sRequestType = HttpRequestTypeHTTP;
    request.sResponseType = HttpResponseTypeJSON;
    return request;
}

+ (instancetype)jsonRequest {
    HttpRequest *request = [HttpRequest new];
    request.sRequestType = HttpRequestTypeJSON;
    request.sResponseType = HttpResponseTypeJSON;
    return request;
}

+ (instancetype)imgRequest {
    HttpRequest *request = [HttpRequest new];
    request.sResponseType = HttpResponseTypeImage;
    return request;
}

+ (instancetype)plistRequest {
    HttpRequest *request = [HttpRequest new];
    request.sResponseType = HttpResponseTypePlist;
    return request;
}

+ (instancetype)xmlRequest {
    HttpRequest *request = [HttpRequest new];
    request.sResponseType = HttpResponseTypeXMLParser;
    return request;
}

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)init {
    if (self = [super init]) {
        _sTimeout = -1;
        _sTryCount = 1;
        _cachePolicy = HttpUseProtocolCachePolicy;
        _needHandleData = YES;
    }
    return self;
}

#pragma mark - Task
///=============================================================================
/// @name Task
///=============================================================================

- (GTask<GTaskResult *> *)requestCompleteInterceptor:(id)response {
    id<HttpRequestConfigDelegate> config = self.sConfig?:[HttpRequestManager instance].config;
    if ([config respondsToSelector:@selector(requestCompleteInterceptor:)]) {
        return [config requestCompleteInterceptor:response];
    }
    return ATTask(GTaskResultFulfilled, response);
}

- (GTask<HttpResult *> *)task {
    @weakify(self);
    return [self manager].then(^id(AFHTTPSessionManager *t) {
        @strongify(self);
        if (!t) { LOGI(@"[Request] => Manager nil."); return nil; }
        return [self requestTask:t];
    }).then(^id(RACTuple *t) {
        RACTupleUnpack(NSURLSessionDataTask *task, id res) = t;
        return [self requestCompleteInterceptor:res].then(^id(GTask<GTaskResult *> *sub) {
            return RACTuplePack(task, res);
        });
    }).then(^id(RACTuple *t) {
        RACTupleUnpack(NSURLSessionDataTask *task, id res) = t;
        if ([res isKindOfClass:NSError.class]) {
            return [self handleError:res task:task];
        } else {
            return [self handleResponse:res task:task];
        }
    });
}

- (id)handleError:(NSError *)error task:(NSURLSessionDataTask *)task {
    NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    id result = data ? [self handleErrorData:data task:task error:error] : [self handleError:error];
    return result;
}

- (GTask<RACTuple *> *)requestTask:(AFHTTPSessionManager *)manager {
    GTaskSource *tcs = [GTaskSource source];
    [self taskWithManager:manager success:^(NSURLSessionDataTask *task, id response) {
        [tcs setResult:RACTuplePack(task, response)];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [tcs setResult:RACTuplePack(task, error)];
    }];
    return tcs.task;
}

- (HttpResult *)handleErrorData:(id)data task:(NSURLSessionTask *)task error:(NSError *)err {
    /// 为了兼容接口报网络异常, 还返回数据的情况
    NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)task.response;
    if (ResponseIsJSON(rsp)) {
        AFJSONResponseSerializer *seri = [AFJSONResponseSerializer serializer];
        seri.removesKeysWithNullValues = YES;
        NSError *error;
        data = [seri responseObjectForResponse:rsp data:data error:&error];
        if (![data isKindOfClass:NSData.class]) return [self handleData:data response:rsp];
        return [self handleError:err];
    }
    return [self handleError:err];
}

- (HttpResult *)handleResponse:(id)data task:(NSURLSessionDataTask *)task {
    NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)task.response;
    if ([data isKindOfClass:NSDictionary.class] || [data isKindOfClass:NSArray.class]) {
        return [self handleData:data response:rsp];
    } else if (ResponseIsJSON(rsp) && !(self.sResponseType & HttpResponseTypeJSON)) {
        LOGW(@"[Request] => 🌟 Fix sResponseType contain HttpResponseTypeJSON");
        return [self tryJSON:data response:rsp];
    } else if (ResponseIsImage(rsp) && !(self.sResponseType & HttpResponseTypeJSON)) {
        LOGW(@"[Request] => 🌟 Fix sResponseType contain HttpResponseTypeImage");
        return [self tryImage:data response:rsp];
    } else if (ResponseIsText(rsp)) {
        LOGW(@"[Request] => 🌟 MIMEType start with 'text/'.");
        [self tryText:data response:rsp];
    }
    return [self handleData:data response:rsp];
}

- (HttpResult *)tryJSON:(id)data response:(NSHTTPURLResponse *)rsp {
    AFJSONResponseSerializer *seri = [AFJSONResponseSerializer serializer];
    seri.removesKeysWithNullValues = YES;
    NSError *error;
    data = [seri responseObjectForResponse:rsp data:data error:&error];
    if (error) return [self handleError:error];
    return [self handleData:data response:rsp];
}

- (HttpResult *)tryImage:(id)data response:(NSHTTPURLResponse *)rsp {
    if ([data isKindOfClass:UIImage.class]) return [self handleData:data response:rsp];
    AFImageResponseSerializer *seri = [AFImageResponseSerializer serializer];
    NSError *error;
    data = [seri responseObjectForResponse:rsp data:data error:&error];
    if (error) return [self handleError:error];
    return [self handleData:data response:rsp];
}

- (HttpResult *)tryText:(id)data response:(NSHTTPURLResponse *)rsp {
    id str = [[NSString alloc] initWithData:data encoding:[self stringEncoding:rsp]];
    if (str) return [self handleData:data response:rsp];
    NSMutableDictionary *mutI = @{
                                  NSLocalizedDescriptionKey: [NSString stringWithFormat:@"[Request] => Failed: The server returned invalid string data: %@", [rsp MIMEType]],
                                  NSURLErrorFailingURLErrorKey:[rsp URL],
                                  NSURLErrorFailingURLStringErrorKey: rsp.URL.absoluteString,
                                  AFNetworkingOperationFailingURLResponseErrorKey: rsp,
                                  }.mutableCopy;
    if (data) mutI[AFNetworkingOperationFailingURLResponseDataErrorKey] = data;
    NSError *error = [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:mutI];
    return [self handleError:error];
}

- (HttpResult *)handleData:(id)data response:(NSURLResponse *)rsp {
    HttpResult *result = [HttpResult new];
    result.code = 200;
    result.suc = YES;
    if (_needHandleData) {
        if ([data isKindOfClass:NSDictionary.class]) {
            NSDictionary *map = [self resultTransfrom];
            if (data[map[HttpResultKeyCode]]) result.code = [data[map[HttpResultKeyCode]] integerValue];
            if (data[map[HttpResultKeyMessage]]) result.message = data[map[HttpResultKeyMessage]];
            id sData = data[map[HttpResultKeyData]];
            if (sData && [sData isKindOfClass:NSDictionary.class]) {
                result.data = [self dataDicTransform:sData class:self.sDataTransform];
            } else if (sData && [sData isKindOfClass:NSArray.class]) {
                result.data = [self dataArrTransform:sData];
            } else if (self.sDataTransform) {
                LOGI(@"[Request] => Prevent crash, abandon data. DataClass:%@, Data:%@", NSStringFromClass([data class]), data);
            } else {
                result.data = sData;
            }
            NSMutableDictionary *mut = [data mutableCopy];
            [mut removeObjectForKey:map[HttpResultKeyCode]];
            [mut removeObjectForKey:map[HttpResultKeyMessage]];
            [mut removeObjectForKey:map[HttpResultKeyData]];
            if (mut.count > 0) result.extra = [self dataDicTransform:mut class:self.sExtraDataTransform];
        } else if ([data isKindOfClass:NSArray.class]) {
            result.data = [self dataArrTransform:data];
        } else if (self.sDataTransform){
            LOGI(@"[Request] => Prevent crash, abandon data. DataClass:%@, Data:%@", NSStringFromClass([data class]), data);
        } else {
            result.data = data;
        }
    } else {
        result.originData = data;
    }
    return result;
}

- (NSDictionary *)resultTransfrom {
    id<HttpRequestConfigDelegate> config = self.sConfig?:[HttpRequestManager instance].config;
    NSMutableDictionary *temp = @{HttpResultKeyCode:HttpResultKeyCode,
                                  HttpResultKeyMessage:HttpResultKeyMessage,
                                  HttpResultKeyData:HttpResultKeyData
                                  }.mutableCopy;
    if ([config respondsToSelector:@selector(resultCustomPropertyMapper)]) {
        NSDictionary *map = [config resultCustomPropertyMapper];
        if (map[HttpResultKeyCode]) temp[HttpResultKeyCode] = map[HttpResultKeyCode];
        if (map[HttpResultKeyMessage]) temp[HttpResultKeyMessage] = map[HttpResultKeyMessage];
        if (map[HttpResultKeyData]) temp[HttpResultKeyData] = map[HttpResultKeyData];
    }
    return temp.copy;
}

- (id)dataDicTransform:(NSDictionary *)dic class:(Class)cls {
    if (!cls) return dic;
    id trans = [cls modelWithJSON:dic];
    if (trans) return trans;
    return dic;
}

- (NSArray *)dataArrTransform:(NSArray *)arr {
    if (!self.sDataTransform) return arr;
    NSMutableArray *mut = @[].mutableCopy;
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id trans = [self.sDataTransform modelWithJSON:obj];
        if (trans) [mut addObject:trans];
    }];
    return mut;
}

- (NSStringEncoding)stringEncoding:(NSURLResponse *)rsp {
    id encodeName = [rsp textEncodingName];
    if (!encodeName) return NSUTF8StringEncoding;
    CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodeName);
    if (encoding == kCFStringEncodingInvalidId) return NSUTF8StringEncoding;
    return CFStringConvertEncodingToNSStringEncoding(encoding);
}

- (HttpResult *)handleError:(NSError *)error {
    LOGI(@"[Request] => Request Error.");
    LOGI(@"[Request] => ErrorCode:%i, userInfo:%@", error.code, error.userInfo);
    HttpResult *result = [HttpResult new];
    result.code = error.code;
    NSMutableDictionary *mut = @{}.mutableCopy;
    [mut addEntriesFromDictionary:error.userInfo];
    mut[@"errorDescription"] = error.description;
    result.userInfo = mut.copy;
    return result;
}

- (NSURLSessionDataTask *)taskWithManager:(AFHTTPSessionManager *)manager
                                  success:(void (^)(NSURLSessionDataTask *task, id responseObj))success
                                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    switch (self.sMethod) {
        case HttpMethodGet: {
            return [manager GET:self.sUrlString parameters:self.sParams progress:self.sDownload success:success failure:failure];
        }
        case HttpMethodPost: {
            if (self.sFormData) {
                return [manager POST:self.sUrlString parameters:self.sParams constructingBodyWithBlock:self.sFormData progress:self.sUpload success:success failure:failure];
            }
            return [manager POST:self.sUrlString parameters:self.sParams progress:self.sDownload success:success failure:failure];
        }
        case HttpMethodHead:
            return [manager HEAD:self.sUrlString parameters:self.sParams
                         success:^(NSURLSessionDataTask *task) {
                             success(task, nil);
                         } failure:failure];
        case HttpMethodPut:
            return [manager PUT:self.sUrlString parameters:self.sParams success:success failure:failure];
        case HttpMethodDelete:
            return [manager DELETE:self.sUrlString parameters:self.sParams success:success failure:failure];
        case HttpMethodPatch:
            return [manager PATCH:self.sUrlString parameters:self.sParams success:success failure:failure];
        default:
            return nil;
    }
}

- (GTask<AFHTTPSessionManager *> *)manager {
    id<HttpRequestConfigDelegate> config = self.sConfig?:[HttpRequestManager instance].config;
    
    if (![self fixUrlString:config]) return [GTask taskWithValue:nil];
    
    return [self requestHeaders:config].then(^id(GTaskResult<NSDictionary *> *t) {
        if (!t.suc) return [GTask taskWithValue:nil];
        
        AFHTTPSessionManager *task = [AFHTTPSessionManager manager];
        task.securityPolicy        = [self ufqSecurityPolicy];
        task.requestSerializer     = [self requestSerializer];
        task.requestSerializer.cachePolicy = (NSURLRequestCachePolicy)self.cachePolicy;
        task.responseSerializer    = [self responseSerializer];
        [t.data.allKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            [task.requestSerializer setValue:t.data[key] forHTTPHeaderField:key];
        }];
        task.requestSerializer.timeoutInterval = [self requestTimeout:config];
        return [GTask taskWithValue:task];
    });
}

- (BOOL)fixUrlString:(id<HttpRequestConfigDelegate>)config {
    if (!self.sUrlString || self.sUrlString.length == 0) {
        LOGE(@"[Request] => Url Error.");
        return NO;
    } else if (![self.sUrlString hasPrefix:@"http"]) {
        if (![config respondsToSelector:@selector(requestBaseUrl)]) {
            LOGE(@"[Request] => Url Error, Fix: %@ responder the 'requestBaseUrl'.", NSStringFromClass(config.class));
            return NO;
        }
        //TODO: 是否该操作可以遗留给AFNetworking自己处理
        NSURL *baseUrl = [NSURL URLWithString:[config requestBaseUrl]];
        NSURL *url = [NSURL URLWithString:self.sUrlString];
        if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
            url = [url URLByAppendingPathComponent:@""];
        }
        NSString *str = [NSURL URLWithString:url.absoluteString relativeToURL:baseUrl].absoluteString;
        if ([config respondsToSelector:@selector(handleRequestUrl:)]) {
            self.sUrlString = [config handleRequestUrl:str];
        } else {
            self.sUrlString = str;
        }
    }
    return YES;
}

- (NSTimeInterval)requestTimeout:(id<HttpRequestConfigDelegate>)config {
    if (self.sTimeout >= 0) {
        return self.sTimeout;
    } else if ([config respondsToSelector:@selector(requestTimeout)]) {
        return [config requestTimeout];
    } else {
        return 60;
    }
}

- (GTask<GTaskResult *> *)requestHeaders:(id<HttpRequestConfigDelegate>)config {
    NSMutableDictionary *mut = @{}.mutableCopy;
    if ([config respondsToSelector:@selector(requestHeaders)]) {
        [mut addEntriesFromDictionary:[config requestHeaders]];
    } else if ([config respondsToSelector:@selector(requestHeadersTask)]) {
        return [config requestHeadersTask];
    }
    if (self.sHeaders.count) {
        [mut addEntriesFromDictionary:self.sHeaders];
    }
    return [GTask taskWithValue:GTaskResult(YES, mut)];
}

- (AFSecurityPolicy *)ufqSecurityPolicy {
    AFSecurityPolicy *policy = [AFSecurityPolicy defaultPolicy];
    return policy;
}

- (AFHTTPRequestSerializer *)requestSerializer {
    switch (self.sRequestType) {
        case HttpRequestTypeHTTP:
            return [AFHTTPRequestSerializer serializer];
        case HttpRequestTypeJSON:
            return [AFJSONRequestSerializer serializer];
        case HttpRequestTypePlist:
            return [AFPropertyListRequestSerializer serializer];
    }
}

- (AFHTTPResponseSerializer *)responseSerializer {
    NSMutableArray<AFHTTPResponseSerializer *> *sers = @[].mutableCopy;
    if (self.sResponseType & HttpResponseTypeHTTP) {
        [sers addObject:[AFHTTPResponseSerializer serializer]];
    }
    if (self.sResponseType & HttpResponseTypeJSON) {
        AFJSONResponseSerializer *seri = [AFJSONResponseSerializer serializer];
        seri.removesKeysWithNullValues = YES;
        seri.acceptableContentTypes = [[NSSet alloc] initWithArray:HttpJSONTypes];
        [sers addObject:seri];
    }
    if (self.sResponseType & HttpResponseTypeXMLParser) {
        // @"application/xml", @"text/xml"
        [sers addObject:[AFXMLParserResponseSerializer serializer]];
    }
    if (self.sResponseType & HttpResponseTypePlist) {
        // @"application/x-plist"
        [sers addObject:[AFPropertyListResponseSerializer serializer]];
    }
    if (self.sResponseType & HttpResponseTypeImage) {
        [sers addObject:[AFImageResponseSerializer serializer]];
    }
    if (sers.count == 1) return sers.firstObject;
    return [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:sers];
}

#pragma mark - Promise Like
///=============================================================================
/// @name Promise Like
///=============================================================================

- (HttpRequest *(^)(NSDictionary *headers))headers {
    return ^id(NSDictionary *headers) {
        NSMutableDictionary *mut = self.sHeaders?self.sHeaders.mutableCopy:@{}.mutableCopy;
        [mut addEntriesFromDictionary:headers];
        self.sHeaders = mut.copy;
        return self;
    };
}
- (HttpRequest *(^)(NSTimeInterval timeout))timeout {
    return ^id(NSTimeInterval timeout) {
        self.sTimeout = timeout;
        return self;
    };
}
- (HttpRequest *(^)(HttpMethod type))method {
    return ^id(HttpMethod type) {
        self.sMethod = type;
        return self;
    };
}
- (HttpRequest *(^)(HttpRequestType type))requestType{
    return ^id(HttpRequestType type) {
        self.sRequestType = type;
        return self;
    };
}
- (HttpRequest *(^)(HttpResponseType type))responseType {
    return ^id(HttpResponseType type) {
        self.sResponseType = type;
        return self;
    };
}
- (HttpRequest *(^)(HttpCachePolicy policy))policy {
    return ^id(HttpCachePolicy policy) {
        self.cachePolicy = policy;
        return self;
    };
}
- (HttpRequest *(^)(NSString *urlString))urlString {
    return ^id(NSString *urlString) {
        self.sUrlString = urlString;
        return self;
    };
}
- (HttpRequest *(^)(NSInteger tryCount))tryCount {
    return ^id(NSInteger tryCount) {
        self.sTryCount = tryCount;
        return self;
    };
}
- (HttpRequest *(^)(id params))params {
    return ^id(id params) {
        self.sParams = params;
        return self;
    };
}
- (HttpRequest *(^)(void (^nullable)(id<AFMultipartFormData> formData)))formData {
    return ^id(void (^block)(id<AFMultipartFormData> formData)) {
        self.sFormData = block;
        return self;
    };
}
- (HttpRequest *(^)(void (^nullable)(NSProgress *)))downloadProgress {
    return ^id(void (^block)(NSProgress *)) {
        self.sDownload = block;
        return self;
    };
}
- (HttpRequest *(^)(void (^nullable)(NSProgress *)))uploadProgress {
    return ^id(void (^block)(NSProgress *)) {
        self.sUpload = block;
        return self;
    };
}
- (HttpRequest *(^)(Class cls))dataTransform {
    return ^id(Class cls) {
        self.sDataTransform = cls;
        return self;
    };
}
- (HttpRequest *(^)(Class cls))extraDataTransform {
    return ^id(Class cls) {
        self.sExtraDataTransform = cls;
        return self;
    };
}
- (HttpRequest *(^)(BOOL need))handleData {
    return ^id(BOOL need) {
        self.needHandleData = need;
        return self;
    };
}
- (HttpRequest *(^)(id<HttpRequestConfigDelegate> config))config {
    return ^id(id<HttpRequestConfigDelegate> config) {
        self.sConfig = config;
        return self;
    };
}
@end
