//
//  DMSUniqueDataManager.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * 利用内存缓存, NSUserDefault, SAMKeychain
 * 保存与设备绑定的唯一的数据
 */
@interface DMSUniqueDataManager : NSObject

+ (BOOL)setObject:(NSString *)value forKey:(NSString *)key;
+ (NSString *)getObjectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
