//
//  DMWechatBindPhoneView.m
//  c_doumi
//
//  Created by ltl on 2019/4/13.
//  Copyright © 2019 doumijianzhi. All rights reserved.
//

static  NSString *const kPhoneTFPlaceHolder = @"请输入11位手机号码";
static  NSString *const kVerificationTFPlaceHolder = @"请输入6位验证码";
static  NSString *const kPositiveBtnTitle = @"确认";
static  NSString *const kVerificationBtnTitle = @"获取验证码";

#import "DMLWeChatBindPhoneView.h"
//#import "DMLauchSetting.h"//应该是启动的时候的
#import "UIView+LoginUIViewPosition.h"
#import "DMLoginAdapter.h"
#import "DMLoginCoreLogic.h"
#import "DMCaptchaAlertController.h"
#import "NSTimer+Block.h"

@interface DMLWeChatBindPhoneView()
@property (nonatomic, strong) NSTimer *timer;
@end


@implementation DMLWeChatBindPhoneView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
        self.backgroundColor = bgColor;
        [self addViews];
    }
    return self;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.backgroundColor = UIColor.whiteColor;
        [self addViews];
    }
    return self;
}

- (void )addViews {
    [self addBackBtn];
    [self addTitle];
    
    [self addPhoneTF];
    [self addFirstLineView];
    
    [self addVerificationTF];
    [self addVerificationBtn];
    [self addSecondLineView];
    
    [self addPositiveBtn];

    [self addCannotGetVerificationLabel];
}

- (void)addBackBtn {
    UIView *view = [[UIView alloc] init];
    self.topView = view;
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
    self.topView.backgroundColor = bgColor;
    [self addSubview:view];
    
    //TODO: 约束设置
    view.DL_top = self.DL_bounds_top;
    view.DL_left = self.DL_bounds_left;
    view.DL_size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 44);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn = btn;
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateNormal];
    [view addSubview:btn];
    
    //TODO: 约束设置
    btn.DL_top = self.DL_bounds_top + 11;
    btn.DL_left = self.DL_bounds_left + 16;
    btn.DL_size = CGSizeMake(22, 22);
}

- (void)addTitle {
    UILabel *tilteLable = [[UILabel alloc] init];
    tilteLable.text = @"为了账户安全";
    tilteLable.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
    tilteLable.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0];
    
    [self addSubview:tilteLable];
    
    //TODO: 约束设置
    tilteLable.DL_top = self.topView.DL_bottom + 41;
    tilteLable.DL_left = self.DL_bounds_left + 40;
    tilteLable.DL_size = CGSizeMake(144, 32);
    
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel = subTitleLabel;
    subTitleLabel.text = @"请验证手机号";
    subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    subTitleLabel.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0];
    
    [self addSubview:subTitleLabel];
    
    //TODO: 约束设置
    subTitleLabel.DL_top = tilteLable.DL_bottom + 8;
    subTitleLabel.DL_left = tilteLable.DL_left;
    subTitleLabel.DL_size = CGSizeMake(87, 22);
}

- (void)addPhoneTF{
    UITextField *phoneTF = [[UITextField alloc] init];
    self.phoneTF = phoneTF;
    phoneTF.borderStyle = UITextBorderStyleNone;
    phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTF.returnKeyType = UIReturnKeySearch;
    phoneTF.enablesReturnKeyAutomatically = YES;
    
    UIColor *phoneTFBG = UIColor.whiteColor;
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        phoneTFBG = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:28/255.0 green:28/255.0 blue:30/255.0 alpha:1/1.0];
            } else {
                return UIColor.whiteColor;
            }
        }];
    }
#endif
    phoneTF.backgroundColor = phoneTFBG;
    
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    
    UIColor *textColor = UIColor.blackColor;
    //防止 Xcode10 编译报错
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1/1.0];
            } else {
                return UIColor.blackColor;
            }
        }];
    }
#endif
    phoneTF.textColor = textColor;
    
    
    UIColor *placeHolderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    UIFont *placeHolderFont = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    NSMutableAttributedString *placeholderString =
    [[NSMutableAttributedString alloc] initWithString:kPhoneTFPlaceHolder
                                           attributes:@{NSForegroundColorAttributeName : placeHolderColor,
                                                        NSFontAttributeName : placeHolderFont
                                           }];
    phoneTF.attributedPlaceholder = placeholderString;
    [self addSubview:phoneTF];
    
    //TODO: 约束设置
    phoneTF.DL_top = self.subTitleLabel.DL_bottom + 72;
    phoneTF.DL_left = self.subTitleLabel.DL_left;
    phoneTF.DL_width = self.DL_width - 40 - self.subTitleLabel.DL_left;
    phoneTF.DL_height = 36;
    
    //限制手机号最多输入11位
    [self.phoneTF addTarget:self action:@selector(dealWithTextField:) forControlEvents:UIControlEventEditingChanged];
}

//TODO: 文本框输入限制

- (void)addFirstLineView {
    UIView *view = [[UIView alloc] init];
    self.firstLineView = view;
    view.backgroundColor =  [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1/1.0];
    [self addSubview:view];
    
    //TODO: 约束设置
    view.DL_top = self.phoneTF.DL_bottom + 15;
    view.DL_left = self.DL_bounds_left + 40;
    view.DL_width = self.DL_width - 40 - self.subTitleLabel.DL_left;
    view.DL_height = 0.5;
}

- (void)addVerificationTF {
    UITextField *verificationTF = [[UITextField alloc] init];
    self.verificationTF = verificationTF;
    verificationTF.borderStyle = UITextBorderStyleNone;
    verificationTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    verificationTF.returnKeyType = UIReturnKeySearch;
    verificationTF.enablesReturnKeyAutomatically = YES;
    verificationTF.placeholder = kVerificationTFPlaceHolder;
    
    UIColor *phoneTFBG = UIColor.whiteColor;
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        phoneTFBG = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:28/255.0 green:28/255.0 blue:30/255.0 alpha:1/1.0];
            } else {
                return UIColor.whiteColor;
            }
        }];
    }
#endif
    verificationTF.backgroundColor = phoneTFBG;
    
    verificationTF.keyboardType = UIKeyboardTypeNumberPad;
    
    UIColor *textColor = UIColor.blackColor;
    //防止 Xcode10 编译报错
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1/1.0];
            } else {
                return UIColor.blackColor;
            }
        }];
    }
#endif
    verificationTF.textColor = textColor;
    
    UIColor *placeHolderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    UIFont *placeHolderFont = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    NSMutableAttributedString *placeholderString =
    [[NSMutableAttributedString alloc] initWithString:kVerificationTFPlaceHolder
                                           attributes:@{NSForegroundColorAttributeName : placeHolderColor,
                                                        NSFontAttributeName : placeHolderFont
                                           }];
    verificationTF.attributedPlaceholder = placeholderString;
    [self addSubview:verificationTF];
    
    //TODO: 约束设置
    verificationTF.DL_top = self.firstLineView.DL_bottom + 18;
    verificationTF.DL_left = self.subTitleLabel.DL_left;
    verificationTF.DL_width = self.DL_bounds_right - 130 - self.subTitleLabel.DL_left;
    verificationTF.DL_height = 36;
    
    //限制手机号最多输入6位
    [self.verificationTF addTarget:self action:@selector(dealWithTextField:) forControlEvents:UIControlEventEditingChanged];
}


- (void)dealWithTextField:(UITextField *)field {
    if (field == self.phoneTF) {
        if (field.text.length > 11) {
            field.text = [field.text substringToIndex:11];
        }
//        [DMLauchSetting sharedInstance].launchGuideModel.phone = text;
        if (self.phoneTF.text.length >= 11 && ![self.timer isValid]) {
            self.verificationBtn.enabled = YES;
            [self.verificationBtn setTitleColor:[UIColor colorWithRed:(64)/255.0 green:(64)/255.0 blue:(64)/255.0 alpha:1.0] forState:UIControlStateNormal];
        } else {
            self.verificationBtn.enabled = NO;
            [self.verificationBtn setTitleColor:[UIColor colorWithRed:(153)/255.0 green:(153)/255.0 blue:(153)/255.0 alpha:1.0] forState:UIControlStateDisabled];
        }
    } else if (field == self.verificationTF) {
        if (field.text.length > 6) {
            field.text = [field.text substringToIndex:6];
        }
    }
    
    if (self.phoneTF.text.length >= 0 && self.verificationTF.text.length >= 6) {
        [self setPositiveBtnToAble];
    } else {
        [self setPositiveBtnToUnable];
    }
}

- (void)setPositiveBtnToAble {
    self.positiveBtn.enabled = YES;
    [self.positiveBtn setTitleColor:[UIColor colorWithRed:(64)/255.0 green:(64)/255.0 blue:(64)/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.positiveBtn.backgroundColor =  [UIColor colorWithRed:(255)/255.0 green:(204)/255.0 blue:(0)/255.0 alpha:1.0];
    self.positiveBtn.layer.shadowColor = [UIColor colorWithRed:(255)/255.0 green:(204)/255.0 blue:(0)/255.0 alpha:1.0].CGColor;
    self.positiveBtn.layer.shadowOffset = CGSizeMake(0, 2);
    self.positiveBtn.layer.shadowRadius = 14.f;
    self.positiveBtn.layer.shadowOpacity = 0.4f;
}

- (void)setPositiveBtnToUnable {
    self.positiveBtn.enabled = NO;
    [self.positiveBtn setTitleColor:[UIColor colorWithRed:(153)/255.0 green:(153)/255.0 blue:(153)/255.0 alpha:1.0] forState:UIControlStateDisabled];
    self.positiveBtn.backgroundColor = [UIColor colorWithRed:(229)/255.0 green:(229)/255.0 blue:(229)/255.0 alpha:1.0];
    self.positiveBtn.layer.shadowColor = UIColor.whiteColor.CGColor;
    self.positiveBtn.layer.shadowOffset = CGSizeMake(0, 0);
    self.positiveBtn.layer.shadowRadius = 0.f;
    self.positiveBtn.layer.shadowOpacity = 0.f;
}


- (void)addVerificationBtn {
    
    UIButton *btn = [[UIButton alloc] init];
    self.verificationBtn = btn;
    [btn setTitle:kVerificationBtnTitle forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [btn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [self addSubview:btn];
    
    btn.DL_top = self.verificationTF.DL_top + 8;
    btn.DL_left = self.verificationTF.DL_right + 7;
    btn.DL_size = CGSizeMake(90, 22);
    
    [btn addTarget:self action:@selector(getVerificationCode) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 获取验证码逻辑
- (void)getVerificationCode {
    if (![DMLoginAdapter isNetworkConnected]) {
        [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"无网络"];
        return;
    }
    
    NSString * title = @"请输入图片验证码确认你不是机器人";
    NSString * phoneNum = self.phoneTF.text;// [DMLoginAdapter launchGuidePhone];
    NSString * keyboard = @"default";
    NSString * type = @"0";  // 修改手机号发送验证type：1
    NSString * smsType = @"0";
    
    
          //TODO: showNoDimMessage [MBProgressHUD showNoDimMessage:@""];
          //TODO: 网络请求
    [DMLoginCoreLogic requestSMSAuthCodeForMobileNumber:phoneNum capthcaString:nil type:type smsType:smsType successBlock:^(id responseObj, NSDictionary *userInfo) {

        NSDictionary *data = responseObj;
        NSString *codeState = data[@"code"];
        if ([codeState intValue]  == 0 ) {

            [self countingDown];
            [self.verificationTF becomeFirstResponder];

            [DMLoginAdapter handleToastType:ToastType_Hide_All_Animated message:nil];
        } else {
            [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"获取验证码失败"];
        }

    } failBlock:^(NSError *error, NSDictionary *userInfo) {

        [DMLoginAdapter handleToastType:ToastType_Hide_All_NoAni message:nil];

        if ([[userInfo objectForKey:@"code"] integerValue] == -3) {
            DMLCaptchaAlertConfig *captchaConfig = DMLCaptchaAlertConfig.new;
            captchaConfig.title = title;
            captchaConfig.mobile = phoneNum;
            captchaConfig.type = type;
            captchaConfig.smsType = smsType;
            captchaConfig.confirmBtnTxt = @"确定";
            captchaConfig.cancelBtnTxt = @"取消";
            captchaConfig.confirmBlock = ^(NSString * _Nonnull captcha) {
                [self countingDown];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.verificationTF becomeFirstResponder];
                });
            };
            UIViewController *dialog = [DMCaptchaAlertController captchaAlertWithConfig:captchaConfig];
            [[self viewController] presentViewController:(UIViewController *)dialog animated:YES completion:nil];
            
        } else {
            NSString *message = userInfo[@"message"];
            if (message.length > 0)
                [DMLoginAdapter handleToastType:ToastType_Show_Error message:nil];
        }
    }];
    
}

- (UIViewController *)viewController {
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        
        next = next.nextResponder;
    } while (next != nil);
    
    return nil;
}
     
- (void)countingDown {
    
    
    if (![self.timer isValid]) {
        
        __block NSInteger timerSeconds = 60;
        
        self.timer = [NSTimer block_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
            if (timerSeconds == 0) {
                [ self.verificationBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                [ self.verificationBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0] forState:UIControlStateNormal];
                self.verificationBtn.enabled = YES;
                
                self.verificationBtn.DL_left = self.verificationTF.DL_right + 7;
            } else {
                self.verificationBtn.enabled = NO;
                self.verificationBtn.DL_left = self.verificationTF.DL_right + 15;
                
                [self.verificationBtn setTitleColor:[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0] forState:UIControlStateNormal];
                [self.verificationBtn setTitle:[NSString stringWithFormat:@"%lus后重发", (unsigned long)--timerSeconds] forState:UIControlStateDisabled];
            }
            
//            timerSeconds--;
            if (timerSeconds < 0) {
                [timer invalidate];
                timer = nil;
            }
        } repeats:YES];
        
        [self.timer fire];
    }
}
     
- (void)addSecondLineView {
    UIView *view = [[UIView alloc] init];
    self.secondLineView = view;
    view.backgroundColor =  [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1/1.0];
    [self addSubview:view];
    
    view.DL_left = self.DL_bounds_left + 40;
    view.DL_top = self.verificationTF.DL_bottom + 15;
    view.DL_width = self.DL_width - 40 - view.DL_left;
    view.DL_height = 0.5;
}


#pragma mark - 点击了确认按钮
- (void)addPositiveBtn {
    UIButton *btn = [[UIButton alloc] init];
    self.positiveBtn = btn;
    btn.enabled = NO;
    btn.layer.cornerRadius = 4.f;
    UIColor *DMColorHex999999_1 = [UIColor colorWithRed:(153)/255.0 green:(153)/255.0 blue:(153)/255.0 alpha:1.0];
    [btn setTitleColor:DMColorHex999999_1 forState:UIControlStateNormal];
    [self addSubview:btn];
    [btn setTitle:kPositiveBtnTitle forState:UIControlStateNormal];
    btn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    
    btn.DL_top = self.secondLineView.DL_bottom + 32.5;
    btn.DL_left = self.secondLineView.DL_left;
    btn.DL_width = self.secondLineView.DL_width;
    btn.DL_height = 44;
    
    [self setPositiveBtnToUnable];
}



- (BOOL)verificationPhoneNum {
    
    if (_phoneTF.text.length == 0) {
        [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"请输入手机号"];
        return NO;
    } else if (_phoneTF.text.length > 0){
        return YES;
    }
    return YES;
}


- (void)addCannotGetVerificationLabel {
    UILabel *label = [[UILabel alloc] init];
    self.cannotGetVerificationLabel = label;
    label.text = @"无法获取验证码？";
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    [self addSubview:label];
    
    label.DL_top = self.positiveBtn.DL_bottom + 24;
    label.DL_size = CGSizeMake(96, 20);
    label.DL_right = self.positiveBtn.DL_right;
}

- (void)resignTxtField {
    [self.phoneTF resignFirstResponder];
    [self.verificationTF resignFirstResponder];
}

@end
