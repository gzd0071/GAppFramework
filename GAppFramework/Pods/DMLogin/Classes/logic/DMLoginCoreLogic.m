//
//  DMLoginCoreLogic.m
//  DMLogin
//
//  Created by zhangjiexin on 2019/7/10.
//

#import "DMLoginCoreLogic.h"
#import "DMLoginAdapter.h"
#import "DMLoginStore.h"
#import "DMLChinaMobileTool.h"

@implementation DMLCoreLogicConfig
@end

@interface DMLoginCoreLogic ()
@property (nonatomic, strong) DMLCoreLogicConfig *config;
@end

@implementation DMLoginCoreLogic

+ (NSDictionary *)currentUserInfo {
    return [DMLoginStore shareInstance].loginSuccessData;
}

//这里没有业务逻辑
+ (void)requestSMSAuthCodeForMobileNumber:(NSString *)mobileNumber capthcaString:(nullable NSString *)capthca type:(NSString *)type smsType:(NSString *)smsType successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock {
    NSString *Url = @"https://jz-c.doumi.com/api/v2/client/authCkCode";
    Url = [NSString stringWithFormat:@"%@/api/v2/client/authCkCode", [DMLoginAdapter networkDomain]];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:2];
    [param setObject:mobileNumber forKey:@"mobile"];
    if (type) {
        [param setObject:type forKey:@"type"];
    }
    if (capthca) {
        [param setObject:capthca forKey:@"code"];
    }
    if (smsType) {
        [param setObject:smsType forKey:@"smsType"];
    }
    [DMLoginAdapter requestHeaderWithSuccessBlock:^(NSDictionary * _Nonnull headers) {
        [DMLoginNetWork postJsonRequestWithUrl:Url headers:headers body:param success:successBlock fail:failBlock];
    }];
}

+ (void)loginWithPhone:(NSString *)phone
            verifyCode:(NSString *)verifyCode
          successBlock:(successBlock)successBlock
             failBlock:(failBlock)failBlock {
    NSString *Url = @"https://jz-c.doumi.com/api/v2/client/login";
    Url = [NSString stringWithFormat:@"%@/api/v2/client/login", [DMLoginAdapter networkDomain]];
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    
    param[@"notificationState"] = [DMLoginAdapter APNSState];
    param[@"idfa"]   = [DMLoginAdapter getIDFA];
    param[@"mobile"] = phone;
    if (verifyCode) {
        param[@"code"] = verifyCode;
    }
    [DMLoginAdapter requestHeaderWithSuccessBlock:^(NSDictionary * _Nonnull headers) {
        [DMLoginNetWork postJsonRequestWithUrl:Url headers:headers body:param success:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
            
            [DMLoginStore shareInstance].loginSuccessData = responseObj;
#warning 通知外部请求成功
            
            if (successBlock) {
                successBlock(responseObj, userInfo);
            }
        } fail:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
            
            [DMLoginAdapter setlaunchGuideVerifyCode:@""];
#warning 通知外部请求失败
            
            
            if (failBlock) {
                failBlock(error, userInfo);
            }
        }];
    }];
}

+ (void)loginWithWeChatGetCodeS:(blankBlock)getCodeS
                       getCodeF:(blankBlock)getCodeF
                      getTokenS:(void(^)(id sender))getTokenS
                      getTokenF:(blankBlock)getTokenF
                   successBlock:(successBlock)successBlock
                      failBlock:(failBlock)failBlock {
    __weak typeof(self) weakSelf = self;
    [DMLoginAdapter Wechat_GetCodeSuccess:^(id sender) {
        if (getCodeS) {
            getCodeS();
        }
        [DMLoginAdapter Wechat_GetTokenWithCode:sender[@"code"] success:^(id sender) {
            NSString *str = ([[UIApplication sharedApplication] currentUserNotificationSettings] == UIUserNotificationTypeNone)? @"off" : @"on";
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:sender];
            params[@"type"] = @"weixin";
            [params setObject:str forKey:@"notificationState"];//c 独有
            if (getTokenS) {
                getTokenS(params);
            }
            
            [weakSelf linkThirdAccount:params successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
                
                if (successBlock) {
                    successBlock(responseObj, userInfo);
                }
            } failBlock:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
                if (failBlock) {
                    failBlock(error, userInfo);
                }
            }];
            
        } failure:^(NSString *sender) {
            if (getTokenF) {
                getTokenF();
            }
        }];
        
    } failure:^(NSString *sender) {
        if (getCodeF) {
            getCodeF();
        }
    }];
}

+ (void)loginWithChinaMobileFrom:(UIViewController *)from
                    getPhoneNumS:(blankBlock)getPhoneNumS
                    getPhoneNumF:(void (^)(id sender))getPhoneNumF
                        getAuthS:(blankBlock)getAuthS
                       getAuthF:(void(^)(id sender))getAuthF
                    successBlock:(successBlock)successBlock
                       failBlock:(failBlock)failBlock {
    __weak typeof(self) weakSelf = self;
    [DMLoginAdapter chinaMobileLoginFrom:from
                            getPhoneNumS:getPhoneNumS
                            getPhoneNumF:getPhoneNumF
                                getAuthS:^(id  _Nonnull sender) {
                                   if (getAuthS) {
                                       getAuthS();
                                   }
                                   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:sender];
                                   params[@"type"] = @"chinamobile";
//                                   params[@"token"] = @"chinamobile1qaz2wsxedcvbn";
//                                   params[@"openId"] =  @"chinamobile23rtgcxdtyuijn";
                                   [weakSelf linkThirdAccount:params successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
                                       
                                       if (successBlock) {
                                           successBlock(responseObj, userInfo);
                                       }
                                   } failBlock:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
                                       if (failBlock) {
                                           failBlock(error, userInfo);
                                       }
                                   }];
                               } getAuthF:^(NSString * _Nonnull resultStr) {
                                   if (getAuthF) {
                                       getAuthF(resultStr);
                                   }
                                 }];
}

+ (void)chinaMobilegetPhoneNumS:(blankBlock)getPhoneNumS
                   getPhoneNumF:(void (^)(id sender))getPhoneNumF {
    [DMLChinaMobileTool getPhoneNumS:getPhoneNumS getPhoneNumF:getPhoneNumF timeOut:1000];
}

+ (void)loginWithChinaMobileFrom:(UIViewController *)from
                        getAuthS:(blankBlock)getAuthS
                        getAuthF:(void(^)(id sender))getAuthF
                    successBlock:(successBlock)successBlock
                       failBlock:(failBlock)failBlock {
    __weak typeof(self) weakSelf = self;
    [DMLChinaMobileTool getAuthS:^(id sender) {
        if (getAuthS) {
            getAuthS();
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:sender];
        params[@"type"] = @"chinamobile";
        [weakSelf linkThirdAccount:params successBlock:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
            
            if (successBlock) {
                successBlock(responseObj, userInfo);
            }
        } failBlock:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
            if (failBlock) {
                failBlock(error, userInfo);
            }
        }];
    }
                        getAuthF:getAuthF
                         superVC:from];
}

+ (void)linkThirdAccount:(NSDictionary *)info successBlock:(successBlock)successBlock  failBlock:(failBlock)failBlock {
    NSString *Url = @"https://jz-c.doumi.com/api/v3/client/ucenter/thirdbindlogin";
    Url = [NSString stringWithFormat:@"%@/api/v3/client/ucenter/thirdbindlogin", [DMLoginAdapter networkDomain]];
    [DMLoginAdapter requestHeaderWithIsNeedC_UA:YES SuccessBlock:^(NSDictionary * _Nonnull headers) {
        [DMLoginNetWork postJsonRequestWithUrl:Url headers:headers body:info success:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
            NSDictionary *data = responseObj;
            [DMLoginAdapter setUserLoginData:data[@"data"]];
            if ([[NSString stringWithFormat:@"%@", responseObj[@"code"]] integerValue]) {
                [DMLoginStore shareInstance].loginSuccessData = data;
            }
            if (successBlock) {
                successBlock(responseObj, userInfo);
            }
        } fail:failBlock];
    }];
}


+ (void)requestCaptchaBase64ImageWithSuccessBlock:(void(^)(UIImage *captcha))successBlock failBlock:(failBlock)failBlock {
    NSString *Url = @"https://jz-c.doumi.com/api/v2/client/ajax/encodedcode";
    Url = [NSString stringWithFormat:@"%@/api/v2/client/ajax/encodedcode", [DMLoginAdapter networkDomain]];
    [DMLoginAdapter requestHeaderWithSuccessBlock:^(NSDictionary * _Nonnull headers) {
        [DMLoginNetWork getJsonRequestWithUrl:Url headers:headers body:nil success:^(id  _Nullable responseObj, NSDictionary * _Nullable userInfo) {
            UIImage * decodeImage;
             NSString *base64ImageStr = [responseObj objectForKey:@"pic_code"];
            if (base64ImageStr) {
                base64ImageStr = [base64ImageStr stringByReplacingOccurrencesOfString:@"data:image/gif;base64," withString:@""];
                NSData * decodeImageData = [[NSData alloc] initWithBase64EncodedString:base64ImageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                decodeImage = [UIImage imageWithData:decodeImageData];
            }
            if (successBlock) {
                successBlock(decodeImage);
            }
        } fail:failBlock];
    }];
}

- (instancetype)initWithConfig:(DMLCoreLogicConfig *)config {
    if (self = [super init]) {
        self.config = config;
    }
    return self;
}

//+ (void)start {
//
//}

@end
