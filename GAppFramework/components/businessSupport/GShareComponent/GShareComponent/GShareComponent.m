//
//  GShareComponent.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/15.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "GShareComponent.h"
#import <WeChatLib/WXApi.h>
#import <GLogger/Logger.h>
#import <GTask/GTask.h>
#import <GTask/GTask+Fwd.h>
#import <GHttpRequest/HttpRequest.h>
#import <GHttpRequest/HttpDefaultConfig.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "GShareAlert.h"

@implementation GSObject
@end

@implementation GSMini
@end

@interface GShareComponent ()
@end

@implementation GShareComponent

/// ACTION 多场景分享
+ (GTask *)share:(GSObject *(^)(GShareScene scene))block {
    return [self share:GShareSceneWXSession|GShareSceneWXTimeline|GShareSceneQQ|GShareSceneQQZone block:block];
}
/// ACTION 多场景分享
+ (GTask *)share:(GShareScene)type block:(GSObject *(^)(GShareScene scene))block; {
    GTask *task = (type & (type - 1)) ? [GShareAlert alert:type] : ATTask(@(type));
    return task.then(^(GShareScene sence) {
        return [self share:sence data:block(sence)];
    });
}
/// ACTION 单场景直接分享
+ (GTask *)share:(GShareScene)scene data:(GSObject *)data {
    switch (scene) {
        case GShareSceneWXMini: return [self wechatMini:(GSMini *)data];
        case GShareSceneWXSession: return [self wechatSession:data];
        case GShareSceneWXTimeline: return [self wechatTimeline:data];
        case GShareSceneQQZone:
        case GShareSceneQQ: return [self qq:data scene:scene];
        default: return ATTask(GTaskResultRejected, @NO);
    }
}

#pragma mark - QQ
///=============================================================================
/// @name QQ
///=============================================================================

+ (GTask *)qq:(GSObject *)so scene:(GShareScene)scene {
    [self registerQQ];
    QQApiNewsObject *obj;
    if ([so.thumb isKindOfClass:UIImage.class]) {
        obj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:so.url] title:so.title description:so.desc previewImageData:UIImagePNGRepresentation(so.thumb)];
    } else {
        obj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:so.url] title:so.title description:so.desc previewImageURL:[NSURL URLWithString:so.thumb]];
    }
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
    QQApiSendResultCode code;
    if (scene == GShareSceneQQ) {
        code = [QQApiInterface sendReq:req];
    } else {
        code = [QQApiInterface SendReqToQZone:req];
    }
    return nil;
}

+ (BOOL)registerQQ {
    id result = [[TencentOAuth alloc] initWithAppId:@"1105593450" andDelegate:nil];
    return result;
}

#pragma mark - Wechat
///=============================================================================
/// @name Wechat
///=============================================================================

/// 分享至: 微信会话
+ (GTask *)wechatSession:(GSObject *)so {
    WXWebpageObject *wb = [WXWebpageObject object];
    wb.webpageUrl = so.url;
    return [self share:WXSceneSession wb:wb data:so];
}
/// 分享至: 朋友圈
+ (GTask *)wechatTimeline:(GSObject *)so {
    WXWebpageObject *wb = [WXWebpageObject object];
    wb.webpageUrl = so.url;
    return [self share:WXSceneTimeline wb:wb data:so];
}
/// 分享至: 微信小程序
+ (GTask *)wechatMini:(GSMini *)mo {
    WXMiniProgramObject *mini = [WXMiniProgramObject object];
    mini.webpageUrl  = mo.url;
    mini.userName    = mo.id;
    mini.path        = mo.path;
    mini.hdImageData = mo.thumb;
    return [self share:WXSceneSession wb:mini data:mo];
}

+ (GTask *)share:(enum WXScene)scene wb:(id)wb data:(GSObject *)data {
    return [self hanlderImg:data.thumb].then(^(UIImage *thumb) {
        WXMediaMessage *msg = [WXMediaMessage message];
        msg.title = data.title;
        msg.description = data.desc;
        if ([wb isKindOfClass:WXMiniProgramObject.class]) {
            WXMiniProgramObject *mini = wb;
            mini.hdImageData = [self handleSize:thumb size:128*1024];
        }
        msg.thumbData = [self handleSize:thumb size:32*1024];
        msg.mediaObject = wb;
        return [self share:scene msg:msg];
    });
}

+ (GTask *)share:(enum WXScene)scene msg:(WXMediaMessage *)msg {
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        return ATTask(@NO);
    }
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = msg;
    req.scene = scene;
    BOOL result = [WXApi sendReq:req];
    if (!result) ATTask(@NO);
    return nil;
}

#pragma mark - Functions
///=============================================================================
/// @name Funcs
///=============================================================================

/// 处理图片数据得到图片
/// @param thumb
///    @type {NSString *} 当作图片地址链接, 将会下载图片
///    @type {UIImage *} 当作结果返回
/// @return {ATask *}
+ (GTask<UIImage *> *)hanlderImg:(id)thumb {
    if ([thumb isKindOfClass:UIImage.class]) return ATTask(thumb);
    return [HttpRequest imgRequest].urlString(thumb).config(HttpDefaultConfig.new)
    .task.then(^id(HttpResult *t) {
        return t.data;
    });
}
/// 图片进行大小处理
/// @warning 分为三个层次 1 0.5 0.1处理, 如果还超过大小, 默认不返回图片, 防止分享由于图片过大不能处理
+ (NSData *)handleSize:(UIImage *)img size:(NSUInteger)size {
    NSData *data = UIImageJPEGRepresentation(img, 1);
    if (data.length <= size) return data;
    data = UIImageJPEGRepresentation(img, 0.5);
    if (data.length <= size) return data;
    data = UIImageJPEGRepresentation(img, 0.1);
    if (data.length <= size) return data;
    return nil;
}

@end
