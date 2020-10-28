//
//  DMAlertDialogView.h
//  test
//
//  Created by JasonLin on 3/30/16.
//

#import <UIKit/UIKit.h>
#import "DMLoginBaseAlertView.h"

@interface DMLoginAlertView : DMLoginBaseAlertView

@property (nonatomic, retain) UIImageView * bgImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subtitleLabel;
@property (nonatomic, strong) UIButton * confirmButton;
@property (nonatomic, strong) UIButton * cancelButton;

@property (nonatomic,copy) void(^imageClickBlock)(void);

- (instancetype)initWithTitle:(NSString *)aTitle attributedTitle:(NSAttributedString *)aAttrTitle subtitle:(NSString *)aSubtitle attributedSubTitle:(NSAttributedString *)aAttrSubTitle confirmStr:(NSString *)confirmStr cancelStr:(NSString *)cancelStr headerImage:(UIImage *)aImage;

@end
