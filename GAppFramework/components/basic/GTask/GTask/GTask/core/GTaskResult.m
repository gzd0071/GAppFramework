//
//  GTaskResult.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/15.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "GTaskResult.h"

@implementation GTaskResult
+ (instancetype)taskResultWithSuc:(BOOL)suc {
    return [[self alloc] initWithSuc:suc data:nil];
}
+ (instancetype)taskResultWithSuc:(BOOL)suc data:(id)data {
    return [[self alloc] initWithSuc:suc data:data];
}
- (instancetype)initWithSuc:(BOOL)suc data:(id)data {
    if (self = [super init]) {
        _suc = suc;
        _data = data;
    }
    return self;
}
@end


