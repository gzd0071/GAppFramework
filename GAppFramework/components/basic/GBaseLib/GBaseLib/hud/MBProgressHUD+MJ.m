//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+MJ.h"
@implementation MBProgressHUD (MJ)

+ (void)fitKeyboardShow:(NSString *)text icon:(NSString *)icon view:(UIView *)view keybaoradHeight:(CGFloat)height
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (height > 0)
    {
        CGFloat origionY = view.bounds.size.height / 2;
        CGFloat aimY = (view.bounds.size.height - height) / 2;
        hud.yOffset =  aimY - origionY + 64.0;
    }
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.5];
}

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.5];
}

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view minShowTime:(float)minShow
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.minShowTime = minShow;
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.5];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    if([error isKindOfClass:[NSString class]]&&error&&error.length>0){
        [self show:error icon:@"error.png" view:view];
    }
}


+ (void)showError:(NSString *)error minShowSeconds:(float)minShow
{
    if([error isKindOfClass:[NSString class]]&&error&&error.length>0){
        [self show:error icon:@"error.png" view:nil minShowTime:minShow];
    }
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

+ (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
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

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    BOOL isDimBackground = YES;
    if (view == nil)
    {
        view = [UIApplication sharedApplication].keyWindow;
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view type:message.length>0?1:0 animated:YES];
    hud.labelText = message;
    hud.labelFont = [UIFont systemFontOfSize:14];

    hud.dimBackground = isDimBackground;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (MBProgressHUD *)showNoDimMessage:(NSString *)message view:(UIView *)view {
    BOOL isDimBackground = NO;
    
    if (!view) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view type:message.length>0?1:0 animated:YES];
    hud.labelText = message;
    hud.labelFont = [UIFont systemFontOfSize:14];
     
    hud.dimBackground = isDimBackground;
     
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    return hud;
}
+ (MBProgressHUD *)showNoDimMessage:(NSString *)message;
{
    
    [self showNoDimMessage:message view:nil];
}

+ (MBProgressHUD *)showWebViewMessage:(NSString *)message toView:(UIView *)view
{
    if (view == nil)
    {
        view = [UIApplication sharedApplication].keyWindow;
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view type:message.length>0?1:0 animated:YES];
    hud.labelText = message;
    hud.labelFont = [UIFont systemFontOfSize:14];
    

    hud.color = [UIColor clearColor];
    
    hud.dimBackground = NO;
    
    hud.labelColor = [self colorFromHexRGB:@"404040"];
    
    
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    return hud;
}
+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}
@end
