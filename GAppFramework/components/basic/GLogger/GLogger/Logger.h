//
//  Logger.h
//  Logger
//
//  Created by iOS_Developer_G on 2019/8/7.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ENUM
///=============================================================================
/// @name ENUM
///=============================================================================
/*!
 * 日志等级
 */
typedef NS_OPTIONS(NSUInteger, LogFlag){
    /** 0...00001 LogFlagError */
    LogFlagError      = (1 << 0),
    /** 0...00010 LogFlagWarning */
    LogFlagWarning    = (1 << 1),
    /** 0...00100 LogFlagInfo */
    LogFlagInfo       = (1 << 2),
    /** 0...01000 LogFlagDebug */
    LogFlagDebug      = (1 << 3),
    /** 0...10000 LogFlagVerbose */
    LogFlagVerbose    = (1 << 4)
};
/*!
 *  日志输出等级
 */
typedef NS_ENUM(NSUInteger, LogLevel){
    /** No logs */
    LogLevelOff       = 0,
    /** Error logs only */
    LogLevelError     = (LogFlagError),
    /** Error and warning logs */
    LogLevelWarning   = (LogLevelError   | LogFlagWarning),
    /** Error, warning and info logs */
    LogLevelInfo      = (LogLevelWarning | LogFlagInfo),
    /** Error, warning, info and debug logs */
    LogLevelDebug     = (LogLevelInfo    | LogFlagDebug),
    /** Error, warning, info, debug and verbose logs */
    LogLevelVerbose   = (LogLevelDebug   | LogFlagVerbose),
    /** The Import LogLevel */
    LogLevelEnvironment,
    /** All logs (1...11111) */
    LogLevelAll       = NSUIntegerMax
};

///> 用时统计事件输出, 可监听后然后接收事件
extern NSString * const ALoggerTimeLogNotification;

#pragma mark - MACRO
///=============================================================================
/// @name MACRO
///=============================================================================
///>
#ifndef LOG_ASYNC_ENABLED
    #define LOG_ASYNC_ENABLED YES
#endif
///> 日志等级
#ifndef LOG_LEVEL
    #define LOG_LEVEL LogLevelEnvironment
#endif
///> 日志输出宏
#define LOG_CUSTOM_MAYBE(async, flag, A, ...) \
        LogCustom(async, LOG_LEVEL, flag, __PRETTY_FUNCTION__, __FILE__, __LINE__, A, ##__VA_ARGS__)
#if DEBUG
///> 表示不可恢复的错误 
#define LOGE(A, ...) LOG_CUSTOM_MAYBE(NO, LogFlagError, A, ##__VA_ARGS__)
///> 表示可恢复的数据 
#define LOGW(A, ...) LOG_CUSTOM_MAYBE(LOG_ASYNC_ENABLED, LogFlagWarning, A, ##__VA_ARGS__)
///> 表示非错误的信息 
#define LOGI(A, ...) LOG_CUSTOM_MAYBE(LOG_ASYNC_ENABLED, LogFlagInfo, A, ##__VA_ARGS__)
///> 表示数据主要用于调试 
#define LOGD(A, ...) LOG_CUSTOM_MAYBE(LOG_ASYNC_ENABLED, LogFlagDebug, A, ##__VA_ARGS__)
///> 几乎提供了所有的细节, 主要用于跟踪执行过程中的控制流 
#define LOGV(A, ...) LOG_CUSTOM_MAYBE(LOG_ASYNC_ENABLED, LogFlagVerbose, A, ##__VA_ARGS__)
///> 主要用于时间节点 
#define LOGT(...) \
    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__)) \
    (LOGT_1(__VA_ARGS__)) \
    (LOGT_2(__VA_ARGS__))
#define LOGTES(A, B, ...) \
    static dispatch_once_t logonceToken; \
    dispatch_once(&logonceToken, ^{ \
    [Logger timeLog:A str:B, ##__VA_ARGS__];\
    });
///> Do not use this directly. Use the LOGT macro above.
#define LOGT_1(A) [Logger timeTag:A]
#define LOGT_2(A, B, ...) [Logger timeLog:A str:B, ##__VA_ARGS__]
#else
#define LOGE(A, ...)
#define LOGW(A, ...)
#define LOGI(A, ...)
#define LOGD(A, ...)
#define LOGV(A, ...)
///> 主要用于时间节点 
#define LOGT(...)
#define LOGTES(A, B, ...)
#endif

#pragma mark - FUNCTIONS
///=============================================================================
/// @name FUNCTIONS
///=============================================================================

extern void LogCustom(BOOL async, LogLevel level, LogFlag flag, const char *function,
                      const char *file, NSUInteger line, NSString *frmt, ...);

/*!
 * 开发日志库:
 *    1. 便于显示更好的显示日志, unicode中文化
 *    2. 日志等级可在运行期间动态控制修改
 *    3. 日志便于用于组件, 第三方组件的日志的显示等级由targetAPP统一配置
 */
@interface Logger : NSObject
///> 初始化日志 
+ (void)setupLogger:(LogLevel)level;
///> 动态更新日志等级 
+ (void)updateLevel:(LogLevel)level;
///> 当前日志等级 
+ (LogLevel)currentLogLevel;
@end

@interface Logger (TimeLogger)
///> 开始用时统计事件 
+ (void)timeTag:(NSString *)tag;
///> 结束用时统计事件, 并输出日志 
+ (void)timeLog:(NSString *)tag str:(NSString *)str, ...;
@end

NS_ASSUME_NONNULL_END
