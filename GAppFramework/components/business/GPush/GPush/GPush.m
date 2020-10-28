//
//  GPush.m
//  GPush
//
//  Created by guozd on 2019/12/04.
//

#import "GPush.h"
#import <ReactiveObjC/RACSignal+Operations.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>
#import <GPermission/GPermission.h>
#import <GTask/GTask.h>
#import <GLogger/Logger.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface GPush ()
///> 推送:
@property (nonatomic, assign) BOOL background;
///> 推送: DeviceToken
@property (nonatomic, strong) NSString *dt;
///> 推送: DeviceToken
@property (nonatomic, strong) RACSignal *dtsignal;
@end

@implementation GPush

#pragma mark - Notifications
///=============================================================================
/// @name Notifications
///=============================================================================
/// APP进入后台
+ (void)applicationWillResignActive:(UIApplication *)application {
    [GPush push].background = YES;
}
/// 收到远程推送消息(iOS 7.0~10.0)
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    GPushState state = GPushStateFore;
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
        state = [GPush push].background ? GPushStateBack : GPushStateUnStart;
    [self handlerRemoteNotification:userInfo state:state];
    completionHandler(UIBackgroundFetchResultNewData);
}
/// APP在前台收到远程或本地消息 决定是否展示(iOS 10.0, *)
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)) {
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [self handlerRemoteNotification:notification.request.content.userInfo state:GPushStateFore];
    } else {
        [self handlerLocalNotification:notification.request.content.userInfo state:GPushStateFore];
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}
/// APP点击 收到远程或本地推送消息(iOS 10.0, *)
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
    GPushState state = GPushStateForeClick;
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
        state = [GPush push].background ? GPushStateBack : GPushStateUnStart;
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [self handlerRemoteNotification:response.notification.request.content.userInfo state:state];
    } else {
        [self handlerLocalNotification:response.notification.request.content.userInfo state:state];
    }
    completionHandler();
}

+ (void)handlerRemoteNotification:(NSDictionary *)userInfo state:(GPushState)state {
    LOGI(@"[GPush] ==> %i", state);
}

+ (void)handlerLocalNotification:(NSDictionary *)userInfo state:(GPushState)state {
    LOGI(@"[GPush] ==> %i", state);
}

#pragma mark - Auth
///=============================================================================
/// @name Auth
///=============================================================================

+ (GTask *)auth {
    AuthStatus status = [GPermission push];
    if (status == AuthStatusUnDetermined) return [GPermission pushAuth];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    return ATTask(@(status==AuthStatusAuthorized));
}

#pragma mark - Device Token
///=============================================================================
/// @name Device Token
///=============================================================================

+ (void)handlerDeviceToken:(NSData *)data {
    [GPush push].dt = [self deviceToken:data];
    LOGI(@"[DeviceToken]: %@", [GPush push].dt);
}

+ (RACSignal *)deviceTokenSignal {
    RACSignal *sig = [[GPush push].dtsignal filter:^BOOL(id x) {
        return x && [x length];
    }];
    return sig;
}

#pragma mark - Functions
///=============================================================================
/// @name Functions
///=============================================================================

///> DeviceToken: NSData => NSString
+ (NSString *)deviceToken:(NSData *)data {
    if (@available(iOS 13.0, *)) {
        if (![data isKindOfClass:[NSData class]]) return nil;
        const unsigned *tokenBytes = [data bytes];
        return [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                    ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                    ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                    ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    } else {
        NSString *dt = [data description];
        dt = [dt stringByReplacingOccurrencesOfString:@"<" withString:@""];
        dt = [dt stringByReplacingOccurrencesOfString:@">" withString:@""];
        dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
        return dt;
    }
}

+ (instancetype)push {
    static GPush *push;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        push = [GPush new];
    });
    return push;
}

- (instancetype)init {
    if (self = [super init]) {
        _dtsignal = RACObserve(self, dt);
    }
    return self;
}

@end
