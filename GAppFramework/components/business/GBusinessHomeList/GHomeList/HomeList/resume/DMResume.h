//
//  DMResume.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/7/9.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/NSObject+YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMResume : NSObject<YYModel>
///> 性别 
@property (nonatomic, strong) NSString *sex;
///> 身份要求 
@property (nonatomic, strong) NSString *identity;
///> 赋值结束 
@property (nonatomic, strong) NSString *done;
+ (instancetype)share;
- (void)update;
@end

NS_ASSUME_NONNULL_END
