//
//  DMHListView.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/24.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMHListModel.h"
#import <GProtocol/ViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN
@class iCarousel;

@protocol DMHParamsListDelegate <NSObject>
///> 请求参数: 获取职位列表 
- (NSDictionary *)listParams;
///> 请求参数: 获取运营位 
- (NSDictionary *)panelParams;
///> 职位类型: 获取全职or兼职 
- (NSString *)workType;
///> 事件回调: 滚动回调 distance范围为[-44,0] 
- (void)scrollAnimate:(CGFloat)distance;
///> 事件回调: 职位列表返回默认筛选数据,用于更新filter显示 
- (void)updateMoreData:(DMHDefaultMore *)more;
- (void)updateExposureIds:(NSInteger)count;

#pragma mark - 埋点相关
///=============================================================================
/// @name 埋点相关
///=============================================================================
///> 事件回调: 埋点回调 
- (void)evlog:(NSString *)ev params:(nullable NSDictionary *)params;
///> 获取: 当前TAG(如推荐) 
- (NSString *)evTag;
///> 获取: 筛选项 
- (NSString *)evMore;
@optional
///> 用于首页导航条动画 
- (void)scrollViewNaviAnimate:(BOOL)isFull;
#pragma mark - 滚动回调
///=============================================================================
/// @name 滚动回调
///=============================================================================
- (void)hscrollViewDidScroll:(UIScrollView *)scrollView;
- (void)hscrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end

@interface DMHListView : UIView<ViewDelegate>
///> 
@property (nonatomic, weak) UIViewController<DMHParamsListDelegate> *vc;

- (BOOL)isRefresh;
@end

NS_ASSUME_NONNULL_END
