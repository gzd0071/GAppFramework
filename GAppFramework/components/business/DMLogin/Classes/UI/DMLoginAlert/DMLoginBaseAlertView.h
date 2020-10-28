//
//  DMLoginAlertView.h
//  test
//
//  Created by JasonLin on 3/24/16.
//

#import <UIKit/UIKit.h>

#define DM_TEXTCOLOR [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1]
#define DM_AlertViewBGColor   [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]
#define DMColorHex999999   [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]
#define DMColorHex404040   [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1]
#define DMColorHexE5E5E5   [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1]

#define DMColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define kDialogButtonHeight     45.f
#define kDialogTitleLabelHeight 18.f
#define kDialogSubLabelHeight   12.f
#define kDialogVMarginLarge     24.f
#define kDialogVMarginSmall     12.f

#define kDialogFontTitleLabel   [UIFont boldSystemFontOfSize:18.f]
#define kDialogFontSubLabel     [UIFont systemFontOfSize:14.f]
#define kDialogFontButton       [UIFont systemFontOfSize:16.f]

#define kDialogCenterViewWidth    266.f
#define kDialogCenterHeaderHeight 104.f
#define kDialogCenterButtonWidth  110.f
#define kDialogCenterHMargin      15.f

#define kDialogBottomViewWidth  [UIScreen mainScreen].bounds.size.width
#define kDialogBottomHMargin    40.f * [UIScreen mainScreen].bounds.size.width / 375.f

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define DM_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define DM_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
#endif

typedef NS_ENUM(NSInteger, DMDialogViewStyle) {
    DMDialogViewStyleNormal = 0,
    DMDialogViewStyleCorner,
};

@interface DMLoginBaseAlertView : UIView
- (instancetype)initWithStyle:(DMDialogViewStyle)preferredStyle;
- (CGRect)customAddSubviews;
- (CGRect)customLayoutSubviews;

+ (UILabel *)titleLabel;
+ (UILabel *)subtitleLabel;
+ (UIButton *)confirmButton;
+ (UIButton *)confirmButton:(UIFont *)titleFont titleColor:(UIColor *)titleColor;
+ (UIButton *)cancelButton;
+ (UIButton *)buttonWithFontSize:(CGFloat)size color:(UIColor *)color bgImage:(NSString *)imageName;
@end
