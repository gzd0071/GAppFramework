//
//  GInvokeBlock.m
//  ATask
//
//  Created by iOS_Developer_G on 2019/11/26.
//

#import "GInvokeBlock.h"

#import <Foundation/NSMethodSignature.h>

/// @see PromiseKit
struct ABlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;    // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
};

typedef NS_OPTIONS(NSUInteger, ABlockDescriptionFlags) {
    ABlockDescriptionFlagsHasCopyDispose = (1 << 25),
    ABlockDescriptionFlagsHasCtor        = (1 << 26), // helpers have C++ code
    ABlockDescriptionFlagsIsGlobal       = (1 << 28),
    ABlockDescriptionFlagsHasStret       = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    ABlockDescriptionFlagsHasSignature   = (1 << 30)
};

static NSMethodSignature *AMethodSignatureForBlock(id block) {
    if (!block) return nil;
    struct ABlockLiteral *blockRef = (__bridge struct ABlockLiteral *)block;
    ABlockDescriptionFlags flags = (ABlockDescriptionFlags)blockRef->flags;
    if (flags & ABlockDescriptionFlagsHasSignature) {
        void *signatureLocation = blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);

        if (flags & ABlockDescriptionFlagsHasCopyDispose) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }
        const char *signature = (*(const char **)signatureLocation);
        return [NSMethodSignature signatureWithObjCTypes:signature];
    }
    return 0;
}

@interface AMKArray : NSObject {
@public
    id objs[3];
    NSUInteger count;
} @end

@implementation AMKArray
- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    if (count <= idx) return nil;
    return objs[idx];
}
@end

id __AMKArrayWithCount(NSUInteger count, ...) {
    AMKArray *this = [AMKArray new];
    this->count = count;
    va_list args;
    va_start(args, count);
    for (NSUInteger x = 0; x < count; ++x)
        this->objs[x] = va_arg(args, id);
    va_end(args);
    return this;
}

static inline id _ACallVariadicBlock(id frock, id result) {
    NSCAssert(frock, @"");
    NSMethodSignature *sig = AMethodSignatureForBlock(frock);
    const NSUInteger nargs = sig.numberOfArguments;
    const char rtype = sig.methodReturnType[0];
    if (nargs >= 2) {
        const char ftype = *[sig getArgumentTypeAtIndex:1];
        if (ftype == 'd') {
            
        }
    }
    #define call_block_with_rtype(type) ({^type{ \
        switch (nargs) { \
            case 1: \
                return ((type(^)(void))frock)(); \
            case 2: { \
                const id arg = [result class] == [AMKArray class] ? result[0] : result; \
                const char ftype = *[sig getArgumentTypeAtIndex:1]; \
                if (ftype == 'q' || ftype == 'Q') { \
                    return ((type(^)(NSInteger))frock)([arg integerValue]); \
                } else if (ftype == 'B') { \
                    return ((type(^)(BOOL))frock)([arg boolValue]); \
                } else if (ftype == 'f' || ftype == 'd') { \
                    return ((type(^)(float))frock)([arg floatValue]); \
                } \
                return ((type(^)(id))frock)(arg); \
            } \
            case 3: { \
                const char ftype = *[sig getArgumentTypeAtIndex:1]; \
                if (ftype == 'q' || ftype == 'Q') { \
                    type (^block)(NSInteger, id) = frock; \
                    return [result class] == [AMKArray class] \
                    ? block([result[0] integerValue], result[1]) \
                    : block([result integerValue], nil); \
                } else if (ftype == 'B') { \
                    type (^block)(BOOL, id) = frock; \
                    return [result class] == [AMKArray class] \
                    ? block([result[0] boolValue], result[1]) \
                    : block([result boolValue], nil); \
                } else if (ftype == 'f' || ftype == 'd') { \
                    type (^block)(float, id) = frock; \
                    return [result class] == [AMKArray class] \
                    ? block([result[0] floatValue], result[1]) \
                    : block([result floatValue], nil); \
                } \
                type (^block)(id, id) = frock; \
                return [result class] == [AMKArray class] \
                    ? block(result[0], result[1]) \
                    : block(result, nil); \
            } \
            case 4: { \
                const char ftype = *[sig getArgumentTypeAtIndex:1]; \
                if (ftype == 'q' || ftype == 'Q') { \
                    type (^block)(NSInteger, id, id) = frock; \
                    return [result class] == [AMKArray class] \
                    ? block([result[0] integerValue], result[1], result[2]) \
                    : block([result integerValue], nil, nil); \
                } else if (ftype == 'B') { \
                    type (^block)(BOOL, id, id) = frock; \
                    return [result class] == [AMKArray class] \
                    ? block([result[0] boolValue], result[1], result[2]) \
                    : block([result boolValue], nil, nil); \
                } else if (ftype == 'f' || ftype == 'd') { \
                    type (^block)(float, id, id) = frock; \
                    return [result class] == [AMKArray class] \
                    ? block([result[0] floatValue], result[1], result[2]) \
                    : block([result floatValue], nil, nil); \
                } \
                type (^block)(id, id, id) = frock; \
                return [result class] == [AMKArray class] \
                    ? block(result[0], result[1], result[2]) \
                    : block(result, nil, nil); \
            } \
            default: \
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"ATaskKit: The provided block’s argument count is unsupported." userInfo:nil]; \
        }}();})

    switch (rtype) {
        case 'v':
            call_block_with_rtype(void);
            return nil;
        case '@':
            return call_block_with_rtype(id) ?: nil;
        case '*': {
            char *str = call_block_with_rtype(char *);
            return str ? @(str) : nil;
        }
        case 'c': return @(call_block_with_rtype(char));
        case 'i': return @(call_block_with_rtype(int));
        case 's': return @(call_block_with_rtype(short));
        case 'l': return @(call_block_with_rtype(long));
        case 'q': return @(call_block_with_rtype(long long));
        case 'C': return @(call_block_with_rtype(unsigned char));
        case 'I': return @(call_block_with_rtype(unsigned int));
        case 'S': return @(call_block_with_rtype(unsigned short));
        case 'L': return @(call_block_with_rtype(unsigned long));
        case 'Q': return @(call_block_with_rtype(unsigned long long));
        case 'f': return @(call_block_with_rtype(float));
        case 'd': return @(call_block_with_rtype(double));
        case 'B': return @(call_block_with_rtype(_Bool));
        case '^':
            if (strcmp(sig.methodReturnType, "^v") == 0) {
                call_block_with_rtype(void);
                return nil;
            }
        default:
            @throw [NSException exceptionWithName:@"ATaskKit" reason:@"ATaskKit: Unsupported method signature." userInfo:nil];
    }
}

id ACallBlock(id frock, id result) {
    @try {
        return _ACallVariadicBlock(frock, result);
    } @catch (id thrown) {
        if ([thrown isKindOfClass:[NSString class]])
            return thrown;
        if ([thrown isKindOfClass:[NSError class]])
            return thrown;
        @throw thrown;
    }
}
