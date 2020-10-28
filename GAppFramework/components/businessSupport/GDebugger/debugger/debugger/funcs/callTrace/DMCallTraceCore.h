//
//  DMCallTraceCore.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/26.
//  Copyright © 2019 doumi. All rights reserved.
//

#ifndef DMCallTraceCore_h
#define DMCallTraceCore_h

#include <stdio.h>
#include <objc/objc.h>

/// 方法触发信息 结构体
typedef struct {
    /// 类
    __unsafe_unretained Class cls;
    /// 方法
    SEL sel;
    /// 耗时(单位: 微秒us)
    uint64_t time;
    /// 深度
    int depth;
} DMCallRecord;

#pragma mark - Functions
///=============================================================================
/// @name Functions
///=============================================================================

///> 开始 
extern void DMCallTraceStart(void);
///> 结束 
extern void DMCallTraceStop(void);
///> 获取记录 
extern DMCallRecord *DMGetCallRecords(int *num);
///> 清除 
extern void DMClearCallRecords(void);

///> 配置: 设置方法最小耗时, 默认为1000us 
extern void DMCallConfigMinTime(uint64_t us);
///> 配置: 设置方法最大深度, 默认为3 
extern void DMCallConfigMaxDepth(int depth);

#endif
