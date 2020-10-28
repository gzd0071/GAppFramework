//
//  GHud.h
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * 定制: TOAST\HUD
 */
@interface GHud : NSObject

#pragma mark - Toast
///=============================================================================
/// @name Toast
///=============================================================================

/// Toast提示
/// @param txt 文案
/// @see   +toast:view:
+ (void)toast:(NSString *)txt;
/// Toast提示
/// @param txt 文案
/// @param view 文案提示所在父视图
+ (void)toast:(NSString *)txt view:(UIView *)view;

#pragma mark - HUD
///=============================================================================
/// @name HUD
///=============================================================================

/// 显示加载框
/// @see +hud:dim:view
+ (void)hud;
/// 显示加载框
/// @see +hud:dim:view
+ (void)hud:(nullable NSString *)txt;
/// 显示加载框
/// @see +hud:dim:view
+ (void)hud:(nullable NSString *)txt view:(nullable UIView *)view;
/// 显示加载框
/// @see +hud:dim:view
+ (void)hud:(nullable NSString *)txt dim:(BOOL)dim;
/// 显示加载框
/// @param txt 文案
/// @param dim 是否需要黑色背景, 默认为YES
/// @param view 容器视图, 默认为keywindow
+ (void)hud:(nullable NSString *)txt dim:(BOOL)dim view:(nullable UIView *)view;
/// 显示加载框, 加载框没有背景色
/// @param txt 文案
/// @param view 容器视图, 默认为keywindow
+ (void)webHud:(nullable NSString *)txt view:(UIView *)view;

/// 隐藏加载框
/// @see +hide:
+ (void)hide;
/// 隐藏加载框
/// @param view {UIView *} 容器视图
+ (void)hide:(nullable UIView *)view;
/// 隐藏加载框
/// @see +hide:
+ (void)hideAll;
/// 隐藏加载框
/// @param view {UIView *} 容器视图
+ (void)hideAll:(nullable UIView *)view;

/// 是否已经显示加载框
+ (BOOL)isHud;
/// 是否已经显示加载框
+ (BOOL)isHud:(nullable UIView *)view;

@end

NS_ASSUME_NONNULL_END
