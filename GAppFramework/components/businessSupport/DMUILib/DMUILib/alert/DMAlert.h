//
//  DMAlert.h
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/18.
//

#import <UIKit/UIKit.h>

@protocol DMAlertHandlerDelegate;
@class    DMAlertAction;

NS_ASSUME_NONNULL_BEGIN

///> 弹框类型 
typedef NS_ENUM(NSInteger, DMAlertType) {
    ///> 斗米默认
    DMAlertTypeDoumi   = 0,
    ///> 斗米B端
    DMAlertTypeDoumiB,
    ///> 系统
    DMAlertTypeSystem,
    ///> 自定义Sheet
    DMAlertTypeSheet
};

///> 弹框样式 
typedef NS_ENUM(NSInteger, DMAlertStyle) {
    ///> Sheet
    DMAlertStyleSheet   = 0,
    ///> Alert
    DMAlertStyleAlert
};

///> 弹框事件样式 
typedef NS_ENUM(NSInteger, DMAlertActionStyle) {
    DMAlertActionStyleDefault   = 0,
    DMAlertActionStyleCancel,
    DMAlertActionStyleDestructive
};

///> 弹框事件位置 
typedef NS_ENUM(NSInteger, DMAlertActionPosition) {
    DMAlertActionPositionDefault = 0,
    DMAlertActionPositionHeader,
    DMAlertActionPositionBottom
};

@protocol DMAlertActionViewDelegate <NSObject>
- (UIView *)actionView:(DMAlertAction *)action sszie:(CGSize)ssize;
@end

///> 弹框事件 
@interface DMAlertAction : NSObject
#pragma mark - CONVENIENT
///=============================================================================
/// @name CONVENIENT
///=============================================================================
+ (instancetype)action;
+ (instancetype)action:(id<DMAlertActionViewDelegate>)delegate;
#pragma mark - DOT SYNTAX
///=============================================================================
/// @name 点语法
///=============================================================================
///> 数据: 标题 
- (DMAlertAction *(^)(id title))title;
///> 数据: 标题颜色 
- (DMAlertAction *(^)(UIColor *color))titleColor;
///> 数据: 样式 
- (DMAlertAction *(^)(DMAlertActionStyle style))style;
///> 数据: 自定义视图 
- (DMAlertAction *(^)(UIView *view))custom;
///> 数据: 自定义视图 
- (DMAlertAction *(^)(id<DMAlertActionViewDelegate> delegate))delegate;
///> 数据: 位置 
- (DMAlertAction *(^)(DMAlertActionPosition position))position;
///> 数据: 事件处理 
- (DMAlertAction *(^)(void (^)(DMAlertAction *action)))handler;
#pragma mark - PROPERTIES
///=============================================================================
/// @name PROPERTIES
///=============================================================================
///> 数据: 事件块 
@property (nonatomic, copy) void (^block)(DMAlertAction *action);
///> 数据: 标题 
@property (nonatomic, strong) id sTitle;
///> 数据: 标题颜色 
@property (nonatomic, strong) UIColor *sTitleColor;
///> 数据: 样式 
@property (nonatomic, assign) DMAlertActionStyle sStyle;
///> 数据: 位置 
@property (nonatomic, assign) DMAlertActionPosition sPosition;
///> 数据: 自定义视图 
@property (nonatomic, strong) UIView *sCustom;
///> 数据: 自定义视图 
@property (nonatomic, weak) id<DMAlertActionViewDelegate> sdelegate;
@end

///> 弹框类 
@interface DMAlert : UIView
#pragma mark - CONVENIENT
///=============================================================================
/// @name CONVENIENT
///=============================================================================
///> 初始化 
+ (instancetype)alert;
///> 消失 
- (void)dismiss:(BOOL)animate complete:(void (^)(DMAlert *alert))block;
#pragma mark - DOT SYNTAX
///=============================================================================
/// @name 点语法
///=============================================================================
///> 数据: 标题 
- (DMAlert *(^)(id title))title;
///> 数据: 文案 
- (DMAlert *(^)(id message))message;
///> 数据: 类型 
- (DMAlert *(^)(DMAlertType type))type;
///> 数据: 标题 
- (DMAlert *(^)(DMAlertStyle style))style;
///> 数据: 事件 
- (DMAlert *(^)(DMAlertAction *action))addAction;
///> 数据: 事件, DMAlertAction or NSArray<DMAlertAction *> 
- (DMAlert *(^)(id action))addActions;
///> 弹框: 触发 
- (void(^)(UIViewController * _Nullable vc))show;
///> 弹框: 转嫁消化器alert 
- (void(^)(id<DMAlertHandlerDelegate> alert, UIViewController *vc))alert;
#pragma mark - PROPERTIES
///=============================================================================
/// @name PROPERTIES
///=============================================================================
///> 数据: 标题 
@property (nonatomic, strong) id sTitle;
///> 数据: 文案 
@property (nonatomic, strong) id sMessage;
///> 数据: 类型 
@property (nonatomic, assign) DMAlertType sType;
///> 数据: 样式 
@property (nonatomic, assign) DMAlertStyle sStyle;
///> 数据: Actions 
@property (nonatomic, strong) NSMutableArray<DMAlertAction *> *actions;
@end

NS_ASSUME_NONNULL_END
