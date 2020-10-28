//
//  GStartManager.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/10.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * 启动逻辑
 */
@interface GStartManager : NSObject
+ (void)startLogical:(nullable NSDictionary *)launchOptions;
@end

NS_ASSUME_NONNULL_END
