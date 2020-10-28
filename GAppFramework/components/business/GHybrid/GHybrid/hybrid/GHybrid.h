//
//  GHybrid.h
//  GHybrid
//
//  Created by iOS_Developer_G on 2019/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GTask<T>;
@class GTaskResult;


/// MARK: GHybridDelegate
////////////////////////////////////////////////////////////////////////////////
/// @@class GHybridDelegate
////////////////////////////////////////////////////////////////////////////////

/*!
 * Hybrid协议, JS与Native交互协议
 */
@protocol GHybridDelegate <NSObject>

/// [JS交互]: Native实现,与JS交互后返回结果
/// @param str {NSString *} 方法串
- (GTask<NSString *> *)evaluateJavaScript:(NSString *)str;

@optional
/// [JS交互]: 是否拦截JS事件
/// @param name {NSString *} 方法名
/// @param args {NSDictionary *} JS事件参数
/// @return {TaskResult}
///     a. result.suc == YES: 会阻断后续的JS事件执行
///     b. result.suc == NO : 不会阻断后续的JS事件执行
- (GTaskResult *)handleAction:(NSString *)name args:(NSDictionary *)args;

/// [JS交互]: 类前缀
/// @return {NSString *} 如未实现默认前缀为DMA
- (NSString *)classPrefix;
@end


/// MARK: GHybrid
////////////////////////////////////////////////////////////////////////////////
/// @@class GHybrid
////////////////////////////////////////////////////////////////////////////////

@interface GHybrid : NSObject

/// Hybrid: 拦截网页URL请求
/// @param url 网页URLRequest.URL
/// @param model 协议准守方
+ (BOOL)handleHybridAction:(NSURL *)url model:(UIViewController<GHybridDelegate> *)model;
@end

NS_ASSUME_NONNULL_END
