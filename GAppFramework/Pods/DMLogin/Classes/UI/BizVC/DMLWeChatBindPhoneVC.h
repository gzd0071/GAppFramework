//
//  WechatBindPhoneViewController.h
//  GAppFramework
//
//  Created by ltl on 2019/4/12.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMLWeChatBindPhoneView.h"
#import "DMLoginDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMLWeChatVCConfig : NSObject
@property (nonatomic, copy) void(^ loginWithThirdInfo)(NSDictionary *info, successBlock sBlock, failBlock fBlock);
@property (nonatomic, copy) void(^ reqVerifyCode)(NSString *phone, NSString *type, NSString *smsType, successBlock sBlock, failBlock fBlock);
@property (nonatomic, strong) NSDictionary *lastThirdBindSender;
@end


@interface DMLWeChatBindPhoneVC : UIViewController
@property (nonatomic, strong) DMLWeChatVCConfig *config;
@property (nonatomic, copy) void(^weChatVCBackPressed)(void);

- (instancetype)initWithConfig:(DMLWeChatVCConfig *)config;

@end

NS_ASSUME_NONNULL_END
