//
//  GRouter.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/7/18.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "GRouter.h"
#import <GTask/GTaskResult.h>
#import <GTask/GInvokeBlock.h>
#import <GProtocol/ProtocolExtend.h>
#import <GTask/GTask+Private.h>
#import <ReactiveObjC/RACmetamacros.h>

NSString * const RouterDefaultHandler = @"krouterdefault";

#ifndef LOG_LEVEL
#define LOG_LEVEL LogLevelEnvironment
#endif
#import <GLogger/Logger.h>

////////////////////////////////////////////////////////////////////////////////
/// @@class GRouterDigester
////////////////////////////////////////////////////////////////////////////////

@implementation GRouterDigester
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - GRouterDataDelegate
////////////////////////////////////////////////////////////////////////////////
@defs(GRouterDataDelegate)

- (GTaskSource *)tcs {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTcs:(GTaskSource *)tcs {
    objc_setAssociatedObject(self, @selector(tcs), tcs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable GTask *)delegateTask {
    if (self.tcs) return self.tcs.task;
    self.tcs = [GTaskSource source];
    return self.tcs.task;
}
@end

////////////////////////////////////////////////////////////////////////////////
/// @@class GRouter
////////////////////////////////////////////////////////////////////////////////

#define kRouterLog @"[Router] => "

@interface GRouter()
///> URD注册表
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary<NSString *, Class> *> *schemes;
@end

@implementation GRouter

+ (instancetype)instance {
    static GRouter *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GRouter new];
        manager.schemes = @{}.mutableCopy;
    });
    return manager;
}

+ (void)registScheme:(NSString *)scheme urd:(NSString *)urd cls:(Class)cls  {
    if (!scheme || !urd || !cls) {
        LOGE(@"[RouterRegister] => Failed: scheme(%@); urd(%@); cls(%@)", scheme, urd, cls);
        return;
    }
    LOGV(@"[RouterRegister] => %@", @{@"scheme":scheme, @"urd":urd, @"cls":cls});
    NSMutableDictionary *schemeD = [GRouter instance].schemes[scheme].mutableCopy;
    if (!schemeD) schemeD = @{}.mutableCopy;
    NSString *pre = schemeD[[urd lowercaseString]];
    if (pre) LOGW(@"[RouterRegister] => Register Duplicate %@", urd);
    [schemeD setObject:cls forKey:[urd lowercaseString]];
    [GRouter instance].schemes[scheme] = schemeD;
    LOGV(@"[RouterRegister] => Register Success.");
}

+ (BOOL)hadRegister:(NSString *)scheme {
    return [GRouter instance].schemes[scheme];
}

#pragma mark - SCHEME
///=============================================================================
/// @name SCHEME
///=============================================================================

+ (GTask *)router:(NSString *)uri {
    return [self router:uri params:nil navi:nil];
}
+ (GTask *)router:(NSString *)uri params:(id)params {
    return [self router:uri params:params navi:nil];
}
+ (GTask *)router:(NSString *)uri navi:(UINavigationController *)navi {
    return [self router:uri params:nil navi:navi];
}
+ (GTask *)router:(NSString *)uri params:(id)params navi:(UINavigationController *)navi {
    LOGT(@"RouterAction");
    LOGI(@"%@Start: %@", kRouterLog, uri);
    if (!([uri isKindOfClass:[NSString class]] && uri.length))  {
        LOGE(@"%@Uri Error.", kRouterLog);
        return nil;
    }
    NSURL *url = [NSURL URLWithString:uri];
    GRouterDigester *model = [self getDigester:url params:params];
    if (!model.digester) {
        LOGE(@"%@Scheme %@ has no digester.", kRouterLog, url.absoluteString);
        return nil;
    }
    LOGI(@"%@Digester is %@", kRouterLog, model.digester);
    return [self digest:model navi:navi];
}
///> 获取消化器 
+ (GRouterDigester *)getDigester:(NSURL *)url params:(id)params {
    GRouterDigester *model = [GRouterDigester new];
    model.url = url;
    if (!url.scheme && NSClassFromString(url.absoluteString)) {
        model.digester = NSClassFromString(url.absoluteString);
    } else {
        NSString *key = [url.host?[url.host lowercaseString]:url.absoluteString lowercaseString];
        model.digester = url.scheme ? [GRouter instance].schemes[url.scheme][key] : nil;
        if(!model.digester) {
            id low = [RouterDefaultHandler lowercaseString];
            model.digester = [GRouter instance].schemes[low][low];
        }
    }
    model.data = [self paraDict:url.query];
    if (!model.data) model.data = params;
    return model;
}
///> 消化URD 
+ (GTask *)digest:(GRouterDigester *)digester navi:navi {
    GTaskSource *tcs = [GTaskSource source];
    GTask *rt = [self beforeInterceptors:digester data:navi]
    .then(^id(GTaskResult<GTask *> *t) {
        if (!t.suc) {
            LOGI(@"%@BeforeInterceptor prevent the default push flow.", kRouterLog);
            GTask *task = [t.data isKindOfClass:GTask.class]?t.data:[GTask new];
            return task.process(^(id data){ [tcs setProcess:data];});
        }
        id kNavi = navi ?: [self navi];
        if (!kNavi) { LOGI(@"%@Navi not found.", kRouterLog);return nil; }
        if ([digester.digester respondsToSelector:@selector(routerAction:navi:)]) {
            GTask *task = [(id<GRouterTaskDelegate>)digester.digester routerAction:digester navi:kNavi];
            if (task) return task.process(^(id data){ [tcs setProcess:data];});
            return task;
        }
        GTask *task = [self pushViewControllerWithVC:(Class)(digester.digester) data:digester.data path:nil navi:kNavi];
        if (task) return task.process(^(id data){ [tcs setProcess:data];});
        return task;
    });
    [rt pipe:^(_GTaskStatus status, id result) {
        [tcs setResult:result type:status == _GTaskStatusFulfilled ? GTaskResultFulfilled : GTaskResultRejected];
    }];
    return tcs.task;
}
///> 如果是视图则默认跳转 
+ (GTask *)pushViewControllerWithVC:(Class)cls data:(id)data path:(NSString *)path navi:(UINavigationController *)navi {
    LOGI(@"%@Handle, %@", kRouterLog, @{@"vcString":NSStringFromClass(cls)?:@"", @"path":path?:@"nil", @"params":data?:@"nil"});
    LOGT(@"RouterAction", @"一次Router操作");
    UIViewController *vc = [[cls alloc] init];
    if (![vc isKindOfClass:UIViewController.class]) {
        LOGE(@"%@Handle Error, %@ is not a viewcontroller class.", vc);
        return nil;
    }
    if ([vc respondsToSelector:@selector(routerPassParamters:)]) {
        LOGI(@"%@Params passed.", kRouterLog);
        [(id<GRouterDataDelegate>)vc routerPassParamters:data];
    }
    GTask *after = [self afterInterceptors:vc data:data navi:navi];
    after.then(^id(GTaskResult *t) {
        if (t.suc) {
            LOGI(@"%@Uri push success.", kRouterLog);
            [navi pushViewController:vc animated:YES];
        } else {
            LOGI(@"%@Uri push failed, After interceptor prevent the default push flow.", kRouterLog);
        }
        return nil;
    });
    if ([vc conformsToProtocol:@protocol(GRouterTaskDelegate)] &&
        [vc respondsToSelector:@selector(delegateTask)]) {
        return [(id<GRouterTaskDelegate>)vc delegateTask];
    }
    return nil;
}

#pragma mark - Interceptor
///=============================================================================
/// @name Interceptor
///=============================================================================

+ (GTask *)beforeInterceptors:(GRouterDigester *)digester data:(id)data {
    if ([digester.digester respondsToSelector:@selector(beforeInterceptors:)]) {
        LOGV(@"%@Has BeforeInterceptors", kRouterLog);
        return [self interceptors:[digester.digester beforeInterceptors:digester] data:data];
    }
    return [GTask taskWithValue:GTaskResult(YES)];
}

+ (GTask *)afterInterceptors:(UIViewController *)vc data:(id)data navi:navi {
    if ([vc respondsToSelector:@selector(afterInterceptors:vc:navi:)]) {
        LOGV(@"%@Has afterInterceptors.", kRouterLog);
        return [self interceptors:[(id<GRouterDataDelegate>)vc afterInterceptors:data vc:vc navi:navi] data:data];
    }
    return [GTask taskWithValue:GTaskResult(YES)];
}

+ (GTask *)interceptors:(id)obj data:(id)data {
    if ([obj isKindOfClass:NSString.class]) {
        return [self getTask:obj data:data];
    } else if ([obj isKindOfClass:NSNumber.class]) {
        return [GTask taskWithValue:GTaskResult([obj boolValue])];
    } else if ([obj isKindOfClass:GTaskResult.class]) {
        return [GTask taskWithValue:obj];
    } else if ([obj isKindOfClass:GTask.class]) {
        return obj;
    } else if ([obj isKindOfClass:NSArray.class]) {
        __block GTask *task = [GTask taskWithValue:GTaskResult(YES)];
        [obj enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            task = task.then(^id(GTaskResult *t) {
                return t.suc ? [self interceptors:object data:data] : t.data;
            });
        }];
        return task;
    }
    return [GTask taskWithValue:GTaskResult(YES)];
}

+ (GTask *)getTask:(NSString *)name data:(id)data {
    Class cls = NSClassFromString(name);
    if (!cls) return [GTask taskWithValue:GTaskResult(YES)];
    if ([cls conformsToProtocol:@protocol(GRouterInterceptorDelegate)] &&
        [cls respondsToSelector:@selector(interceptor:)]) {
        return [(id<GRouterInterceptorDelegate>)cls interceptor:data];
    }
    return [GTask taskWithValue:GTaskResult(YES)];
}

#pragma mark - Navi
///=============================================================================
/// @name Navi
///=============================================================================

+ (UINavigationController *)navi {
    UIViewController *topVC = [[UIApplication sharedApplication].windows.firstObject rootViewController];
    while ([topVC presentedViewController]) {
        topVC = [topVC presentedViewController];
    }
    if ([topVC isKindOfClass:[UITabBarController class]]) {
        topVC = [(UITabBarController *)topVC selectedViewController];
    }
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        UIViewController *vc = [(UINavigationController *)topVC visibleViewController];
        if ([vc presentedViewController] && [[vc presentingViewController] isKindOfClass:UINavigationController.class]) {
            topVC = [topVC presentedViewController];
        }
        return (UINavigationController *)topVC;
    }
    return nil;
}

///> 解析 URI 参数 
+ (NSDictionary *)paraDict:(NSString *)para {
    if (!para) return nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *arr = [para componentsSeparatedByString:@"&"];
    [arr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSArray *keyValue = [obj componentsSeparatedByString:@"="];
        NSString *value = [keyValue.lastObject?:@"" stringByRemovingPercentEncoding];
        [dict setValue:value forKey:keyValue.firstObject?:@""];
    }];
    return dict;
}

@end
