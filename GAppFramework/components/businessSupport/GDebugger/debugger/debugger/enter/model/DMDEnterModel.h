//
//  DMDEnterModel.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DebuggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMDEnterModel : NSObject
///> 标题 
@property (nonatomic, copy) NSString *title;
///> 功能 
@property (nonatomic, strong) NSArray<Class<DebuggerPluginDelegate>> *plugins;
@end

NS_ASSUME_NONNULL_END
