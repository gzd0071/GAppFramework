//
//  LoginCoreVC.m
//  DMLogin
//
//  Created by Loyal on 2019/6/18.
//

#import "LoginCoreVC.h"
#import "DMLLoginHeaderView.h"
#import "DMLLoginMiddleView.h"
#import "DMLLoginBottomView.h"
#import "DMLOneKeyLoginView.h"

#import "DMLWeChatBindPhoneVC.h"
#import "DMLSMSValidationVC.h"
#import "DMLoginAdapter.h"
#import "UIView+LoginUIViewPosition.h"

#import "DMLoginStore.h"
#import "DMLoginNetWork.h"

#import "DMLoginCoreLogic.h"
#import "DMLChinaMobileTool.h"

#import "CarrierTool.h"

@interface LoginCoreVC ()<DMLSMSDelegate>
@property (nonatomic, strong) LoginCoreVCConfig *config;

@property (nonatomic,strong) DMLLoginMiddleView *middleLoginView;
@property (nonatomic,strong) DMLLoginHeaderView *headerLoginView;
@property (nonatomic,strong) DMLLoginBottomView *bottomLoginView;
@property (nonatomic,strong) DMLOneKeyLoginView *oneKeyLoginView;

@property (nonatomic, assign) BOOL isWechatLogin;

@property (nonatomic, strong) UIViewController *currentVC;

//第三方登录的信息
@property (nonatomic, strong) NSMutableDictionary *lastThirdBindSender;

//集合类，用于存储需要和本 VC 生命周期同步的量
@property (nonatomic, strong) NSMutableSet *externContiner;

@end

@interface LoginModuleConfig :NSObject
@end
@implementation LoginModuleConfig
@end

@implementation LoginCoreVCConfig
@end

@implementation LoginCoreVC

- (instancetype)initWithConfig:(LoginCoreVCConfig *)config {
    if (self = [super init]) {
        self.config = config;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *bgColor = UIColor.whiteColor;
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:28/255.0 green:28/255.0 blue:30/255.0 alpha:1/1.0];
            } else {
                return UIColor.whiteColor;
            }
        }];
    }
#endif
    self.view.backgroundColor = bgColor;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self addLoginView_headerView];
    
        [self addLoginView_middleView];
    
    if ([DMLoginAdapter isWXAppInstalled]){
        [self addLoginView_bottomView];
    }
    
    
    [self.oneKeyLoginView.oneKeyLoginBtn addTarget:self action:@selector(clickOneKeyLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomLoginView.wechatBtn addTarget:self action:@selector(weChatLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.oneKeyLoginView.otherPhoneLogin addTarget:self action:@selector(clickOtherPhoneLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.middleLoginView.getVerificationBtn addTarget:self action:@selector(clickGetVerificationBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.middleLoginView.agreementBtn addTarget:self action:@selector(pushToAgreementVC) forControlEvents:UIControlEventTouchUpInside];
    [self.oneKeyLoginView.agreementBtn addTarget:self action:@selector(pushToAgreementVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditing)]];
    
    self.config.loginCoreVCViewDidLoad();
    if ([self.delegate respondsToSelector:@selector(loginViewDidLoad)]) {
        [self.delegate loginViewDidLoad];
    }
#ifdef DEBUG
    self.view.layer.borderColor = UIColor.redColor.CGColor;
    self.view.layer.borderWidth = 2;
#endif
    
    [self onekeyJudgement];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignPhoneTF)];
    [self.view addGestureRecognizer:tap];
}

- (void)onekeyJudgement {
    
    //用户手机号判断 移动/联通/电信（双卡需要额外去验证，看流量卡 和 当前t读取的是否有误）
    switch ([CarrierTool getOperatorsType]) {
            case CarrierType_ChinaMobile:
            [self flashVerifyLogin];
//            [self chinaMobileLogin];
            break;
            
            case CarrierType_ChinaUnicom:
            case CarrierType_ChinaTelecom:
            case CarrierType_dualSim_iOS12:
            [self flashVerifyLogin];
            break;
            
        default:
            break;
    }
}

- (void)chinaMobileLogin {
    if (self.config.chinaMobileGetPhoneNum) {
        self.config.chinaMobileGetPhoneNum(^{
            if (self.config.chinaMobileLogin) {
                self.config.chinaMobileLogin(self, ^{
                    //获取用户授权成功
                    ;
                }, ^(id sender) {
                    //获取用户授权失败
                    BOOL isNeedShowToast = YES;
                    NSString *msg = @"授权失败，请稍后重试";
                    if ([sender isKindOfClass:[NSString class]]) {
                        if ([sender isEqualToString:@"无网络"]) {
                            // 移动返回 code 200022
                            msg = @"网络连接失败";
                        } else if ([sender isEqualToString:@"用户取消登录"]) {
                            // 移动返回 code 200020
                            isNeedShowToast = NO;
                            msg = nil;
                        }
                    }
                    if (isNeedShowToast) {
                        [self loginFailureToast:msg];
                    }
                }, ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
                    //获取 token 关联斗米账号登录成功
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
                    
                    if (code == 1000) {// 成功
                        [self loginSuccessToast:@"登录成功"];
                        // 表格通过
                        [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=login_success" domain:@"/jianzhi/newestguide/one"];
                    } else {
                        if ([responseObj isKindOfClass:[NSDictionary class]]) {
                            [self loginFailureToast:[responseObj valueForKey:@"message"]];
                        } else {
                            [self loginFailureToast:@"登录失败，请稍后重试"];
                        }
                    }
                }, ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
                    //获取 token 关联斗米账号登录失败
                    [self dismissViewControllerAnimated:YES completion:nil];
                    NSString *msg = @"登录失败，请稍后重试";
                    if (error.code == -1009) {
                        msg = @"网络异常";
                    }
                    [self loginFailureToast:msg];
                    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/cmcc/login"];
                });
            }
        }, ^(id sender) {
            ;
        });
    }
}

//联通、电信使用闪验登录
- (void)flashVerifyLogin {
    if (self.config.flashVerifyGetPhoneNum) {
        self.config.flashVerifyGetPhoneNum(^{
            //成功获取到验证码
            UIColor *clor = [UIApplication sharedApplication].delegate.window.backgroundColor;
            [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor whiteColor];
            if (self.config.flashVerifyLogin) {
                self.config.flashVerifyLogin(self, ^{
                    //获取用户授权成功
                    [UIApplication sharedApplication].delegate.window.backgroundColor = nil;
                }, ^(id sender) {
                    //获取用户授权失败
                    BOOL isNeedShowToast = YES;
                    NSString *msg = @"授权失败，请稍后重试";
                    if ([sender isKindOfClass:[NSString class]]) {
                        if ([sender isEqualToString:@"无网络"]) {
                            // 移动返回 code 200022
                            msg = @"网络连接失败";
                        } else if ([sender isEqualToString:@"用户取消登录"] ||
                                   [sender isEqualToString:@"取消免密登录"] ) {
                            // 移动返回 code 200020
                            isNeedShowToast = NO;
                            msg = nil;
                        } else if ([sender isEqualToString:@"一键登录失败：未打开网络"]) {
                            msg = @"网络异常";
                        }
                    }
                    if (isNeedShowToast) {
                        [self loginFailureToast:msg];
                    }
                    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/chuanglan/login"];
                    [UIApplication sharedApplication].delegate.window.backgroundColor = nil;
                }, ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
                    //关联斗米账号登录成功
                    //获取 token 关联斗米账号登录成功
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
                    
                    if (code == 1000) {// 成功
                        [self loginSuccessToast:@"登录成功"];
                        // 表格通过
                        [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=login_success" domain:@"/jianzhi/chuanglan/login"];
                    } else {
                        if ([responseObj isKindOfClass:[NSDictionary class]]) {
                            [self loginFailureToast:[responseObj valueForKey:@"message"]];
                        } else {
                            [self loginFailureToast:@"登录失败，请稍后重试"];
                        }
                        [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/chuanglan/login"];
                    }
                }, ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
                    //关联斗米账号登录失败
                    //获取 token 关联斗米账号登录失败
                    [self dismissViewControllerAnimated:YES completion:nil];
                    NSString *msg = @"登录失败，请稍后重试";
                    if (error.code == -1009) {
                        msg = @"网络异常";
                    }
                    [self loginFailureToast:msg];
                    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/chuanglan/login"];
                });
            }
        }, ^(id sender) {
            //未获取到验证码
        });
    }
}

- (void)endEditing {
    self.editing = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    //禁止右滑返回
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    [self.middleLoginView checkVerifyButtonState];
    if ([self.delegate respondsToSelector:@selector(loginViewWillAppear:)]) {
        [self.delegate loginViewWillAppear:animated];
    }
}

- (void)bindToLoginVCWithVar:(id)var {
    if (!self.externContiner) {
        self.externContiner = NSMutableSet.new;
    }
    [self.externContiner addObject:var];
}

- (void)clickOneKeyLoginBtn {
    // 埋点检查 c 通过 b 通过 表格通过
    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=login" domain:@"/jianzhi/newestguide/one"];
    if (self.config.loginWithChinaMobile) {
        self.config.loginWithChinaMobile(self, ^{
            //获取手机号成功
            ;
        }, ^(id sender) {
            //获取手机号失败
            [self loginFailureToast:@"授权失败，请稍后重试"];
        }, ^{
            //获取用户授权成功
            ;
        }, ^(id sender) {
            //获取用户授权失败
            [self loginFailureToast:@"授权失败，请稍后重试"];
        }, ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
            //获取 token 关联斗米账号登录成功
            [self dismissViewControllerAnimated:YES completion:nil];
            
            NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
            
            if (code == 1000) {// 成功
                [self loginSuccessToast:@"登录成功"];
                // 表格通过
                [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=login_success" domain:@"/jianzhi/newestguide/one"];
            } else {
                [self loginFailureToast:@"授权失败，请稍后重试"];
            }
        }, ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
            //获取 token 关联斗米账号登录失败
            [self dismissViewControllerAnimated:YES completion:nil];
            [self loginFailureToast:@"授权失败，请稍后重试"];
            [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/cmcc/login"];
        });
    }
}

- (void)clickGetVerificationBtn {
    // 埋点检查 bc 相同，注意 两端的实现
    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=obtain" domain:@"/jianzhi/newestguide/one"];
    
    if ([self verifyPhoneNum]) {
        [self addSmsVC];
    }
}

- (void)addSmsVC {
    DMLSMSValidationVC *smsVC;
    DMLSMSVCConfig *smsConfig = DMLSMSVCConfig.new;
    NSMutableArray *container = NSMutableArray.new;
    //网络请求
    smsConfig.reqVerifyCode = self.config.reqVerifyCode;
    
    //返回按钮点击
    LoginCoreVC *loginVC = [[LoginCoreVC alloc] initWithConfig:self.config];
    if (self.config.SMSVCToMainVC) {
        smsConfig.SMSVCBackClicked = ^() {
            UIViewController *sms = container.firstObject;
            self.config.SMSVCToMainVC(loginVC, sms.navigationController);
        };
    } else {
        smsConfig.SMSVCBackClicked = ^() {
            [self transitionToViewController:loginVC];
        };
    }
    //验证码输入完成
    smsConfig.fromUserCenterDidFinishSMSCode = ^(NSString * _Nonnull code) {
        if (self.config.fromUserCenterFinishInputSMSCode) {
            self.config.fromUserCenterFinishInputSMSCode();
        }
        [self userCenterDidInputSMSCode:code];
    };
    //验证码输入完成
    smsConfig.didFinishSMSCode = ^(NSString * _Nonnull code) {
        [self userCenterDidInputSMSCode:code];
    };
    smsVC = [[DMLSMSValidationVC alloc] initWithConfig:smsConfig];
    [container addObject:smsVC];
    smsVC.phone = self.middleLoginView.phoneTF.text;
    if (self.config.pushToSMSVC) {
        self.config.pushToSMSVC(smsVC);
    } else {
        [self transitionToViewController:smsVC];
    }
}

- (void)guideResumeBackButtonClicked:(UIButton *)btn {
    LoginCoreVC *loginVC = LoginCoreVC.new;
    if (self.delegate) {
        loginVC.delegate = self.delegate;
    }
    if (self.customedAddWeChatBindVC) {
        loginVC.customedAddWeChatBindVC = self.customedAddWeChatBindVC;
    }
    if (self.customedAddsmsVC) {
        loginVC.customedAddsmsVC = self.customedAddsmsVC;
    }
    [self transitionToViewController:loginVC];
}

- (void)pushToAgreementVC {
    self.navigationController.navigationBar.hidden = NO;
    [DMLoginAdapter pushToAgreementVC];//[KCUriDispatcher dispatcher:@"doumi://agreement"];
    //这边自己做的view，动画过去就行了
    
    //    UIViewController *vc = UIViewController.new;
    //    [self.navigationController pushViewController:vc animated:YES];
}

# pragma mark - 验证码登录界面
- (void)clickOtherPhoneLogin {
    self.oneKeyLoginView.hidden = YES;
    self.middleLoginView.hidden = NO;
    // 埋点检查 c 通过 b 通过 表格通过
    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=other" domain:@"/jianzhi/newestguide/one"];
    
}

- (void)userCenterDidInputSMSCode:(NSString *)code {
    //输入验证码完成，进行登录操作
    [self loadingToast:nil];
    self.config.loginWithPhone(self.middleLoginView.phoneTF.text,
                               code,
                               ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
                                   [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
                                   //埋点
                                   // 埋点检查 c 通过 b 通过
                                   [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=login" domain:@"/jianzhi/newestguide/second"];
                               },
                               ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
                                   [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
                                   
                                   // 埋点检查 c 通过
                                   NSDictionary *dict = @{@"Function":@"fail"};
                                   [DMLoginAdapter UMengCollection:@"NovGuideVerify_Function" content:dict];
                                   //toast操作
                                   [DMLoginAdapter handleToastType:ToastType_Hide_Single message:nil];
                                   if ([userInfo isKindOfClass:[NSDictionary class]] && userInfo[@"message"]) {
                                       //埋点
                                       [DMLoginAdapter handleToastType:ToastType_Show_Error message:userInfo[@"message"]];
                                   } else {
                                       [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:@"请求失败"];
                                   }
                               });
}

- (BOOL)verifyPhoneNum {
    if (self.middleLoginView.phoneTF.text.length == 0) {
        [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"请输入手机号"];
        [self setVerificationBtnUnable];
        return NO;
    } else if (self.middleLoginView.phoneTF.text.length > 0) {
        [self setVerificationBtnUnable];
        return YES;
    }
    return YES;
}

- (void)setVerificationBtnUnable {
    self.middleLoginView.verificationBtn.enabled = NO;
    
    UIColor *btnTitleColor = [UIColor colorWithRed:(153)/255.0 green:(153)/255.0 blue:(153)/255.0 alpha:1.0];
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        btnTitleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:28/255.0 green:28/255.0 blue:30/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:(153)/255.0 green:(153)/255.0 blue:(153)/255.0 alpha:1.0];
            }
        }];
    }
#endif
    [self.middleLoginView.verificationBtn setTitleColor:btnTitleColor forState:UIControlStateDisabled];
    
    UIColor *btnBGColor = [UIColor colorWithRed:(229)/255.0 green:(229)/255.0 blue:(229)/255.0 alpha:1.0];
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        btnBGColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:108/255.0 green:108/255.0 blue:108/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:(229)/255.0 green:(229)/255.0 blue:(229)/255.0 alpha:1.0];
            }
        }];
    }
#endif
    self.middleLoginView.verificationBtn.backgroundColor = btnBGColor;
    self.middleLoginView.verificationBtn.layer.shadowColor = UIColor.whiteColor.CGColor;
    self.middleLoginView.verificationBtn.layer.shadowOffset = CGSizeMake(0, 0);
    self.middleLoginView.verificationBtn.layer.shadowRadius = 0.f;
    self.middleLoginView.verificationBtn.layer.shadowOpacity = 0.f;
}


#pragma mark - 微信登录
- (void)weChatLogin {
    self.isWechatLogin = YES;
    // 埋点检查 c 通过 b 通过 表格通过
    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=wechat_login" domain:@"/jianzhi/newestguide/one"];
    
    self.config.loginWithWeChat(^{//获取 code 成功
        [self loadingToast:@"获取授权信息"];
    }, ^{//获取 code 失败
        [self loginFailureToast:@"应用授权失败，请稍后重试"];
    }, ^(id sender) {//获取 token 成功
        self.lastThirdBindSender = sender;
    }, ^{//获取 token 失败
        [self loginFailureToast:@"应用授权失败，请稍后重试"];
    }, ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
        [self handleWeChatLoginSuccess:responseObj];
    }, ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        [self loginFailureToast:@"应用授权失败，请稍后重试"];
    });
}

- (void)handleWeChatLoginSuccess:(id)responseObj {
    if (responseObj) {
        NSDictionary *data = responseObj;
        NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
        
        if (code == 1000) { // 成功
            [self loginSuccessToast:@"登录成功"];
            [self.delegate loginSuccessWithType:DMLoginType_WeChat userInfo:data[@"data"]];
            [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
            
            // 埋点检查 c 通过 b 通过 表格通过
            [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=wechat_success"  domain:@"/jianzhi/newestguide/one"];
        } else if (code == -412) { //未绑定
            [DMLoginAdapter handleToastType:ToastType_Hide_Single message:nil];
            if (self.customedAddWeChatBindVC) {
                self.customedAddWeChatBindVC(self.lastThirdBindSender);
            } else {
                DMLWeChatVCConfig *weChatConfig = DMLWeChatVCConfig.new;
                weChatConfig.loginWithThirdInfo = self.config.loginWithThirdInfo;
                weChatConfig.reqVerifyCode = self.config.reqVerifyCode;
                weChatConfig.lastThirdBindSender = self.lastThirdBindSender;
                
                DMLWeChatBindPhoneVC *wechatVC = [[DMLWeChatBindPhoneVC alloc] initWithConfig:weChatConfig];
                
                
                __weak typeof(wechatVC) weakWeChatVC = wechatVC;
                wechatVC.weChatVCBackPressed = ^{
                    LoginCoreVC *vc = [[LoginCoreVC alloc] initWithConfig:self.config];
                    if (self.config.WeChatBindVCToMainVC) {
                        self.config.WeChatBindVCToMainVC(vc, weakWeChatVC.navigationController);
                    } else {
                        [weakWeChatVC.navigationController pushViewController:vc animated:YES];
                        weakWeChatVC.navigationController.navigationBar.hidden = NO;
                    }
                };
                if (self.config.pushToWeChatBindVC) {
                    self.config.pushToWeChatBindVC(wechatVC);
                } else {
                    [self transitionToViewController:wechatVC];
                }
                
            }
        } else if (code == -200) { //账号不存在
            [DMLoginAdapter handleToastType:ToastType_Hide_Single message:nil];
            [DMLoginAdapter handleToastType:ToastType_Show_Normal message:@"请先注册"];
        } else {
            if (code == -408) { // 已绑定
                [self.delegate loginSuccessWithType:DMLoginType_WeChat_HaveBinded userInfo:data[@"data"]];
            } else {
                if ([responseObj isKindOfClass:[NSDictionary class]]) {
                    [self loginFailureToast:[responseObj valueForKey:@"message"]];
                } else {
                    [self loginFailureToast:@"登录失败"];
                }
            }
        }
    }
}

//////  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓    以下是纯view 操作，不需要看了

#pragma mark - 界面布局
- (void)addLoginView_headerView {
    if (!self.headerLoginView) {
        CGRect headerRect = CGRectMake(0, 0, self.view.DL_width, 74);
        self.headerLoginView = [[DMLLoginHeaderView alloc] initWithFrame:headerRect];
        [self.view addSubview:self.headerLoginView];
    }
}

- (void)addLoginView_middleView {
    if (!self.middleLoginView) {
        CGRect middleRect = CGRectMake(self.view.DL_bounds_left + 40,
                                       self.headerLoginView.DL_bottom + 123,
                                       self.view.DL_width - (self.view.DL_bounds_left + 40) - 40,
                                       170);
        self.middleLoginView = [[DMLLoginMiddleView alloc] initWithFrame:middleRect];
        [self.view addSubview:self.middleLoginView];
    }
}

- (void)addMoblileOneLoginView {
    if (!self.oneKeyLoginView) {
        CGRect oneKeyRect = CGRectMake(self.view.DL_bounds_left + 40,
                                       self.headerLoginView.DL_bottom + 207,
                                       self.view.DL_width - (self.view.DL_bounds_left + 40) - 40,
                                       146);
        self.oneKeyLoginView = [[DMLOneKeyLoginView alloc] initWithFrame:oneKeyRect];
        [self.view addSubview:self.oneKeyLoginView];
    }
}

- (void)addLoginView_bottomView {
    if (!self.bottomLoginView) {
        CGRect bottomRect = CGRectMake(0,
                                       self.view.DL_bounds_bottom - 146,
                                       self.view.DL_width,
                                       146);
        self.bottomLoginView = [[DMLLoginBottomView alloc] initWithFrame:bottomRect];
        [self.view addSubview:self.bottomLoginView];
    }
}

#pragma mark - 提示相关
- (void)loadingToast:(NSString *)message {
    [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
    [DMLoginAdapter handleToastType:ToastType_Show_Normal message:message];
}


- (void)loginFailureToast:(NSString *)message {
    [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
    if (message.length > 0) {
        [DMLoginAdapter handleToastType:ToastType_Show_Error message:message];
    }
}

- (void)loginSuccessToast:(NSString *)message {
    [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
    if (message.length > 0) {
        [DMLoginAdapter handleToastType:ToastType_Show_Success message:message];
    }
}

- (void)transitionToViewController:(UIViewController *)toVC {
    toVC.view.frame = UIScreen.mainScreen.bounds;
    [self addChildViewController:toVC];
    if (_currentVC) {
        UIViewController *fromVC = _currentVC;
        [self transitionFromViewController:_currentVC
                          toViewController:toVC
                                  duration:0.3
                                   options:UIViewAnimationOptionShowHideTransitionViews
                                animations:^ {
                                }
                                completion:^(BOOL finished) {
                                    [fromVC removeFromParentViewController];
                                } ];
    } else {
        [self.view addSubview:toVC.view];
    }
    _currentVC = toVC;
}

- (void)setDelegate:(id<ModuleLoginDelegate>)delegate {
    if (!delegate) {
        NSLog(@"+_)( loginCoreVC ——> nil"); 
    }
    _delegate = delegate;
}

- (void)resignPhoneTF {
    [self.middleLoginView.phoneTF resignFirstResponder];
}

- (void)dealloc {
    [_externContiner removeAllObjects];
}

@end
