//
//  DMAlertDialogView.m
//  test
//
//  Created by JasonLin on 3/30/16.
//

#import "DMLoginAlertView.h"
//#import "Const.h"
#define DMImageNameInWidgetBundle(x) [UIImage imageNamed:x]

@interface DMLoginAlertView()
@property (nonatomic, assign) BOOL hasTitle;
@property (nonatomic, assign) BOOL hasSubtitle;
@property (nonatomic, assign) BOOL hasConfirmButton;
@property (nonatomic, assign) BOOL hasCancelButton;
@property (nonatomic, assign) NSInteger buttonCount;
@property (nonatomic, assign) BOOL hasImage;
@end

@implementation DMLoginAlertView

- (instancetype)initWithTitle:(NSString *)aTitle attributedTitle:(NSAttributedString *)aAttrTitle subtitle:(NSString *)aSubtitle attributedSubTitle:(NSAttributedString *)aAttrSubTitle confirmStr:(NSString *)confirmStr cancelStr:(NSString *)cancelStr headerImage:(UIImage *)aImage {
    if (self = [super initWithStyle:DMDialogViewStyleCorner]) {
        self.hasTitle = self.hasSubtitle = self.hasConfirmButton = self.hasCancelButton = NO;
        self.buttonCount = 0;
        
        if (aAttrTitle && aAttrTitle.length > 0) {
            self.hasTitle = YES;
            self.titleLabel.attributedText = aAttrTitle;
        }
        else if (aTitle && aTitle.length > 0) {
            self.hasTitle = YES;
            self.titleLabel.text = aTitle;
        }
        
        if (aAttrSubTitle && aAttrSubTitle.length > 0) {
            self.hasSubtitle = YES;
            self.subtitleLabel.attributedText = aAttrSubTitle;
        }
        else if (aSubtitle && aSubtitle.length > 0) {
            self.hasSubtitle = YES;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.headIndent = 0;//头部缩进，相当于左padding
            paragraphStyle.tailIndent = 0;//相当于右padding
            paragraphStyle.lineHeightMultiple = 0;//行间距是多少倍
            
            paragraphStyle.firstLineHeadIndent = 0;//首行头缩进
            paragraphStyle.paragraphSpacing = 0;//段落后面的间距
            paragraphStyle.paragraphSpacingBefore = 0;//段落之前的间距
            
            paragraphStyle.lineSpacing = 5;  //设置行间距
            paragraphStyle.lineBreakMode = self.subtitleLabel.lineBreakMode;
            paragraphStyle.alignment = self.subtitleLabel.textAlignment;
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:aSubtitle];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aSubtitle length])];
            self.subtitleLabel.attributedText = attributedString;
        }
        
        if (confirmStr && confirmStr.length > 0) {
            self.hasConfirmButton = YES;
            self.buttonCount ++;
            [self.confirmButton setTitle:confirmStr forState:UIControlStateNormal];
        }
        
        if (cancelStr && cancelStr.length > 0) {
            self.hasCancelButton = YES;
            self.buttonCount ++;
            [self.cancelButton  setTitle:cancelStr  forState:UIControlStateNormal];
        }
        
        else if (NO == self.hasConfirmButton) {
            self.hasCancelButton = YES;
            self.buttonCount ++;
            [self.cancelButton setTitle:@"关闭"  forState:UIControlStateNormal];
        }
        
        if (aImage) {
            self.hasImage = YES;
            [self.bgImageView setImage:aImage];
        }
        
        self.frame = [self customAddSubviews];
    }
    return self;
}

- (CGRect)customAddSubviews {
    if (self.hasImage)      [self addSubview:self.bgImageView];
    if (self.hasTitle)      [self addSubview:self.titleLabel];
    if (self.hasSubtitle)   [self addSubview:self.subtitleLabel];
    if (self.hasConfirmButton)  [self addSubview:self.confirmButton];
    if (self.hasCancelButton)   [self addSubview:self.cancelButton];
    
    return [super customAddSubviews];
}

- (CGRect)customLayoutSubviews {
    CGFloat x, y, width, height;
    x = y = width = height = 0;
    
    if (self.hasImage) {
        width = kDialogCenterViewWidth;
        height = kDialogCenterHeaderHeight;
        self.bgImageView.frame = CGRectMake(x, y, width, height);
    }
    
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - 20 - kDialogButtonHeight - 2 * kDialogVMarginLarge;
    CGFloat remainHeight;
    CGSize maxSize;
    
    x = kDialogCenterHMargin;
    width = kDialogCenterViewWidth - 2 * kDialogCenterHMargin;
    if (self.hasTitle) {
        y += height + kDialogVMarginLarge;
        remainHeight = maxHeight - y;
        maxSize = CGSizeMake(width, remainHeight);
        if (self.hasSubtitle) {
            maxSize = CGSizeMake(width, remainHeight - kDialogVMarginSmall - kDialogSubLabelHeight);
        }
        CGSize titleLabelSize = DM_MULTILINE_TEXTSIZE(self.titleLabel.text, self.titleLabel.font, maxSize, self.titleLabel.lineBreakMode);
        
        height = titleLabelSize.height;
        self.titleLabel.frame = CGRectMake(x, y, width, height);
    }
    
    if (self.hasSubtitle) {
        y += height + ((self.hasTitle) ? kDialogVMarginSmall : kDialogVMarginLarge);
        remainHeight = maxHeight - y;
        maxSize = CGSizeMake(width, remainHeight);
        CGSize subtitleLabelSize = DM_MULTILINE_TEXTSIZE(self.subtitleLabel.text, self.subtitleLabel.font, maxSize, self.subtitleLabel.lineBreakMode);
        height = subtitleLabelSize.height * 1.3;
        self.subtitleLabel.frame = CGRectMake(x, y, width, height);
    }
    
    if (self.buttonCount > 0) {
        if (self.buttonCount == 2)
            width = kDialogCenterButtonWidth;
        y += height + kDialogVMarginLarge;
        height = kDialogButtonHeight;
        
        if (self.hasCancelButton) {
            self.cancelButton.frame = CGRectMake(x, y, width, height);
        }
        
        if (self.hasConfirmButton) {
            x = kDialogCenterViewWidth - width - kDialogCenterHMargin;
            self.confirmButton.frame = CGRectMake(x, y, width, height);
        }
    }
    
    y += height + kDialogVMarginLarge;
    return CGRectMake(0, 0, kDialogCenterViewWidth, y);
}

#pragma mark - Getter

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_bg_captcha"]];
        _bgImageView.userInteractionEnabled = YES;//打开用户交互

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        
        [_bgImageView addGestureRecognizer:tapGesture];
    }
    return _bgImageView;
}

- (void)clickImage{
    if (self.imageClickBlock) {
        self.imageClickBlock();
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [DMLoginBaseAlertView titleLabel];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [DMLoginBaseAlertView subtitleLabel];
        _subtitleLabel.numberOfLines = 0;
    }
    return _subtitleLabel;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [DMLoginBaseAlertView confirmButton];
    }
    return _confirmButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [DMLoginBaseAlertView cancelButton];
    }
    return _cancelButton;
}

@end
