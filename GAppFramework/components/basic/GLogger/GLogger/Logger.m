//
//  Logger.m
//  Logger
//
//  Created by iOS_Developer_G on 2019/8/7.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "Logger.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "GSocket.h"

@interface ASocketLogger : DDAbstractLogger<DDLogger>
@end

@implementation ASocketLogger
+ (instancetype)sharedInstance {
    static ASocketLogger *slog;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        slog = [ASocketLogger new];
    });
    return slog;
}
- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *message = _logFormatter ? [_logFormatter formatLogMessage:logMessage] : logMessage->_message;
    [GSocket sendMessage:message];
}
- (DDLoggerName)loggerName {
    return @"cocoa.lumberjack.socketLogger";
}
@end

#pragma mark - Logger
///=============================================================================
/// @name Logger
///=============================================================================

static NSString * const LogLevelKey = @"kLogLevelUserDefaultKey";

@interface Logger()<DDLogFormatter>
///> 缓存的日志等级 
@property (nonatomic, assign) LogLevel logLevel;
///>
@property (nonatomic, strong) NSMutableDictionary *timeL;
@end

@implementation Logger

#pragma mark - Singleton
///=============================================================================
/// @name Singleton
///=============================================================================

+ (instancetype)share {
    static Logger *log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = [Logger new];
        log.timeL    = @{}.mutableCopy;
        log.logLevel = [[NSUserDefaults standardUserDefaults] integerForKey:LogLevelKey];
    });
    return log;
}

- (void)updateLevel:(LogLevel)level {
    self.logLevel = level;
    [[NSUserDefaults standardUserDefaults] setInteger:level forKey:LogLevelKey];
}

#pragma mark - Public Functions
///=============================================================================
/// @name Public Functions
///=============================================================================

+ (void)updateLevel:(LogLevel)level {
    if (level != LogLevelOff) [[Logger share] updateLevel:level];
    LogCustom(YES,
              LOG_LEVEL,
              LogFlagVerbose,
              __PRETTY_FUNCTION__,
              __FILE__,
              __LINE__,
              @"[Logger] => Change LogLevel To %@",
              @{@(LogLevelOff):@"LogLevelOff",
                @(LogLevelError):@"LogLevelError",
                @(LogLevelWarning):@"LogLevelWarning",
                @(LogLevelInfo):@"LogLevelInfo",
                @(LogLevelDebug):@"LogLevelDebug",
                @(LogLevelVerbose):@"LogLevelVerbose",
                @(LogLevelAll):@"LogLevelAll"
                }[@(level)]);
    if (level == LogLevelOff) [[Logger share] updateLevel:level];
}

+ (LogLevel)currentLogLevel {
    return [[Logger share] logLevel];
}

+ (void)setupLogger:(LogLevel)level {
    [DDTTYLogger sharedInstance].logFormatter = [Logger new];
    [ASocketLogger sharedInstance].logFormatter = [Logger new];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    if (@available(iOS 10.0, *)) {
        [DDLog addLogger:[DDOSLogger sharedInstance]];
    } else {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
    }
    [DDLog addLogger:[ASocketLogger sharedInstance] withLevel:DDLogLevelAll];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.logFormatter = [Logger new];
    fileLogger.rollingFrequency = kDDDefaultLogRollingFrequency;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    [self updateLevel:level];
}

#pragma mark - DDLogFormatter
///=============================================================================
/// @name DDLogFormatter
///=============================================================================

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError:
            logLevel = @"👉ERROR";
            break;
        case DDLogFlagWarning:
            logLevel = @"👉LWARN";
            break;
        case DDLogFlagInfo:
            logLevel = @"👉LINFO";
            break;
        case DDLogFlagDebug:
            logLevel = @"👉DEBUG";
            break;
        default:
            logLevel = @"👉VBOSE";
            break;
    }
    return [NSString stringWithFormat:@"%@ | %@", logLevel, logMessage->_message];
}

@end

#define LOG_CUST_MACRO(isAsynchronous, lvl, flg, ctx, file, atag, fnct, line, frmt, args) \
[DDLog log : isAsynchronous                                          \
level : lvl                                                     \
flag : flg                                                     \
context : ctx                                                     \
file : file                                                    \
function : fnct                                                    \
line : line                                                    \
tag : atag                                                    \
format : frmt                                                    \
args : args]

#define LOG_CUST_MAYBE(async, lvl, flg, ctx, file, tag, fnct, line, frmt, args) \
do { if(lvl & flg) LOG_CUST_MACRO(async, lvl, flg, ctx, file, tag, fnct, line, frmt, args); } while(0)

void LogCustom(BOOL async, LogLevel level, LogFlag flag, const char *function, const char *file, NSUInteger line, NSString *frmt, ...) {
    if (!frmt) return;
    va_list args;
    va_start(args, frmt);
    if (level & LogLevelEnvironment) level = [Logger share].logLevel;
    LOG_CUST_MAYBE(LOG_ASYNC_ENABLED, (DDLogLevel)level, (DDLogFlag)flag, 0, file, nil, function, line, frmt, args);
    va_end(args);
}

////////////////////////////////////////////////////////////////////////////////
/// @@class TimeLogger 耗时时间日志
////////////////////////////////////////////////////////////////////////////////
///> 商家信息
NSString * const ALoggerTimeLogNotification = @"ALoggerTimeLogNotification";

@implementation Logger (TimeLogger)
+ (void)timeTag:(NSString *)tag {
    [Logger share].timeL[tag] = [self timestamp];
}
+ (void)timeLog:(NSString *)tag str:(NSString *)frmt, ... {
    //FIXME: 使用CACurrentMediaTime来获取时间
    if (!tag || tag.length == 0) return;
    NSString *start = [Logger share].timeL[tag];
    if (!start) return;
    va_list args;
    va_start(args, frmt);
    NSInteger pad = ([[self timestamp] integerValue] - [start integerValue]);
    NSString *str = [[NSString alloc] initWithFormat:frmt arguments:args];
    LOGD(@"[TimePro] => %@ 耗时: %@", str, [self formatTime:pad/1000.0]);
    [[NSNotificationCenter defaultCenter] postNotificationName:ALoggerTimeLogNotification object:@{@"name": str, @"time": @(pad)}];
    va_end(args);
}
+ (NSString *)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970]*1000;
    return [NSString stringWithFormat:@"%.6f", time];
}
+ (NSString *)formatTime:(NSTimeInterval)pad {
    if (pad >= 3600 * 24) {
        return [NSString stringWithFormat:@"%ldd", (long)(pad/(3600 *24))];
    } else if (pad >= 3600) {
        return [NSString stringWithFormat:@"%ldh", (long)(pad/(3600))];
    } else if (pad >= 60) {
        return [NSString stringWithFormat:@"%ldmin", (long)(pad/(60))];
    } else if (pad >= 1) {
        return [NSString stringWithFormat:@"%.2fs", pad];
    } else {
        return [NSString stringWithFormat:@"%ldms", (long)(pad * 1000)];
    }
}
@end


