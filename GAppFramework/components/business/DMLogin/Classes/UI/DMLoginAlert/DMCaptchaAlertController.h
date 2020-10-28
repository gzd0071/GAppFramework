//
//  DMCaptchaDialogController.h
//  test
//
//  Created by JasonLin on 3/24/16.
//

#import "DMLoginBaseAlertController.h"
#import "DMLoginDefine.h"

@interface DMCaptchaAlertController : DMLoginBaseAlertController

/**
 图片验证码对话框

 @param title 标题
 @param mobile 手机号
 @param keyboardType 键盘样式
 @param confirm 确定文案
 @param cancel 取消文案
 @param confirmBlock 确定回调
 @param cancelBlock 取消回调
 @return 图片验证码对话框
 */
+ (instancetype)dialogWithTitle:(NSString *)title mobile:(NSString *)mobile keyboardType:(NSString *)keyboardType type:(NSString *)type smsType:(NSString *)smsType confirmStr:(NSString *)confirm cancelStr:(NSString *)cancel confirmBlock:(void(^)(NSString * captcha))confirmBlock cancelBlock:(void(^)(void))cancelBlock;

+ (instancetype)captchaAlertWithConfig:(DMLCaptchaAlertConfig *)config;
@end
