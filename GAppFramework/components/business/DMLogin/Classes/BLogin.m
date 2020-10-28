//
//  BLogin.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/9/7.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "BLogin.h"
#import <GRouter/GRouter.h>
#import <GBaseLib/GConvenient.h>
#import <DMEncrypt/DMEncrypt.h>
#import <AdSupport/AdSupport.h>
#import <GLogger/Logger.h>
#import <YYKit/NSObject+YYModel.h>
#import <DMLogin/DMLogin.h>
#import <GHttpConfig/GRequestUtil.h>
#import <DMLogin/DMLoginCoreLogic.h>
#import <GConst/URDConst.h>
#import <DMUILib/GHud.h>

////////////////////////////////////////////////////////////////////////////////
/// @@class DMUserModel
////////////////////////////////////////////////////////////////////////////////

@implementation DMUserModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"nickName"  : @"nick_name",
             @"realName"  : @"real_name"};
}
#define kUserKey @"dmUserModelKey"
+ (instancetype)user {
    static DMUserModel *user;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [DMUserModel new];
        NSString *json = [[NSUserDefaults standardUserDefaults] valueForKey:kUserKey];
        if (json) {
            LOGI(@"[LOGIN] => Local login data:%@", [json jsonDecoded]);
            [user modelSetWithJSON:[json jsonDecoded]];
        }
    });
    return user;
}
- (void)save {
    NSString *json = [self modelToJSONString];
    [[NSUserDefaults standardUserDefaults] setValue:json forKey:kUserKey];
}
#undef kUserKey
- (void)updateType:(UserType)type {
    _type = type;
    [self save];
}
- (void)update:(id)data {
    self.isLogin = YES;
    [self modelSetWithJSON:data];
    [self save];
}
- (void)logout {
    self.isLogin = NO;
    self.userId  = nil;
    self.mobile  = nil;
    self.nickName = nil;
    self.realName = nil;
    self.type    = UserTypeUnknown;
    [self save];
}
@end

////////////////////////////////////////////////////////////////////////////////
/// @@class BLogin
////////////////////////////////////////////////////////////////////////////////

@interface BLogin()<DMLoginDelegate>
@end

@implementation BLogin

#pragma mark - StartDelegate
///=============================================================================
/// @name StartDelegate
///=============================================================================

+ (GTask<GTaskResult *> *)task {
    if (YES/*[DMUserModel user].isLogin*/) {
        return [GTask taskWithValue:[GTaskResult taskResultWithSuc:YES]];
    }
    // ACTION:登录
    return [self startLogin]
    // ACTION:获取身份
    .then(^id(GTask *t) {
        return [self getUserInfoExtra];
    });
}

+ (GTask *)getUserInfoExtra {
    UserType type = UserTypeStaff;
    [[DMUserModel user] updateType:type];
    return [GTask taskWithValue:[GTaskResult taskResultWithSuc:YES]];
}

#pragma mark - LOGIN
///=============================================================================
/// @name LOGIN
///=============================================================================

+ (instancetype)login {
    static BLogin *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [BLogin new];
    });
    return config;
}

+ (GTask *)startLogin {
    GTaskSource *tcs = [GTaskSource source];
    [DMLogin shareInstance].delegate = [BLogin login];
    DMLCoreLogicConfig *config =  [DMLCoreLogicConfig new];
    config.pushToMainVC = ^(UIViewController *mainVC) {
        id<UIApplicationDelegate> appD = [[UIApplication sharedApplication] delegate];
        appD.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        appD.window.backgroundColor = [UIColor whiteColor];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:mainVC];
        mainVC.dmBarHidden = YES;
        appD.window.rootViewController = navi;
        [appD.window makeKeyAndVisible];
    };
    config.loginMainVCViewDidLoad = ^{};
    config.loginSuccess = ^(DMLoginType loginType, NSDictionary *userInfo) {
        [[DMUserModel user] update:userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tcs setResult:@YES];
        });
    };
    DMLoginCoreLogic *logic = [[DMLoginCoreLogic alloc] initWithConfig:config];
    [logic startWithPush:YES];
    return tcs.task;
}

#pragma mark - DMLoginDelegate
///=============================================================================
/// @name DMLoginDelegate
///=============================================================================

#pragma mark - 通用方法
- (void)log:(NSString *)str {
    LOGI(@"%@", str);
}

- (BOOL)isNetworkConnected {
    return YES;
}

- (void)handleToastType:(ToastType)type message:(NSString *)txt {
    switch (type) {
        case ToastType_Show_Normal:
            [GHud hud:txt];
            break;
        case ToastType_Show_Normal_NoDim:
            [GHud hud:txt dim:NO];
            break;
        case ToastType_Show_Success:
            [GHud toast:txt];
            break;
        case ToastType_Show_Error:
            [GHud toast:txt];
            break;
        case ToastType_Hide_Single:
            [GHud hideAll];
            break;
        case ToastType_Hide_All_Animated:
            [GHud hideAll];
            break;
        case ToastType_Hide_All_NoAni:
            [GHud hideAll];
            break;
        default:
            break;
    }
}

- (NSString *)networkDomain {
    return [self.class requestBaseUrl];
}

#pragma mark - DataEngine
- (void)setLoginData:(NSDictionary *)data {
    
}

#pragma mark - Launch Guide Model 读写
- (id<DMLoginInfoModel>)DMLauchGuideModel {
    return nil;
}
- (void)setLaunchGuideVerifyCode:(NSString *)code {
    
}

#pragma mark - DMUtil 读写
- (NSString *)DMCombineValueForKey:(DMCombineKey)key {
    return @"";
}

#pragma mark - 中移动登录
- (BOOL)isChinaMobileAvaliable {
    return YES;
}
- (void)chinaMobileLoginFrom:(id)from success:(void (^)(id sender))successBlock failure:(void (^)(NSString *resultStr))failureBlock {
}

#pragma mark - 界面
- (void)pushToAgreementVC {
}

#pragma mark - 界面事件统计  (各种统计)
- (void)UMengClick:(NSString *)name content:(id)content {
    
}
- (void)EV_ServiceLog:(NSString *)eventContent domain:(NSString *)domain {
    
}
- (void)EV_VCLog:(NSString *)eventContent para:(id)para vc:(UIViewController *)vc {
    
}
- (void)PV_VCLog:(NSString *)eventContent para:(id)para vc:(UIViewController *)vc {
    
}

#pragma mark - 网络请求header
- (void)requestHeaderWithSuccessBlock:(void (^)(NSDictionary *))sBlock {
    [self requestHeaderWithIsNeedC_UA:YES SuccessBlock:sBlock];
}
- (void)requestHeaderWithIsNeedC_UA:(BOOL)isNeedC_UA SuccessBlock:(void (^)(NSDictionary *))sBlock {
    [GRequestUtil requestDefaultHeader].then(^id(GTaskResult<NSDictionary *> *t) {
        if (t.suc) {
            sBlock(t.data);
        }
        return nil;
    });
}
- (NSString *)getIDFA {
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return [DMEncrypt encryptString:idfa];
}

///> 配置: 请求域名 
+ (NSString *)requestBaseUrl {
    Class cls = NSClassFromString(@"HttpConfig");
    if (!cls)  {
        LOGI(@"%@", @"未设置接口域名");
        return @"未设置接口域名";
    }
    id<HttpRequestConfigDelegate> cfg = [cls new];
    return [cfg requestBaseUrl];
}
@end

