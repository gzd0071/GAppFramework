//
//  DMHybridViewController.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/10.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GBaseLib/GConvenient.h>
#import <GRouter/GRouter.h>
#import <WebKit/WebKit.h>
#import <GTask/GTaskResult.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMHybridViewController : UIViewController<GRouterTaskDelegate>

#pragma mark - Properties
///=============================================================================
/// @name Properties
///=============================================================================

///> 视图:
@property (nonatomic, strong) WKWebView *webView;
///> 链接(https or file:)
@property (nonatomic, strong) NSString *urlString;
///> CGRect: 适配不同页面
@property (nonatomic, assign) CGRect webframe;
///> 滚动视图
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
///> UA
@property (nonatomic, strong) NSString *userAgent;
///> 是否需要刷新组件
@property (nonatomic, assign) BOOL headerRefresh;
///> WB初始化完成
@property (nonatomic, strong) AActionBlock comBlock;

#pragma mark - Functions
///=============================================================================
/// @name Functions
///=============================================================================
///> 方法:重新加载页面 
- (void)reload;
///> 方法:载入新URL 
- (void)reloadUrl:(NSString *)urlString;
///> 方法:web执行交互 
- (void)evaluateJS:(NSString *)jsString;
///> 方法:web执行交互 
- (void)evaluateJS:(NSString *)jsString completionHandler:(void (^)(id, NSError *error))completion;

#pragma mark - rewritable
///=============================================================================
/// @name 重写方法,自定义事件处理
///=============================================================================
///> @rewritable: 标题展示逻辑 
- (void)updateTitle:(NSString *)title;
///> @rewritable: JS事件拦截时机 
- (GTaskResult *)handleAction:(NSString *)func args:(NSDictionary *)args;
///> @rewritable: 滚动事件 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
///> @rewritable: 是否自动处理URD 
- (BOOL)shouldHandleUrd:(NSString *)urd;
///> @rewritable: 是否自动处理URD 
- (BOOL)shouldStartLoadRequest:(NSURLRequest *)request;
@end

NS_ASSUME_NONNULL_END
