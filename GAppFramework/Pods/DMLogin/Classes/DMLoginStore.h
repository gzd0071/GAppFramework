//
//  DMLoginStore.h
//  DMLogin
//
//  Created by zhangjiexin on 2019/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMLoginStore : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, strong) NSDictionary *loginSuccessData;

@end

NS_ASSUME_NONNULL_END
