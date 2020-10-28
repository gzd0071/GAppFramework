//
//  DMCallStack.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/26.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMCallHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DMCallStackType) {
    /// 全部线程
    DMCallStackTypeAll,
    /// 主线程
    DMCallStackTypeMain,
    /// 当前线程
    DMCallStackTypeCurrent
};

@interface DMCallStack : NSObject

///> 获取某线程的栈信息 
+ (NSString *)callStackWithType:(DMCallStackType)type;

/*!
 * 获取莫线程的栈信息
 */
extern NSString *DMStackOfThread(thread_t thread);

@end

NS_ASSUME_NONNULL_END
