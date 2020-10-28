//
//  DMCarton.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/26.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMCarton.h"
#import "DMCallStack.h"

#define STUCKMONITORRATE 88



@interface DMCarton (){
    int timeoutCount;
    CFRunLoopObserverRef observer;
@public
    dispatch_semaphore_t sem;
    CFRunLoopActivity runLoopActivity;
}
@end

@implementation DMCarton

+ (void)load {
    [[DMCarton new] startMonitor];
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    DMCarton *carton = (__bridge DMCarton *)info;
    carton->runLoopActivity = activity;
    
    dispatch_semaphore_t semaphore = carton->sem;
    dispatch_semaphore_signal(semaphore);
}

- (void)startMonitor {
    sem =  dispatch_semaphore_create(0);
    //创建一个观察者
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                        kCFRunLoopAllActivities,
                                        YES,
                                        0,
                                        &runLoopObserverCallBack,
                                        &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //子线程开启一个持续的loop用来进行监控
        while (YES) {
            long wait = dispatch_semaphore_wait(self->sem, dispatch_time(DISPATCH_TIME_NOW, STUCKMONITORRATE * NSEC_PER_MSEC));
            if (wait != 0) {
                if (!self->observer) {
                    self->timeoutCount = 0;
                    self->sem = 0;
                    self->runLoopActivity = 0;
                    return;
                }
                //两个runloop的状态，BeforeSources和AfterWaiting这两个状态区间时间能够检测到是否卡顿
                if (self->runLoopActivity == kCFRunLoopBeforeSources || self->runLoopActivity == kCFRunLoopAfterWaiting) {
                    if (++self->timeoutCount < 3) {
                        continue;
                    }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        NSString *stackStr = [DMCallStack callStackWithType:DMCallStackTypeMain];
//                        SMCallStackModel *model = [[SMCallStackModel alloc] init];
//                        model.stackStr = stackStr;
//                        model.isStuck = YES;
//                        [[[SMLagDB shareInstance] increaseWithStackModel:model] subscribeNext:^(id x) {}];
                        NSLog(@"\n==>%@", stackStr);
                    });
                }
            }
            self->timeoutCount = 0;
        }
    });
}

- (void)endMonitor {
    if (!observer) {
        return;
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    observer = NULL;
}



@end
