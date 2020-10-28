//
//  GShareComponent.h
//  xxxxx
//
//  Created by iOS_Developer_G on 2019/11/29.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GTask<T>;

/// MARK: GSObject
////////////////////////////////////////////////////////////////////////////////
/// @@class GSObject 分享数据模型
////////////////////////////////////////////////////////////////////////////////

@interface GSObject : NSObject
///> 数据: 标题
@property (nonatomic, strong) NSString *title;
///> 数据: 描述
@property (nonatomic, strong) NSString *desc;
///> 数据: 图片URL、Image
@property (nonatomic, strong) id thumb;
///> 数据: 网页URL
@property (nonatomic, strong) NSString *url;
@end

/// MARK: GSMini
////////////////////////////////////////////////////////////////////////////////
/// @@class DMSMini 小程序数据模型
////////////////////////////////////////////////////////////////////////////////

@interface GSMini : GSObject
///> 小程序: 小程序ID
@property (nonatomic, strong) NSString *id;
///> 小程序: 页面路径(不填, 默认拉起首页)
@property (nonatomic, strong) NSString *path;
@end

/// MARK: GShareComponent
////////////////////////////////////////////////////////////////////////////////
/// @@class GShareComponent
////////////////////////////////////////////////////////////////////////////////

///> 分享场景 
typedef NS_OPTIONS(NSUInteger, GShareScene) {
    /// 微信聊天
    GShareSceneWXSession       = (1 << 0),
    /// 微信朋友圈
    GShareSceneWXTimeline      = (1 << 1),
    /// QQ
    GShareSceneQQ              = (1 << 2),
    /// QQ空间
    GShareSceneQQZone          = (1 << 3),
    /// 微信小程序
    GShareSceneWXMini          = (1 << 4),
};

@interface GShareComponent : NSObject

/// ACTION 多场景分享
/// @warning 默认分享场景集成 wxsesion | wxtimeline | qq | qqzone
/// @param block 获取分享数据
/// @see share:block:
+ (GTask *)share:(GSObject *(^)(GShareScene scene))block;

/// ACTION 多场景分享
/// @param type 分享场景, 可以多场景组合(多场景则有弹框)
/// @param block 获取分享数据
+ (GTask *)share:(GShareScene)type block:(GSObject *(^)(GShareScene scene))block;

/// ACTION 单场景直接分享
/// @param type 分享场景
/// @param data 分享数据
+ (GTask *)share:(GShareScene)type data:(GSObject *)data;

@end

NS_ASSUME_NONNULL_END
