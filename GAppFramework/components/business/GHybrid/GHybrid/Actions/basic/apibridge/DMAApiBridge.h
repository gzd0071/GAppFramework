//
//  DMAApi.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/10.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EXPROT]: 暴露接口给HTML
 * JS日志管理
 */
@interface DMAApiBridge : NSObject

/// [JS ACTION]: HTML日志输出
/// @param args
///    @key msg: 输出日志文案
/// @since 1.0.0
+ (id)JSLog:(NSDictionary *)args;

/// [JS ACTION]: HTML获取开发状态
/// @param args nil
/// @return {NSDictinary *}
///    @key isOpenJSLog: 日志开关
+ (id)onBridgeInitComplete:(NSDictionary *)args;

@end

NS_ASSUME_NONNULL_END
