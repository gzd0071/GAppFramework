//
//  TaskResult.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/15.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTask/GTask.h>

NS_ASSUME_NONNULL_BEGIN

/// MARK: GTaskResult
////////////////////////////////////////////////////////////////////////////////
/// @@class GTaskResult
////////////////////////////////////////////////////////////////////////////////

///> 初始化宏
#define GTaskResult(...) \
    metamacro_concat(GTaskResult_, metamacro_argcount(__VA_ARGS__))(__VA_ARGS__)
///> Do not use this directly. Use the GTaskResult macro above.
#define GTaskResult_1(A) [GTaskResult taskResultWithSuc:A]
#define GTaskResult_2(A, B) [GTaskResult taskResultWithSuc:A data:B]
#define GTaskResult_3(A, B, T) [GTaskResult<T> taskResultWithSuc:A data:B]

///> 任务结果 
@interface GTaskResult<T> : NSObject
///> 任务:结果
@property (nonatomic, assign) BOOL suc;
///> 任务:数据
@property (nonatomic, strong, nullable) T data;

/// 初始化方法, 建议使用TaskResult宏
/// @param suc 成功或是失败
/// @param data {id} 支持泛型, 任务数据
+ (instancetype)taskResultWithSuc:(BOOL)suc data:(nullable T)data;
+ (instancetype)taskResultWithSuc:(BOOL)suc;
@end


NS_ASSUME_NONNULL_END
