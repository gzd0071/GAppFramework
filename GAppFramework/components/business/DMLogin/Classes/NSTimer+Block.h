//
//  NSTimer+Block.h
//  DMLogin
//
//  Created by NonMac on 2019/6/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (Block)

+ (NSTimer *)block_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                            block:(void(^)(NSTimer *))block
                                          repeats:(BOOL)repeats;

@end

NS_ASSUME_NONNULL_END
