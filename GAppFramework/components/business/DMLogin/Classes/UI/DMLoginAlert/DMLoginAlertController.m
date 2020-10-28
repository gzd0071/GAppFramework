//
//  DMAlertDialogController.m
//  test
//
//  Created by JasonLin on 3/30/16.
//

#import "DMLoginAlertController.h"
#import "DMLoginAlertView.h"

#define DMImageNameInWidgetBundle(x) [UIImage imageNamed:x]

@interface DMLoginAlertController ()
@property (nonatomic, assign) DMDialogHeaderImageStyle style;
@property (nonatomic, strong) NSString * base64image;
@property (nonatomic, strong) NSArray * attrTitle;
@property (nonatomic, strong) NSArray * attrSubTitle;
@end

@implementation DMLoginAlertController

- (void)setConfirmBtnBkgImageName:(NSString *)confirmBtnBkgImageName {
    [((DMLoginAlertView *)self.contentView).confirmButton setBackgroundImage:[UIImage imageNamed:confirmBtnBkgImageName] forState:UIControlStateNormal];
}

- (void)setConfirmBtnTitleColor:(UIColor *)confirmBtnTitleColor {
    [((DMLoginAlertView *)self.contentView).confirmButton setTitleColor:confirmBtnTitleColor forState:UIControlStateNormal];
}

+ (instancetype)dialogWithTitle:(NSString *)aTitle attributedTitle:(NSArray *)aAttrTitle subtitle:(NSString *)aSubtitle attributedSubTitle:(NSArray *)aAttrSubTitle confirmStr:(NSString *)aConfirm cancelStr:(NSString *)aCancel imageStyle:(DMDialogHeaderImageStyle)aStyle customImageStr:(NSString *)aImageStr confirmBlock:(void(^)(id))confirmBlock cancelBlock:(void(^)(void))cancelBlock {
    return [[[self class] alloc] initWithTitle:aTitle?:@"" attributedTitle:aAttrTitle subtitle:aSubtitle?:@"" attributedSubTitle:aAttrSubTitle confirmStr:aConfirm cancelStr:aCancel imageStyle:aStyle customImageStr:aImageStr confirmBlock:confirmBlock cancelBlock:cancelBlock];
}

+ (instancetype)alertWithConfig:(DMLAlertConfig *)config {
    return [self dialogWithTitle:config.title
                 attributedTitle:config.attrTitle
                        subtitle:config.subTitle
              attributedSubTitle:config.attrSubTitle
                      confirmStr:config.confirmBtnTxt
                       cancelStr:config.cancelBtnTxt
                      imageStyle:DMDialogHeaderImageStyleCustom
                  customImageStr:nil
                    confirmBlock:config.confirmBlock
                     cancelBlock:config.cancelBlock];
}

- (instancetype)initWithTitle:(NSString *)aTitle attributedTitle:(NSArray *)aAttrTitle subtitle:(NSString *)aSubtitle attributedSubTitle:(NSArray *)aAttrSubTitle confirmStr:(NSString *)aConfirm cancelStr:(NSString *)aCancel imageStyle:(DMDialogHeaderImageStyle)aStyle customImageStr:(NSString *)aImageStr confirmBlock:(void(^)(id))confirmBlock cancelBlock:(void(^)(void))cancelBlock {
    if (self = [super init]) {
        self.style = aStyle;
        self.base64image = aImageStr;
        self.attrTitle = aAttrTitle;
        self.attrSubTitle = aAttrSubTitle;
        
        [super customInitWithTitle:aTitle subtitle:aSubtitle confirmStr:aConfirm cancelStr:aCancel confirmBlock:confirmBlock cancelBlock:cancelBlock preferredStyle:DMDialogControllerStyleCenter];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    NSMutableAttributedString * attrTitle = nil;
    NSMutableAttributedString * attrSubTitle = nil;
    if (self.attrTitle) {
        attrTitle = [[NSMutableAttributedString alloc] initWithString:self.titleStr];
        
        for (NSDictionary * dict in self.attrTitle) {
            NSInteger loc = [[dict objectForKey:@"location"] integerValue];
            NSInteger len = [[dict objectForKey:@"length"] integerValue];
            if (loc + len <= self.titleStr.length) {
                NSString * colorStr = [dict objectForKey:@"color"];
                colorStr = [colorStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
                UIColor * color = [self colorFromHexRGB:colorStr];
                [attrTitle addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(loc, len)];
            }
        }
    }
    if (self.attrSubTitle) {
        attrSubTitle = [[NSMutableAttributedString alloc] initWithString:self.subtitleStr];
        
        for (NSDictionary * dict in self.attrSubTitle) {
            NSInteger loc = [[dict objectForKey:@"location"] integerValue];
            NSInteger len = [[dict objectForKey:@"length"] integerValue];
            if (loc + len <= self.subtitleStr.length) {
                NSString * colorStr = [dict objectForKey:@"color"];
                colorStr = [colorStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
                UIColor * color = [self colorFromHexRGB:colorStr];
                NSRange range = NSMakeRange(loc, len);
                [attrSubTitle addAttribute:NSForegroundColorAttributeName value:color range:range];
                
                NSString *bold = [NSString stringWithFormat:@"%@", [dict objectForKey:@"blod"]];
                if ([bold boolValue]) {
                    [attrSubTitle addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.f] range:range];
                }
            }
        }
    }
    
    DMLoginAlertView * customView = [[DMLoginAlertView alloc] initWithTitle:self.titleStr attributedTitle:attrTitle subtitle:self.subtitleStr attributedSubTitle:attrSubTitle confirmStr:self.confirmStr cancelStr:self.cancelStr headerImage:[self imageInStyle:self.style]];
    
    __weak typeof(self)weakSelf = self;
    customView.imageClickBlock = ^{
        if (weakSelf.clickTitleImageViewBlock) {
            weakSelf.clickTitleImageViewBlock();
            
            [weakSelf cancelBtnAction:customView.cancelButton];
        }
    };
    
    self.contentView = customView;
    
    [self addButton:customView.confirmButton action:@selector(confirmBtnAction:)];
    [self addButton:customView.cancelButton action:@selector(cancelBtnAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Actions

- (void)confirmBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
    if (self.confirmBlock) {
        self.confirmBlock(nil);
    }
    [self dismiss];
}

- (void)cancelBtnAction:(UIButton *)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}

#pragma mark - Supports

- (UIImage *)imageInStyle:(DMDialogHeaderImageStyle)style {
    NSString * imageName = [self imageNameFromStyle:style];
    if (imageName) {
        return [UIImage imageNamed:imageName];
    } else {
        return [DMLoginAlertController base64ToImage:self.base64image];
    }
}

- (NSString *)imageNameFromStyle:(DMDialogHeaderImageStyle)style {
    switch (style) {
        case DMDialogHeaderImageStyleApply:     return DMImageNameInWidgetBundle(@"dialog_bg_apply");   break;
        case DMDialogHeaderImageStyleCancel:    return DMImageNameInWidgetBundle(@"dialog_bg_cancel");  break;
        case DMDialogHeaderImageStyleCaptcha:   return DMImageNameInWidgetBundle(@"dialog_bg_captcha"); break;
        case DMDialogHeaderImageStyleCity:      return DMImageNameInWidgetBundle(@"dialog_bg_city");    break;
        case DMDialogHeaderImageStyleDelete:    return DMImageNameInWidgetBundle(@"dialog_bg_delete");  break;
        case DMDialogHeaderImageStyleFail:      return DMImageNameInWidgetBundle(@"dialog_bg_fail");    break;
        case DMDialogHeaderImageStyleLimit:     return DMImageNameInWidgetBundle(@"dialog_bg_limit");   break;
        case DMDialogHeaderImageStyleLogout:    return DMImageNameInWidgetBundle(@"dialog_bg_logout");  break;
        case DMDialogHeaderImageStyleNormal:    return DMImageNameInWidgetBundle(@"dialog_bg_normal");  break;
        case DMDialogHeaderImageStylePhone:     return DMImageNameInWidgetBundle(@"dialog_bg_phone");   break;
        case DMDialogHeaderImageStyleService:   return DMImageNameInWidgetBundle(@"dialog_bg_service"); break;
        case DMDialogHeaderImageStyleShortage:  return DMImageNameInWidgetBundle(@"dialog_bg_shortage");break;
        case DMDialogHeaderImageStyleSuccess:   return DMImageNameInWidgetBundle(@"dialog_bg_success"); break;
        case DMDialogHeaderImageStyleUncommit:  return DMImageNameInWidgetBundle(@"dialog_bg_uncommit");break;
        case DMDialogHeaderImageStyleUnsaved:   return DMImageNameInWidgetBundle(@"dialog_bg_unsaved"); break;
        case DMDialogHeaderImageStyleSign:      return DMImageNameInWidgetBundle(@"dialog_bg_sign"); break;
        case DMDialogHeaderImageStyleContinuousSign:   return DMImageNameInWidgetBundle(@"dialog_bg_continuous_sign"); break;
        case DMDialogHeaderImageStyleLocation:  return DMImageNameInWidgetBundle(@"dialog_bg_location"); break;
        case DMDialogHeaderImageStyleCustom:    return nil;                  break;
        default:                                return DMImageNameInWidgetBundle(@"dialog_bg_normal");  break;
    }
}

+ (DMDialogHeaderImageStyle)imageStyleFormImageName:(NSString *)imageName {
    if (imageName) {
        if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Apply"])        return DMDialogHeaderImageStyleApply;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Cancel"])  return DMDialogHeaderImageStyleCancel;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Captcha"]) return DMDialogHeaderImageStyleCaptcha;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"City"])    return DMDialogHeaderImageStyleCity;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Delete"])  return DMDialogHeaderImageStyleDelete;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Fail"])    return DMDialogHeaderImageStyleFail;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Limit"])   return DMDialogHeaderImageStyleLimit;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Logout"])  return DMDialogHeaderImageStyleLogout;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Normal"])  return DMDialogHeaderImageStyleNormal;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Phone"])   return DMDialogHeaderImageStylePhone;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Service"]) return DMDialogHeaderImageStyleService;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Shortage"])return DMDialogHeaderImageStyleShortage;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Success"]) return DMDialogHeaderImageStyleSuccess;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Uncommit"])return DMDialogHeaderImageStyleUncommit;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Unsaved"]) return DMDialogHeaderImageStyleUnsaved;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Sign"])    return DMDialogHeaderImageStyleSign;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"ContinuousSign"]) return DMDialogHeaderImageStyleContinuousSign;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Location"]) return DMDialogHeaderImageStyleLocation;
        else if (NSOrderedSame == [imageName caseInsensitiveCompare:@"Custom"])  return DMDialogHeaderImageStyleCustom;
        else return DMDialogHeaderImageStyleNormal;
    }
    return DMDialogHeaderImageStyleNormal;
}

- (UIColor *)colorFromHexRGB:(NSString *)inColorString {
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString) {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

@end
