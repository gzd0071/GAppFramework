//
//  GTask+Fwd.h
//  GTask
//
//  Created by iOS_Developer_G on 2019/11/25.
//  Copyright © 2019 GCompany. All rights reserved.
//
#import <Foundation/NSDate.h>

NS_ASSUME_NONNULL_BEGIN
@class GTask;

#ifdef __cplusplus
extern "C" {
#endif

/// 创建任务快捷方式
/// @param value 作为任务的结果
extern __attribute__((overloadable)) GTask *ATTask(id value);
extern __attribute__((overloadable)) GTask *ATTask(GTaskResultType, id value);

/// 延时任务
/// @param duration 延迟时间
/// @example
///    ATAfter(1).then(^{
///       ///...
///    }];
extern GTask *ATAfter(NSTimeInterval duration);

/// 任务机制: 参数任务第一个返回的结果作为任务的结果
/// @param tasks {NSArray<GTask *> *} 任务列表
extern GTask *ATRace(NSArray<GTask *> *tasks);

/// 任务机制: 等待参数 所有任务fulfilled 或 一个任务失败 才会执行的任务
/// @param input
///    @type {NSArray *}
///    @type {GTask *}
///    @type {NSDictionary *}
/// @return
///    @type {NSArray *}
///    @type {NSArray *}
///    @type {NSDictionary *}
extern GTask *ATWhen(id input);

/// 任务机制: 等待参数任务完成后才会执行的任务
/// @param tasks {NSArray *} 任务列表
/// @return {NSArray *}
extern GTask *ATJoin(NSArray *tasks);

#if DEBUG
/// 会等待任务的执行
/// @warning 仅能使用在Debug环境
/// @param task 任务
extern id __nullable ATHang(GTask *task);
#endif

/// 异步线程中执行block块
/// @see dispatch_task_on
extern GTask * dispatch_task(id block);
/// 在指定线程中执行block块
/// @param queue 指定线程
/// @param block 代码块, 执行结果将作为任务的结果
extern GTask * dispatch_task_on(dispatch_queue_t queue, id block);

#ifdef __cplusplus
}   // Extern C
#endif

NS_ASSUME_NONNULL_END
