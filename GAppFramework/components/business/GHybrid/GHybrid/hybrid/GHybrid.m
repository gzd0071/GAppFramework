//
//  GHybrid.m
//  GHybrid
//
//  Created by iOS_Developer_G on 2019/10/24.
//

#import "GHybrid.h"
#import <GTask/GTaskResult.h>
#import <GBaseLib/NSString+Extend.h>
#import <GBaseLib/NSArray+Extend.h>
#import <GTask/GTask+Fwd.h>

#if __has_include(<GLogger/Logger.h>)
#ifndef LOG_LEVEL
    #define LOG_LEVEL LogLevelEnvironment
#endif
#import <GLogger/Logger.h>
#else
#ifndef LOGV
#define LOGV(A, ...)
#endif
#endif

///> [JS事件] 标识SCHEME
static NSString * const kPrivateScheme         = @"kcnative";
static NSString * const kPrepareMessages       = @"ApiBridge.prepareProcessingMessages()";
static NSString * const kFetchMessages         = @"ApiBridge.fetchMessages()";
static NSString * const kCallback              = @"ApiBridge.onCallback(%@)";
static NSString * const kCallbackWithParam     = @"ApiBridge.onCallback(%@, '%@')";
static NSString * const kCallbackWithJSONParam = @"ApiBridge.onCallback(%@, %@)";
///> [JS事件] 对应KEY
static NSString * const kClassKey   = @"clz";
static NSString * const kMethodKey  = @"method";
static NSString * const kArgsKey    = @"args";
static NSString * const kCallBackId = @"callbackId";

@implementation GHybrid

+ (BOOL)handleHybridAction:(NSURL *)url model:(id<GHybridDelegate>)model {
    if ([url.scheme isEqualToString:kPrivateScheme]) {
        [model evaluateJavaScript:kPrepareMessages];
        [self initiativeGetWebAction:model];
        return YES;
    }
    return NO;
}

#pragma mark - Interaction
///=============================================================================
/// @name Interaction
///=============================================================================

///> [JS交互]: 获取事件 
+ (void)initiativeGetWebAction:(id<GHybridDelegate>)model {
    [model evaluateJavaScript:kFetchMessages].then(^id(NSString *t) {
        if (t && [t isKindOfClass:NSString.class] && t.length) {
            [self handleWebAction:t.jsonDecoded model:model];
        }
        return nil;
    });
}

///> [JS交互]: 处理JS事件列表 
+ (void)handleWebAction:(NSArray *)data model:(id<GHybridDelegate>)model {
    if (!data || ![data isKindOfClass:NSArray.class]) return;
    // 转化JS事件列表为本地任务列表
    NSArray<GTask *> *tasks = [data map:^id(id each) {
        if (![each isKindOfClass:NSDictionary.class]) return nil;
        GTask *task = [self getPerformTask:model dict:each];
        if (task && ![task isKindOfClass:GTask.class]) task = [GTask taskWithValue:task];
        if (!task) return nil;
        task.then(^(id result) {
            // 本地任务执行完成后数据转交给JS
            [self evlauteJS:result model:model args:each[kArgsKey]];
        });
        return task;
    }];
    // 等待任务列表都完成后, 继续下次获取JS事件列表数据
    ATJoin(tasks).then(^{
        [self initiativeGetWebAction:model];
    });
}

///> [JS ACTION]: 处理JS事件 
+ (id)getPerformTask:(id<GHybridDelegate>)model dict:(NSDictionary *)dict {
    NSString *clsname  = [self generateClassName:dict[kClassKey] model:model];
    NSString *method   = dict[kMethodKey];
    NSDictionary *args = dict[kArgsKey];
    Class clz = NSClassFromString(clsname);
    LOGV(@"[JS Action] => VC: %@; 类: %@; func:%@;", NSStringFromClass(model.class), clsname, method);
    // 判断页面内部是否实现拦截
    if ([model respondsToSelector:@selector(handleAction:args:)]) {
        GTaskResult *result = [model handleAction:method args:args];
        if (!result.suc) return result.data;
    }
    return [self performSEL:method cls:clz args:args];
}

///> 生成本地类名的格式 
+ (NSString *)generateClassName:(NSString *)name model:(id<GHybridDelegate>)model {
    NSString *prefix = [model respondsToSelector:@selector(classPrefix)] ? [model classPrefix] : @"DMA";
    return [NSString stringWithFormat:@"%@%@%@", prefix, [name substringToIndex:1].uppercaseString, [name substringFromIndex:1]];
}

///> [JS ACTION]: 执行指定类的指定方法 
+ (id)performSEL:(NSString *)name cls:(Class)cls args:(id)args {
    if (!cls) return nil;
    NSString *methodName = [NSString stringWithFormat:@"%@:", name];
    SEL method = NSSelectorFromString(methodName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if([cls respondsToSelector:method]) {
        return [cls performSelector:method withObject:args];
    }
#pragma clang diagnostic pop
    return nil;
}

///> [TOJS]: 获取返回结果传值给JS 
+ (void)evlauteJS:(id)result model:(id<GHybridDelegate>)model args:(NSDictionary *)args {
    NSString *callbackId = args[kCallBackId];
    if (!callbackId && result) {
        if ([result isKindOfClass:NSDictionary.class] ||
            [result isKindOfClass:NSArray.class]) {
            [model evaluateJavaScript:[result jsonString]];
        } else {
            [model evaluateJavaScript:result];
        }
    } else if (!result) {
        [model evaluateJavaScript:[NSString stringWithFormat:kCallback, callbackId]];
    } else if ([result isKindOfClass:NSDictionary.class] ||
               [result isKindOfClass:NSArray.class]) {
        [model evaluateJavaScript:[NSString stringWithFormat:kCallbackWithJSONParam, callbackId, [result jsonString]]];
    } else if ([result isKindOfClass:NSString.class]) {
        [model evaluateJavaScript:[NSString stringWithFormat:kCallbackWithParam, callbackId, result]];
    }
}

@end
