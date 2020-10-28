//
//  DMCaptchaDialogView.h
//  test
//
//  Created by JasonLin on 3/24/16.
//

#import "DMLoginBaseAlertView.h"

@interface DMCaptchaAlertView : DMLoginBaseAlertView
@property (nonatomic, retain) UIImageView * bgImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UITextField * captchaTextField;
@property (nonatomic, strong) UILabel * checkLabel;
@property (nonatomic, strong) UIButton * captchaButton;
@property (nonatomic, strong) UIButton * confirmButton;
@property (nonatomic, strong) UIButton * cancelButton;
@property (nonatomic, strong) UIActivityIndicatorView *captchaIndicatorView;
@property (nonatomic, strong) UIActivityIndicatorView *confirmButtonIndicatorView;

- (instancetype)initWithTitle:(NSString *)aTitle image:(UIImage *)aImage placeHolder:(NSString *)placeHolder confirmStr:(NSString *)confirmStr cancelStr:(NSString *)cancelStr;
- (void)relayoutForCheck:(NSString *)result;
@end
