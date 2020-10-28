//
//  GMainTab.h
//  GMainTabExample
//
//  Created by iOS_Developer_G on 2019/7/13.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GTask;

#pragma mark - PROTOCOL
///=============================================================================
/// @name 协议
///=============================================================================

@protocol GMainTabDelegate <NSObject>
@optional
///> 依赖事件: 是否能选中Item: @return 1. NSNumber(0 or 1); 2. ATask<NSNumber *> 
- (id)shouldSelectTabItem;
///> 事件回调: 选中事件 
- (void)didSelectTabItem;
///> 事件回调: 再次点击选中Item 
- (void)tapSelectedTapItem;
///> 事件回调: 界面完成初始化 
- (void)tabItemViewControllerDidInitial:(NSInteger)idx;
@end

@protocol GMainTabDataSource <NSObject>
@required
///> TAB: 正常图片 
- (NSArray<NSString *> *)tabItemNormalImages;
///> TAB: 选中图片 
- (NSArray<NSString *> *)tabItemSelectedImages;
///> TAB: 标题 
- (NSArray<NSString *> *)tabItemTitles;
///> TAB: 页面 
- (NSArray<NSString *> *)tabItemViewControllers;
@optional
///> TAB: 大按钮位置 
- (NSInteger)indexOfPlusButton;
- (void)customPlusButton:(UIButton *)button;
- (CGFloat)constantOffsetYPlusButton;
@optional
///> TAB: 自定制样式时机 
- (void)customTabBar:(UITabBar *)tabBar;
@end

#pragma mark - GMainTab
///=============================================================================
/// @name GMainTab
///=============================================================================

///> TODO: 支持多TAB 
@interface GMainTab : NSObject
+ (GTask *)task;
@end

NS_ASSUME_NONNULL_END
