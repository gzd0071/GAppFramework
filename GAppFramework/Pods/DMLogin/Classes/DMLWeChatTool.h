//
//  DMLWeChatTool.h
//  DMLogin
//
//  Created by zhangjiexin on 2019/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMLWeChatTool : NSObject

+ (instancetype)sharedInstance;
/**
 向微信终端注册你的id
 一般在 AppDelegate 的 didFinishLaunchingWithOptions 函数中调用
 */
+ (void)initSDKWithID:(NSString *)appId secret:(NSString *)secret;
+ (BOOL)isWeChatInstalled;
/**
 处理微信回调
 
 @param url 调起本应用传递过来的URL
 @return 根据传入的URL返回是否能处理
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

//MARK:- 授权登录
/**
 Step 1，向微信服务器发起请求获取Code
 
 @param successBlock 成功回调，返回从微信服务器获取的信息，回调参数数据结构为：
 {"code":"CODE"}
 @param failureBlock 失败回调，返回错误信息
 @return
 */
+ (BOOL)login1_GetCodeSuccess:(void (^)(id sender))successBlock failure:(void (^)(NSString *sender))failureBlock;
/**
 Step 2，根据Step 1中取得的Code获取AccessToken和OpenID等信息
 
 @param code 从微信服务器取得的Code值
 @param successBlock 成功回调，返回从微信服务器获取的信息，回调参数数据结构为：
 {"access_token":"ACCESS_TOKEN",
 "expires_in":7200,
 "refresh_token":"REFRESH_TOKEN",
 "openid":"OPENID",
 "scope":"SCOPE",
 "unionid":"o6_bmasdasdsad6_2sgVt7hMZOPfL"}
 @param failureBlock 失败回调，返回错误信息
 */
+ (void)login2_GetTokenWithCode:(NSString *)code success:(void (^)(id sender))successBlock failure:(void (^)(NSString *sender))failureBlock;

@property (nonatomic, assign) BOOL isLoginLaunchWeChat;

@end

NS_ASSUME_NONNULL_END
