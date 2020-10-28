//
//  BLogin.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/9/7.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GProtocol/StartDelegate.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UserType) {
    UserTypeUnknown  = 0,     // 身份未知
    UserTypeStaff,            // 求职者
    UserTypeEmployee          // 雇员
};

////////////////////////////////////////////////////////////////////////////////
/// @@class DMUserModel
////////////////////////////////////////////////////////////////////////////////
@interface DMUserModel : NSObject
///> 用户: 登录状态
@property (nonatomic, assign) BOOL isLogin;
///> 用户: ID
@property (nonatomic, strong, nullable) NSString *userId;
///> 用户: 手机好
@property (nonatomic, strong, nullable) NSString *mobile;
///> 用户: 昵称
@property (nonatomic, strong, nullable) NSString *nickName;
///> 用户: 真实名称
@property (nonatomic, strong, nullable) NSString *realName;
///> 用户: 角色类型
@property (nonatomic, assign) UserType type;

///> 单例 
+ (instancetype)user;
- (void)logout;
- (void)updateType:(UserType)type;
@end

////////////////////////////////////////////////////////////////////////////////
/// @@class DMLoginConfig
////////////////////////////////////////////////////////////////////////////////
@interface BLogin : NSObject<StartDelegate>
@end

NS_ASSUME_NONNULL_END
