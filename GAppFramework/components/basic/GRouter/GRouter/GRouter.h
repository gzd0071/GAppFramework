//
//  GRouter.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/7/18.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTask/GTask.h>

#define ROUTER_REGISTER(A, B) \
+ (void)load { [GRouter registScheme:A urd:B cls:self]; }

NS_ASSUME_NONNULL_BEGIN
///> ROUTER宏
#define ROUTER(...) \
    metamacro_concat(Router_, metamacro_argcount(__VA_ARGS__))(__VA_ARGS__)
///> Do not use this directly. Use the GRouter macro above.
#define Router_1(A) [GRouter router:A]
#define Router_2(A, B) [GRouter router:A params:B]
#define Router_3(A, B, C) [GRouter router:A params:B navi:C]

///> 注册漏斗处理事件
extern NSString * const RouterDefaultHandler;

////////////////////////////////////////////////////////////////////////////////
/// @@class GRouter
////////////////////////////////////////////////////////////////////////////////
/*!
 * GRouter 路由器
 * 文档地址 http://confluence.corp.doumi.com/pages/viewpage.action?pageId=6066170
 */
@interface GRouter : NSObject
///> URD分发处理器 
+ (GTask *)router:(NSString *)uri;
+ (GTask *)router:(NSString *)uri navi:(nullable UINavigationController *)navi;
+ (GTask *)router:(NSString *)uri params:(nullable id)params;
+ (GTask *)router:(NSString *)uri params:(nullable id)params navi:(nullable UINavigationController *)navi;
///> 用来注册 推荐使用ROUTER_REGISTER宏 
+ (void)registScheme:(NSString *)scheme urd:(NSString *)urd cls:(Class)cls;
+ (BOOL)hadRegister:(NSString *)scheme;
+ (UINavigationController *)navi;
@end

////////////////////////////////////////////////////////////////////////////////
/// @@class GRouterDigester
////////////////////////////////////////////////////////////////////////////////

@interface GRouterDigester<T> : NSObject
///> Digster: 消化器 
@property (nonatomic, strong) T digester;
///> Digster: 传递数据 
@property (nonatomic, strong) id data;
///> Digster: URL 
@property (nonatomic, strong) NSURL *url;
@end

////////////////////////////////////////////////////////////////////////////////
/// @@class GRouterInterceptorDelegate
////////////////////////////////////////////////////////////////////////////////

@protocol GRouterInterceptorDelegate <NSObject>
///> 类方法, 获取拦截器对象 返回值同拦截器值 
+ (id)interceptor:(nullable id)data;
@end

////////////////////////////////////////////////////////////////////////////////
/// @@protocol GRouterDataDelegate
////////////////////////////////////////////////////////////////////////////////

@protocol GRouterDataDelegate <NSObject>
@optional
///> 用于向 ViewController 传递数据 
- (void)routerPassParamters:(nullable id)data;
@optional
///> 消化器: 接受数据,处理事件 
+ (GTask *)routerAction:(GRouterDigester *)digester navi:(id)navi;
/*! @return
 *     1. @YES or @NO: YES表示拦截,停止后续操作; NO表示不拦截,继续后续操作
 *     2. GTaskResult<GTask *> *
 *     3. GTask<GTaskResult<GTask *> *> *:
 *     4. NSArray<id> *: 如果为数组, 依次执行取得Task结果
 */
@optional
///> 消化器:前置拦截器 
+ (id)beforeInterceptors:(GRouterDigester *)data;
@optional
///> 消化器:后置拦截器 
- (id)afterInterceptors:(nullable id)data vc:(UIViewController *)vc navi:(UINavigationController *)navi;
@end

////////////////////////////////////////////////////////////////////////////////
/// @@protocol GRouterTaskDelegate
////////////////////////////////////////////////////////////////////////////////

///> 遵循协议, 就会自动实现 
@protocol GRouterTaskDelegate <GRouterDataDelegate>
@optional
///> 主要用于内部使用 
- (nullable GTask *)delegateTask;
///> 主要用于界面内部管理界面的任务周期 
@property (nonatomic, strong) GTaskSource *tcs;
@end

NS_ASSUME_NONNULL_END
