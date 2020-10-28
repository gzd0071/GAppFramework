//
//  DMWechat.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/18.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMWechat.h"
#import <WeChatLib/WXApi.h>
#import <GBaseLib/GConvenient.h>

#define WECHAT_APPID  @"wx17e3fbd4bdcf0951"
#define WECHAT_SECRET @"d4624c36b6795d1d99dcf0547af5443d"

@interface DMWechat()<WXApiDelegate>
///> 
@property (nonatomic, strong) GTaskSource *tcs;
@end

@implementation DMWechat

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static DMWechat *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self share];
}

#pragma mark - INIT
///=============================================================================
/// @name INIT
///=============================================================================

+ (void)initSDK {
    [WXApi registerApp:WECHAT_APPID];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:[DMWechat share]];
}

#pragma mark - WXApiDelegate
///=============================================================================
/// @name WXApiDelegate
///=============================================================================

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:SendAuthResp.class]) {
        // 登录回调
    } else if ([resp isKindOfClass:SendMessageToWXResp.class]) {
        
    }
}

- (void)onSendAuthResp:(SendAuthResp *)resp {
    if (resp.errCode == WXSuccess) {
        [[DMWechat share].tcs setResult:RACTuplePack(@YES, resp.code ?: @"")];
    } else if (resp.errCode == WXErrCodeUserCancel) {
        [[DMWechat share].tcs setResult:RACTuplePack(@NO, @"用户取消")];
    } else if (resp.errCode == WXErrCodeAuthDeny) {
        [[DMWechat share].tcs setResult:RACTuplePack(@NO, @"用户拒绝授权")];
    } else {
        [[DMWechat share].tcs setResult:RACTuplePack(@NO, @"用户授权失败")];
    }
}


#pragma mark - LOGIN
///=============================================================================
/// @name LOGIN
///=============================================================================

+ (GTask *)login {
    if (![WXApi isWXAppInstalled]) {
        return nil;
    }
    if (![WXApi isWXAppSupportApi]) {
        return nil;
    }
    GTaskSource *tcs = [GTaskSource source];
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"doumi_state_123";
    BOOL result = [WXApi sendReq:req];
    if (!result) [tcs setResult:@NO];
    [DMWechat share].tcs = tcs;
    return tcs.task;
}

+ (GTask *)getWechatTokenWithCode:(NSString *)code {
    NSString *urlStr = FORMAT(@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WECHAT_APPID, WECHAT_SECRET, code);
    return [self request:urlStr key:@"access_token"];
}

+ (GTask *)getWechatUserInfo:(NSDictionary *)info {
    NSString *urlStr = FORMAT(@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", info[@"access_token"], info[@"openid"]);
    return [self request:urlStr key:@"unionid"];
}

+ (GTask *)request:(NSString *)urlStr key:(NSString *)key {
    GTaskSource *tcs = [GTaskSource source];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!data) [tcs setResult:RACTuplePack(@NO)];
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *valid = result[key];
            if (valid.length > 0) {
                [tcs setResult:RACTuplePack(@YES, result)];
            } else {
                [tcs setResult:RACTuplePack(@NO)];
            }
        });
    });
    return tcs.task;
}


@end
