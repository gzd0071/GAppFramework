//
//  DebuggerManager.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DebuggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define DEBUGER_REGISTER(A) \
+ (void)load { [DebuggerManager addPlugin:A]; }

@interface DebuggerManager : NSObject
///> Plugin: 添加插件 DebugPluginTypeCommon  
+ (void)addPlugin:(Class<DebuggerPluginDelegate>)plugin;
+ (void)addPlugins:(NSArray<Class<DebuggerPluginDelegate>> *)plugins;
///> Plugin: 添加插件 
+ (void)addPlugin:(Class<DebuggerPluginDelegate>)plugin type:(DebugPluginType)type;
+ (void)addPlugins:(NSArray<Class<DebuggerPluginDelegate>> *)plugins type:(DebugPluginType)type;

+ (UINavigationController *)navi;
+ (void)dismiss;
@end

NS_ASSUME_NONNULL_END
