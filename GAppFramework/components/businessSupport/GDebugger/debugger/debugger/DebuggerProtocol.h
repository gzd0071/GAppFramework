//
//  DMSDebugProtocol.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#ifndef DMSDebugProtocol_h
#define DMSDebugProtocol_h

@protocol DMDEnterUIProtocol <NSObject>
///> 初始位置和大小 
- (CGRect)originRect;
@end

typedef NS_ENUM(NSUInteger, DebugPluginType){
    ///> PluginType: 常用 
    DebugPluginTypeCommon  = 0,
    ///> PluginType: 第三方 
    DebugPluginTypeThird,
    ///> PluginType: 性能 
    DebugPluginTypePerformance,
    ///> PluginType: 视觉 
    DebugPluginTypeVision
};

@protocol DebuggerPluginDelegate <NSObject>

///> Plugin: 名称 
+ (NSString *)pluginName;
///> Plugin: 图标 
+ (UIImage *)pluginIcon;
///> Plugin: 类型 
+ (DebugPluginType)pluginType;
///> Plugin: 被点击 
+ (void)pluginTapAction:(UINavigationController *)navi;

@optional
///> Plugin: 启动插件 
+ (void)pluginDidStart;
///> Plugin: 停止插件 
+ (void)pluginDidStop;

@end

#endif /* DMSDebugProtocol_h */
