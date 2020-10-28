//
//  GShow.h
//  GUILib
//
//  Created by iOS_Developer_G on 2019/9/10.
//

#import <Foundation/Foundation.h>
#import <GTask/GTaskResult.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GShowAnimateDelegate <NSObject>
- (CGRect)showFrameAnimation;
- (CGRect)dismissFrameAnimation;
@end

@protocol GShowActionDelegate <NSObject>
@optional
///> 黑色背景点击事件 
- (void)backTapAction;
///> 事件: 视图出现 
- (void)showAppearAction;

- (UIEdgeInsets)backInsets;
@end

///> 动画类型 
typedef NS_ENUM(NSInteger, GShowAnimateType) {
    ///> 从下往上
    GShowAnimateTypeBottom = 0,
    GShowAnimateTypeTop,
    GShowAnimateTypeLeft,
    GShowAnimateTypeRight,
    GShowAnimateTypeCenter,
    GShowAnimateTypeFade,
    GShowAnimateTypeCustomFrame,
    GShowAnimateTypeCustomAnimations,
};

///> 弹框工具 
@interface GShow : NSObject
+ (instancetype)show:(UIView *)view;
+ (instancetype)show:(UIView *)view sview:(nullable UIView *)sview;
+ (instancetype)show:(UIView *)view type:(GShowAnimateType)type;
+ (instancetype)show:(UIView *)view type:(GShowAnimateType)type com:(nullable void (^)(BOOL finish))completion;
+ (instancetype)show:(UIView *)view type:(GShowAnimateType)type sview:(nullable UIView *)sview;
- (void)dismiss:(BOOL)animated;
- (void)dismiss:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;
@end

NS_ASSUME_NONNULL_END
