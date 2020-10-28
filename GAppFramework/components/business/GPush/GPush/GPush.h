//
//  GPush.h
//  GPush
//
//  Created by guozd on 2019/12/04.
//

#import <Foundation/Foundation.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class RACSignal;
@class GTask;
@class UNUserNotificationCenter;

///> 消息类型
typedef NS_ENUM(NSUInteger, GPushState) {
    ///> APP未启动
    GPushStateUnStart  = 0,
    ///> APP处于前台
    GPushStateFore,
    ///> APP处于前台, 用户主动点击
    GPushStateForeClick,
    ///> APP处于后台
    GPushStateBack
};

@protocol GPushDelegate <NSObject>
/// 收到远程推送消息(iOS 7.0~10.0)
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler;
/// APP在前台收到远程或本地消息 决定是否展示
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0));
/// APP远程或本地推送消息点击事件
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0));
/// APP进入
+ (void)applicationWillResignActive:(UIApplication *)application;
@end

/*! 推送逻辑 */
@interface GPush : NSObject<GPushDelegate>

#pragma mark - Auth
///=============================================================================
/// @name Auth: 授权
///=============================================================================

/// 推送授权
/// @warning 如未授权, 则会触发授权, 并返回授权后的结果; 如已授权, 则返回是否已授权
/// @return {(BOOL auth)} 返回是否有权限
+ (GTask *)auth;

#pragma mark - Notifications
///=============================================================================
/// @name Notifications: 推送通知
///=============================================================================

/// 远程推送
/// @note 来源
///    @available(iOS 7.0, *)
///       @App在前后台或未启动: application:didReceiveRemoteNotification:fetchCompletionHandler: (如未实现, 则触发前者; 如实现, 则触发后者)
///    @available(iOS 10.0, *) 与上面方法互斥
///       @App在前台收到推送决定是否展示消息弹框): userNotificationCenter:willPresentNotification:withCompletionHandler:
///       @App在前后台或未启动收到点击事件触发: userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
/// @param userInfo {NSDictionary *}推送数据
+ (void)handlerRemoteNotification:(NSDictionary *)userInfo state:(GPushState)state;
/// 本地推送
/// @note 来源
///    @App未启动: application:didFinishLaunchingWithOptions:
///    @App已启动: application:didReceiveLocalNotification:
+ (void)handlerLocalNotification:(NSDictionary *)userInfo state:(GPushState)state;

#pragma mark - Device Token
///=============================================================================
/// @name Device Token
///=============================================================================

/// DeviceToken 转换与存储
/// @param data {NSData *} deviceToken
/// @warning 在application:didRegisterForRemoteNotificationsWithDeviceToken:中使用
+ (void)handlerDeviceToken:(NSData *)data;

/// DeviceToken 信号
/// @warning 订阅即可获取信号, 只有在deviceToken有值时才会触发
/// @return {RACSigal *}
+ (RACSignal *)deviceTokenSignal;

@end

NS_ASSUME_NONNULL_END
