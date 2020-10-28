//
//  DMCaptchaDialogController.m
//  test
//
//  Created by JasonLin on 3/24/16.
//

#import "DMCaptchaAlertController.h"
#import "DMCaptchaAlertView.h"
#import "DMLoginAdapter.h"
#import "DMLoginCoreLogic.h"

@interface DMCaptchaAlertController () <UITextFieldDelegate>
@property (nonatomic, strong) NSString * keyboardType;
@property (nonatomic, strong) NSString * mobile;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * smsType;
@end

@implementation DMCaptchaAlertController

+ (instancetype)dialogWithTitle:(NSString *)title mobile:(NSString *)mobile keyboardType:(NSString *)keyboardType type:(NSString *)type smsType:(NSString *)smsType confirmStr:(NSString *)confirm cancelStr:(NSString *)cancel confirmBlock:(void(^)(NSString * captcha))confirmBlock cancelBlock:(void(^)(void))cancelBlock {
    return [[[self class] alloc] initWithTitle:title mobile:mobile keyboardType:keyboardType type:type smsType:smsType confirmStr:confirm cancelStr:cancel confirmBlock:confirmBlock cancelBlock:cancelBlock];
}

+ (instancetype)captchaAlertWithConfig:(DMLCaptchaAlertConfig *)config {
    return [self dialogWithTitle:config.title
                          mobile:config.mobile
                    keyboardType:nil
                            type:config.type
                         smsType:config.smsType
                      confirmStr:config.confirmBtnTxt
                       cancelStr:config.cancelBtnTxt
                    confirmBlock:config.confirmBlock
                     cancelBlock:config.cancelBlock];
}

- (instancetype)initWithTitle:(NSString *)title mobile:(NSString *)mobile keyboardType:(NSString *)keyboardType type:(NSString *)type smsType:(NSString *)smsType confirmStr:(NSString *)confirm cancelStr:(NSString *)cancel confirmBlock:(void(^)(NSString * captcha))confirmBlock cancelBlock:(void(^)(void))cancelBlock {
    if (self = [super init]) {
        self.mobile = mobile;
        self.keyboardType = keyboardType;
        self.type = type;
        self.smsType = smsType;
        [super customInitWithTitle:title subtitle:nil confirmStr:confirm cancelStr:cancel confirmBlock:confirmBlock cancelBlock:cancelBlock preferredStyle:DMDialogControllerStyleCenter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DMCaptchaAlertView * customView = [[DMCaptchaAlertView alloc] initWithTitle:self.titleStr image:nil placeHolder:@"请输入验证码" confirmStr:self.confirmStr cancelStr:self.cancelStr];
    self.contentView = customView;
    
    // 获取验证码图片
    [self changeCaptchaImage];
    
    [self addButton:customView.captchaButton action:@selector(captchaBtnAction:)];
    [self addButton:customView.confirmButton action:@selector(confirmBtnAction:)];
    [self addButton:customView.cancelButton action:@selector(cancelBtnAction:)];
    customView.captchaTextField.delegate = self;
    [customView.captchaTextField becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (self.keyboardType) {
        UIKeyboardType type = UIKeyboardTypeDefault;
        if ([self.keyboardType isEqualToString:@"number"]) {
            type = UIKeyboardTypeNumberPad;
        }
        customView.captchaTextField.keyboardType = type;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Actions

- (void)captchaBtnAction:(UIButton *)sender {
    [self changeCaptchaImage];
}

- (void)confirmBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSString * cacheStr = ((DMCaptchaAlertView *)self.contentView).captchaTextField.text;
    
    if (cacheStr.length == 0) {
        [(DMCaptchaAlertView *)self.contentView relayoutForCheck:@"请输入正确的图片验证码"];
        return;
    }
    
    ((DMCaptchaAlertView *)self.contentView).confirmButtonIndicatorView.hidden = NO;
    [((DMCaptchaAlertView *)self.contentView).confirmButtonIndicatorView startAnimating];
    
    if (cacheStr.length > 100) {
        cacheStr = [cacheStr substringToIndex:100];
    }
    cacheStr = [cacheStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 发送短信验证码
    [DMLoginCoreLogic requestSMSAuthCodeForMobileNumber:self.mobile capthcaString:cacheStr type:self.type smsType:self.smsType successBlock:^(id responseObj, NSDictionary *userInfo) {

        if (self.confirmBlock) {
            self.confirmBlock(nil);
        }
        [self dismiss];

        ((DMCaptchaAlertView *)self.contentView).confirmButtonIndicatorView.hidden = YES;
        [((DMCaptchaAlertView *)self.contentView).confirmButtonIndicatorView stopAnimating];

    } failBlock:^(NSError *error, NSDictionary *userInfo) {

        NSInteger code = [[userInfo objectForKey:@"code"] integerValue];
        if (code != -4) {
            NSString *message = [userInfo objectForKey:@"message"];
            if (message.length > 0) {
                [DMLoginAdapter handleToastType:ToastType_Show_Error message:message];
                [self dismiss];
                return;
            }
        }
        [(DMCaptchaAlertView *)self.contentView relayoutForCheck:@"请输入正确的图片验证码"];
        [self changeCaptchaImage];
        ((DMCaptchaAlertView *)self.contentView).confirmButtonIndicatorView.hidden = YES;
        [((DMCaptchaAlertView *)self.contentView).confirmButtonIndicatorView stopAnimating];
    }];
}

- (void)cancelBtnAction:(UIButton *)sender {
    if (self.cancelBlock)
        self.cancelBlock();
        [self dismiss];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField canResignFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Keyobard Action

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect kbFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat offset = CGRectGetMinY(kbFrame) / 2;
    
    if(offset > 0) {
        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            self.view.center = CGPointMake(self.view.center.x, offset);
        }];
    }
}

// MARK: - Supports

/**
 获取图形验证码
 */
- (void)changeCaptchaImage {
    ((DMCaptchaAlertView *)self.contentView).captchaIndicatorView.hidden = NO;
    [((DMCaptchaAlertView *)self.contentView).captchaIndicatorView startAnimating];
    [DMLoginCoreLogic requestCaptchaBase64ImageWithSuccessBlock:^(UIImage * _Nonnull captcha) {
        ((DMCaptchaAlertView *)self.contentView).captchaIndicatorView.hidden = YES;
        [((DMCaptchaAlertView *)self.contentView).captchaIndicatorView stopAnimating];
        [((DMCaptchaAlertView *)self.contentView).captchaButton
         setBackgroundImage:captcha
         forState:UIControlStateNormal];
    } failBlock:^(NSError *error, NSDictionary *userInfo) {
        if (![DMLoginAdapter isNetworkConnected]) {//判断网络是否可用
            [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"无网络"];
        } else {
            [DMLoginAdapter handleToastType:ToastType_Show_Error message:@"获取验证码失败，请重试"];
        }
        
        ((DMCaptchaAlertView *)self.contentView).captchaIndicatorView.hidden = YES;
        [((DMCaptchaAlertView *)self.contentView).captchaIndicatorView stopAnimating];
    }];
}

@end
