//
//  DMCallTrace.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/26.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMCallTraceModel : NSObject
/// 类名
@property (nonatomic, strong) NSString *className;
/// 方法名
@property (nonatomic, strong) NSString *methodName;
/// 是否是类方法
@property (nonatomic, assign) BOOL isClassMethod;
/// 时间消耗 单位s
@property (nonatomic, assign) NSTimeInterval timeCost;
/// Call层级
@property (nonatomic, assign) NSUInteger callDepth;
/// 路径
@property (nonatomic, copy) NSString *path;
/// 是否是最后一个触发
@property (nonatomic, assign) BOOL lastCall;
/// 访问频次
@property (nonatomic, assign) NSUInteger frequency;
///
@property (nonatomic, strong) NSArray <DMCallTraceModel *> *subCosts;

- (NSString *)des;
@end

@interface DMCallTrace : NSObject
///> 获取所有记录 
+ (NSArray<DMCallTraceModel *> *)loadRecords;
@end

NS_ASSUME_NONNULL_END
