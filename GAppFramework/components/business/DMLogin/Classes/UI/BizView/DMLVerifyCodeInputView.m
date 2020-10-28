//
//  VertificationCodeInputView.m
//  VertificationCodeInput
//
//  Created by tangjin on 2018/11/21.
//  Copyright © 2018年 tangjin. All rights reserved.
//

#import "DMLVerifyCodeInputView.h"
#import "DMLVerifyCodeInputLabel.h"

@interface DMLVerifyCodeInputView () <UITextFieldDelegate>

/**验证码/密码输入框的背景图片*/
@property (nonatomic,strong)UIImageView *backgroundImageView;
/**实际用于显示验证码/密码的label*/
@property (nonatomic,strong)DMLVerifyCodeInputLabel *label;
@end
@implementation DMLVerifyCodeInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置透明背景色，保证vertificationCodeInputView显示的frame为backgroundImageView的frame
        self.backgroundColor = [UIColor clearColor];
        /* 调出键盘的textField */
        _textField = [[UITextField alloc]initWithFrame:self.bounds];
        // 隐藏textField，通过点击IDVertificationCodeInputView使其成为第一响应者，来弹出键盘
        _textField.hidden =YES;
        _textField.keyboardType =UIKeyboardTypeNumberPad;
        _textField.delegate =self;
        _textField.font = [UIFont systemFontOfSize:17];
        // 将textField放到最后边
        [self insertSubview:self.textField atIndex:0];
        /* 添加用于显示验证码/密码的label */
        _label = [[DMLVerifyCodeInputLabel alloc]initWithFrame:self.bounds];
        _label.numberOfVertificationCode =_numberOfVertificationCode;
        _label.secureTextEntry =_secureTextEntry;
        _label.font = self.textField.font;

#ifdef __IPHONE_13_0
        //iOS13 适配
        if (@available(ios 13, *)) {
            _label.textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1/1.0];
                } else {
                    return UIColor.blackColor;
                }
            }];
        }
#endif
        [self addSubview:self.label];
    }
    return self;
}
#pragma mark --------- 设置背景图片
- (void)setBackgroudImageName:(NSString *)backgroudImageName {
    _backgroudImageName = backgroudImageName;
    // 若用户设置了背景图片，则添加背景图片
    self.backgroundImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.backgroundImageView.image = [UIImage imageNamed:self.backgroudImageName];
    // 将背景图片插入到label的后边，避免遮挡验证码/密码的显示
    [self insertSubview:self.backgroundImageView belowSubview:self.label];
}
- (void)setNumberOfVertificationCode:(NSInteger)numberOfVertificationCode {
    _numberOfVertificationCode = numberOfVertificationCode;
    // 保持label的验证码/密码位数与IDVertificationCodeInputView一致，此时label一定已经被创建
    self.label.numberOfVertificationCode =_numberOfVertificationCode;
}
- (void)setSecureTextEntry:(bool)secureTextEntry {
    _secureTextEntry = secureTextEntry;
    self.label.secureTextEntry =_secureTextEntry;
}
-(void)becomeFirstResponder{
    [self.textField becomeFirstResponder];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField becomeFirstResponder];
}
#pragma mark ------ 时时监测输入框的内容
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 判断是不是“删除”字符
    if (string.length !=0) {//不是“删除”字符
        // 判断验证码/密码的位数是否达到预定的位数
        if (textField.text.length <self.numberOfVertificationCode) {
            self.label.text = [textField.text stringByAppendingString:string];
            self.vertificationCode =self.label.text;
            if (self.label.text.length == _numberOfVertificationCode) {
                /******* 通过协议将验证码返回当前页面  ******/
                // 下一个 runloop 再进行 resign，防止被提前 resign，无法走 return 导致 textfiled 少一个字符
                dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(returnTextFieldContent:)]){
                    [_delegate returnTextFieldContent:_vertificationCode];
                    [textField resignFirstResponder];
                }
                });
            }
            return YES;
        } else {
            return NO;
        }
    } else if(textField.hasText){//是“删除”字符
        self.label.text = [textField.text substringToIndex:textField.text.length -1];
        self.vertificationCode =self.label.text;
        return YES;
    }
    else
    {
        return YES;
    }
}

@end
