//
//  NSObject+Extend.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/11/30.
//

#import "NSObject+Extend.h"


@implementation NSObject (Extend)

- (NSEnumerator *)enumer {
    if ([self conformsToProtocol:@protocol(SZEnumerable)]) {
        return [(id<SZEnumerable>)self szEnumerator];
    }
    return nil;
}

#pragma mark - Algorithms correlation
///=============================================================================
/// @name 计算相关
///=============================================================================

- (BOOL)allSatisfy:(BOOL (^)(id each))block {
    NSEnumerator *enumerator = [self enumer];
    if (!enumerator) return block(self);
    for (id each in enumerator) {
        if (!block(each)) return NO;
    }
    return YES;
}

- (BOOL)anySatisfy:(BOOL (^)(id each))block {
    NSEnumerator *enumerator = [self enumer];
    if (!enumerator) return block(self);
    for (id each in enumerator) {
        if (block(each)) return YES;
    }
    return NO;
}

- (id)detect:(BOOL (^)(id each))block {
    NSEnumerator *enumerator = [self enumer];
    if (!enumerator) return block(self) ? self : nil;
    for (id each in enumerator) {
        if (block(each)) return each;
    }
    return nil;
}

- (id)map:(id (^)(id each))block {
    NSEnumerator *enumerator = [self enumer];
    if (!enumerator || ![self conformsToProtocol:@protocol(SZEnumerableCollection)])
        return block(self);
    id<SZEnumerableCollection> this = (id<SZEnumerableCollection>)self;
    id mut = [this mutale];
    for (id each in enumerator) {
        [this add:block(each) mutable:mut];
    }
    return [this immutable:mut];
}

- (id)filter:(BOOL (^)(id each))block {
    NSEnumerator *enumerator = [self enumer];
    if (!enumerator || ![self conformsToProtocol:@protocol(SZEnumerableCollection)])
        return block(self) ? self : nil;
    id<SZEnumerableCollection> this = (id<SZEnumerableCollection>)self;
    id mut = [this mutale];
    for (id each in enumerator) {
        if (block(each)) [this add:each mutable:mut];
    }
    return [this immutable:mut];
}

- (id)reduce:(id (^)(id accumulator, id each))block {
    return [self reduce:nil block:block];
}

- (id)reduce:(id)initial block:(id (^)(id acc, id each))block {
    NSEnumerator *enumerator = [self enumer];
    if (!enumerator) return block(initial, self);
    id acc = initial;
    for (id each in enumerator) {
        acc = block(acc, each);
    }
    return acc;
}

- (void)each:(void(^)(id each, NSUInteger idx, BOOL *stop))block {
    return [self each:block separate:nil];
}
- (void)each:(void(^)(id each, NSUInteger idx, BOOL *stop))block separate:(void (^)(void))separate {
    NSEnumerator *enumer = [self enumer];
    BOOL stop;
    if (!enumer) block(self, 0, &stop);
    NSUInteger idx = 0;
    for (id each in enumer) {
        if (idx>0 && separate) separate();
        block(each, idx, &stop);
        if (stop) return;
        idx++;
    }
}

- (id)first {
    NSEnumerator *enumerator = [self enumer];
    if (!enumerator) return self;
    for (id each in enumerator) {
        return each;
    }
    return nil;
}

- (id)fist:(NSUInteger)count {
    return self;
}

@end

#pragma mark - Enumeration Support
///=============================================================================
/// @name Enumeration Support
///=============================================================================

@implementation SZAssociation
- (instancetype)initWithKey:(id)key value:(id)value {
    if (self = [super init]) {
        _key = key;
        _value = value;
    }
    return self;
}
@end

@implementation NSObject (OCAssociationSupport)
- (SZAssociation *)asAssociationWithKey:(id)key {
    return [[SZAssociation alloc] initWithKey:key value:self];
}
- (SZAssociation *)asAssociationWithValue:(id)value {
    return [[SZAssociation alloc] initWithKey:self value:value];
}
@end

#pragma mark - Enumerators
///=============================================================================
/// @name Enumerators
///=============================================================================

/// 迭代器: SZAssociation
@interface SZAssociationEnumerator : NSEnumerator
@property (nonatomic, readonly) NSDictionary *backingDictionary;
@property (nonatomic, readonly) NSEnumerator *keyEnumerator;
@end

@implementation SZAssociationEnumerator
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _backingDictionary = dictionary;
        _keyEnumerator = [_backingDictionary keyEnumerator];
    }
    return self;
}
- (id)nextObject {
    id nextKey = [self.keyEnumerator nextObject];
    if (!nextKey) return nil;
    id nextValue = [self.backingDictionary objectForKey:nextKey];
    return [nextKey asAssociationWithValue:nextValue];
}
@end

/// 迭代器: SZCharacter
@interface SZCharacterEnumerator : NSEnumerator
@property (nonatomic, readonly) NSString *backingString;
@property (nonatomic, readwrite) NSUInteger currentIndex;
@end
@implementation SZCharacterEnumerator
- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        _backingString = string;
        _currentIndex = 0;
    }
    return self;
}
- (id)nextObject {
    if (self.currentIndex >= self.backingString.length) return nil;
    id current = [self.backingString substringWithRange:NSMakeRange(self.currentIndex, 1)];
    self.currentIndex++;
    return current;
}
@end

/// 迭代器: SZInterval
@interface SZIntervalEnumerator : NSEnumerator
@property (nonatomic, readonly) SZInterval *interval;
@property (nonatomic, readwrite) NSInteger index;
@end
@implementation SZIntervalEnumerator
- (instancetype)initWithInterval:(SZInterval *)interval {
    if (self = [super init]) { _interval = interval; _index = 0; } return self;
}
- (NSInteger)size {
    if (self.interval.by == 0) return 0;
    if (self.interval.by < 0) {
        if (self.interval.from < self.interval.to) {
            return 0;
        } else {
            return (self.interval.to - self.interval.from) / self.interval.by + 1;
        }
    } else {
        if (self.interval.to < self.interval.from) {
            return 0;
        } else {
            return (self.interval.to - self.interval.from) / self.interval.by + 1;
        }
    }
}
- (id)nextObject {
    if (self.index > ([self size] - 1)) return nil;
    return @(self.interval.from + (self.interval.by * self.index++));
}
@end

/// 迭代器: SZMapTable
@interface SZMapTableEnumerator : NSEnumerator
@property (nonatomic, readonly) NSMapTable *mapTable;
@property (nonatomic, readonly) NSEnumerator *keyEnumerator;
@end
@implementation SZMapTableEnumerator
- (instancetype)initWithMapTable:(NSMapTable *)mapTable {
    if (self = [super init]) {
        _mapTable = mapTable;
        _keyEnumerator = [_mapTable keyEnumerator];
    }
    return self;
}
- (id)nextObject {
    id nextKey = [self.keyEnumerator nextObject];
    if (!nextKey) return nil;
    id nextValue = [self.mapTable objectForKey:nextKey];
    return [nextKey asAssociationWithValue:nextValue];
}
@end

@interface SZNullEnumerator : NSEnumerator @end
@implementation SZNullEnumerator
- (id)nextObject { return nil; }
@end

#pragma mark - Instance Support
///=============================================================================
/// @name Instance Support
///=============================================================================

@implementation SZInterval
- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to by:(NSInteger)by {
    if (self = [super init]) { _from = from; _to = to; _by = by; } return self;
}
- (id)mutale { return [NSMutableArray array]; }
- (id)immutable:(id)mutable { return [NSArray arrayWithArray:mutable]; }
- (void)add:(id)obj mutable:(id)mut { [mut addObject:obj];}
- (NSEnumerator *)szEnumerator { return [[SZIntervalEnumerator alloc] initWithInterval:self]; }
@end

@interface NSArray (SZEnumeration) <SZEnumerable, SZEnumerableCollection>
@end
@implementation NSArray (SZEnumeration)
- (id)mutale { return [NSMutableArray array]; }
- (id)immutable:(id)mutable { return [self.class arrayWithArray:mutable]; }
- (void)add:(id)obj mutable:(id)mut { [mut addObject:obj]; }
- (NSEnumerator *)szEnumerator { return [self objectEnumerator]; }
@end

@interface NSDictionary (SZEnumeration) <SZEnumerable, SZEnumerableCollection>
@end
@implementation NSDictionary (SZEnumeration)
- (id)mutale { return [NSMutableDictionary dictionary]; }
- (id)immutable:(id)mutable { return [self.class dictionaryWithDictionary:mutable]; }
- (void)add:(id)obj mutable:(id)mut { SZAssociation *as = obj; [mut setObject:as.value forKey:as.key]; }
- (NSEnumerator *)szEnumerator { return [[SZAssociationEnumerator alloc] initWithDictionary:self]; }
@end

@interface NSHashTable (SZEnumeration) <SZEnumerable, SZEnumerableCollection>
@end
@implementation NSHashTable (SZEnumeration)
- (id)mutale { return [[NSHashTable alloc] initWithPointerFunctions:self.pointerFunctions capacity:self.count]; }
- (id)immutable:(id)mutable { return mutable; }
- (void)add:(id)obj mutable:(id)mut { [mut addObject:obj]; }
- (NSEnumerator *)szEnumerator { return [self objectEnumerator]; }
@end

@interface NSMapTable (SZEnumeration) <SZEnumerable, SZEnumerableCollection>
@end
@implementation NSMapTable (SZEnumeration)
- (id)mutale { return [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count]; }
- (id)immutable:(id)mutable { return mutable; }
- (void)add:(id)obj mutable:(id)mut { SZAssociation *as = obj; [mut setObject:as.value forKey:as.key]; }
- (NSEnumerator *)szEnumerator { return [[SZMapTableEnumerator alloc] initWithMapTable:self]; }
@end

@interface NSNull (SZEnumeration) <SZEnumerable>
@end
@implementation NSNull (SZEnumeration)
- (NSEnumerator *)szEnumerator { return [SZNullEnumerator new]; }
@end

@interface NSNumber (SZEnumeration) <SZEnumerable, SZEnumerableCollection>
@end
@implementation NSNumber (SZEnumeration)
- (NSEnumerator *)szEnumerator {
    return [[SZIntervalEnumerator alloc] initWithInterval:[[SZInterval alloc] initWithFrom:0 to:self.integerValue by:1]];
}
- (id)mutale { return [NSMutableArray array]; }
- (id)immutable:(id)mutable { return [NSArray arrayWithArray:mutable]; }
- (void)add:(id)obj mutable:(id)mut { [mut addObject:obj];}
@end

@interface NSPointerArray (SZEnumeration) <SZEnumerable, SZEnumerableCollection>
@end
@implementation NSPointerArray (SZEnumeration)
- (id)mutale { return [NSPointerArray pointerArrayWithPointerFunctions:self.pointerFunctions]; }
- (id)immutable:(id)mutable { return mutable; }
- (void)add:(id)obj mutable:(id)mut { [self addPointer:(__bridge void *)obj]; }
- (NSEnumerator *)szEnumerator { return [self.allObjects objectEnumerator]; }
@end

@interface NSSet (SZEnumeration) <SZEnumerable, SZEnumerableCollection>
@end
@implementation NSSet (SZEnumeration)
- (id)mutale { return [NSMutableSet set]; }
- (id)immutable:(id)mutable { return [self.class setWithSet:mutable]; }
- (void)add:(id)obj mutable:(id)mut { [mut addObject:obj]; }
- (NSEnumerator *)szEnumerator { return [self objectEnumerator]; }
@end

@interface NSString (SZEnumeration) <SZEnumerable, SZEnumerableCollection>
@end
@implementation NSString (SZEnumeration)
- (id)mutale { return [NSMutableString stringWithString:@""]; }
- (id)immutable:(id)mutable {
    if ([mutable isKindOfClass:NSMutableString.class]) {
        return [mutable copy];
    }
    return mutable;
}
- (void)add:(id)obj mutable:(id)mut { [mut appendString:obj]; }
- (NSEnumerator *)szEnumerator { return [[SZCharacterEnumerator alloc] initWithString:self]; }
@end
