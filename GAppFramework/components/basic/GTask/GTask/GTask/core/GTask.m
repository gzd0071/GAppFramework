//
//  GTask.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/11/7.
//

#import "GTask.h"
#import "GTask+Private.h"

#pragma mark - GSealant
///=============================================================================
/// @name GSealant
///=============================================================================

@interface GSealant<R> : NSObject
///> 状态
@property (nonatomic, assign) _GTaskStatus status;
///> handlers
@property (nonatomic, strong) NSMutableArray<R> *bodies;
///> 结果
@property (nonatomic, strong) R value;
@end
@implementation GSealant
- (instancetype)initWithStatus:(_GTaskStatus)status {
    if (self = [super init]) {
        self.status = status;
        _bodies = @[].mutableCopy;
    }
    return self;
}
- (void)append:(id)item {
    [_bodies addObject:item];
}
- (void)resolved:(id)value result:(GTaskResultType)result {
    if (result == GTaskResultRejected) {
        self.status = _GTaskStatusRejected;
    } else if (result == GTaskResultFulfilled) {
        self.status = _GTaskStatusFulfilled;
    }
    self.value = value;
}
@end

#pragma mark - GEmptyBox
///=============================================================================
/// @name GEmptyBox
///=============================================================================

@protocol GBoxDelegate <NSObject>
- (GSealant *)inspect;
- (void)inspect:(void (^)(GSealant *))block;
- (void (^)(GTaskResultType, id))seal;
@end

@interface GEmptyBox<T> : NSObject<GBoxDelegate>
///>
@property (nonatomic, strong) GSealant<T> *sealant;
///>
@property (nonatomic, strong) dispatch_queue_t barrier;
@end
@implementation GEmptyBox
- (instancetype)init {
    if (self = [super init]) {
        _sealant = [[GSealant alloc] initWithStatus:_GTaskStatusPending];
        _barrier = dispatch_queue_create("org.atask.barrier", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}
/// 结果处理
- (void (^)(GTaskResultType, id))seal {
    return ^(GTaskResultType result, id value) {
        __block NSArray *handlers;
        dispatch_barrier_sync(self.barrier, ^{
            if (self.sealant.status != _GTaskStatusPending) return;
            handlers = self.sealant.bodies;
            self.sealant.bodies = @[].mutableCopy;
            [self.sealant resolved:value result:result];
        });
        [handlers enumerateObjectsUsingBlock:^(void (^obj)(id), NSUInteger idx, BOOL *stop) {
            obj(self.sealant);
        }];
    };
}
/// 获取当前状态
- (GSealant *)inspect {
    __block GSealant *rv;
    dispatch_sync(self.barrier, ^{
        rv = self.sealant;
    });
    return rv;
}
/// 当任务未完成时, 保存
- (void)inspect:(void (^)(GSealant *))block {
    __block BOOL sealed = NO;
    dispatch_barrier_sync(self.barrier, ^{
        if (self.sealant.status == _GTaskStatusPending) {
            block(self.sealant);
        } else { sealed = YES; }
    });
    if (sealed) block(self.sealant);
}
@end

@class __GTask;

@interface GTask () {
    __GTask *d;
}
- (__GTask *)d;
- (instancetype)initWith__D:(__GTask *)dd;
@end

// MARK: __GTask
////////////////////////////////////////////////////////////////////////////////
/// @@class __GTask
////////////////////////////////////////////////////////////////////////////////

@interface __GTask : NSObject
///> 任务: 任务周期管理者
@property (nonatomic, strong) GEmptyBox *box;
///> 任务: 进度Block
@property (nonatomic, copy) id proBlock;
@end
@implementation __GTask

/// 根据值类型判断任务的结果
+ (GTaskResultType)typeWithValue:(id)value {
    return [value isKindOfClass:NSError.class]?GTaskResultRejected:GTaskResultFulfilled;
}
/// 主要
- (instancetype)initWithResolver:(void (^)(GTResolver resolver))resolve {
    if (self = [super init]) {
        _box = [GEmptyBox new];
        resolve(^(GTaskResultType result, id value){
            if (result == GTaskResultProcess) {
                if (self.proBlock) ACallBlock(self.proBlock, value);
            } else if ([value isKindOfClass:GTask.class]) {
                GTask *p = (GTask *)value;
                [p.d pipe:^(_GTaskStatus status, id value) {
                    self.box.seal([__GTask typeWithValue:value], value);
                }];
            } else {
                self.box.seal(result, value);
            }
        });
    }
    return self;
}

- (void)pipe:(void (^)(_GTaskStatus, id))block {
    GSealant *sealant = self.box.inspect;
    if (sealant.status == _GTaskStatusPending) {
        [self.box inspect:^(GSealant *seal) {
            if (seal.status == _GTaskStatusPending) {
                [seal append:^(GSealant *obj){ block(obj.status, obj.value);}];
            } else {
                block(seal.status, seal.value);
            }
        }];
    } else {
        block(sealant.status, sealant.value);
    }
}

- (void)process:(id)excute {
    self.proBlock = excute;
}

- (GTask *)thenOn:(dispatch_queue_t)q excute:(id(^)(id))excute {
    __GTask *task = [[__GTask alloc] initWithResolver:^(GTResolver resolve) {
        [self pipe:^(_GTaskStatus status, id value) {
           if (status == _GTaskStatusFulfilled) {
               dispatch_block_t block = ^{
                   id svalue = excute(value);
                   resolve([__GTask typeWithValue:svalue], svalue);
               };
               q ? dispatch_async(q, block) : block();
           } else {
               resolve(GTaskResultRejected, value);
           }
       }];
    }];
    return [[GTask alloc] initWith__D:task];
}

- (GTask *)catchOn:(dispatch_queue_t)q excute:(id(^)(id))excute {
    __GTask *task = [[__GTask alloc] initWithResolver:^(GTResolver resolve) {
        [self pipe:^(_GTaskStatus status, id value) {
           if (status == _GTaskStatusRejected) {
               dispatch_async(q, ^{
                   id svalue = excute(value);
                   resolve([__GTask typeWithValue:svalue], svalue);
               });
           } else {
               resolve(GTaskResultFulfilled, value);
           }
       }];
    }];
    return [[GTask alloc] initWith__D:task];
}

- (GTask *)ensureOn:(dispatch_queue_t)q excute:(dispatch_block_t)excute {
    __GTask *task = [[__GTask alloc] initWithResolver:^(GTResolver resolve) {
        [self pipe:^(_GTaskStatus status, id value) {
           dispatch_async(q, ^{
               excute();
               GTaskResultType result = [value isKindOfClass:NSError.class] ? GTaskResultRejected : GTaskResultFulfilled;
               resolve(result, value);
           });
       }];
    }];
    return [[GTask alloc] initWith__D:task];
}
- (id)wait {
    if ([NSThread isMainThread]) {
        ///TODO: 添加警告日志
    }
    __block id result = [self getValue];
    if (!result) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        [self pipe:^(_GTaskStatus status, id value) {
            result = value;
            dispatch_group_leave(group);
        }];
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
    return result;
}
/// 线程安全
- (id)getValue {
    GSealant *seal = self.box.inspect;
    if (seal.status == _GTaskStatusRejected || seal.status == _GTaskStatusFulfilled) {
        return seal.value;
    }
    return nil;
}
@end

// MARK: ATask
////////////////////////////////////////////////////////////////////////////////
/// @@class ATask
////////////////////////////////////////////////////////////////////////////////

@implementation GTask

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

+ (instancetype)taskWithResolverValueBlock:(void (^)(id value))resolver {
    return [self taskWithResolverBlock:^(GTResolver _Nonnull resolve) {
        resolver(^(id value){
            resolve([__GTask typeWithValue:value], value);
        });
    }];
}
+ (instancetype)taskWithResolverBlock:(void (^)(GTResolver))resolveBlock {
    id d = [[__GTask alloc] initWithResolver:resolveBlock];
    return [[self alloc] initWith__D:d];
}
+ (instancetype)taskWithValue:(id)value {
    id d = [[__GTask alloc] initWithResolver:^(GTResolver resolve) {
        resolve([__GTask typeWithValue:value], value);
    }];
    return [[self alloc] initWith__D:d];
}
- (instancetype)initWithResolver:(GTResolver __strong *)resolver {
    if (self = [super init]) {
        d = [[__GTask alloc] initWithResolver:^(GTResolver resolve) {
            *resolver = resolve;
        }];
    }
    return self;
}

#pragma mark - Private
///=============================================================================
/// @name Private
///=============================================================================

/// 内部使用
- (id)d {
    return d;
}
- (instancetype)initWith__D:(__GTask *)dd {
    if (self = [super init]) { self->d = dd; }
    return self;
}
- (void)pipe:(void (^)(_GTaskStatus, id))block {
    [self->d pipe:^(_GTaskStatus status, id value) {
        block(status, value);
    }];
}

#pragma mark - Properties
///=============================================================================
/// @name Properties
///=============================================================================

- (id)value {
    id obj = d.box.inspect.value;
    if ([obj isKindOfClass:NSClassFromString(@"AMKArray")]) return obj[0];
    return obj;
}
- (BOOL)rejected {
    GSealant *seal = d.box.inspect;
    return seal.status == _GTaskStatusRejected;
}
- (BOOL)fulfilled {
    GSealant *seal = d.box.inspect;
    return seal.status == _GTaskStatusFulfilled;
}
- (BOOL)pending {
    GSealant *seal = d.box.inspect;
    return seal.status == _GTaskStatusPending;
}
- (BOOL)cancel {
    GSealant *seal = d.box.inspect;
    return seal.status == _GTaskStatusCancel;
}

#pragma mark - Functions
///=============================================================================
/// @name Functions
///=============================================================================
- (GTask *(^)(id))then {
    return ^(id block) {
        return [self->d thenOn:nil excute:^(id obj) {
            return ACallBlock(block, obj);
        }];
    };
}
- (GTask *(^)(dispatch_queue_t, id))thenOn {
    return ^(dispatch_queue_t q, id block) {
        return [self->d thenOn:q excute:^(id obj) {
            return ACallBlock(block, obj);
        }];
    };
}
- (GTask *(^)(id))catch {
    return ^(id block) {
        return [self->d catchOn:dispatch_get_main_queue() excute:^(id obj) {
            return ACallBlock(block, obj);
        }];
    };
}
- (GTask *(^)(dispatch_queue_t, id))catchOn {
    return ^(dispatch_queue_t q, id block) {
        return [self->d catchOn:q excute:^(id obj) {
            return ACallBlock(block, obj);
        }];
    };
}
- (GTask *(^)(dispatch_block_t))ensure {
    return ^(dispatch_block_t block) {
        return [self->d ensureOn:dispatch_get_main_queue() excute:block];
    };
}
- (GTask *(^)(dispatch_queue_t, dispatch_block_t))ensureOn {
    return ^(dispatch_queue_t q, dispatch_block_t block) {
        return [self->d ensureOn:q excute:block];
    };
}
- (GTask *(^)(id))process {
    return ^(id block) {
        [self->d process:block];
        return self;
    };
};
- (id)resolveProcess:(id)value {
    if (!(self->d).proBlock) return nil;
    return ACallBlock((self->d).proBlock, value);
}
- (id)wait {
    return [self->d wait];
}

@end

// MARK: GTaskSource
////////////////////////////////////////////////////////////////////////////////
/// @@class GTaskSource
////////////////////////////////////////////////////////////////////////////////

@interface GTaskSource ()
@property (nonatomic, copy) GTResolver resolver;
@end

@implementation GTaskSource

+ (instancetype)source {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        GTResolver resolver;
        _task = [[GTask alloc] initWithResolver:&resolver];
        _resolver = resolver;
    }
    return self;
}

- (void)setResult:(id)value type:(GTaskResultType)type {
    if (type == GTaskResultProcess) {
        [self setProcess:value];
    } else {
        _resolver(type, value);
    }
}

- (void)setResult:(id)value {
    GTaskResultType result = [__GTask typeWithValue:value];
    _resolver(result, value);
}

- (id)setProcess:(id)value {
    return [self.task resolveProcess:value];
}

@end

#pragma mark - Task
///=============================================================================
/// @name ATask
///=============================================================================

__attribute__((overloadable)) GTask *ATTask(id value) {
    return [GTask taskWithValue:value];
}
__attribute__((overloadable)) GTask *ATTask(GTaskResultType type, id value) {
    return [GTask taskWithResolverBlock:^(GTResolver resolve) {
        resolve(type, value);
    }];
}



