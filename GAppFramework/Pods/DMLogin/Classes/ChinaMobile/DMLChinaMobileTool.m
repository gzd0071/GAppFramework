//
//  DMChinaMobileTool.m
//
//
//  Created by Non on 22/11/2017.
//

#import "DMLChinaMobileTool.h"
//#import <TYRZSDK/TYRZSDK.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "DMLoginAdapter.h"

@interface DMLChinaMobileTool()
@property (nonatomic, assign, getter=isUsable) BOOL usable;
@end

@implementation DMLChinaMobileTool

+ (DMLChinaMobileTool *)sharedInstance {
    static dispatch_once_t once;
    static DMLChinaMobileTool * singleton;
    dispatch_once( &once, ^{
        singleton = [[DMLChinaMobileTool alloc] init];
        singleton.usable = NO;
    });
    return singleton;
}

+ (void)initSDK {
//    [UASDKLogin.shareLogin registerAppId:@"300011728405" AppKey:@"47BE774CF1098A5692123578183D18B0"];
    [self checkUsability];
}

// 检查可用性
+ (void)checkUsability {
    //获取本机运营商名称
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    //当前手机所属运营商名称
    NSString *mobile;
    //先判断有没有SIM卡，如果没有则不获取本机运营商
    if (!carrier.isoCountryCode) {
        mobile = @"无运营商";
    } else{
        mobile = [carrier carrierName];
    }
    if (![mobile isEqual:@"中国移动"]) {
        [DMLChinaMobileTool sharedInstance].usable = NO;
        //引导填写简历第一步    /jianzhi/guide/first        SDK返回失败或点击下一步时仍未返回
        [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/guide/first"];
    } else {
        [DMLChinaMobileTool sharedInstance].usable = YES;
    }
}

+ (void)testTime {
//    static int index = 0;
//    NSDate *date = [NSDate date];
//    [UASDKLogin.shareLogin getPhoneNumberCompletion:^(NSDictionary * _Nonnull result) {
//        NSString *resultCode = result[@"resultCode"];
//        if ([resultCode isEqualToString:@"103000"]) {
//            [DMLChinaMobileTool sharedInstance].usable = YES;
//            NSLog(@"===================%f", [[NSDate date] timeIntervalSinceDate:date]);
//
//            //引导填写简历第一步    /jianzhi/guide/first        预约取号接口返回成功
//            [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=success" domain:@"/jianzhi/guide/first"];
//        } else {
//            [DMLChinaMobileTool sharedInstance].usable = NO;
//            //引导填写简历第一步    /jianzhi/guide/first        SDK返回失败或点击下一步时仍未返回
//            [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/guide/first"];
//        }
//
//        if (++index < 100) {
//            [self testTime];
//        }
//    }];
}

+ (BOOL)usable
{
    BOOL result = [DMLChinaMobileTool sharedInstance].usable;
    return result;
    return NO;
}

/**
 显示一键登录

 @param vc <#vc description#>
 @param title <#title description#>
 @param image <#image description#>
 @param complete <#complete description#>
 */
+ (void)loginFrom:(UIViewController *)vc
            title:(NSString *)title
             logo:(UIImage *)image
        getPhoneNumS:(void(^)(void))getPhoneNumS
        getPhoneNumF:(void (^)(id sender))getPhoneNumF
         complete:(void (^)(id sender))complete {

    // 隐藏右侧按钮
//    [TYRZUILogin enableCustomSMS:YES];
//    __weak typeof(UIViewController *) weakVC = vc;
//
//    UACustomModel *configModel = [self showConfigWithVC:weakVC];
//    [UASDKLogin.shareLogin getPhoneNumberCompletion:^(NSDictionary * _Nonnull result) {
//        NSString *resultCode = result[@"resultCode"];
//        if ([resultCode isEqualToString:@"103000"]) {
//            [DMLChinaMobileTool sharedInstance].usable = YES;
//            //预约取号接口返回成功
//            [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=success" domain:@"/jianzhi/guide/first"];
//
//            if (getPhoneNumS) {
//                getPhoneNumS();
//            }
//            [UASDKLogin.shareLogin getAuthorizationWithModel:configModel complete:^(id  _Nonnull sender) {
//                complete(sender);
//            }];
//        } else {
//            [DMLChinaMobileTool sharedInstance].usable = NO;
//            //SDK返回失败或点击下一步时仍未返回
//            [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/guide/first"];
//
//            if (getPhoneNumF) {
//                getPhoneNumF(result);
//            }
//        }
//    }];
}

+ (void)loginFrom:(UIViewController *)vc
        getPhoneNumS:(void(^)(void))getPhoneNumS
        getPhoneNumF:(void (^)(id sender))getPhoneNumF
          getAuthS:(void (^)(id sender))getAuthS
          getAuthF:(void (^)(NSString *resultStr))getAuthF {
    [DMLChinaMobileTool
     loginFrom:vc
     title:@"斗米"
     logo:[UIImage imageNamed:@"cornerLogo"]
     getPhoneNumS:getPhoneNumS
     getPhoneNumF:getPhoneNumF
     complete:^(id sender) {
         if ([sender[@"resultCode"] isEqual:@"103000"]) {
             getAuthS(sender);
         } else {
             if ([sender[@"resultCode"] isEqual:@"102301"]) {
                 getAuthF(@"DM用户取消");
             } else {
                 NSString *result = sender[@"desc"];
                 getAuthF(result);
             }
         }
     }];
}

+ (void)getPhoneNumS:(void(^)(void))getPhoneS getPhoneNumF:(void (^)(id sender))getPhoneF timeOut:(int)timeout {
//    [UASDKLogin.shareLogin setTimeoutInterval:timeout];
//    [UASDKLogin.shareLogin getPhoneNumberCompletion:^(NSDictionary * _Nonnull result) {
//        NSString *resultCode = result[@"resultCode"];
//        if ([resultCode isEqualToString:@"103000"]) {
//            [DMLChinaMobileTool sharedInstance].usable = YES;
//            //预约取号接口返回成功
//            [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=success" domain:@"/jianzhi/newestguide/first"];
//
//            if (getPhoneS) {
//                getPhoneS();
//            }
//        } else {
//            [DMLChinaMobileTool sharedInstance].usable = NO;
//            //SDK返回失败或点击下一步时仍未返回
//            [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=fail" domain:@"/jianzhi/newestguide/first"];
//
//            if (getPhoneF) {
//                getPhoneF(result);
//            }
//        }
//    }];
}

+ (void)getAuthS:(void (^)(id sender))getAuthS getAuthF:(void (^)(NSString *resultStr))getAuthF superVC:(UIViewController *)vc {
    __weak typeof(UIViewController *) weakVC = vc;
//    UACustomModel *configModel = [self showConfigWithVC:weakVC];
//    [UASDKLogin.shareLogin setTimeoutInterval:7000];
//    [DMLoginAdapter event:@"@atype=click@ca_name=doumi@ca_source=app@ca_from=login" domain:@"/jianzhi/newestguide/one"];
//    [DMLoginAdapter PVEvent:@"/jianzhi/cmcc/login" para:nil vc:vc];
//    [UASDKLogin.shareLogin getAuthorizationWithModel:configModel complete:^(id  _Nonnull sender) {
//        if ([sender[@"resultCode"] isEqual:@"103000"]) {
//            getAuthS(sender);
//        } else {
//            if ([sender[@"resultCode"] isEqual:@"102301"]) {
//                getAuthF(@"DM用户取消");
//            } else {
//                NSString *result = sender[@"desc"];
//                getAuthF(result);
//            }
//        }
//    }];
}

//+ (UACustomModel *)showConfigWithVC:(UIViewController *)VC {
//    UACustomModel *configModel = UACustomModel.new;
//    configModel.currentVC = VC;
//
//    configModel.navColor = UIColor.whiteColor;
//    configModel.navText = nil;
//    configModel.navReturnImg = [UIImage imageNamed:@"onekeyClose"];
//
//    configModel.logoOffsetY = 55;
//    configModel.logoImg = [UIImage imageNamed:@"onekeyCenterImg"];
//
//    configModel.numberSize = 22;
//    configModel.numberColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
//    configModel.numFieldOffsetY = 145;
//
//    configModel.sloganOffsetY = 185;
//
//    UIImage *imgNormal = [UIImage imageNamed:@"onekeyBtnYellow"];
//    UIImage *imgGray = [UIImage imageNamed:@"onekeyBtnGray"];
//    configModel.logBtnImgs = @[imgNormal, imgGray, imgNormal];
//    configModel.logBtnText = @"本机号码一键登录";
//    configModel.logBtnTextColor =  [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
//    // 登录按钮顶端 与 导航栏底部 的距离
//    configModel.logBtnOffsetY = 242;
//
//    configModel.swithAccHidden = YES;
//
//    configModel.appPrivacyColor = @[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1],
//                                    [UIColor colorWithRed:102/255.0 green:153/255.0 blue:255/255.0 alpha:1]];
//    // 文本控件顶部 距离 文字实际显示 10.5
//
////    x = h - (btnY+40) -  32 + 10.5
//
////    1110 = 242 * 3 + 40*3
////    2436 - 1110  - 32 + 10.5
//    // 一键登录按钮 与 授权文字之间的距离
//    CGFloat gapBtnAndPrivacy = 24;
//    CGFloat naviBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
//    configModel.privacyOffsetY = (VC.view.frame.size.height - naviBarHeight) - (configModel.logBtnOffsetY + 40) - gapBtnAndPrivacy + 10.5;
//    configModel.privacyState = YES;
//    configModel.checkedImg = [UIImage imageNamed:@"blank"];
//    configModel.uncheckedImg = [UIImage imageNamed:@"blank"];
//
//    NSString *url = [NSHomeDirectory() stringByAppendingString:@"/Documents/html/agreement.html"];
//    configModel.appPrivacyTwo = @[@"用户注册与隐私保护协议", url];
//
//    return configModel;
//}

@end
