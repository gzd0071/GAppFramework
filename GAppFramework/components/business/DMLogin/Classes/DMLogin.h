//
//  DMLogin.h
//  DMLogin
//
//  Created by NonMac on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "DMLoginDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DMLoginDelegate <NSObject>
@required

#pragma mark - 通用方法
- (void)log:(NSString *)str;    //日志
- (BOOL)isNetworkConnected;     //网络状况
- (void)handleToastType:(ToastType)type message:(NSString *)txt; //toast 展示
- (NSString *)networkDomain;//网络请求域名 线上/sim/test

#pragma mark - DataEngine
- (void)setLoginData:(NSDictionary *)data;

#pragma mark - Launch Guide Model 读写
- (id<DMLoginInfoModel>)DMLauchGuideModel;
- (void)setLaunchGuideVerifyCode:(NSString *)code;

#pragma mark - DMUtil 读写
- (NSString *)DMCombineValueForKey:(DMCombineKey)key;

#pragma mark - 中移动登录
- (BOOL)isChinaMobileAvaliable;
- (void)chinaMobileLoginFrom:(id)from success:(void (^)(id sender))successBlock failure:(void (^)(NSString *resultStr))failureBlock;

#pragma mark - 界面
- (void)pushToAgreementVC;//跳转到用户协议界面

#pragma mark - 界面事件统计  (各种统计)
- (void)UMengClick:(NSString *)name content:(id)content;
- (void)EV_ServiceLog:(NSString *)eventContent domain:(NSString *)domain;
- (void)EV_VCLog:(NSString *)eventContent para:(id)para vc:(UIViewController *)vc;
- (void)PV_VCLog:(NSString *)eventContent para:(id)para vc:(UIViewController *)vc;

#pragma mark - 网络请求header
- (void)requestHeaderWithSuccessBlock:(void (^)(NSDictionary *))sBlock;
- (void)requestHeaderWithIsNeedC_UA:(BOOL)isNeedC_UA SuccessBlock:(void (^)(NSDictionary *))sBlock;
- (NSString *)getIDFA;

@end


@interface DMLogin : NSObject

@property (nonatomic, weak) id<DMLoginDelegate> delegate;

+ (instancetype)shareInstance;
+ (BOOL)isUseNewLogin;
@end

NS_ASSUME_NONNULL_END
