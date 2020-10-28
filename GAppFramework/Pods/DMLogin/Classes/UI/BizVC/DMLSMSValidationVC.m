//
//  DMSMSValidationViewController.m
//  c_doumi
//
//  Created by tangjun on 2018/11/22.
//  Copyright © 2018年 GAppFramework. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

#import "DMLSMSValidationVC.h"
#import "DMLVerifyCodeInputView.h"

#import "DMLoginAdapter.h"
#import "DMLoginCoreLogic.h"
#import "NSTimer+Block.h"
#import "DMLoginAlertController.h"
#import "DMCaptchaAlertController.h"

#import "DMLKeyChain.h"

@implementation DMLSMSVCConfig
@end

@interface DMLSMSValidationVC ()<getTextFieldContentDelegate>
{
    DMLVerifyCodeInputView *vertificationCodeInputView;
    BOOL hasSend;
    BOOL hasToasted;
}
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *pageTitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *contentLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *smsContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UILabel *countingDownLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *getCallVerifyBtn;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) DMLSMSVCConfig *SMSVCConfig;

@end

@implementation DMLSMSValidationVC

- (instancetype)initWithConfig:(DMLSMSVCConfig *)config {
    if (self = [super init]) {
        self.SMSVCConfig = config;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    vertificationCodeInputView = [[DMLVerifyCodeInputView alloc] initWithFrame:CGRectMake(12,20,[UIScreen mainScreen].bounds.size.width - 32 - 24 ,44)];
    vertificationCodeInputView.delegate = self;
    /****** 设置验证码/密码的位数默认为四位 ******/
    vertificationCodeInputView.numberOfVertificationCode = 6;
    /*********验证码（显示数字）YES,隐藏形势 NO，数字形式**********/
    vertificationCodeInputView.secureTextEntry =NO;
    [_smsContainer addSubview:vertificationCodeInputView];
    
    [vertificationCodeInputView becomeFirstResponder];

    NSString *phoneNum = [self getSMSCodePhone];//[DMLauchSetting sharedInstance].launchGuideModel.phone;
    self.contentLabel.text = [NSString stringWithFormat:@"接收验证码的手机号是 %@", phoneNum];
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        self.contentLabel.textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:107/255.0 green:107/255.0 blue:108/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
            }
        }];
    }
#endif
    

#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        self.pageTitleLabel.textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0];
            }
        }];
    }
#endif
    
    UIColor *backBtnTitleColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0];
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        backBtnTitleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:152/255.0 green:152/255.0 blue:153/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0];
            }
        }];
    }
#endif
    [self.backBtn setTitleColor:backBtnTitleColor forState:UIControlStateNormal];
    
    UIColor *resendBtnTitleColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1/1.0];
#ifdef __IPHONE_13_0
    if (@available(ios 13, *)) {
        resendBtnTitleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:175/255.0 green:176/255.0 blue:176/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1/1.0];
            }}];
    }
#endif
    [self.resendButton setTitleColor:resendBtnTitleColor forState:UIControlStateNormal];
    self.countingDownLabel.textColor = resendBtnTitleColor;
    [self.getCallVerifyBtn setTitleColor:resendBtnTitleColor forState:UIControlStateNormal];

#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        self.smsContainer.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:44/255.0 green:44/255.0 blue:46/255.0 alpha:1/1.0];
            } else {
                return UIColor.whiteColor;
            }
        }];
    }
#endif
    
    UIColor *bgColor = UIColor.whiteColor;
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:28/255.0 green:28/255.0 blue:30/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1/1.0];
            }
        }];
    }
#endif
    self.view.backgroundColor = bgColor;
    
    hasToasted = NO;
    
    
#ifdef DEBUG
    self.view.layer.borderColor = UIColor.blueColor.CGColor;
    self.view.layer.borderWidth = 2;
#endif
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        //    登录页面_验证码登录
    //只有 c 端有这个 PV //[DMLoginAdapter PVEvent:@"/jianzhi/login/validate" para:nil vc:self];//[self addPVLog:@"/jianzhi/login/validate" param:nil];
    // 埋点检查 c 通过
    [DMLoginAdapter PVEvent:@"/jianzhi/newestguide/second" para:nil vc:self];
    
    // 获取一次验证码
//    登录页面_验证码登录    /jianzhi/login/validate        获取验证码        @atype=click@ca_name=doumi@ca_source=app@ca_from=obtain
    NSString *evContent = [NSString stringWithFormat:@"@atype=click@ca_name=doumi@ca_source=app@auz_notification=%@@%@", [DMLoginAdapter APNSState], @"ca_from=obtain"];
    //只有 c 端有这个  EV
    // 埋点检查 c 通过
    [DMLoginAdapter EVLog:evContent para:nil vc:self];
    
    
    
    
    NSString *phoneNum = [self getSMSCodePhone];//[DMLauchSetting sharedInstance].launchGuideModel.phone;
    if (![self.childViewControllers count]) {
        [self sendSMSCode:phoneNum];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//#ifdef DEBUG
//    self.view.layer.borderColor = UIColor.redColor.CGColor;
//    self.view.layer.borderWidth = 2;
//#endif
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [super viewDidDisappear:animated];
}

//all code was inputed
#pragma mark - 短信验证码填完后
-(void)returnTextFieldContent:(NSString*)content {
    KeyChainLog(([NSString stringWithFormat:@"%s, code:%@", __FUNCTION__, content]));
    hasSend = NO;
    [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
    [DMLoginAdapter handleToastType:ToastType_Show_Normal message:nil];
    //移除特殊验证码的校验
    if (![[DMLoginAdapter launchGuideverifyCode] isEqualToString:@"888888"] &&
        ![content isEqualToString:@"888888"] &&
        [[DMLoginAdapter launchGuideverifyCode] isEqual:content]) {
        hasSend = YES;
        KeyChainLog(([NSString stringWithFormat:@"userCode:%@, curCode:%@", [DMLoginAdapter launchGuideverifyCode], content]));
    }
    [DMLoginAdapter setlaunchGuideVerifyCode:content];
    
    if (![[DMLoginAdapter DMCombineValueForKey:DMCK_LoginFromMe] isEqualToString:@"yes"]) {
        if (self.SMSVCConfig.didFinishSMSCode) {
            KeyChainLog(@"有 finishSMSCode");
            if (!hasSend) {
                KeyChainLog(@"未发送过相同验证码 1");
                self.SMSVCConfig.didFinishSMSCode(vertificationCodeInputView.vertificationCode);
                hasSend = YES;
            } else {
                KeyChainLog(@"发送过相同验证码 1");
                [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
                [DMLoginAdapter handleToastType:ToastType_Show_Normal message:@"验证码已发送..."];
            }
        } else {
            KeyChainLog(@"无 finishSMSCode");
            [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
            [DMLoginAdapter handleToastType:ToastType_Show_Normal message:@"正在登录中…"];
        }
    } else {
        if (self.SMSVCConfig.fromUserCenterDidFinishSMSCode) {
            KeyChainLog(@"有 fromUserCenterDidFinishSMSCode");
            if (!hasSend) {
                KeyChainLog(@"未发送过相同验证码 2");
                self.SMSVCConfig.fromUserCenterDidFinishSMSCode(vertificationCodeInputView.vertificationCode);
                hasSend = YES;
            } else {
                KeyChainLog(@"发送过相同验证码 2");
                [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
                [DMLoginAdapter handleToastType:ToastType_Show_Normal message:@"验证码已发送.."];
            }
        } else {
            KeyChainLog(@"无 fromUserCenterDidFinishSMSCode");
            [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
            [DMLoginAdapter handleToastType:ToastType_Show_Normal message:@"正在登录中"];
        }
    }
}

//返回
- (IBAction)tapBack:(id)sender {
    // 埋点检查 c 通过
    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=back" domain:@"/jianzhi/newestguide/second"];
    NSDictionary *dict = @{@"Function":@"back"};
    [DMLoginAdapter UMengCollection:@"NovGuideVerify_Function" content:dict];
    
    self.SMSVCConfig.SMSVCBackClicked();
}

//收不到验证码
- (IBAction)tapNoValidation:(id)sender {
    // 埋点检查 c 通过
    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=noyzm" domain:@"/jianzhi/newestguide/second"];

    
    NSString *phoneNum = [self getSMSCodePhone];
    [self sendVoiceVerificationCode:phoneNum];
}

//重新获取
- (IBAction)tapRetry:(id)sender {
    // 埋点检查 c 通过
    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=regain" domain:@"/jianzhi/newestguide/second"];

    NSDictionary *dict = @{@"Function":@"refresh"};
    //只在c端
    // 埋点检查 c 通过
    [DMLoginAdapter UMengCollection:@"NovGuideVerify_Function" content:dict];
    
    NSString *phoneNum = [self getSMSCodePhone];
    [self sendSMSCode:phoneNum];
}

#pragma mark -

- (void)sendSMSCode:(NSString *)mobileNumber {
    if (!mobileNumber || mobileNumber.length < 0) {
        [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"请输入正确的手机号"];
        return;
    }
    
    [DMLoginAdapter handleToastType:ToastType_Show_Normal_NoDim message:@""];
    self.SMSVCConfig.reqVerifyCode(mobileNumber,//phone
                                   @"0",//type
                                   nil,//smsType
    ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {//成功回调
        NSDictionary *dict = @{@"Value":@"0"};
        // 埋点检查 c 通过
        [DMLoginAdapter UMengCollection:@"NovGuideVerify_Code" content:dict];
        
        [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒计时
            [self countingDown];
        });
    }, ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {//失败回调
        NSDictionary *dict = @{@"Value":@"1"};
        // 埋点检查 c 通过
        [DMLoginAdapter UMengCollection:@"NovGuideVerify_Code" content:dict];
        
        [DMLoginAdapter handleToastType:ToastType_Hide_All_NoAni message:nil];
        
        if ([[userInfo objectForKey:@"code"] integerValue] == -3) {
//            TODO: todo展示对话框
            DMLCaptchaAlertConfig *captchaConfig = DMLCaptchaAlertConfig.new;
            captchaConfig.title = @"请输入验证码";
            captchaConfig.mobile = mobileNumber;
            captchaConfig.type = @"0";
            captchaConfig.smsType = nil;
            captchaConfig.confirmBtnTxt = @"确定";
            captchaConfig.cancelBtnTxt = @"取消";
            captchaConfig.confirmBlock = ^(NSString * _Nonnull captcha) {
                [self countingDown];
            };
            UIViewController *dialog = [DMCaptchaAlertController captchaAlertWithConfig:captchaConfig]; //[DMLoginAdapter createCaptchaAlertWithConfig:captchaConfig];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:dialog animated:YES completion:nil];
            });
        } else {
            NSString *message = userInfo[@"message"];
            if (message.length > 0) {
                [DMLoginAdapter handleToastType:ToastType_Show_Error message:message];
            } else {
                if (error.code == -1009) {
                    [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"网络连接失败"];
                }
            }
        }
    });
}

- (void)sendVoiceVerificationCode:(NSString *)phoneNum {
    DMLAlertConfig *alertConfig = DMLAlertConfig.new;
    alertConfig.title = @"语音验证码";
    alertConfig.attrTitle = nil;
    alertConfig.subTitle = @"我们将以电话形式告知您验证码，请注意接听025、125、950等开头的来电";
    alertConfig.attrSubTitle = nil;
    alertConfig.confirmBtnTxt = @"接听";
    alertConfig.cancelBtnTxt = @"取消";
    alertConfig.confirmBlock = ^(id para){
        BOOL isCounting = [self.timer isValid];
        if (isCounting) {
            [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"操作过于频繁，请60秒后重试"];
            return;
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        self.SMSVCConfig.reqVerifyCode(phoneNum,
                                       @"0",//type
                                       @"1",//smsType
        ^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
            [self countingDown];
        }, ^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
            if ([[userInfo objectForKey:@"code"] integerValue] == -3) {
                DMLCaptchaAlertConfig *captchaConfig = DMLCaptchaAlertConfig.new;
                captchaConfig.title = @"请输入验证码";
                captchaConfig.mobile = phoneNum;
                captchaConfig.type = @"0";
                captchaConfig.smsType = @"1";
                captchaConfig.confirmBtnTxt = @"确定";
                captchaConfig.cancelBtnTxt = @"取消";
                captchaConfig.confirmBlock = ^(NSString * _Nonnull captcha) {
                    [self countingDown];
                };
                UIViewController * dialog = [DMCaptchaAlertController captchaAlertWithConfig:captchaConfig];//[DMLoginAdapter createCaptchaAlertWithConfig:captchaConfig];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:dialog animated:YES completion:nil];
                });
            } else {
                NSString *message = userInfo[@"message"];
                if (message.length > 0) {
                    [DMLoginAdapter handleToastType:ToastType_Show_Error message:message];
                }
            }
        });
    };
    alertConfig.cancelBlock = nil;
    UIViewController *alert = [DMLoginAlertController alertWithConfig:alertConfig];//[DMLoginAdapter createAlertWithConfig:alertConfig];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)countingDown {
    if (![self.timer isValid]) {
        if (!hasToasted) {
            [DMLoginAdapter handleToastType:ToastType_Show_Success message:@"验证码已发送"];
            hasToasted = YES;
        }
        
        __block NSInteger timerSeconds = 60;
        self.resendButton.hidden = YES;
        self.resendButton.userInteractionEnabled = NO;
        
        self.countingDownLabel.text = [NSString stringWithFormat:@"%ld秒后重新获取", (long)timerSeconds];
        
        self.timer = [NSTimer block_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
            self.countingDownLabel.hidden = NO;
            self.countingDownLabel.text = [NSString stringWithFormat:@"%ld秒后重新获取", (long)timerSeconds];
            timerSeconds--;
            if (timerSeconds < 0) {
                self.countingDownLabel.hidden = YES;
                self.resendButton.hidden = NO;
                self.resendButton.userInteractionEnabled = YES;
                hasToasted = NO;
                [timer invalidate];
                timer = nil;
            }
        } repeats:YES];
        
        [self.timer fire];
    }
}


- (NSString *)getSMSCodePhone {
    if (_phone) {
        return _phone;
    } else {
        return [DMLoginAdapter launchGuidePhone];
    }
}

@end
