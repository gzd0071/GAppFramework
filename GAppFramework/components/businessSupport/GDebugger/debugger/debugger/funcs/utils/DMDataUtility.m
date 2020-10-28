//
//  DMDataUtility.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/28.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDataUtility.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <zlib.h>

static NSString *gDMRootDirectoryName = @"/com.doumi.app";

@implementation DMDataUtility

+ (double)currentTime {
    struct timeval t0;
    gettimeofday(&t0, NULL);
    return t0.tv_sec + t0.tv_usec * 1e-6;
}

+ (NSTimeInterval)appLaunchedTime {
    static NSTimeInterval appLaunchedTime;
    if (appLaunchedTime == 0.f) {
        struct kinfo_proc procInfo;
        size_t structSize = sizeof(procInfo);
        int mib[] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
        
        if (sysctl(mib, sizeof(mib) / sizeof(*mib), &procInfo, &structSize, NULL, 0) != 0) {
            NSLog(@"sysctrl failed");
            appLaunchedTime = [[NSDate date] timeIntervalSince1970];
        } else {
            struct timeval t = procInfo.kp_proc.p_un.__p_starttime;
            appLaunchedTime = t.tv_sec + t.tv_usec * 1e-6;
        }
    }
    return appLaunchedTime;
}

+ (NSString *)storeDirectory {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:gDMRootDirectoryName];}

+ (NSString *)currentStoreDirectoryNameFormat {
    return @"yyyy-MM-dd_HH-mm-ss+SSS";
}

+ (NSString *)currentStorePath {
    static dispatch_once_t onceToken;
    static NSString *storeDirectory;
    dispatch_once(&onceToken, ^{
        NSString *hawkeyePath = [DMDataUtility storeDirectory];
        NSTimeInterval appLaunchedTime = [DMDataUtility appLaunchedTime];
        NSDate *launchedDate = [NSDate dateWithTimeIntervalSince1970:appLaunchedTime];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[self currentStoreDirectoryNameFormat]];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *formattedDateString = [dateFormatter stringFromDate:launchedDate];
        
        storeDirectory = [hawkeyePath stringByAppendingPathComponent:formattedDateString];
    });
    return storeDirectory;
}

@end
