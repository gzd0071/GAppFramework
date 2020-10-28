//
//  NSObject+Extend.h
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: Protocol: SZEnumerableCollection
////////////////////////////////////////////////////////////////////////////////
/// @@protocol SZEnumerableCollection
////////////////////////////////////////////////////////////////////////////////

@protocol SZEnumerableCollection <NSObject>
/// 返回可变对象
- (id)mutale;
/// 添加obj到可变对象
- (void)add:(id)obj mutable:(id)mut;
/// 返回不可变对象
- (id)immutable:(id)mutable;
@end

// MARK: Protocol: SZEnumerable
////////////////////////////////////////////////////////////////////////////////
/// @@protocol SZEnumerable
////////////////////////////////////////////////////////////////////////////////

@protocol SZEnumerable <NSObject>
- (NSEnumerator *)szEnumerator;
@end

// MARK: SZAssociation
////////////////////////////////////////////////////////////////////////////////
/// @@class SZAssociation
////////////////////////////////////////////////////////////////////////////////

/// NSDictionary
@interface SZAssociation : NSObject
@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;
@end

/// 作为NSNumber强化
@interface SZInterval : NSObject <SZEnumerable, SZEnumerableCollection>
@property (nonatomic, readonly) NSInteger from;
@property (nonatomic, readonly) NSInteger to;
@property (nonatomic, readonly) NSInteger by;
- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to by:(NSInteger)by;
@end


@interface NSObject (Extend)

#pragma mark - Enumerable
///=============================================================================
/// @name Enumerable
///=============================================================================

/// 快速迭代器
/// @return A NSEnumerator
- (NSEnumerator *)enumer;
/// All Satisfy.
/// @param block 块
/// @warning 当未有元素时, 默认返回YES;
/// @return 所有block返回值都为YES时, 返回YES; 否则返NO;
- (BOOL)allSatisfy:(BOOL (^)(id each))block;
/// Any Satisfy.
/// @param block 块
/// @warning 当未有元素时, 默认返回NO;
/// @return 当有任一block返回值都为YES时, 返回YES; 否则返NO;
- (BOOL)anySatisfy:(BOOL (^)(id each))block;
/// First Satisfy.
/// @warning 未有满足元素时返回nil;
/// @param block 块
/// @return 检测元素值, 返回第一个block返回值为YES的元素值;
- (id)detect:(BOOL (^)(id each))block;
/// Map.
/// @warning
///    a. 当block返回nil时, 会crash, map主要是保证进多少出多少
///    b. 返回的是个不可变对象
///    c. 如果是NSNumber类型, 返回的是个数组默认从0开始, 以1递增(如果需要, 可使用SZInterval)
/// @param block 块
/// @return 每个block返回值组成一个新的集合
- (id)map:(id (^)(id each))block;
/// Filter.
/// @param block 块
/// @return 剔除元素值中所有block返回NO的元素
- (id)filter:(BOOL (^)(id each))block;
/// Reduce.
/// @param block 块
/// @see reduce:block:
- (id)reduce:(id (^)(id acc, id each))block;
/// Reduce.
/// @param block 块
- (id)reduce:(nullable id)initial block:(id (^)(id acc, id each))block;
/// Each.
/// @param each 块
/// @see each:separate:
- (void)each:(void(^)(id each, NSUInteger idx, BOOL *stop))each;
- (void)each:(void(^)(id each, NSUInteger idx, BOOL *stop))each separate:(nullable void (^)(void))separate;
@end

NS_ASSUME_NONNULL_END
