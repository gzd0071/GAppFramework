//
//  DMSToken.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GTask<T>;

/*!
 * 获取设备DeviceToken、AccessToken
 */
@interface DMSToken : NSObject

#pragma mark - Access Token
///=============================================================================
/// @name Access Token
///=============================================================================

/// [TOKEN]: 获取AccessToken
/// @return {NSString *} 有则返之, 无则返""
+ (NSString *)accessToken;

/// [TOKEN TASK]: 任务, 获取AccessToken
///     a. 会先触发getDeviceToken任务
///     b. 按规则生成AccessToken
/// @return {ATask<NSString *> *} 有则返之, 无则返""
+ (GTask<NSString *> *)getAccessToken;

#pragma mark - Device Token
///=============================================================================
/// @name Device Token
///=============================================================================

/// [TOKEN]: 获取deviceToken
/// @return {NSString *} 有则返之, 无则返"-"
+ (NSString *)deviceToken;

/// [TOKEN TASK]: 任务, 获取DeviceToken
///     a. 会先触发getDeviceToken任务
/// @return {ATask<NSString *> *} 有则返之, 无则返""
+ (GTask<NSString *> *)getDeviceToken;

@end

NS_ASSUME_NONNULL_END
