//
//  GHud.m
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/11/25.
//

#import "GHud.h"
#import <GBaseLib/MBProgressHUD+MJ.h>

@implementation GHud

#pragma mark - Toast
///=============================================================================
/// @name Toast
///=============================================================================

/// 弹框提示
+ (void)toast:(NSString *)txt {
    [MBProgressHUD showError:txt];
}
/// 弹框提示
+ (void)toast:(NSString *)txt view:(UIView *)view {
    [MBProgressHUD showError:txt toView:view];
}

#pragma mark - HUD
///=============================================================================
/// @name HUD
///=============================================================================

/// 显示加载框
+ (void)hud {
    [self hud:nil dim:NO view:nil];
}
+ (void)hud:(nullable NSString *)txt {
    [self hud:txt dim:YES view:nil];
}
+ (void)hud:(nullable NSString *)txt view:(nullable UIView *)view {
    [self hud:txt dim:YES view:view];
}
+ (void)hud:(nullable NSString *)txt dim:(BOOL)dim {
    [self hud:txt dim:dim view:nil];
}
+ (void)hud:(nullable NSString *)txt dim:(BOOL)dim view:(nullable UIView *)view {
    if (dim) {
        [MBProgressHUD showMessage:txt toView:view];
    } else {
        [MBProgressHUD showNoDimMessage:txt view:view];
    }
}

+ (void)webHud:(nullable NSString *)txt view:(UIView *)view {
    [MBProgressHUD showWebViewMessage:txt toView:view];
}

/// 隐藏加载框
+ (void)hide {
    [MBProgressHUD hideHUD];
}
+ (void)hide:(UIView *)view {
    if (!view) view = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:view animated:YES];
}
+ (void)hideAll {
    [self hideAll:nil];
}
+ (void)hideAll:(UIView *)view {
    if (!view) view = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

/// 是否已经显示加载框
+ (BOOL)isHud {
    return [self isHud:nil];
}
/// 是否已经显示加载框
+ (BOOL)isHud:(UIView *)view {
    return !![MBProgressHUD HUDForView:view];
}


@end
