//
//  DMAXMLHttpRequest.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/16.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GTask<T>;

/*!
 * [EXPROT]: 暴露接口给HTML
 * JS请求管理
 */
@interface DMAXMLHttpRequest : NSObject

/// [JS ACTION]: 创建一个请求
/// @param args
///    @key id: 请求标识符
/// @since 1.0.0
+ (GTask *)create:(NSDictionary *)args;

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
+ (GTask *)open:(NSDictionary *)args;

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
+ (GTask *)send:(NSDictionary *)args;
@end

NS_ASSUME_NONNULL_END
