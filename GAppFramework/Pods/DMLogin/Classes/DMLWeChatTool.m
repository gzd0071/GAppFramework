//
//  DMLWeChatTool.m
//  DMLogin
//
//  Created by zhangjiexin on 2019/6/20.
//

#import "DMLWeChatTool.h"
#import <WeChatLib/WXApi.h>

static NSString *globalAppId, *globalAppSecret;

@interface DMLWeChatTool ()<WXApiDelegate>
@property (nonatomic, strong) void (^successBlock)(id sender);
@property (nonatomic, strong) void (^failureBlock)(NSString *);
@property (nonatomic, strong) NSString *authState;
@end

@implementation DMLWeChatTool

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DMLWeChatTool * singleton;
    dispatch_once( &once, ^{
        singleton = [[DMLWeChatTool alloc] init];
        singleton.isLoginLaunchWeChat = NO;
    });
    return singleton;
}

+ (BOOL)isWeChatInstalled {
    return [WXApi isWXAppInstalled];
}

+ (void)initSDKWithID:(NSString *)appId secret:(NSString *)secret {
    [WXApi registerApp:appId];
    globalAppId = appId;
    globalAppSecret = secret;
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:[DMLWeChatTool sharedInstance]];
}

// MARK:- 登录

// Step 1: 发起请求，获取Code
+ (BOOL)login1_GetCodeSuccess:(void (^)(id sender))successBlock failure:(void (^)(NSString *sender))failureBlock {
    if (![WXApi isWXAppInstalled]) {
        failureBlock(@"请安装微信后重试");
        return NO;
    } else if (![WXApi isWXAppSupportApi]) {
        failureBlock(@"微信版本过低，请更新微信后重试");
        return NO;
    }
    
    [DMLWeChatTool setSuccess:successBlock failure:failureBlock];
    
    NSString *authState = @"doumi_state_123";
    [DMLWeChatTool sharedInstance].authState = authState;
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = authState;
    BOOL result = [WXApi sendReq:req];
    return result;
}

// Step 2: 根据Code，获取AccessToken
+ (void)login2_GetTokenWithCode:(NSString *)code success:(void (^)(id sender))successBlock failure:(void (^)(NSString *sender))failureBlock {
    NSString * urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", globalAppId, globalAppSecret, code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL * url = [NSURL URLWithString:urlStr];
        NSString * dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData * data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *accessToken = result[@"access_token"];
                if (accessToken.length > 0) //获取成功
                {
                    [DMLWeChatTool callBlock:successBlock sender:result];
                    return;
                }
            }
            //获取失败
            [DMLWeChatTool callBlock:failureBlock sender:nil];
        });
    });
}


//+ (void)

//MARK:- WXApi Delegate

- (void)onResp:(BaseResp *)resp {
    // 第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        [DMLWeChatTool handleSendAuthResp:(SendAuthResp *)resp];
    }
}


// 设置成功/失败回调
+ (void)setSuccess:(void(^)(id))successBlock failure:(void(^)(id))failureBlock {
    DMLWeChatTool *wx = [DMLWeChatTool sharedInstance];
    wx.successBlock = successBlock;
    wx.failureBlock = failureBlock;
}

// 处理授权回调
+ (void)handleSendAuthResp:(SendAuthResp *)resp {
    int code = resp.errCode;
    // ERR_OK = 0(用户同意)
    if (code ==  0) {
        NSString *state = resp.state;
        if ([[DMLWeChatTool sharedInstance].authState isEqual:state]) {
            NSString * code = resp.code;
            NSDictionary * result = @{@"code":code};
            [DMLWeChatTool callBlock:[DMLWeChatTool sharedInstance].successBlock sender:result];
        } else {
            [DMLWeChatTool callBlock:[DMLWeChatTool sharedInstance].failureBlock sender:@""];
        }
    }
    // ERR_USER_CANCEL = -2（用户取消）
    else if (code == -2) {
        [DMLWeChatTool callBlock:[DMLWeChatTool sharedInstance].failureBlock sender:@"用户取消"];
    }
    // ERR_AUTH_DENIED = -4（用户拒绝授权）
    else if (code == -4) {
        [DMLWeChatTool callBlock:[DMLWeChatTool sharedInstance].failureBlock sender:@"用户拒绝授权"];
    }
}

// 较安全的回调操作
+ (void)callBlock:(void(^)(id))block sender:(id)sender {
    if (block) {
        block(sender);
    }
}


- (void)setIsLoginLaunchWeChat:(BOOL)isLoginLaunchWeChat {
    _isLoginLaunchWeChat = isLoginLaunchWeChat;
    NSLog(@"isLoginLaunchWeChat = %d", isLoginLaunchWeChat);
}


@end
