//
//  DMLoginCoreLogic+UIConfiguration.m
//  DMLogin
//
//  Created by zhangjiexin on 2019/7/13.
//

#import "DMLoginCoreLogic+UIConfiguration.h"
#import "LoginCoreVC.h"
#import <DMLFlashVerifyTool.h>

@implementation DMLoginCoreLogic (UIConfiguration)

- (void)startWithPush:(BOOL)isPush {
    LoginCoreVCConfig *config = LoginCoreVCConfig.new;
    config.loginCoreVCViewDidLoad = [self mainConfig].loginMainVCViewDidLoad;
    config.fromUserCenterFinishInputSMSCode = [self mainConfig].fromUserCenterFinishInputSMSCode;
    config.pushToSMSVC = [self mainConfig].pushToSMSVC;
    config.pushToWeChatBindVC = [self mainConfig].pushToWeChatBindVC;
    config.WeChatBindVCToMainVC = [self mainConfig].WeChatBindVCToMainVC;
    config.SMSVCToMainVC = [self mainConfig].SMSVCToMainVC;
    
    config.loginWithPhone = ^(NSString *phone, NSString *verifyCode, successBlock sBlock, failBlock fBlock) {
        [DMLoginCoreLogic
         loginWithPhone:phone
         verifyCode:verifyCode
         successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
             //向内部透传
             if (sBlock) {
                 sBlock(responseObj, userInfo);
             }
             //对外部反馈
             [self mainConfig].loginSuccess(DMLoginType_Phone, responseObj);
         } failBlock:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
             //向内部透传
             if (fBlock) {
                 NSString *msg = @"请求失败";
                 if ([userInfo isKindOfClass:[NSDictionary class]] && [userInfo objectForKey:@"message"]) {
                     msg = [userInfo objectForKey:@"message"];
                 } else if ([error.userInfo objectForKey:@"NSLocalizedDescription"]) {
                     msg = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                 }
                 fBlock(error, @{@"message" : msg});
             }
             //对外部反馈
//             [self mainConfig].loginFail();
         }];
    };
    
    config.chinaMobileGetPhoneNum = ^(blankBlock getPhoneNumS, void (^getPhoneNumF)(id sender)) {
        [DMLoginCoreLogic chinaMobilegetPhoneNumS:getPhoneNumS getPhoneNumF:getPhoneNumF];
    };
    
    config.chinaMobileLogin = ^(UIViewController *from, blankBlock getAuthS, void (^getAuthF)(id sender), successBlock sBlock, failBlock fBlock) {
        [DMLoginCoreLogic
         loginWithChinaMobileFrom:from
         getAuthS:getAuthS
         getAuthF:getAuthF
         successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
             //向内部透传
             if (sBlock) {
                 sBlock(responseObj, userInfo);
             }
             
             NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
             if (code == 1000) { // 成功
                 [self mainConfig].loginSuccess(DMLoginType_WeChat, responseObj[@"data"]);
             } else {
             }
         } failBlock:fBlock];
    };
    
    config.flashVerifyGetPhoneNum = ^(blankBlock getPhoneNumS, void (^getPhoneNumF)(id sender)) {
        [DMLFlashVerifyTool getPhoneNumS:getPhoneNumS getPhoneNumF:getPhoneNumF timeOut:1];
    };
    
    config.flashVerifyLogin = ^(UIViewController *from, blankBlock getAuthS, void (^getAuthF)(id sender), successBlock sBlock, failBlock fBlock) {
        [DMLFlashVerifyTool getAuthS:^(id  _Nonnull sender) {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:sender];
            params[@"type"] = @"shanyan";
            if (getAuthS) {
                getAuthS();
            }
            [DMLoginCoreLogic linkThirdAccount:params successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
             
                //向内部透传
                if (sBlock) {
                    sBlock(responseObj, userInfo);
                }
                
                NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
                if (code == 1000) { // 成功
                    [self mainConfig].loginSuccess(DMLoginType_WeChat, responseObj[@"data"]);
                } else {
                }
            } failBlock:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
                if (fBlock) {
                    fBlock(error, userInfo);
                }
            }];
        } getAuthF:getAuthF superVC:from];
    };
    
    config.loginWithWeChat = ^(blankBlock getCodeS, blankBlock getCodeF, void (^getTokenS)(id sender), blankBlock getTokenF, successBlock sBlock, failBlock fBlock) {
        [DMLoginCoreLogic
         loginWithWeChatGetCodeS:getCodeS
         getCodeF:getCodeF
         getTokenS:getTokenS
         getTokenF:getTokenF
         successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
             //向内部透传
             if (sBlock) {
                 sBlock(responseObj, userInfo);
             }
             
             //对外部反馈
             NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
             if (code == 1000) { // 成功
                 [self mainConfig].loginSuccess(DMLoginType_WeChat, responseObj[@"data"]);
             } else if (code == -412) { //未绑定
             } else if (code == -200) { //账号不存在
             } else {
                 if (code == -408) { // 已绑定
                     [self mainConfig].loginSuccess(DMLoginType_WeChat_HaveBinded, responseObj[@"data"]);
                 }
             }
         } failBlock:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
             //向内部透传
             if (fBlock) {
                 fBlock(error, userInfo);
             }
         }];
    };
    
    config.reqVerifyCode = ^(NSString *phone, NSString *type, NSString *smsType, successBlock sBlock, failBlock fBlock) {
        [DMLoginCoreLogic
         requestSMSAuthCodeForMobileNumber:phone
         capthcaString:nil
         type:type
         smsType:smsType
         successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
             if (sBlock) {
                 sBlock(responseObj, userInfo);
             }
         } failBlock:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
             if (fBlock) {
                 fBlock(error, userInfo);
             }
         }];
    };
    
    config.loginWithThirdInfo = ^(NSDictionary *info, successBlock sBlock, failBlock fBlock) {
        [DMLoginCoreLogic linkThirdAccount:info successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
            //向内部透传
            if (sBlock) {
                sBlock(responseObj, userInfo);
            }
            
            if (responseObj) {
                NSInteger code = [[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue];
                if (code == 1000) {// 成功
                    [self mainConfig].loginSuccess(DMLoginType_WeChat_From_Unbind, responseObj[@"data"]);
                }
            }
        } failBlock:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
            if (fBlock) {
                fBlock(error, userInfo);
            }
        }];
    };
    
    
    
    
    LoginCoreVC *mainVC = [[LoginCoreVC alloc] initWithConfig:config];
    if (isPush) {
        [self mainConfig].pushToMainVC(mainVC);
    }
    self.mainVC = mainVC;
//    self.config.supserVC
}

- (DMLCoreLogicConfig *)mainConfig {
    return [self performSelector:@selector(config)];
}

@end
