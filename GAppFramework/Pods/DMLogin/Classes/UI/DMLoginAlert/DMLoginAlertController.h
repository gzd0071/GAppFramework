//
//  DMAlertDialogController.h
//  test
//
//  Created by JasonLin on 3/30/16.
//

#import "DMLoginBaseAlertController.h"
#import "DMLoginDefine.h"

/**
 *  对话框顶部图片
 */
typedef enum : NSUInteger {
    // 申请
    DMDialogHeaderImageStyleApply = 0,
    // 取消
    DMDialogHeaderImageStyleCancel,
    // 验证码
    DMDialogHeaderImageStyleCaptcha,
    // 城市
    DMDialogHeaderImageStyleCity,
    // 删除
    DMDialogHeaderImageStyleDelete,
    // 失败
    DMDialogHeaderImageStyleFail,
    // 上限
    DMDialogHeaderImageStyleLimit,
    // 登出
    DMDialogHeaderImageStyleLogout,
    // 通用
    DMDialogHeaderImageStyleNormal,
    // 电话
    DMDialogHeaderImageStylePhone,
    // 客服
    DMDialogHeaderImageStyleService,
    // 申请完
    DMDialogHeaderImageStyleShortage,
    // 成功
    DMDialogHeaderImageStyleSuccess,
    // 未提交
    DMDialogHeaderImageStyleUncommit,
    // 未保存
    DMDialogHeaderImageStyleUnsaved,
    // 签到
    DMDialogHeaderImageStyleSign,
    // 连续签到
    DMDialogHeaderImageStyleContinuousSign,
    // 定位
    DMDialogHeaderImageStyleLocation,
    // 自定义，显示传入图片
    DMDialogHeaderImageStyleCustom
} DMDialogHeaderImageStyle;

@interface DMLoginAlertController : DMLoginBaseAlertController

@property (nonatomic, strong) UIColor * confirmBtnTitleColor;
@property (nonatomic, strong) NSString *confirmBtnBkgImageName;

@property (nonatomic,copy) void(^clickTitleImageViewBlock)(void);

/**
 *  Alert类型对话框，对应控件的值传空，则不显示该控件。
 *
 *  @param aTitle       标题
 *  @param aSubtitle    副标题
 *  @param aConfirm     确定按钮标题
 *  @param aCancel      取消按钮标题
 *  @param aStyle       对话框顶部图片类型
 *  @param aImageStr    自定义图片base64
 *  @param confirmBlock 确定回调
 *  @param cancelBlock  取消回调
 *
 *  @return Alert类型对话框
 */
+ (instancetype)dialogWithTitle:(NSString *)aTitle attributedTitle:(NSArray *)aAttrTitle subtitle:(NSString *)aSubtitle attributedSubTitle:(NSArray *)aAttrSubTitle confirmStr:(NSString *)aConfirm cancelStr:(NSString *)aCancel imageStyle:(DMDialogHeaderImageStyle)aStyle customImageStr:(NSString *)aImageStr confirmBlock:(void(^)(id))confirmBlock cancelBlock:(void(^)(void))cancelBlock;

+ (instancetype)alertWithConfig:(DMLAlertConfig *)config;

+ (DMDialogHeaderImageStyle)imageStyleFormImageName:(NSString *)imageName;

@end
