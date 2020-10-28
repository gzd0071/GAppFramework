//
//  MBProgressHUD+MJ.h
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (MJ)

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showError:(NSString *)error minShowSeconds:(float)minShow;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showWebViewMessage:(NSString *)message toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;
+ (MBProgressHUD *)showMessage:(NSString *)message;
+ (MBProgressHUD *)showNoDimMessage:(NSString *)message;
+ (MBProgressHUD *)showNoDimMessage:(NSString *)message view:(UIView *)view;
+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;
+ (void)fitKeyboardShow:(NSString *)text icon:(NSString *)icon view:(UIView *)view keybaoradHeight:(CGFloat)height;

@end