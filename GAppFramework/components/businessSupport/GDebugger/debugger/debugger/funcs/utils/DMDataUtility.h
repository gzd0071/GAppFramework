//
//  DMDataUtility.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/28.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMDataUtility : NSObject

///> App启动时间 
+ (NSTimeInterval)appLaunchedTime;

///> Hawkeye Cache Files Root: default /Document/com.meitu.hawkeye/, see gMTHawkeyeStoreDirectoryRoot for detail 
+ (NSString *)storeDirectory;
///> yyyy-MM-dd_HH:mm:ss+SSS 
+ (NSString *)currentStoreDirectoryNameFormat;
+ (NSString *)currentStorePath;

@end

NS_ASSUME_NONNULL_END
