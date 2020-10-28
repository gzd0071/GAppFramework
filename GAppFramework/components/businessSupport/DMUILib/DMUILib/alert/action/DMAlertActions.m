//
//  DMAlertActions.m
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/26.
//

#import "DMAlertActions.h"
#import <GBaseLib/GConvenient.h>
#import <YYKit/UIImage+YYAdd.h>

@implementation DMAlertActions

+ (DMAlertAction *)cancelAction:(id)title {
    return [DMAlertAction action].title(title).style(DMAlertActionStyleCancel);
}

#pragma mark - HeaderImageAction
///=============================================================================
/// @name HeaderImageAction
///=============================================================================

+ (DMAlertAction *)headerAction {
    return [self headerAction:DMAlertHeaderTypeNormal];
}

+ (DMAlertAction *)headerActionWithTypeName:(NSString *)typeName {
    return [self headerAction:[self typeFromTypeName:typeName]];
}

+ (DMAlertAction *)headerAction:(DMAlertHeaderType)type {
    UIView *header = [self header:type];
    return [DMAlertAction action].position(DMAlertActionPositionHeader).custom(header);
}

+ (UIView *)header:(DMAlertHeaderType)type {
    UIImageView *header = [UIImageView new];
    header.image = IMAGE([self headerImage:type]);
    header.size = CGSizeMake(kCAWidth, 104.f);
    return header;
}

+ (NSString *)headerImage:(DMAlertHeaderType)type {
    switch (type) {
        case DMAlertHeaderTypeCity:           return @"dialog_bg_city";
        case DMAlertHeaderTypeSign:           return @"dialog_bg_sign";
        case DMAlertHeaderTypeFail:           return @"dialog_bg_fail";
        case DMAlertHeaderTypePhone:          return @"dialog_bg_phone";
        case DMAlertHeaderTypeApply:          return @"dialog_bg_apply";
        case DMAlertHeaderTypeLimit:          return @"dialog_bg_limit";
        case DMAlertHeaderTypeCancel:         return @"dialog_bg_cancel";
        case DMAlertHeaderTypeDelete:         return @"dialog_bg_delete";
        case DMAlertHeaderTypeLogout:         return @"dialog_bg_logout";
        case DMAlertHeaderTypeResume:         return @"dialog_bg_resume";
        case DMAlertHeaderTypeService:        return @"dialog_bg_service";
        case DMAlertHeaderTypeSuccess:        return @"dialog_bg_success";
        case DMAlertHeaderTypeCaptcha:        return @"dialog_bg_captcha";
        case DMAlertHeaderTypeUnsaved:        return @"dialog_bg_unsaved";
        case DMAlertHeaderTypeShortage:       return @"dialog_bg_shortage";
        case DMAlertHeaderTypeLocation:       return @"dialog_bg_location";
        case DMAlertHeaderTypeUncommit:       return @"dialog_bg_uncommit";
        case DMAlertHeaderTypeContinuousSign: return @"dialog_bg_continuous_sign";
        default: return @"dialog_bg_normal";
    }
}

+ (DMAlertHeaderType)typeFromTypeName:(NSString *)str {
    if (!str) return DMAlertHeaderTypeNormal;
    NSDictionary *dict = @{@"apply":@1,
                           @"cancel":@2,
                           @"captcha":@3,
                           @"city":@4,
                           @"delete":@5,
                           @"fail":@6,
                           @"limit":@7,
                           @"logout":@8,
                           @"phone":@9,
                           @"service":@10,
                           @"shortage":@11,
                           @"success":@12,
                           @"uncommit":@13,
                           @"unsaved":@14,
                           @"sign":@15,
                           @"continuoussign":@16,
                           @"location":@17,
                           @"resume":@18
                           };
    return [dict[[str lowercaseString]] integerValue];
}

#pragma mark - PHONE ACTION
///=============================================================================
/// @name PHONE ACTION
///=============================================================================

+ (DMAlertAction *)phoneAction:(NSString *)phone block:(void(^)(DMAlertType type))block {
    DMAlertAction *action = [DMAlertAction action];
    return action.handler(^(DMAlertAction *action) {
        NSString *ps = FORMAT(@"tel://%@", phone);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ps]];
    });
}

#pragma mark - C BTNS
///=============================================================================
/// @name C BTNS
///=============================================================================

+ (DMAlertAction *)bstyleBtnsAction:(NSArray *)actions alert:(DMAlert *)alert {
    UIView *view = [UIView new];
    if ([actions isKindOfClass:DMAlertAction.class]) actions = @[actions];
    NSMutableArray *mut = @[].mutableCopy;
    [actions enumerateObjectsUsingBlock:^(DMAlertAction *action, NSUInteger idx, BOOL *stop) {
        if ([action.sTitle length]) [mut addObject:action];
    }];
    actions = mut.copy;
    BOOL two = actions.count == 2;
    [actions enumerateObjectsUsingBlock:^(DMAlertAction *action, NSUInteger idx, BOOL *stop) {
        UIButton *btn = [self btnFromAction:action];
        if (two) btn.frame = CGRectMake(15+((kCAWidth-30-20)/2+10)*idx, 0, (kCAWidth-30-20)/2, 45.0);
        else btn.frame = CGRectMake(15, 55*idx, kCAWidth-30, 45.0);
        [btn addEvents:UIControlEventTouchUpInside action:^{
            [alert dismiss:YES complete:^(DMAlert * _Nonnull alert) {
                if (action.block) action.block(action);
            }];
        }];
        [view addSubview:btn];
    }];
    view.frame = CGRectMake(0, 0, kCAWidth, two?(45+20):(55*actions.count + 10));
    return [DMAlertAction action].position(DMAlertActionPositionBottom).custom(view);
}

+ (UIButton *)btnFromAction:(DMAlertAction *)action {
    if (!action.sTitle) return nil;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    id title = [self btnTitle:action];
    [btn setAttributedTitle:title forState:UIControlStateNormal];
    UIColor *color  = action.sStyle == DMAlertActionStyleCancel ? HEX(@"ffffff", @"1c1c1e") : HEX(@"6699ff");
    UIColor *scolor = action.sStyle == DMAlertActionStyleCancel ? HEX(@"ffffff", @"1c1c1e") : HEX(@"6699ff");
    [btn setBackgroundImage:[UIImage imageWithColor:color] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:scolor] forState:UIControlStateHighlighted];
    if (action.sStyle == DMAlertActionStyleCancel) {
        btn.layer.borderColor = HEX(@"999999", @"989899").CGColor;
        btn.layer.borderWidth = HALFPixal;
    }
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
    return btn;
}

+ (NSAttributedString *)btnTitle:(DMAlertAction *)action {
    if ([action.sTitle isKindOfClass:NSAttributedString.class]) {
        return action.sTitle;
    }
    UIColor *color;
    if (action.sTitleColor) {
        color = action.sTitleColor;
    } else if (action.sStyle == DMAlertActionStyleCancel) {
        color = HEX(@"404040", @"dddddd");
    } else {
        color = HEX(@"ffffff", @"1c1c1e");
    }
    id attr = @{NSFontAttributeName:FONT(16), NSForegroundColorAttributeName:color };
    return [[NSAttributedString alloc] initWithString:action.sTitle attributes:attr];
}

#pragma mark - INPUT ACTION
///=============================================================================
/// @name INPUT ACTION
///=============================================================================

+ (DMAlertAction *)inputAction {
    UIView *view = [UIView new];
    view.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    view.frame = CGRectMake(0, -12, kCAWidth, 30+24+45+24);
    
    UITextField *tf = [self creatTextFeild];
    tf.frame = CGRectMake(15, 0, kCAWidth-30, 30);
    [view addSubview:tf];
    
    UIButton *confirm = [self creatConfirmBtn];
    UIButton *cancel  = [self creatCancelBtn];
    cancel.frame  = CGRectMake(15, tf.bottom+24, 110, 45);
    confirm.frame = CGRectMake(kCAWidth-110-15, tf.bottom+24, 110, 45);
    [view addSubview:confirm];
    [view addSubview:cancel];
    
    return [DMAlertAction action].position(DMAlertActionPositionBottom).custom(view);
}

+ (UIButton *)creatConfirmBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
    [btn setTitle:@"确认" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:HEX(@"F5C839", @"ffbb00")] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:HEX(@"F2B735")] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageWithColor:HEX(@"e5e5e5", @"303033")] forState:UIControlStateDisabled];
    return btn;
}

+ (UIButton *)creatCancelBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds     = YES;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = HEX(@"e5e5e5", @"303033").CGColor;
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setBackgroundColor:HEX(@"ffffff", @"1c1c1e")];
    return btn;
}

+ (UITextField *)creatTextFeild {
    UITextField *tf =  [[UITextField alloc] init];
    tf.textColor = HEX(@"404040", @"dddddd");
    tf.borderStyle = UITextBorderStyleNone;
    tf.font = FONT(14);
    tf.keyboardType = UIKeyboardTypeDefault;
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.clipsToBounds = YES;
    tf.layer.borderWidth = 0.5;
    tf.layer.borderColor = HEX(@"e5e5e5", @"303033").CGColor;
    tf.backgroundColor = HEX(@"f7f7f7", @"000000");
    return tf;
}

@end
