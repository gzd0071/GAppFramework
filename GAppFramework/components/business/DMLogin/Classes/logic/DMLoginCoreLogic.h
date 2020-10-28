//
//  DMLoginCoreLogic.h
//  DMLogin
//
//  Created by zhangjiexin on 2019/7/10.
//

#import <Foundation/Foundation.h>
#import "DMLoginNetWork.h"
#import "LoginCoreVC.h"

NS_ASSUME_NONNULL_BEGIN
@protocol logicDelegate <NSObject>

- (void)loginSuccessWithType:(DMLoginType)loginType userInfo:(NSDictionary *)userInfo;
- (void)loginFail;

@end


@interface DMLCoreLogicConfig : NSObject
@property (nonatomic, weak) UIViewController *superVC;
@property (nonatomic, copy) void(^ pushToMainVC)(UIViewController *mainVC);
@property (nonatomic, copy) void(^ pushToSMSVC)(UIViewController *SMSVC);
@property (nonatomic, copy) void(^ pushToWeChatBindVC)(UIViewController *weChatBindVC);
@property (nonatomic, copy) void(^ WeChatBindVCToMainVC)(UIViewController *mainVC, UINavigationController *navi);
@property (nonatomic, copy) void(^ SMSVCToMainVC)(UIViewController *mainVC, UINavigationController *navi);

@property (nonatomic, copy) void(^ fromUserCenterFinishInputSMSCode)(void);
@property (nonatomic, copy) void(^ loginMainVCViewDidLoad)(void);
@property (nonatomic, copy) void(^ loginSuccess)(DMLoginType loginType, NSDictionary *userInfo);
@property (nonatomic, copy, nullable) void(^ loginFail)(void);

@end


@interface DMLoginCoreLogic : NSObject

@property (nonatomic, weak) id<logicDelegate> UIDelegate;
@property (nonatomic, strong) UIViewController *mainVC;

#pragma mark - 两种集成方式通用接口
+ (NSDictionary *)currentUserInfo;

#pragma mark - 只使用 逻辑 层的对外方法
+ (void)requestSMSAuthCodeForMobileNumber:(NSString *)mobileNumber capthcaString:(nullable NSString *)capthca type:(NSString *)type smsType:(NSString *)smsType successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;

+ (void)loginWithPhone:(NSString *)phone
            verifyCode:(NSString *)verifyCode
          successBlock:(successBlock)successBlock
             failBlock:(failBlock)failBlock;

+ (void)loginWithWeChatGetCodeS:(blankBlock)getCodeS
                       getCodeF:(blankBlock)getCodeF
                      getTokenS:(void(^)(id sender))getTokenS
                      getTokenF:(blankBlock)getTokenF
                   successBlock:(successBlock)successBlock
                      failBlock:(failBlock)failBlock;

+ (void)loginWithChinaMobileFrom:(UIViewController *)from
                    getPhoneNumS:(blankBlock)getPhoneNumS
                    getPhoneNumF:(void (^)(id sender))getPhoneNumF
                        getAuthS:(blankBlock)getTokenS
                        getAuthF:(void(^)(id sender))getTokenF
                    successBlock:(successBlock)successBlock
                       failBlock:(failBlock)failBlock;

+ (void)chinaMobilegetPhoneNumS:(blankBlock)getPhoneNumS
                   getPhoneNumF:(void (^)(id sender))getPhoneNumF;

+ (void)loginWithChinaMobileFrom:(UIViewController *)from
                        getAuthS:(blankBlock)getAuthS
                        getAuthF:(void(^)(id sender))getAuthF
                    successBlock:(successBlock)successBlock
                       failBlock:(failBlock)failBlock;

+ (void)linkThirdAccount:(NSDictionary *)info successBlock:(successBlock)successBlock  failBlock:(failBlock)failBlock;

+ (void)requestCaptchaBase64ImageWithSuccessBlock:(void(^)(UIImage *captcha))successBlock failBlock:(failBlock)failBlock;



#pragma mark - 使用带 UI 层的方法
- (instancetype)initWithConfig:(DMLCoreLogicConfig *)config;
- (void)startWithPush:(BOOL)isPush;

@end

NS_ASSUME_NONNULL_END
