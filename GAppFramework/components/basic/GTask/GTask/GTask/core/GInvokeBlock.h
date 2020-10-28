//
//  GInvokeBlock.h
//  ATask
//
//  Created by iOS_Developer_G on 2019/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

///> 元宏: 最多支持3个参数 
#define ATuple(...) __ATuple(__VA_ARGS__, 3, 2, 1)
#define __ATuple(_1, _2, _3, N, ...) __AMKArrayWithCount(N, _1, _2, _3)
extern id __nonnull __AMKArrayWithCount(NSUInteger, ...);

/// Block: 触发block
/// @param block 块的第一个参数支持自动转换; 支持的类型id, BOOL, 枚举, NSInteger, float
/// @param result 当result未ATuple宏包装的参数时, 会自动转换为block的参数
extern id ACallBlock(id block, id result);

#ifdef __cplusplus
}   // Extern C
#endif

NS_ASSUME_NONNULL_END
