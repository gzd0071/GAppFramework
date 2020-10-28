//
//  DMLoginAdapter.m
//  DMLogin
//
//  Created by NonMac on 2019/6/4.
//

#import "DMLoginAdapter.h"
#import "DMLogin.h"
#import "DMLWeChatTool.h"
#import "DMLoginNetWork.h"
#import "DMLChinaMobileTool.h"

@implementation DMLoginAdapter

#pragma mark - 通用方法
+ (void)log:(NSString *)str {
    [[DMLogin shareInstance].delegate log:str];
}

+ (BOOL)isNetworkConnected {
    return [[DMLogin shareInstance].delegate isNetworkConnected];
    return [DMLoginNetWork checkNetCanUse];
}

+ (void)handleToastType:(ToastType)type message:(NSString *)txt {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DMLogin shareInstance].delegate handleToastType:type message:txt];
    });
}

+ (NSString *)APNSState {
    return ([[UIApplication sharedApplication] currentUserNotificationSettings] == UIUserNotificationTypeNone)? @"off" : @"on";
}

+ (NSString *)networkDomain {
    return [[DMLogin shareInstance].delegate networkDomain];
}

#pragma mark - DataEngine
+ (void)setUserLoginData:(NSDictionary *)data {
    [[DMLogin shareInstance].delegate setLoginData:data];
}

#pragma mark - Launch Guide Model 读写
//Launch Guide Model
+ (id<DMLoginInfoModel>)DMLauchGuideModel {
    return [[DMLogin shareInstance].delegate DMLauchGuideModel];
}

+ (NSString *)launchGuidePhone {//[DMLauchSetting sharedInstance].launchGuideModel.phone;
    return [[self DMLauchGuideModel] phone];
}

+ (NSString *)launchGuideverifyCode {
    return [[self DMLauchGuideModel] verifyCode];
}

+ (void)setlaunchGuideVerifyCode:(NSString *)code {
    [[DMLogin shareInstance].delegate setLaunchGuideVerifyCode:code];
}

#pragma mark - DMUtil  对持久化文件(plist)读写
//LaunchSetting
+ (NSString *)DMCombineValueForKey:(DMCombineKey)key {
    return [[DMLogin shareInstance].delegate DMCombineValueForKey:key];
}

#pragma mark - 微信登录
+ (BOOL)isWXAppInstalled {
    return [DMLWeChatTool isWeChatInstalled];
}

//第一步骤
+ (void)Wechat_GetCodeSuccess:(void (^)(id sender))successBlock failure:(void (^)(NSString *sender))failureBlock {
    [DMLWeChatTool login1_GetCodeSuccess:successBlock failure:failureBlock];
    [DMLWeChatTool sharedInstance].isLoginLaunchWeChat = YES;
}

//第二步骤
+ (void)Wechat_GetTokenWithCode:(NSString *)code success:(void (^)(id sender))successBlock failure:(void (^)(NSString *sender))failureBlock {
    [DMLWeChatTool login2_GetTokenWithCode:code success:successBlock failure:failureBlock];
    [DMLWeChatTool sharedInstance].isLoginLaunchWeChat = YES;
}

#pragma mark - 中移动登录
+ (BOOL)isChinaMobileAvaliable {
    return [DMLChinaMobileTool usable];
}

+ (void)chinaMobileLoginFrom:(id)from getPhoneNumS:(blankBlock)getPhoneNumS getPhoneNumF:(void (^)(id sender))getPhoneNumF getAuthS:(void (^)(id sender))getAuthS getAuthF:(void (^)(NSString *resultStr))getAuthF {
    [DMLChinaMobileTool loginFrom:from getPhoneNumS:getPhoneNumS getPhoneNumF:getPhoneNumF getAuthS:getAuthS getAuthF:getAuthF];
//    [[DMLogin shareInstance].delegate chinaMobileLoginFrom:from success:successBlock failure:failureBlock];
}

#pragma mark - 界面控制
+ (void)pushToAgreementVC {//跳转到用户协议界面
    [[DMLogin shareInstance].delegate pushToAgreementVC];
}


#pragma mark - 界面事件统计  (各种统计)
+ (void)UMengCollection:(NSString *)event content:(id)content {//UMengClick(@"NovGuideVerify_Function",dict)
    [[DMLogin shareInstance].delegate UMengClick:event content:content];
}

+ (void)event:(nullable NSString *)eventContent domain:(NSString *)domain {// logService addEVLog
    [[DMLogin shareInstance].delegate EV_ServiceLog:eventContent domain:domain];
}

+ (void)EVLog:(nullable NSString *)eventContent para:(nullable id)para vc:(UIViewController *)vc {//[self addEVLog:EVKeyAppendWithCommonKey(@"ca_from=obtain") param:nil];
    [[DMLogin shareInstance].delegate EV_VCLog:eventContent para:para vc:vc];
}
+ (void)PVEvent:(nullable NSString *)eventContent para:(nullable id)para vc:(UIViewController *)vc {// self addPVLog:@" param:nil
    [[DMLogin shareInstance].delegate PV_VCLog:eventContent para:para vc:vc];
}

#pragma mark - network
+ (void)requestCaptchaBase64ImageWithSuccessBlock:(successBlock)successBlock failBlock:(failBlock)failBlock {
    NSString *Url = @"https://jz-c.doumi.com/api/v2/client/ajax/encodedcode";
    Url = [NSString stringWithFormat:@"%@/api/v2/client/ajax/encodedcode", [self networkDomain]];
//    NSString *Url = @"https://jz-c-sim.doumi.com/api/v2/client/ajax/encodedcode";
    https://jz-c-sim.doumi.com
    [DMLoginAdapter requestHeaderWithSuccessBlock:^(NSDictionary * _Nonnull headers) {
        [DMLoginNetWork getJsonRequestWithUrl:Url headers:headers body:nil success:successBlock fail:failBlock];
    }];
}

+ (void)login:(NSString *)mobileCode verifyCode:(NSString *)verifyCode password:(NSString *)pwd jsonDict:(NSDictionary *)jsonDict invite_code:(NSString *)invite_code successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock {
    NSString *Url = @"https://jz-c.doumi.com//api/v2/client/login";
    Url = [NSString stringWithFormat:@"%@/api/v2/client/login", [self networkDomain]];
//    NSString *Url = @"https://jz-c-sim.doumi.com//api/v2/client/login";
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    
    param[@"notificationState"] = [self APNSState];
    param[@"idfa"]   = [self getIDFA];
    param[@"mobile"] = mobileCode;
    if (verifyCode)  param[@"code"]         = verifyCode;
    if (pwd)         param[@"password"]     = pwd;
    if (invite_code) param[@"invite_code"]  = invite_code;
    if (jsonDict)
    for (NSString * key in [jsonDict allKeys])
    [param setObject:jsonDict[key]
              forKey:key];
    
    [DMLoginAdapter requestHeaderWithSuccessBlock:^(NSDictionary * _Nonnull headers) {
        [DMLoginNetWork postJsonRequestWithUrl:Url headers:headers body:param success:successBlock fail:failBlock];
    }];
}

+ (void)linkThirdAccount:(NSDictionary *)info           successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock {
    
    NSString *Url = @"https://jz-c.doumi.com/api/v3/client/ucenter/thirdbindlogin";
    Url = [NSString stringWithFormat:@"%@/api/v3/client/ucenter/thirdbindlogin", [self networkDomain]];
//    NSString *Url = @"https://jz-c-sim.doumi.com/api/v3/client/ucenter/thirdbindlogin";
    
    
    [DMLoginAdapter requestHeaderWithIsNeedC_UA:YES SuccessBlock:^(NSDictionary * _Nonnull headers) {
        [DMLoginNetWork postJsonRequestWithUrl:Url headers:headers body:info success:successBlock fail:failBlock];
    }];
}

+ (void)requestSMSAuthCodeForMobileNumber:(NSString *)mobileNumber capthcaString:(nullable NSString *)capthca type:(NSString *)type smsType:(NSString *)smsType successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock {
    NSString *Url = @"https://jz-c.doumi.com/api/v2/client/authCkCode";
    Url = [NSString stringWithFormat:@"%@/api/v2/client/authCkCode ", [self networkDomain]];
//    NSString *Url = @"https://jz-c-sim.doumi.com/api/v2/client/authCkCode";
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:2];
    [param setObject:mobileNumber forKey:@"mobile"];
    if (type) {
        [param setObject:type forKey:@"type"];
    }
    if (capthca) {
        [param setObject:capthca forKey:@"code"];
    }
    if (smsType) {
        [param setObject:smsType forKey:@"smsType"];
    }
    [DMLoginAdapter requestHeaderWithSuccessBlock:^(NSDictionary * _Nonnull headers) {
        [DMLoginNetWork postJsonRequestWithUrl:Url headers:headers body:param success:successBlock fail:failBlock];
    }];
}

+ (void)requestHeaderWithSuccessBlock:(void (^)(NSDictionary *))sBlock {
    [[DMLogin shareInstance].delegate requestHeaderWithSuccessBlock:sBlock];
}

+ (void)requestHeaderWithIsNeedC_UA:(BOOL)isNeedC_UA SuccessBlock:(void (^)(NSDictionary *))sBlock {
    [[DMLogin shareInstance].delegate requestHeaderWithIsNeedC_UA:isNeedC_UA SuccessBlock:sBlock];
}

+ (NSString *)getIDFA {
    return [[DMLogin shareInstance].delegate getIDFA];
}

@end

@implementation DMLAlertConfig
@end

@implementation DMLCaptchaAlertConfig
@end

@implementation DMLBaseInfoVCConfig
@end

@implementation DMLJobSelectVCConfig
@end
