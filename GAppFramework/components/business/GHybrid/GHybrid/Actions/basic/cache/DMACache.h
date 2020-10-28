//
//  DMACache.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/11.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EXPROT]: 暴露接口给HTML
 * JS Cache管理
 */
@interface DMACache : NSObject

/// [JS ACTION]: 获取本地缓存
/// @param  args @key cacheKey: {NSString *} 键值
/// @return {id} 返回存储的对象, 没有则返回null
/// @since  2.6.0
+ (id)getCache:(NSDictionary *)args;

/// [JS ACTION]: 设置本地缓存
/// @param args {NSDictianry *}
///    @key cacheKey {NSString *}  键值
///    @key cacheData {id}  要缓存的数据
///    @key cacheTime {NSNumber *} 缓存时间
/// @return nil
/// @since  2.6.0
+ (id)setCache:(NSDictionary *)args;

/// [JS ACTION]: 删除本地缓存
/// @param args {NSDictianry *}
///    @key cacheKey  {NSString *}  键值
/// @return nil
/// @since  2.6.0
+ (id)deleteCache:(NSDictionary *)args;

/// [JS ACTION]: 获取内存缓存
/// @param  args {NSDictionary *}
///    @key cacheKey: {NSString *} 键值
/// @return {id} 返回存储的对象, 没有则返回null
/// @since  2.6.0
+ (id)getMemoryCache:(NSDictionary *)args;

/// [JS ACTION]: 删除内存缓存
/// @param args {NSDictianry *}
///    @key cacheKey  {NSString *}  键值
/// @return nil
/// @since  2.6.0
+ (id)deleteMemoryCache:(NSDictionary *)args;

/// [JS ACTION]: 设置内存缓存
/// @param args {NSDictianry *}:
///    @key cacheKey  {NSString *}  键值;
///    @key cacheData {id}  要缓存的数据;
/// @return nil
/// @since  2.6.0
+ (id)setMemoryCache:(NSDictionary *)args;

@end

NS_ASSUME_NONNULL_END
