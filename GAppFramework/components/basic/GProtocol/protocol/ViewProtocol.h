//
//  ProtocolExtend.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/15.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <GBaseLib/GConvenient.h>

NS_ASSUME_NONNULL_BEGIN

///> action 

#define RGB(A, B, C)   [UIColor colorWithRed:(A)/255.0 green:(B)/255.0 blue:(C)/255.0 alpha:1]

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

@protocol ViewDelegate <NSObject>
///> 主要用于 View 
@optional
+ (nonnull id)viewWithModel:(nullable id)model action:(nullable AActionBlock)action;
+ (nonnull id)viewWithModel:(nullable id)model baction:(nullable BActionBlock)action;
+ (nonnull id)viewWithFrame:(CGRect)frame model:(nullable id)model action:(nullable AActionBlock)action;
+ (nonnull id)viewWithFrame:(CGRect)frame model:(nullable id)model baction:(nullable BActionBlock)action;
///> 主要用于 Cell 
@optional
- (void)viewModel:(nullable id)model action:(nullable AActionBlock)action;
- (void)viewModel:(nullable id)model baction:(nullable BActionBlock)action;
- (void)viewUIModel:(nullable id)model;
///> 用于向view 或 cell中传递事件 
@optional
- (nullable AActionBlock)viewAction;
///> view 事件传递 
- (void)viewAction:(id)x;
@end

#pragma mark - GSViewDelegate
///=============================================================================
/// @name GSViewDelegate
///=============================================================================

@protocol GSViewDelegate <NSObject>
///>  
@optional
@property (nonatomic, strong) UIScrollView *scro;
@required
- (NSArray *)vdViewsArray;
@optional
- (void)vdAddViews;
@optional
- (id)vdModel:(NSInteger)idx;
@optional
- (CGFloat)vdPadding:(NSInteger)idx;
@optional
- (void)vdTapAction:(id)tuple;
@optional
- (id)vdUIData:(NSInteger)idx;
@optional
- (void)vdUpdateLayout;
@end

#pragma mark - TabBarDelegate
///=============================================================================
/// @name DMSTabBarDelegate
///=============================================================================

@protocol DMSTabBarDelegate <NSObject>
@optional
///> 是否能被选中 
- (BOOL)tabShouldSelect;
///> 当前选中tabItem再次被点击 
- (void)tabTapedWhenTheSelectedTabItem;
///> 当前视图已经选中 
- (void)tabDidSelected;
@end

@protocol NaviDelegate <NSObject>
@optional
- (UIBarButtonItem *)naviRightBarItem;
- (UIBarButtonItem *)naviLeftBarItem;
- (void)naviLeftBarItemAction;
@end

NS_ASSUME_NONNULL_END
