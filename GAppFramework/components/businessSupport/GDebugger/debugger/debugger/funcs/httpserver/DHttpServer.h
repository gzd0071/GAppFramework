//
//  DHttpServer.h
//  Debugger
//
//  Created by iOS_Developer_G on 2019/9/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * TODO:
 *   1. 架设网页日志显示器 [x]
 *      a. 日志过滤显示
 *   2. 开发网页日志配置页
 *   3. dek替换网页
 *   4. 开发网页账户切换器
 */
@interface DHttpServer : NSObject

/*!
 * 启动服务
 */
+ (void)startServer;

/*!
 * 获取当前IP与端口号
 * e.g. http://192.168.2.32:15151
 */
+ (NSString *)getIPPort;

+ (void)addGetRequest:(NSString *)path result:(NSDictionary *(^)(NSString *path))result;

@end

NS_ASSUME_NONNULL_END
