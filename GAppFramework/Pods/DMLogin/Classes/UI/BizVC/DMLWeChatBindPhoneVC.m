//
//  WechatBindPhoneViewController.m
//  GAppFramework
//
//  Created by ltl on 2019/4/12.
//  Copyright © 2019 doumi. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

#import "DMLWeChatBindPhoneVC.h"
#import "LoginCoreVC.h"

#import "DMLoginAdapter.h"
#import "DMLoginCoreLogic.h"
#import "UIView+LoginUIViewPosition.h"
#import "DMLoginStore.h"

#import "DMLoginAlertController.h"
#import "DMCaptchaAlertController.h"

@implementation DMLWeChatVCConfig
@end


@interface DMLWeChatBindPhoneVC ()
@property (nonatomic,strong) DMLWeChatBindPhoneView *bindPhoneView;
@property (nonatomic, strong) NSDictionary *loginSuccessData;

@end

@implementation DMLWeChatBindPhoneVC

- (instancetype)initWithConfig:(DMLWeChatVCConfig *)config {
    if (self = [super init]) {
        self.config = config;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    // 添加顶部空白
    //TODO: 编译替换
    double s_width = [[UIScreen mainScreen] bounds].size.width;
    double s_height = [[UIScreen mainScreen] bounds].size.height;
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (MAX(s_width, s_height)) >= 812.0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
        [self.view addSubview:view];
        view.backgroundColor = UIColor.whiteColor;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
        [self.view addSubview:view];
        view.backgroundColor = UIColor.whiteColor;
    }
    
    
    [self addBindPhoneView];
    
    // 点击了无法获取验证码
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDialogController)];
    self.bindPhoneView.cannotGetVerificationLabel.userInteractionEnabled = YES;
    [self.bindPhoneView.cannotGetVerificationLabel addGestureRecognizer:tap];

    [self.bindPhoneView.positiveBtn addTarget:self action:@selector(weChatBindPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.bindPhoneView.backBtn addTarget:self action:@selector(goBackToLoginVC) forControlEvents:UIControlEventTouchUpInside];
    
    [DMLoginAdapter PVEvent:@"/jianzhi/login/mobile" para:nil vc:self];
#ifdef DEBUG
    self.view.layer.borderColor = UIColor.cyanColor.CGColor;
    self.view.layer.borderWidth = 2;
#endif
}

- (void)goBackToLoginVC {
    self.weChatVCBackPressed();
}

- (void)weChatBindPhone {
    [self loadingToast:nil];
    
    NSString *phone = self.bindPhoneView.phoneTF.text;// [DMLoginAdapter launchGuidePhone];
    NSString *code = self.bindPhoneView.verificationTF.text;
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.config.lastThirdBindSender];
    dict[@"mobile"] = phone;
    dict[@"code"] = code;
    
    self.config.loginWithThirdInfo(dict, ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
        if (responseObj) {
            NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
            if (code == 1000) {// 成功
                [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
                NSDictionary *data = responseObj[@"data"];
                self.loginSuccessData = data;
                [self.bindPhoneView.phoneTF resignFirstResponder];
                [self.bindPhoneView.verificationTF resignFirstResponder];
                [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=wechat_success"  domain:@"/jianzhi/newestguide/one"];
                [DMLoginAdapter event:@"@atype=success@ca_name=doumi@ca_source=app@ca_from=bind"  domain:@"/jianzhi/login/mobile"];
            } else if (code == -205) {
                [self loginFailureToast:@"验证码错误"];
            } else {
                [self loginFailureToast:@"此手机号已绑定过其他微信账号，请勿重复绑定"];
            }
        }
    }, ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        [self loginFailureToast:@"手机号验证失败，请稍后重试！"];
    });
}

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

- (void)addBindPhoneView {
    if(!self.bindPhoneView){
        DMLWeChatBindPhoneView *bindPhoneView = [[DMLWeChatBindPhoneView alloc] initWithFrame:self.view.bounds];
        self.bindPhoneView = bindPhoneView;
        [self.view addSubview:bindPhoneView];
        
        [bindPhoneView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:bindPhoneView action:@selector(resignTxtField)]];
        
#warning —— 需要检查是否会引起崩溃
//        [bindPhoneView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing:)]];
        
        if (@available(iOS 11.0, *)) {
            CGRect guideFrame = [[UIApplication sharedApplication] statusBarFrame];// self.view.safeAreaLayoutGuide.layoutFrame;
            bindPhoneView.DL_top = guideFrame.size.height;
            bindPhoneView.DL_left = self.view.DL_bounds_left;
            bindPhoneView.DL_width = self.view.DL_width;
            bindPhoneView.DL_height = self.view.DL_height;
        } else {
            bindPhoneView.DL_top = self.view.DL_bounds_top;
            bindPhoneView.DL_left = self.view.DL_bounds_left;
            bindPhoneView.DL_width = self.view.DL_width;
            bindPhoneView.DL_height = self.view.DL_height;
        }
    }
}


- (void)showDialogController {
    if (self.bindPhoneView.phoneTF.text.length  < 11 ) {
        [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"请输入正确的手机号"];
    } else {
        DMLAlertConfig *alertConfig = DMLAlertConfig.new;
        alertConfig.title = @"语音验证码";
        alertConfig.attrTitle = nil;
        alertConfig.subTitle = @"我们将以电话形式告知您验证码，请注意接听025、125、950等开头的来电";
        alertConfig.attrSubTitle = nil;
        alertConfig.confirmBtnTxt = @"接听";
        alertConfig.cancelBtnTxt = @"取消";
        alertConfig.confirmBlock = ^(id para){
            NSString *phoneNum = self.bindPhoneView.phoneTF.text;// [DMLoginAdapter launchGuidePhone];
            self.config.reqVerifyCode(phoneNum,
                                      @"0",
                                      @"1",
            ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
    
            }, ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {if ([[userInfo objectForKey:@"code"] integerValue] == -3) {
                DMLCaptchaAlertConfig *captchaConfig = DMLCaptchaAlertConfig.new;
                captchaConfig.title = @"请输入验证码";
                captchaConfig.mobile = phoneNum;
                captchaConfig.type = @"0";
                captchaConfig.smsType = @"1";
                captchaConfig.confirmBtnTxt = @"确定";
                captchaConfig.cancelBtnTxt = @"取消";
                UIViewController * dialog = [DMCaptchaAlertController captchaAlertWithConfig:captchaConfig];
                
                [self presentViewController:(UIViewController *)dialog animated:YES completion:nil];
            } else {
                NSString *message = userInfo[@"message"];
                if (message.length > 0) {
                    [DMLoginAdapter handleToastType:ToastType_Show_Error message:message];
                }
            }
            });
        };
        
        UIViewController *alert = [DMLoginAlertController alertWithConfig:alertConfig];//[DMLoginAdapter createAlertWithConfig:alertConfig];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
};
@end
