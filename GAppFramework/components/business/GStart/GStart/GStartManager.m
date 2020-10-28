//
//  GStartManager.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/10.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "GStartManager.h"
#import <GHybrid/DMDekTask.h>
#import "DMAdTask.h"
#import "DMThirdTask.h"
#import "DMStartExtra.h"
#import <DMLogin/DMLogin.h>
#import <DMLogin/BLogin.h>
#import <GProtocol/StartDelegate.h>
#import <GMainTab/GMainTab.h>
#import <GBaseLib/GConvenient.h>
#import <GPush/GPush.h>

@implementation GStartManager

#pragma mark - logical
///=============================================================================
/// @name logical
///=============================================================================

+ (void)load {
    __block id observer =
    [[NSNotificationCenter defaultCenter]
     addObserverForName: @"UIApplicationDidFinishLaunchingNotification"
     object:nil
     queue:nil
     usingBlock:^(NSNotification *note) {
         [self startLogical:note.userInfo];
         [[NSNotificationCenter defaultCenter] removeObserver:observer];
     }];
}

#pragma mark - Logic
///=============================================================================
/// @name Logic
///=============================================================================

/*!
 * 逻辑组合
 */
+ (void)startLogical:(NSDictionary *)launchOptions {
    // 步骤一: 登录(包含身份选择)
    [BLogin task]
    // 步骤三: TAB
    .then(^id(GTaskResult *t) {
        return [GMainTab task];
    })
    // 步骤四: 广告模块
    .then(^id(GTaskResult *t) {
        return [DMAdTask task];
    })
    // 步骤五: 第三方初始 or DEK模块
    .then(^id(GTaskResult *t) {
        [GPush auth];
        // TODO: 三方是否需要提前, 比如Bugly
        [DMThirdTask task];
        [DMDekTask task];
        [DMStartExtra task];
        return nil;
    });
    // 步骤六: 首页出现后的相关逻辑 如推送或者弹框
}

@end
