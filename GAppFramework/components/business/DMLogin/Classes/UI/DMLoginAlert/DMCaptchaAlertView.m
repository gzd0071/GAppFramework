//
//  DMCaptchaDialogView.m
//  test
//
//  Created by JasonLin on 3/24/16.
//

#import "DMCaptchaAlertView.h"

@interface DMCaptchaAlertView()
@property (nonatomic, strong) UIView *captchaView;

@property (nonatomic, assign) BOOL checkEnable;
@end

@implementation DMCaptchaAlertView

- (instancetype)initWithTitle:(NSString *)aTitle image:(UIImage *)aImage placeHolder:(NSString *)placeHolder confirmStr:(NSString *)confirmStr cancelStr:(NSString *)cancelStr {
    if (self = [super initWithStyle:DMDialogViewStyleCorner]) {
        self.checkEnable = NO;
        self.titleLabel.text = aTitle;
        
        NSAttributedString *attributes =
        [[NSAttributedString alloc]
         initWithString:placeHolder
         attributes:@{NSForegroundColorAttributeName: DMColorHex999999}];
        self.captchaTextField.attributedPlaceholder = attributes;
        
        [self.captchaButton setBackgroundImage:aImage forState:UIControlStateNormal];
        [self.confirmButton setTitle:confirmStr forState:UIControlStateNormal];
        [self.cancelButton  setTitle:cancelStr  forState:UIControlStateNormal];
        
        self.frame = [self customAddSubviews];
    }
    return self;
}

- (void)relayoutForCheck:(NSString *)result {
    self.checkEnable = result ? YES: NO;
    
    [UIView animateWithDuration:0.15 animations:^{
        if (self.checkEnable) {
            self.checkLabel.text = result;
            [self addSubview:self.checkLabel];
            
            self.captchaView.layer.borderColor = DMColor(255, 102, 0).CGColor;
        }
        
        CGPoint origin = self.frame.origin;
        CGSize size = [self customLayoutSubviews].size;
        self.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        
        
        
        if (NO == self.checkEnable)
        {
            self.checkLabel.frame = CGRectMake(self.checkLabel.frame.origin.x,
                                               self.checkLabel.frame.origin.y - 12.f,
                                               self.checkLabel.frame.size.width,
                                               0);
            
            self.captchaView.layer.borderColor = DMColorHexE5E5E5.CGColor;
        }
    } completion:^(BOOL finished) {
        if (NO == self.checkEnable)
            [self.checkLabel removeFromSuperview];
    }];
}

- (CGRect)customAddSubviews {
    [self addSubview:self.bgImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.confirmButton];
    [self addSubview:self.cancelButton];
    
    [self addSubview:self.captchaView];
    [self.captchaView addSubview:self.captchaTextField];
    [self.captchaView addSubview:self.captchaButton];
    [self.captchaView addSubview:self.captchaIndicatorView];
    [self addSubview:self.confirmButtonIndicatorView];
    
    
    if (self.checkEnable)
        [self addSubview:self.checkLabel];
    
    return [super customAddSubviews];
}

- (CGRect)customLayoutSubviews {
    CGFloat x, y, width, height;
    
    x = y = 0;
    width = kDialogCenterViewWidth;
    height = kDialogCenterHeaderHeight;
    self.bgImageView.frame = CGRectMake(x, y, width, height);
    
    x = kDialogCenterHMargin;
    y += height + kDialogVMarginLarge;
    width = kDialogCenterViewWidth - 2 * kDialogCenterHMargin;
    height = kDialogTitleLabelHeight;
    self.titleLabel.frame = CGRectMake(x, y, width, height);
    
    y += height + kDialogVMarginSmall;
    height = kDialogButtonHeight + 1;
    self.captchaView.frame = CGRectMake(x, y, width, height);
    
    self.captchaTextField.frame = CGRectMake(1.f, 1.5f, 140.f, height - 2.f);
    self.captchaButton.frame = CGRectMake(141.f, 1.f, width - 142.f, height - 2.f);
    self.captchaIndicatorView.frame = self.captchaButton.frame;
    
    
    
    if (_checkEnable) {
        x = kDialogCenterHMargin;
        y += height + kDialogVMarginSmall + 4.f;
        width = kDialogCenterViewWidth - 2 * kDialogCenterHMargin;
        height = 11.3;
        self.checkLabel.frame = CGRectMake(x, y, width, height);
    }
    
    x = kDialogCenterHMargin;
    y += height + kDialogVMarginLarge;
    width = kDialogCenterButtonWidth;
    height = kDialogButtonHeight;
    self.cancelButton.frame = CGRectMake(x, y, width, height);
    
    x = kDialogCenterViewWidth - width - kDialogCenterHMargin;
    self.confirmButton.frame = CGRectMake(x, y, width, height);
    self.confirmButtonIndicatorView.frame = CGRectMake(x, y, width, height);
    
    y += height + kDialogVMarginLarge;
    return CGRectMake(0, 0, kDialogCenterViewWidth, y);
}

#pragma mark - Getter

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dml_alert_bg_captcha"]];
    }
    return _bgImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [DMLoginBaseAlertView titleLabel];
        _titleLabel.font =  [UIFont systemFontOfSize:12.0f];
        _titleLabel.textColor = DMColorHex999999;
    }
    return _titleLabel;
}

- (UITextField *)captchaTextField {
    if (!_captchaTextField) {
        _captchaTextField = [[UITextField alloc] init];
        _captchaTextField.textColor = DMColorHex404040;
        _captchaTextField.borderStyle = UITextBorderStyleNone;
        _captchaTextField.font =  [UIFont systemFontOfSize:14.f];
        _captchaTextField.keyboardType = UIKeyboardTypeDefault;
        _captchaTextField.returnKeyType = UIReturnKeyDone;
        _captchaTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _captchaTextField.leftViewMode = UITextFieldViewModeAlways;
        _captchaTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return _captchaTextField;
}

- (UIButton *)captchaButton {
    if (!_captchaButton) {
        _captchaButton = [[UIButton alloc] init];
        _captchaButton.clipsToBounds = YES;
        [_captchaButton setImage:[UIImage imageNamed:@"Widget.bundle/dialog_captcha_refresh"] forState:UIControlStateNormal];
        [_captchaButton setImage:[UIImage imageNamed:@"Widget.bundle/dialog_captcha_refresh"] forState:UIControlStateSelected];
    }
    return _captchaButton;
}

- (UILabel *)checkLabel {
    if (!_checkLabel) {
        _checkLabel = [[UILabel alloc] initWithFrame:
                       CGRectMake(kDialogCenterHMargin,
                                  CGRectGetMaxY(self.captchaView.frame),
                                  kDialogCenterViewWidth - 2 * kDialogCenterHMargin,
                                  0)];
        _checkLabel.textColor = DMColor(255, 102, 0);
        _checkLabel.textAlignment = NSTextAlignmentCenter;
        _checkLabel.font =  [UIFont systemFontOfSize:12.f];
    }
    return _checkLabel;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [DMLoginBaseAlertView confirmButton];
    }
    return _confirmButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton)     {
        _cancelButton = [DMLoginBaseAlertView cancelButton];
    }
    return _cancelButton;
}

- (UIView *)captchaView {
    if (!_captchaView) {
        _captchaView = [UIView new];
        _captchaView.layer.borderWidth = 1.f;
        _captchaView.clipsToBounds = YES;
        _captchaView.layer.borderColor = DMColorHexE5E5E5.CGColor;
    }
    return _captchaView;
}

- (UIActivityIndicatorView *)captchaIndicatorView {
    if (!_captchaIndicatorView) {
        _captchaIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _captchaIndicatorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        _captchaIndicatorView.hidden = YES;
    }
    return _captchaIndicatorView;
}

- (UIActivityIndicatorView *)confirmButtonIndicatorView {
    if (!_confirmButtonIndicatorView) {
        _confirmButtonIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _confirmButtonIndicatorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        _confirmButtonIndicatorView.hidden = YES;
    }
    return _confirmButtonIndicatorView;
}


@end
