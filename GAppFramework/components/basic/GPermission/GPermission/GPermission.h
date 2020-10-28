//
//  Permission.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/15.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTask;

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wstrict-prototypes"
typedef void(^PMActionBlock)();
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@interface GPermission : NSObject

#pragma mark - ENUM
///=============================================================================
/// @name ENUM
///=============================================================================

/*！授权状态 */
typedef NS_ENUM(NSInteger, AuthStatus) {
    ///> 未确定 
    AuthStatusUnDetermined = 0,
    ///> iOS家长权限阻止了授权 
    AuthStatusRestricted,
    ///> 拒绝 
    AuthStatusDenied,
    ///> 已授权 
    AuthStatusAuthorized
};

/*！地理位置授权方式 */
typedef NS_ENUM(NSInteger, LocationAuthType) {
    ///> 使用期间(处于前台) 
    LocationAuthTypeWhenInUse,
    ///> 前后台 
    LocationAuthTypeAlways,
};

#pragma mark - AuthStatus
///=============================================================================
/// @name AuthStatus
///=============================================================================

///> 授权状态: 推送 
+ (AuthStatus)push;
///> 授权状态: 相册 
+ (AuthStatus)photo;
///> 授权状态: 日历 
+ (AuthStatus)event;
///> 授权状态: 提醒 
+ (AuthStatus)reminder;
///> 授权状态: 相机 
+ (AuthStatus)camera;
///> 授权状态: 地理位置 
+ (AuthStatus)location;
///> 授权状态: 联系人 
+ (AuthStatus)contacts;
///> 授权状态: 麦克风 
+ (AuthStatus)microphone;

#pragma mark - Auth
///=============================================================================
/// @name Auth
///=============================================================================

/*! 授权结果:
 *  t.result: @1 (代表授权成功) or @0 (代表授权失败)
 */

///> 授权结果: 推送 
+ (GTask *)pushAuth;
///> 授权结果: 相册 
+ (GTask *)photoAuth;
///> 授权结果: 日历 
+ (GTask *)eventAuth;
///> 授权结果: 相机 
+ (GTask *)cameraAuth;
///> 授权结果: 联系人 
+ (GTask *)contactsAuth;
///> 授权结果: 麦克风 
+ (GTask *)microphoneAuth;
///> 授权结果: 地理位置 
+ (GTask *)locationAuth:(LocationAuthType)type;

#pragma mark - preAuth
///=============================================================================
/// @name preAuth
///=============================================================================

///> 预授权: 推送 
+ (void)pushPreAuth;
///> 预授权: 相册 
+ (void)photoPreAuth;
///> 预授权: 日历 
+ (void)eventPreAuth;
///> 预授权: 相机 
+ (void)cameraPreAuth;
///> 预授权: 联系人 
+ (void)contactsPreAuth;
///> 预授权: 麦克风 
+ (void)microphonePreAuth;
///> 预授权: 地理位置 
+ (void)locationPreAuth:(LocationAuthType)type;
///> 上报数据: LBS位置 
+ (void)requestLocation:(PMActionBlock)block;

@end

NS_ASSUME_NONNULL_END
