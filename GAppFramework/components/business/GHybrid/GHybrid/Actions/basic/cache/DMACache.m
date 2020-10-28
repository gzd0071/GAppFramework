//
//  DMACache.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/11.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMACache.h"
#import <YYKit/YYCache.h>
#import <YYKit/YYMemoryCache.h>

///> 缓存名称
#define HTML_CACHE_NAME @"html_cache"

#define kCacheKeyKey    @"cacheKey"     // 本地缓存键的值
#define kCacheValueKey  @"cacheData"    // 本地缓存的值
#define kCacheTimeKey   @"cacheTime"    // 缓存时间
#define kCacheTypeKey   @"type"         // 缓存类型

@interface DMACache ()
///> 缓存单例
@property (nonatomic, strong) YYCache *cache;
@end

@implementation DMACache

+ (instancetype)cache {
    static DMACache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [DMACache new];
        cache.cache = [YYCache cacheWithName:HTML_CACHE_NAME];
    });
    return cache;
}

#pragma mark - Disk Cache
///=============================================================================
/// @name 本地缓存
///=============================================================================

/// [JS ACTION]: 获取本地缓存
/// @param  args @key cacheKey: {NSString *} 键值
/// @return {id} 返回存储的对象, 没有则返回null
/// @since  2.6.0
+ (id)getCache:(NSDictionary *)args {
    YYCache *cache = [DMACache cache].cache;
    NSString *key = args[kCacheKeyKey];
    if ([cache containsObjectForKey:key]) {
        id result = [cache objectForKey:key];
        if (![result isKindOfClass:NSNull.class]) return result;
    }
    return @"null";
}

/// [JS ACTION]: 设置本地缓存
/// @param args {NSDictianry *}
///    @key cacheKey {NSString *}  键值
///    @key cacheData {id}  要缓存的数据
///    @key cacheTime {NSNumber *} 缓存时间
/// @return nil
/// @since  2.6.0
+ (id)setCache:(NSDictionary *)args {
    YYCache *cache = [DMACache cache].cache;
    [cache setObject:args[kCacheValueKey] forKey:args[kCacheKeyKey] withBlock:^{}];
    return nil;
}

/// [JS ACTION]: 删除本地缓存
/// @param args {NSDictianry *}
///    @key cacheKey  {NSString *}  键值
/// @return nil
/// @since  2.6.0
+ (id)deleteCache:(NSDictionary *)args {
    YYCache *cache = [DMACache cache].cache;
    NSString *key = args[kCacheKeyKey];
    if ([cache containsObjectForKey:key]) {
        [cache removeObjectForKey:key];
    }
    return nil;
}

#pragma mark - Memory Cache
///=============================================================================
/// @name 内存缓存
///=============================================================================

/// [JS ACTION]: 获取内存缓存
/// @param  args {NSDictionary *}
///    @key cacheKey: {NSString *} 键值
/// @return {id} 返回存储的对象, 没有则返回null
/// @since  2.6.0
+ (id)getMemoryCache:(NSDictionary *)args {
    YYCache *cache = [DMACache cache].cache;
    NSString *key = args[kCacheKeyKey];
    if ([cache.memoryCache containsObjectForKey:key]) {
        return [cache.memoryCache objectForKey:key];
    }
    return @"null";
}

/// [JS ACTION]: 删除内存缓存
/// @param args {NSDictianry *}
///    @key cacheKey  {NSString *}  键值
/// @return nil
/// @since  2.6.0
+ (id)deleteMemoryCache:(NSDictionary *)args {
    YYCache *cache = [DMACache cache].cache;
    NSString *key = args[kCacheKeyKey];
    if ([cache.memoryCache containsObjectForKey:key]) {
        [cache.memoryCache removeObjectForKey:key];
    }
    return nil;
}

/// [JS ACTION]: 设置内存缓存
/// @param args {NSDictianry *}:
///    @key cacheKey  {NSString *}  键值;
///    @key cacheData {id}  要缓存的数据;
/// @return nil
/// @since  2.6.0
+ (id)setMemoryCache:(NSDictionary *)args {
    YYCache *cache = [DMACache cache].cache;
    [cache.memoryCache setObject:args[kCacheValueKey] forKey:args[kCacheKeyKey]];
    return nil;
}

@end
