//
//  GTask.h
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/11/7.
//

#import <Foundation/Foundation.h>
#import "GInvokeBlock.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GTaskResultType) {
    GTaskResultProcess = 0,
    GTaskResultFulfilled,
    GTaskResultRejected
};

@interface GTask<__covariant ResultType> : NSObject

typedef void (^GTResolver)(GTaskResultType result, id __nullable data);

#pragma mark - Class Functions
///=============================================================================
/// @name 类方法
///=============================================================================

/// 创建一个已经完成的任务
/// @param value
///    a. {NSError *} 返回一个处理结果为失败的任务
///    b. {GTask *}
///    c. {id} 返回一个处理结果为成功的任务
/// @return 一个已经完成的任务
+ (instancetype)taskWithValue:(__nullable id)value;

+ (instancetype)taskWithResolverValueBlock:(void (^)(id value))resolve;
/// 创建一个已经完成的任务
/// @param resolveBlock
///    a. GTResolver 处理任务的结果
///       i. 参数1: {GTaskResult}
///          @warning: 当参数2为ATask时, 参数2任务的结果将作为新任务的结果
///          @type: GTaskResultProcess, 任务进度反馈block, 或者事件回调
///          @type: GTaskResultFulfilled, 任务处理成功
///          @type: GTaskResultRejected, 任务处理失败
///       ii. 参数2: {id}
///          @support: ATuple(...), 此中c的参数将被解析为回调block的参数
///          @support: id
/// @example
///   a. [GTask taskWithResolverBlock:^(GTResolver resolve) {
///           resolve(GTaskResultProcess, ATuple(@(GTaskResultRejected), @23));
///           resolve(GTaskResultFulfilled, @23);
///      }].process(^(GTaskResult result, NSNumber *data) {
///
///      }).then(^(NSNumber *result){
///
///      });
/// @return 一个已经完成的任务
+ (instancetype)taskWithResolverBlock:(void (^)(GTResolver))resolveBlock;
- (instancetype)initWithResolver:(GTResolver __strong __nonnull * __nonnull)resolver;

#pragma mark - Properties
///=============================================================================
/// @name 属性列表
///=============================================================================

/// 任务结果
/// @warning pending状态时, 值为空
@property (nonatomic, readonly) __nullable ResultType value;
/// 任务状态: 正在处理
@property (nonatomic, readonly) BOOL pending;
/// 任务状态: 处理成功
@property (nonatomic, readonly) BOOL fulfilled;
/// 任务状态: 处理失败
@property (nonatomic, readonly) BOOL rejected;
/// 任务状态: 任务取消
@property (nonatomic, readonly) BOOL cancel;

#pragma mark - Instance Functions
///=============================================================================
/// @name 实例方法
///=============================================================================

- (GTask *(^)(id))then;
- (GTask *(^)(dispatch_queue_t, id))thenOn;
- (GTask *(^)(dispatch_block_t))ensure;
- (GTask *(^)(dispatch_queue_t, dispatch_block_t))ensureOn;
- (GTask *(^)(id))catch;
- (GTask *(^)(dispatch_queue_t, id))catchOn;
- (GTask *(^)(id))process;

- (id)wait;

@end

// MARK: GTaskSource
////////////////////////////////////////////////////////////////////////////////
/// @@class GTaskSource
////////////////////////////////////////////////////////////////////////////////

///> 可以使用此方式, 亦可使用GTResolver
@interface GTaskSource<__covariant T> : NSObject
+ (instancetype)source;
///> 管理的任务
@property (nonatomic, strong, readonly) GTask<T> *task;
/// 完成任务
/// @param value 任务的结果
- (void)setResult:(T)value;
- (void)setResult:(T)value type:(GTaskResultType)type;
/// 任务进度
/// @param value 任务的结果
- (id)setProcess:(id)value;
@end

#ifdef __cplusplus
extern "C" {
#endif

/// 创建任务快捷方式
/// @param value 作为任务的结果
extern __attribute__((overloadable)) GTask *ATTask(id value);
extern __attribute__((overloadable)) GTask *ATTask(GTaskResultType, id value);

#ifdef __cplusplus
}   // Extern C
#endif

NS_ASSUME_NONNULL_END
