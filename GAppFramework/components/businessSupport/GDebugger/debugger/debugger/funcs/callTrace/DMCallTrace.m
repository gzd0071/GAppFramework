//
//  DMCallTrace.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/26.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMCallTrace.h"
#import "DMCallTraceCore.h"
#import <objc/runtime.h>

@implementation DMCallTraceModel
- (NSString *)des {
    NSMutableString *str = [NSMutableString new];
    [str appendFormat:@"%6.2fms|", _timeCost * 1000.0];
    for (NSUInteger i = 0; i < _callDepth; i++) {
        [str appendString:@"  "];
    }
    [str appendFormat:@"%s[%@ %@]", (_isClassMethod ? "+" : "-"), _className, _methodName];
    return str;
}

- (NSString *)description {
    return [self des];
}

@end


@implementation DMCallTrace

+ (void)load {
//    [self start];
}

+ (void)start {
    DMCallConfigMaxDepth(20);
    DMCallConfigMinTime(1000);
    DMCallTraceStart();
}

#pragma mark -
///=============================================================================
/// @name
///=============================================================================

+ (NSArray<DMCallTraceModel *> *)loadRecords {
    NSMutableArray<DMCallTraceModel *> *arr = [NSMutableArray new];
    int num = 0;
    DMCallRecord *records = DMGetCallRecords(&num);
    for (int i = 0; i < num; i++) {
        DMCallRecord *rd = &records[i];
        DMCallTraceModel *model = [DMCallTraceModel new];
        model.className = NSStringFromClass(rd->cls);
        model.methodName = NSStringFromSelector(rd->sel);
        model.isClassMethod = class_isMetaClass(rd->cls);
        model.timeCost = (double)rd->time / 1000000.0;
        model.callDepth = rd->depth;
        [arr addObject:model];
    }
    NSUInteger count = arr.count;
    NSMutableArray *result = @[].mutableCopy;
    for (NSUInteger i = 0; i < count; i++) {
        DMCallTraceModel *top = result.lastObject;
        DMCallTraceModel *model = arr[i];
        while (top && top.callDepth > model.callDepth) {
            NSMutableArray *sub = model.subCosts ? [model.subCosts mutableCopy] : @[].mutableCopy;
            [sub insertObject:top atIndex:0];
            model.subCosts = [sub copy];
            [result removeLastObject];
            
            top = result.lastObject;
        }
        [result addObject:model];
    }
    return [result copy];
}

@end
