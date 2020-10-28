//
//  NSArray+Extend.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/10/22.
//

#import "NSArray+Extend.h"
#import <YYKit/NSArray+YYAdd.h>

@implementation NSArray (Extend)
- (NSString *)jsonString {
    return [self jsonStringEncoded];
}
- (NSArray *)map:(id(^)(id each))block {
    NSMutableArray *mut = @[].mutableCopy;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id result = block(obj);
        if (result) [mut addObject:result];
    }];
    return mut.copy;
}
- (id)detect:(BOOL (^)(id each))block {
    __block id robj;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL suc = block(obj);
        if (!suc) return;
        *stop = YES;
        robj = obj;
    }];
    return robj;
}
@end
