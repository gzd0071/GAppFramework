//
//  DMStartExtra.m
//  GStart
//
//  Created by iOS_Developer_G on 2019/11/28.
//

#import "DMStartExtra.h"
#import <GTask/GTask.h>
#import <GTask/GTask+Fwd.h>
#import <DMEncrypt/DMEncrypt.h>
#import <AdSupport/AdSupport.h>
#import <GHttpRequest/HttpRequest.h>

@implementation DMStartExtra

+ (GTask *)task {
    dispatch_task(^{ [self uploadIDFA]; });
    return ATTask(@YES);
}

/// 上报IDFA信息
/// @warning 如设备未上报则需上报
/// 异步线程
+ (void)uploadIDFA {
    
}

@end
