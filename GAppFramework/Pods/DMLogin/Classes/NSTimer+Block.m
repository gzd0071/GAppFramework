//
//  NSTimer+Block.m
//  DMLogin
//
//  Created by NonMac on 2019/6/5.
//

#import "NSTimer+Block.h"

@implementation NSTimer (Block)

+ (NSTimer *)block_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                              block:(void(^)(NSTimer *))block
                                            repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:self
                                          selector:@selector(private_blockInvoke:)
                                          userInfo:[block copy]
                                           repeats:repeats];
}

+ (void)private_blockInvoke:(NSTimer *)timer {
    void (^block)(NSTimer *) = timer.userInfo;
    if(block) {
        block(timer);
    }
}

@end
