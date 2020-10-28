//
//  DMLoginAdapter.h
//  DMLogin
//
//  Created by NonMac on 2019/6/4.
//

#import <Foundation/Foundation.h>
#import "DMLoginDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMLoginAdapter : NSObject

#pragma mark - 通用方法
+ (void)log:(NSString *)str;
+ (BOOL)isNetworkConnected;
+ (void)handleToastType:(ToastType)type message:(nullable NSString *)txt;
+ (NSString *)APNSState;
+ (NSString *)networkDomain;
+ (NSString *)getIDFA;

#pragma mark - DataEngine
+ (void)setUserLoginData:(NSDictionary *)data;

#pragma mark - Launch Guide Model 读写
//launch setting
+ (id<DMLoginInfoModel>)DMLauchGuideModel;
+ (NSString *)launchGuidePhone;//[DMLauchSetting sharedInstance].launchGuideModel.phone;
+ (NSString *)launchGuideverifyCode;

#pragma mark - DMUtil 对持久化文件(plist)读写
+ (NSString *)DMCombineValueForKey:(DMCombineKey)key;
+ (void)setlaunchGuideVerifyCode:(NSString *)code;

#pragma mark - 微信登录
+ (BOOL)isWXAppInstalled;
+ (void)Wechat_GetCodeSuccess:(void (^)(id sender))successBlock failure:(void (^)(NSString *sender))failureBlock;
+ (void)Wechat_GetTokenWithCode:(NSString *)code success:(void (^)(id sender))successBlock failure:(void (^)(NSString *sender))failureBlock;

#pragma mark - 中移动登录
+ (BOOL)isChinaMobileAvaliable;
+ (void)chinaMobileLoginFrom:(id)from getPhoneNumS:(blankBlock)getTokenS getPhoneNumF:(void (^)(id sender))getTokenF getAuthS:(void (^)(id sender))successBlock getAuthF:(void (^)(NSString *resultStr))failureBlock;

#pragma mark - 界面控制
+ (void)pushToAgreementVC;//跳转到用户协议界面

#pragma mark - 界面事件统计  (各种统计)
+ (void)UMengCollection:(NSString *)event content:(id)content;//UMengClick(@"NovGuideVerify_Function",dict)
+ (void)event:(nullable NSString *)eventContent domain:(NSString *)domain;//[self addEVLog:EVKeyAppendWithCommonKey(@"ca_from=obtain") param:nil];

//只用在c端实现
+ (void)EVLog:(nullable NSString *)eventContent para:(nullable id)para vc:(UIViewController *)vc;
//只用在c端实现
+ (void)PVEvent:(nullable NSString *)eventContent para:(nullable id)para vc:(UIViewController *)vc;

#pragma mark - 网络请求
//+ (void)requestCaptchaBase64ImageWithSuccessBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;
//+ (void)login:(NSString *)mobileCode verifyCode:(NSString *)verifyCode password:(NSString *)pwd jsonDict:(NSDictionary *)jsonDict invite_code:(NSString *)invite_code successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;
//+ (void)linkThirdAccount:(NSDictionary *)info           successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;
//+ (void)requestSMSAuthCodeForMobileNumber:(NSString *)mobileNumber capthcaString:(nullable NSString *)capthca type:(NSString *)type smsType:(NSString *)smsType successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;

+ (void)requestHeaderWithSuccessBlock:(void (^)(NSDictionary *))sBlock;
+ (void)requestHeaderWithIsNeedC_UA:(BOOL)isNeedC_UA SuccessBlock:(void (^)(NSDictionary *))sBlock;

@end

NS_ASSUME_NONNULL_END
