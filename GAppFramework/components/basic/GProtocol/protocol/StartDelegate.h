//
//  StartDelegate.h
//  GProtocol
//
//  Created by iOS_Developer_G on 2019/10/12.
//

#import <Foundation/Foundation.h>

@class GTask;

NS_ASSUME_NONNULL_BEGIN

///> 启动协议 
@protocol StartDelegate <NSObject>
///> 任务 
+ (GTask *)task;
@end

NS_ASSUME_NONNULL_END
