//
//  AServerFileHandlers.h
//  Debugger
//
//  Created by iOS_Developer_G on 2019/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AServerFileHandlers : NSObject

/*!
 * 处理接收到的文件
 * @param filename {NSString *} 文件名称
 * @param path {NSString *} 文件存储沙盒路径
 */
+ (void)handleFile:(NSString *)filename path:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
