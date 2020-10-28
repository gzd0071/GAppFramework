//
//  AppDelegate.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/5/8.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <GLogger/Logger.h>
#import <GStart/DMWechat.h>
#import <ReactiveObjC/RACmetamacros.h>
#import <GPush/GPush.h>
#import <ReactiveObjC/RACSignal+Operations.h>
#import <ReactiveObjC/RACSignal.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#if DEBUG
static LogLevel const logLevel = LogLevelAll;
#endif

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
#if DEBUG
    [Logger setupLogger:logLevel];
#endif
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
    }
    return YES;
}

#pragma mark - PUSH
///=============================================================================
/// @name PUSH
///=============================================================================

/// 在此获取DeviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    [GPush handlerDeviceToken:deviceToken];
}
/// 收到远程推送消息(iOS 7.0~10.0)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    [GPush application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
/// APP在前台收到远程推送消息(iOS 10.0, *)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)) {
    [GPush userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}
/// APP未启动或在后台收到远程推送消息(iOS 7.0, *)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
    [GPush userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

#pragma mark - OpenUrl
///=============================================================================
/// @name OpenUrl
///=============================================================================

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([DMWechat handleOpenURL:url]) {
        return YES;
    }
    return YES;
}

#pragma mark - Back/Front
///=============================================================================
/// @name Back/Front
///=============================================================================

- (void)applicationWillResignActive:(UIApplication *)application {
    [GPush applicationWillResignActive:application];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
