//
//  DMAlertActions.h
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/26.
//

#import <UIKit/UIKit.h>
#import "DMAlert.h"

NS_ASSUME_NONNULL_BEGIN

///> 弹框宽度
#define kCAWidth  266.0f

///> 弹框头样式 
typedef NS_ENUM(NSInteger, DMAlertHeaderType) {
    ///> 默认样式
    DMAlertHeaderTypeNormal = 0,
    ///>
    DMAlertHeaderTypeApply,
    ///>
    DMAlertHeaderTypeCancel,
    ///>
    DMAlertHeaderTypeCaptcha,
    ///>
    DMAlertHeaderTypeCity,
    ///>
    DMAlertHeaderTypeDelete,
    ///>
    DMAlertHeaderTypeFail,
    ///>
    DMAlertHeaderTypeLimit,
    ///>
    DMAlertHeaderTypeLogout,
    ///>
    DMAlertHeaderTypePhone,
    ///>
    DMAlertHeaderTypeService,
    ///>
    DMAlertHeaderTypeShortage,
    ///>
    DMAlertHeaderTypeSuccess,
    ///>
    DMAlertHeaderTypeUncommit,
    ///>
    DMAlertHeaderTypeUnsaved,
    ///>
    DMAlertHeaderTypeSign,
    ///>
    DMAlertHeaderTypeContinuousSign,
    ///>
    DMAlertHeaderTypeLocation,
    ///>
    DMAlertHeaderTypeResume
};

@interface DMAlertActions : UIView

#pragma mark - CancelAction
///=============================================================================
/// @name 取消
///=============================================================================
+ (DMAlertAction *)cancelAction:(id)title;

#pragma mark - HeaderImageAction
///=============================================================================
/// @name 图面样式Action
///=============================================================================
+ (DMAlertAction *)headerAction;
+ (DMAlertAction *)headerAction:(DMAlertHeaderType)type;
+ (DMAlertAction *)headerActionWithTypeName:(NSString *)typeName;

#pragma mark - PHONE ALERT ACTION
///=============================================================================
/// @name PHONE ALERT ACTION
///=============================================================================
+ (DMAlertAction *)phoneAction:(NSString *)phone block:(void(^)(DMAlertType type))block;

+ (DMAlertAction *)bstyleBtnsAction:(NSArray *)actions alert:(DMAlert *)alert;

+ (DMAlertAction *)inputAction;
@end

NS_ASSUME_NONNULL_END
