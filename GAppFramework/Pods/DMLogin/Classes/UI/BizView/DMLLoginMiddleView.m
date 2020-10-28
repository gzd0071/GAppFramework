//
//  DMNewLoginMiddleView.m
//  c_doumi
//
//  Created by ltl on 2019/3/18.
//  Copyright © 2019 GAppFramework. All rights reserved.
//


static  NSString *const kPhoneTFPlaceHolder = @"请输入手机号码";
static  NSString *const kBtnTitle = @"获取验证码";


#import "DMLLoginMiddleView.h"
#import "UIView+LoginUIViewPosition.h"
//#import "DMLauchSetting.h"//TODO: 启动项设置

@implementation DMLLoginMiddleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addViews];
    }
    return self;
}

- (void )addViews {
    [self addPhoneTF];
    [self addLineView];
    [self addVerificationBtn];
    [self addProtocolView];
}
- (void)addPhoneTF{
    UITextField *phoneTF = [[UITextField alloc] init];
    self.phoneTF = phoneTF;    
    phoneTF.borderStyle = UITextBorderStyleNone;
    phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTF.returnKeyType = UIReturnKeySearch;
    phoneTF.enablesReturnKeyAutomatically = YES;
    phoneTF.placeholder = kPhoneTFPlaceHolder;
    
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
    
    UIColor *placeHolderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];//✔️ 暗黑模式不变色
    UIFont *placeHolderFont = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    NSMutableAttributedString *placeholderString =
    [[NSMutableAttributedString alloc] initWithString:kPhoneTFPlaceHolder
                                           attributes:@{NSForegroundColorAttributeName : placeHolderColor,
                                                        NSFontAttributeName : placeHolderFont
                                           }];
    phoneTF.attributedPlaceholder = placeholderString;
    [self addSubview:phoneTF];
    
    phoneTF.DL_top = self.DL_bounds_top;
    phoneTF.DL_left = self.DL_bounds_left;
    phoneTF.DL_width = self.DL_width;
    phoneTF.DL_height = 36;
    
    //限制手机号最多输入11位
    //如果多余11位，则进行前11位的截取
    //TODO: todo 字数限制
    
    [self.phoneTF addTarget:self action:@selector(dealWithTextField:) forControlEvents:UIControlEventEditingChanged];
}

- (void)checkVerifyButtonState {
    [self dealWithTextField:self.phoneTF];
}

- (void)dealWithTextField:(UITextField *)field {
    if (field.text.length > 11) {
        field.text = [field.text substringToIndex:11];
    }
    if (field.text.length >= 11) {
        self.getVerificationBtn.enabled = YES;
        [self.getVerificationBtn setTitleColor:[UIColor colorWithRed:(64)/255.0 green:(64)/255.0 blue:(64)/255.0 alpha:1.0] forState:UIControlStateNormal];//✔️ 暗黑模式不变色
        
        UIColor *btnBGColor = [UIColor colorWithRed:(255)/255.0 green:(204)/255.0 blue:(0)/255.0 alpha:1.0];
#ifdef __IPHONE_13_0
        //iOS13 适配
        if (@available(ios 13, *)) {
            btnBGColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return [UIColor colorWithRed:253/255.0 green:186/255.0 blue:44/255.0 alpha:1/1.0];
                } else {
                    return [UIColor colorWithRed:255/255.0 green:204/255.0 blue:0/255.0 alpha:1.0];
                }
            }];
        }
#endif
        self.getVerificationBtn.backgroundColor = btnBGColor;
        self.getVerificationBtn.layer.shadowColor = [UIColor colorWithRed:(255)/255.0 green:(204)/255.0 blue:(0)/255.0 alpha:1.0].CGColor;
        self.getVerificationBtn.layer.shadowOffset = CGSizeMake(0, 2);
        self.getVerificationBtn.layer.shadowRadius = 14.f;
        self.getVerificationBtn.layer.shadowOpacity = 0.4f;
    } else {
        [self setVerificationBtnUnable];
    }
}

- (void)addLineView {
    UIView *view = [[UIView alloc] init];
    self.lineView = view;
    UIColor *lineColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1/1.0];
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        lineColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1/1.0];
            }
        }];
    }
#endif
    view.backgroundColor = lineColor;
    
    [self addSubview:view];
    
    //TODO: 界面设置
    view.DL_top = self.phoneTF.DL_bottom + 15;
    view.DL_left = self.DL_bounds_left;
    view.DL_width = self.DL_width;
    view.DL_height = 0.5;
//    view.center = CGPointMake(self.center.x, view.center.y);
}

- (void)addVerificationBtn {
    UIButton *btn = [[UIButton alloc] init];
    self.getVerificationBtn = btn;
    btn.enabled = NO;
    btn.layer.cornerRadius = 4.f;
    UIColor *DMColorHex999999_1 = [UIColor colorWithRed:(153)/255.0 green:(153)/255.0 blue:(153)/255.0 alpha:1.0];
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        DMColorHex999999_1 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:28/255.0 green:28/255.0 blue:30/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:(153)/255.0 green:(153)/255.0 blue:(153)/255.0 alpha:1.0];
            }
        }];
    }
#endif
     [btn setTitleColor:DMColorHex999999_1 forState:UIControlStateNormal];
    self.verificationBtn = btn;
    [self addSubview:btn];
    [btn setTitle:kBtnTitle forState:UIControlStateNormal];
    btn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    
    //TODO: 界面设置
    btn.DL_top = self.lineView.DL_bottom + 32.5;
    btn.DL_left = self.DL_bounds_left;
    btn.DL_width = self.DL_width;
    btn.DL_height = 44;
    
    [self setVerificationBtnUnable];
    //TODO: 字数限制
    // ≥11 位的按钮才能正常工作
//    id phoneTFSignal;
}

- (void)setVerificationBtnUnable {
    self.verificationBtn.enabled = NO;
    
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
    [self.verificationBtn setTitleColor:[UIColor colorWithRed:(153)/255.0 green:(153)/255.0 blue:(153)/255.0 alpha:1.0] forState:UIControlStateDisabled];

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
    self.verificationBtn.backgroundColor = btnBGColor;
    self.verificationBtn.layer.shadowColor = UIColor.whiteColor.CGColor;
    self.verificationBtn.layer.shadowOffset = CGSizeMake(0, 0);
    self.verificationBtn.layer.shadowRadius = 0.f;
    self.verificationBtn.layer.shadowOpacity = 0.f;
}


- (void)addProtocolView {
    UIView *view = [[UIView alloc] init];
    [self addSubview:view];
    
    //TODO: 界面设置
    view.DL_top = self.verificationBtn.DL_bottom + 24;
    view.DL_width = 250;
    view.DL_height = 39;
    view.center = CGPointMake(self.DL_width/2, view.center.y);
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"登录即表示同意";
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];//✔️ 暗黑模式不变色
    [view addSubview:label];
    
    //TODO: 界面设置
    label.DL_top = view.DL_bounds_top;
    label.DL_left = view.DL_bounds_left;
    label.DL_width = 84;
    label.DL_height = view.DL_height/2;
    
    UIButton *btn = [[UIButton alloc] init];
    self.agreementBtn = btn;
    [btn setTitle:@"《用户注册与隐私保护协议》" forState:UIControlStateNormal];
    btn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [btn setTitleColor:[UIColor colorWithRed:102/255.0 green:153/255.0 blue:1 alpha:1/1.0] forState:UIControlStateNormal];//✔️ 暗黑模式不变色
    [view addSubview:btn];
    
    //TODO: 界面设置
    btn.DL_top = label.DL_top;// - 6;
    btn.DL_left = label.DL_right;
    btn.DL_width = 156;
    btn.DL_height = view.DL_height/2;

    
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"斗米将依据平台协议，严格保护您的个人信息";
    label2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    label2.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];//✔️ 暗黑模式不变色
    [view addSubview:label2];
    
    //TODO: 界面设置
    label2.DL_left = view.DL_bounds_left;
    label2.DL_width = view.DL_width;
    label2.DL_height = view.DL_height/2;
    label2.DL_bottom = view.DL_bounds_bottom;
}


@end
