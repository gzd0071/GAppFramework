//
//  GTask+Fwd.m
//  ATask
//
//  Created by iOS_Developer_G on 2019/11/25.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
#import <stdatomic.h>
#import "GTask.h"
#import "GTask+Private.h"

NSString *const ATErrorDomain = @"ATaskErrorDomain";
#define ATaskInvalidUsageError 31

#pragma mark - After
///=============================================================================
/// @name After
///=============================================================================

/// 延时任务
GTask *ATAfter(NSTimeInterval duration) {
    return [GTask taskWithResolverBlock:^(GTResolver resolve) {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_global_queue(0, 0), ^{
            resolve(GTaskResultFulfilled, @(duration));
        });
    }];
}

#pragma mark - Race
///=============================================================================
/// @name Race
///=============================================================================

/// 任务机制: 参数任务第一个返回的结果作为任务的结果
GTask *ATRace(NSArray<GTask *> *tasks) {
    return [GTask taskWithResolverBlock:^(GTResolver resolve) {
        for (GTask *task in tasks) {
            [task pipe:^(_GTaskStatus status, id value) {
                GTaskResultType result = status == _GTaskStatusFulfilled ? GTaskResultFulfilled : GTaskResultRejected;
                resolve(result, value);
            }];
        }
    }];
}

#pragma mark - Cancel
///=============================================================================
/// @name Cancel
///=============================================================================

GTask *ATCancel(GTask *task, GTResolver resolve) {
    if (!task || !resolve) return task;
    GTask *cancel = [[GTask alloc] initWithResolver:&resolve];
    return ATRace(@[task, cancel]);
};

#pragma mark - When
///=============================================================================
/// @name When
///=============================================================================

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/// 机制: 等待参数任务完成后才会执行的任务
GTask *ATWhen(NSArray *tasks) {
    if (!tasks) {
        id error = [NSError errorWithDomain:ATErrorDomain code:ATaskInvalidUsageError userInfo:@{NSLocalizedDescriptionKey:@"ATWhen(nil)"}];
        return [GTask taskWithValue:error];
    }
    if ([tasks isKindOfClass:[NSArray class]] || [tasks isKindOfClass:NSDictionary.class]) {
        if (tasks.count == 0) return [GTask taskWithValue:tasks];
    } else if ([tasks isKindOfClass:GTask.class]) {
        tasks = @[tasks];
    } else {
        return [GTask taskWithValue:tasks];
    }
    
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:(int64_t)[tasks count]];
    progress.pausable = NO;
    progress.cancellable = NO;
    
    __block int32_t ct = (int32_t)[tasks count];
    BOOL const isDic = [tasks isKindOfClass:NSDictionary.class];
    
    GTResolver resolve;
    GTask *task = [[GTask alloc] initWithResolver:&resolve];
    NSInteger idx = 0;
    for (__strong id key in tasks) {
        GTask *task = isDic ? ((NSDictionary *)tasks)[key] : key;
        if (!isDic) key = @(idx);
        if (![task isKindOfClass:GTask.class]) {
            task = [GTask taskWithValue:task];
        }
        [task pipe:^(_GTaskStatus status, id value) {
            if (progress.fractionCompleted >= 1) {
                return;
            }
            if (status == _GTaskStatusRejected) {
                progress.completedUnitCount = progress.totalUnitCount;
                resolve(GTaskResultRejected, value);
            } else if (OSAtomicDecrement32(&ct) == 0) {
                progress.completedUnitCount = progress.totalUnitCount;
                id results;
                if (isDic) {
                    results = [NSMutableDictionary new];
                    for (id key in tasks) {
                        id task = ((NSDictionary *)tasks)[key];
                        results[key] = [task isKindOfClass:GTask.class] ? ((GTask *)task).value : task;
                    }
                } else {
                    results = [NSMutableArray new];
                    for (GTask *task in tasks) {
                        id value = [task isKindOfClass:GTask.class] ? (task.value?:[NSNull null]) : task;
                        [results addObject:value];
                    }
                }
                resolve(GTaskResultFulfilled, results);
            } else {
                progress.completedUnitCount++;
            }
        }];
    }
    return task;
}
#pragma GCC diagnostic pop

#pragma mark - Join
///=============================================================================
/// @name Join
///=============================================================================

GTask *ATJoin(NSArray *tasks) {
    if (!tasks) {
        id error = [NSError errorWithDomain:ATErrorDomain code:ATaskInvalidUsageError userInfo:@{NSLocalizedDescriptionKey:@"ATJoin(nil)"}];
        return [GTask taskWithValue:error];
    }
    if (tasks.count == 0) {
        return [GTask taskWithValue:tasks];
    }
    GTResolver resolve;
    GTask *task = [[GTask alloc] initWithResolver:&resolve];
    NSPointerArray *results = [NSPointerArray strongObjectsPointerArray];
    results.count = tasks.count;
    __block atomic_int ct = tasks.count;
    __block BOOL rejected = NO;
    [tasks enumerateObjectsUsingBlock:^(GTask *obj, NSUInteger idx, BOOL *stop) {
        [obj pipe:^(_GTaskStatus status, id value) {
            if (status == _GTaskStatusRejected) {
                rejected = YES;
            }
            [results replacePointerAtIndex:idx withPointer:(__bridge void *)(value ?: [NSNull null])];
            atomic_fetch_sub_explicit(&ct, 1, memory_order_relaxed);
            if (ct == 0) {
                if (!rejected) {
                    resolve(GTaskResultFulfilled, results.allObjects);
                } else {
                    resolve(GTaskResultRejected, tasks);
                }
            }
        }];
        (void)stop;
    }];
    return task;
}

#pragma mark - Seq
///=============================================================================
/// @name Seq
///=============================================================================

/// 依次执行
GTask *ATSeq(NSArray *tasks) {
    if (tasks.count == 0) return [GTask taskWithValue:tasks];
    return ATTask(@(YES));
}

#pragma mark - Hang
///=============================================================================
/// @name Hang
///=============================================================================

id ATHang(GTask *task) {
    if (!task.pending) return task.value;
    
    static CFRunLoopSourceContext context;
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
    task.ensure(^{
        CFRunLoopStop(runLoop);
    });
    while (task.pending) {
        CFRunLoopRun();
    }
    CFRunLoopRemoveSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
    CFRelease(runLoopSource);
    return task.value;
}

#pragma mark - Dispatch
///=============================================================================
/// @name Dispatch
///=============================================================================

GTask *dispatch_task_on(dispatch_queue_t queue, id block) {
    return [GTask taskWithValue:nil].thenOn(queue, block);
};

GTask *dispatch_task(id block) {
    return dispatch_task_on(dispatch_get_global_queue(0, 0), block);
}
