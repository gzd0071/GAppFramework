//
//  DMSMSValidationViewController.h
//  c_doumi
//
//  Created by tangjun on 2018/11/22.
//  Copyright © 2018年 GAppFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DMLoginDefine.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DMLSMSDelegate <NSObject>
@optional

//- (void)guideResumeBackButtonClicked:(UIButton *)btn;
//- (void)guideResumeDidInputSMSCode;
//- (void)userCenterDidInputSMSCode; //没有登录个人中心点击登录----》输入手机号点击获取验证码---》到本页验证码输入完后的操作
//- (void)userCenterDidInputSMSCode:(NSString *)code;

@end

@interface DMLSMSVCConfig : NSObject

@property (nonatomic, copy) void(^ reqVerifyCode)(NSString *phone, NSString *type, NSString *smsType, successBlock sBlock, failBlock fBlock);
@property (nonatomic, copy) void(^ SMSVCBackClicked)(void);
@property (nonatomic, copy) void(^ fromUserCenterDidFinishSMSCode)(NSString *code);
@property (nonatomic, copy) void(^ didFinishSMSCode)(NSString *code);
@end

@interface DMLSMSValidationVC : UIViewController
//@property (nonatomic, weak) id<DMLSMSDelegate> delegate;
@property (nonatomic, copy) NSString *phone;

- (instancetype)initWithConfig:(DMLSMSVCConfig *)config;

@end

NS_ASSUME_NONNULL_END
