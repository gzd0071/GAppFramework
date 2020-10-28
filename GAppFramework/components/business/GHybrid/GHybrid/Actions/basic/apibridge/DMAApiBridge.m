//
//  DMAApi.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/10.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMAApiBridge.h"
#import <GLogger/Logger.h>

@implementation DMAApiBridge

#pragma mark - HTML Log
///=============================================================================
/// @name HTML日志控制
///=============================================================================

/// [JS ACTION]: HTML日志输出
/// @param args
///    @key msg: 输出日志文案
/// @since 1.0.0
+ (id)JSLog:(NSDictionary *)args {
    LOGD(@"[JSLog] %@", args ? args[@"msg"] : @"");
    return  nil;
}

/// [JS ACTION]: HTML获取开发状态
/// @param args nil
/// @return {NSDictinary *}
///    @key isOpenJSLog: 日志开关
+ (id)onBridgeInitComplete:(NSDictionary *)args {
#if DEBUG
    return @{@"isOpenJSLog": @YES};
#else
    return @{@"isOpenJSLog": @NO};
#endif
}

@end
