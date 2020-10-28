//
//  DMLoginAlertView.m
//  test
//
//  Created by JasonLin on 3/24/16.
//

#import "DMLoginBaseAlertView.h"

#define kBackgroundColor [UIColor whiteColor]

@implementation DMLoginBaseAlertView

- (instancetype)initWithStyle:(DMDialogViewStyle)preferredStyle {
    if (self = [super init]) {
        if (preferredStyle == DMDialogViewStyleCorner) {
            self.layer.cornerRadius = 20.f;
            self.layer.masksToBounds = YES;
            
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
            [self addGestureRecognizer:tap];
        }
        self.backgroundColor = kBackgroundColor;
    }
    return self;
}

- (CGRect)customAddSubviews {
    return [self customLayoutSubviews];
}

- (CGRect)customLayoutSubviews {
    return CGRectZero;
}

#pragma mark - Public Tools

+ (UILabel *)titleLabel {
    UILabel * label = [[UILabel alloc] init];
    label.textColor = DMColor(64, 64, 64);
    label.font =  kDialogFontTitleLabel;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

+ (UILabel *)subtitleLabel {
    UILabel * label = [[UILabel alloc] init];
    label.textColor = DMColor(64, 64, 64);
    label.font =  kDialogFontSubLabel;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

+ (UIButton *)confirmButton {
    return [[self class] confirmButton:nil titleColor:nil];
}

+ (UIButton *)confirmButton:(UIFont *)titleFont titleColor:(UIColor *)titleColor {
    if (!titleFont) {
        titleFont = kDialogFontButton;
    }
    if (!titleColor) {
        titleColor = DMColor(64, 64, 64);
    }
    
    UIButton * button = [[UIButton alloc] init];
    button.titleLabel.font =  titleFont;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    UIImage *normal = [UIImage imageNamed:@"dml_alert_confirm_normal"];
    CGFloat top = normal.size.height * 0.5;
    CGFloat left = normal.size.width * 0.5;
    CGFloat bottom = normal.size.height * 0.5;
    CGFloat right = normal.size.width * 0.5;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    UIImageResizingMode mode = UIImageResizingModeStretch;
    UIImage *resizeableNormal = [normal resizableImageWithCapInsets:edgeInsets resizingMode:mode];
    
    [button setBackgroundImage:resizeableNormal forState:UIControlStateNormal];
    
    
    UIImage *selected = [UIImage imageNamed:@"dml_alert_confirm_selected"];
    CGFloat selectedTop = selected.size.height * 0.5;
    CGFloat selectedLeft = selected.size.width * 0.5;
    CGFloat selectedBottom = selected.size.height * 0.5;
    CGFloat selectedRight = selected.size.width * 0.5;
    UIEdgeInsets selectedEdgeInsets = UIEdgeInsetsMake(selectedTop, selectedLeft, selectedBottom, selectedRight);
    UIImageResizingMode selectedMode = UIImageResizingModeStretch;
    UIImage *resizeableSelected = [normal resizableImageWithCapInsets:selectedEdgeInsets resizingMode:selectedMode];
    
    [button setBackgroundImage:resizeableSelected forState:UIControlStateHighlighted];
    
    return button;
}

+ (UIButton *)cancelButton {
    UIButton * button = [[UIButton alloc] init];
    button.titleLabel.font =  kDialogFontButton;
    [button setTitleColor:DMColor(80, 80, 80) forState:UIControlStateNormal];
    
    UIImage *normal = [UIImage imageNamed:@"dml_alert_cancel_normal"];
    CGFloat top = normal.size.height * 0.5;
    CGFloat left = normal.size.width * 0.5;
    CGFloat bottom = normal.size.height * 0.5;
    CGFloat right = normal.size.width * 0.5;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    UIImageResizingMode mode = UIImageResizingModeStretch;
    UIImage *resizeableNormal = [normal resizableImageWithCapInsets:edgeInsets resizingMode:mode];
    
    [button setBackgroundImage:resizeableNormal forState:UIControlStateNormal];
    
    
    UIImage *selected = [UIImage imageNamed:@"dml_alert_cancel_selected"];
    CGFloat selectedTop = selected.size.height * 0.5;
    CGFloat selectedLeft = selected.size.width * 0.5;
    CGFloat selectedBottom = selected.size.height * 0.5;
    CGFloat selectedRight = selected.size.width * 0.5;
    UIEdgeInsets selectedEdgeInsets = UIEdgeInsetsMake(selectedTop, selectedLeft, selectedBottom, selectedRight);
    UIImageResizingMode selectedMode = UIImageResizingModeStretch;
    UIImage *resizeableSelected = [normal resizableImageWithCapInsets:selectedEdgeInsets resizingMode:selectedMode];
    
    [button setBackgroundImage:resizeableSelected forState:UIControlStateHighlighted];
    
    return button;
}

+ (UIButton *)buttonWithFontSize:(CGFloat)size color:(UIColor *)color bgImage:(NSString *)imageName {
    UIButton * button = [[UIButton alloc] init];
    button.titleLabel.font =  [UIFont systemFontOfSize:size];
    
    if (!color) {
        color = DMColor(80, 80, 80);
    }
    [button setTitleColor:color forState:UIControlStateNormal];
    
    if (imageName) {
        [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    }
    return button;
}

@end
