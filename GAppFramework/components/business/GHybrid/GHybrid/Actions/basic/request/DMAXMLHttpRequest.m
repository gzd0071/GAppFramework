//
//  DMAXMLHttpRequest.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/16.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMAXMLHttpRequest.h"
#import <GBaseLib/GConvenient.h>
#import <GTask/GTask.h>
#import <YYKit/NSObject+YYModel.h>
#import <GHttpRequest/HttpRequest.h>

// MARK: DMIRequestModel
////////////////////////////////////////////////////////////////////////////////
/// @@class JS请求数据模型
////////////////////////////////////////////////////////////////////////////////

@interface DMIRequestModel : NSObject<YYModel>
///> 请求: 标识符
@property (nonatomic, strong) NSNumber *id;
///> 请求: 方法名(GET、POST)
@property (nonatomic, strong) NSString *method;
///> 请求: 请求头参数(UserAgent)
@property (nonatomic, strong) NSString *useragent;
///> 请求: 请求头参数(Referer)
@property (nonatomic, strong) NSString *referer;
///> 请求: SCHEME(http、https)
@property (nonatomic, strong) NSString *scheme;
///> 请求: 域名
@property (nonatomic, strong) NSString *host;
///> 请求: 端口号
@property (nonatomic, strong) NSString *port;
///> 请求: 请求路径路径
@property (nonatomic, strong) NSString *url;
///> 请求: 全路径
@property (nonatomic, strong) NSString *href;
///> 请求: cookie
@property (nonatomic, strong) NSString *cookie;
@end

@implementation DMIRequestModel
@end

// MARK: DMAXMLHttpRequest
////////////////////////////////////////////////////////////////////////////////
/// @@class JS请求管理类
////////////////////////////////////////////////////////////////////////////////

@interface DMAXMLHttpRequest()
///> 保存所有请求对象
@property (nonatomic, strong) NSMutableDictionary *dict;
@end

@implementation DMAXMLHttpRequest

+ (instancetype)share {
    static DMAXMLHttpRequest *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DMAXMLHttpRequest new];
        manager.dict = @{}.mutableCopy;
    });
    return manager;
}


#pragma mark - HTML Request
///=============================================================================
/// @name HTML请求
///=============================================================================

/// [JS ACTION]: 创建一个请求
/// @param args
///    @key id: 请求标识符
/// @since 1.0.0
+ (GTask *)create:(NSDictionary *)args {
    NSNumber *objectId = args[@"id"];
    HttpRequest *request = [HttpRequest jsonRequest];
    [DMAXMLHttpRequest share].dict[objectId] = request;
    return nil;
}

/// [JS ACTION]: 设置请求参数
/// @param args
///    @key id:        请求标识符
///    @key method:    请求类型(GET,POST)
///    @key herf:      请求全路径地址(取自window.location.href)
///    @key scheme:    请求scheme(取自window.location.protocol)
///    @key host:      请求域名(取自window.location.hostname)
///    @key port:      请求端口(取自window.location.port)
///    @key url:       请求路径
///    @key async:     同步或是异步
///    @key timeout:   请求超时时间
///    @key referer:   请求referer
///    @key useragent: 请求UserAgent
/// @since 1.0.0
+ (GTask *)open:(NSDictionary *)args {
    NSNumber *objectId = args[@"id"];
    HttpRequest *request = [DMAXMLHttpRequest share].dict[objectId];
    if (!request) {
        request = [HttpRequest request];
        [DMAXMLHttpRequest share].dict[objectId] = request;
    }
    DMIRequestModel *model = [DMIRequestModel modelWithJSON:args];
    NSMutableDictionary *header = request.sHeaders.mutableCopy;
    header[@"User-Agent"] = model.useragent ?: @"";
    if (model.referer) header[@"Referer"] = model.referer;
    if (model.cookie)  header[@"Cookie"] = model.cookie;
    request.sHeaders = header;
    BOOL isRelative = NO; //[uriUrl isRelative];
    if (isRelative) {
        NSArray *list = @[];//[uriUrl getPathSegments];
        NSUInteger nSegmentCount = list.count;
        if (nSegmentCount > 0) {
            NSString *tmpPath = [model.url hasPrefix:@"/"] ? model.url : [NSString stringWithFormat:@"/%@", model.url];
            NSString *tmpPort = model.port && model.port.length > 0 ? [NSString stringWithFormat:@":%@", model.port] : @"";
            model.url = FORMAT(@"%@//%@%@%@", model.scheme, model.host, tmpPort, tmpPath);
        } else {
            model.url = model.href;
        }
    }
    request.method([self getTypeWithString:model.method]).urlString(model.url);
    return nil;
}

/// [JS ACTION]: 请求参数
/// @param args
///    @key id:        请求标识符
///    @key method:    请求类型(GET,POST)
///    @key herf:      请求全路径地址(取自window.location.href)
///    @key scheme:    请求scheme(取自window.location.protocol)
///    @key host:      请求域名(取自window.location.hostname)
///    @key port:      请求端口(取自window.location.port)
///    @key url:       请求路径
///    @key async:     同步或是异步
///    @key timeout:   请求超时时间
///    @key referer:   请求referer
///    @key useragent: 请求UserAgent
/// @since 1.0.0
+ (GTask *)send:(NSDictionary *)args {
    GTaskSource *tcs = [GTaskSource source];
    NSNumber *objectId = args[@"id"];
    HttpRequest *request = [DMAXMLHttpRequest share].dict[objectId];
    request.needHandleData = NO;
    id params = [GConvenient paraDict:args[@"data"]];
    request.params(params).task.then(^id(HttpResult *t) {
        [[DMAXMLHttpRequest share].dict removeObjectForKey:objectId];
        NSDictionary *data = @{};
        if (t.suc && ([t.originData isKindOfClass:NSDictionary.class] || [t.originData isKindOfClass:NSArray.class])) {
            data = @{@"id": objectId ?: @"",
                     @"readyState": @4,
                     @"status": @200,
                     @"responseText": [t.originData jsonString]
                     };
        }
        NSString *str = FORMAT(@"XMLHttpRequest.setProperties(%@)", [data jsonString]);
        [tcs setResult:str];
        return nil;
    });
    return tcs.task;
}

+ (GTask *)setRequestHeader:(NSDictionary *)args {
    NSNumber *objectId = args[@"id"];
    HttpRequest *request = [DMAXMLHttpRequest share].dict[objectId];
    if (request) {
        NSMutableDictionary *header = request.sHeaders.mutableCopy;
        header[args[@"headerName"]] = FORMAT(@"%@", args[@"headerValue"]);
        request.sHeaders = header;
    }
    return nil;
}

+ (GTask *)overrideMimeType:(NSDictionary *)args {
    return nil;
}
/// 取消请求
+ (GTask *)abort:(NSDictionary *)args {
    NSNumber *objectId = args[@"id"];
    HttpRequest *request = [DMAXMLHttpRequest share].dict[objectId];
    if (request) [request cancel];
    return nil;
}

+ (HttpMethod)getTypeWithString:(NSString *)str {
    if ([str isEqualToString:@"GET"]) {
        return HttpMethodGet;
    } else if ([str isEqualToString:@"POST"]) {
        return HttpMethodPost;
    }
    return HttpMethodPost;
}

@end
