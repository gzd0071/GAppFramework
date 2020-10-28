//
//  DMLFlashVerifyTool.m
//  DMLogin
//
//  Created by Non on 2019/9/24.
//

#import "DMLFlashVerifyTool.h"
//#import <CL_ShanYanSDK/CL_ShanYanSDK.h>
#import "DMLoginAdapter.h"

@implementation DMLFlashVerifyTool

+ (void)initSDK {
//    [CLShanYanSDKManager initWithAppId:@"KTHWDG15" AppKey:@"AnVmrjL1"
// complete:^(CLCompleteResult * _Nonnull completeResult) {
//        //        if (completeResult.error) {
//        //            CLConsoleLog(@"SDK 初始化失败：%@",completeResult.message);
//        //        }else{
//        //            CLConsoleLog(@"SDK 初始化成功：%@",completeResult.message);
//        //        }
//    }];
}

+ (void)getPhoneNumS:(void(^)(void))getPhoneS getPhoneNumF:(void (^)(id sender))getPhoneF timeOut:(int)timeout {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self initSDK];
//    });
//
//    __block BOOL isTimeout = NO;
////    timeout += 1;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        isTimeout = YES;
//    });
//
//    __weak typeof(self) weakSelf = self;
//    [CLShanYanSDKManager preGetPhonenumber:^(CLCompleteResult * _Nonnull completeResult) {
//        if (isTimeout) {
//            NSLog(@"+_)( 超时");
//            return;
//        }
//        if (completeResult.error) {
//            //            CLConsoleLog(@"%@",completeResult.error.description);
//            if (getPhoneF) {
//                getPhoneF(nil);
//            }
//        } else {
//            //            CLConsoleLog(@"%@",completeResult.yy_modelDescription);
//            if (getPhoneS) {
//                getPhoneS();
//            }
//        }
//    }];
}



+ (void)getAuthS:(void (^)(id sender))getAuthS getAuthF:(void (^)(NSString *resultStr))getAuthF superVC:(UIViewController *)vc {
//    CLUIConfigure * baseUIConfigure;
//    baseUIConfigure = [self configureStyle1:[CLUIConfigure new]];
//    baseUIConfigure.viewController = vc;
//    baseUIConfigure.manualDismiss = @(YES);
//
//    __weak typeof(self) weakSelf = self;
//    [DMLoginAdapter PVEvent:@"/jianzhi/chuanglan/login" para:nil vc:vc];
//    [CLShanYanSDKManager quickAuthLoginWithConfigure:baseUIConfigure openLoginAuthListener:^(CLCompleteResult * _Nonnull completeResult) {
//        if (completeResult.error) {
////            CLConsoleLog(@"openLoginAuthListener:%@",completeResult.error.domain);
//        } else {
////            CLConsoleLog(@"openLoginAuthListener:%@",completeResult.yy_modelToJSONObject);
//        }
//    } oneKeyLoginListener:^(CLCompleteResult * _Nonnull completeResult) {
//        __strong typeof(self) strongSelf = weakSelf;
//        if (completeResult.error) {
//            if (getAuthF) {
//                getAuthF([completeResult.error domain]);
//            }
////            [strongSelf hideShanYanAuthPageMaskViewWhenUseWindow];
//
//            //提示：错误无需提示给用户，可以在用户无感知的状态下直接切换登录方式
//            if (completeResult.code == 1011){
//                //用户取消登录（点返回）
//                //处理建议：如无特殊需求可不做处理，仅作为交互状态回调，此时已经回到当前用户自己的页面
//                //点击sdk自带的返回，无论是否设置手动销毁，授权页面都会强制关闭
//            }  else{
//                //处理建议：其他错误代码表示闪验通道无法继续，可以统一走开发者自己的其他登录方式，也可以对不同的错误单独处理
//                //1003    一键登录获取token失败
//                //其他     其他错误//
//
//                //关闭授权页
//                [CLShanYanSDKManager finishAuthControllerAnimated:YES Completion:nil];
//            }
//        } else {
////            [strongSelf getPhonenumber:completeResult.data];
//            if (getAuthS) {
//                getAuthS([completeResult valueForKey:@"data"]);
//            }
//        }
//    }];
}


//+ (CLUIConfigure *)configureStyle1:(CLUIConfigure *)inputConfigure{
//    CGFloat screenWidth_Portrait;
//    CGFloat screenHeight_Portrait;
//    CGFloat screenWidth_Landscape;
//    CGFloat screenHeight_Landscape;
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
//        screenWidth_Portrait = UIScreen.mainScreen.bounds.size.width;
//        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.height;
//        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.height;
//        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.width;
//    } else {
//        screenWidth_Portrait = UIScreen.mainScreen.bounds.size.height;
//        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.width;
//        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.width;
//        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.height;
//    }
//
//    CGFloat screenScale = [UIScreen mainScreen].bounds.size.width/375.0;
//    if (screenScale > 1) {
//        screenScale = 1;
//    }
//
//    CLUIConfigure * baseUIConfigure = inputConfigure;
//
//    //Loading-
//    baseUIConfigure.clLoadingSize = [NSValue valueWithCGSize:CGSizeMake(50, 50)];
//    baseUIConfigure.clLoadingIndicatorStyle = @(UIActivityIndicatorViewStyleWhite);
//    baseUIConfigure.clLoadingTintColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1];
//    baseUIConfigure.clLoadingBackgroundColor = [UIColor whiteColor];
//    baseUIConfigure.clLoadingCornerRadius = @(5);
//
//
//    baseUIConfigure.clNavigationBackgroundClear = @(YES);
//    baseUIConfigure.clNavigationBottomLineHidden = @(YES);
//
//
//    //LOGO
//    baseUIConfigure.clLogoImage = [UIImage imageNamed:@"onekeyCenterImg"];
//    baseUIConfigure.clLogoCornerRadius = @(10);
//
//
//    //PhoneNumber
//    baseUIConfigure.clPhoneNumberColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
//    baseUIConfigure.clPhoneNumberFont = [UIFont fontWithName:@"PingFang-SC-Medium" size:22.0*screenScale];
//
//
//    NSTimeInterval current = CFAbsoluteTimeGetCurrent();
//    NSLog(@"current:%f",current);
//
//    baseUIConfigure.clLoginBtnText = @"本机号码一键登录";
//
//    baseUIConfigure.clLoginBtnTextFont = [UIFont fontWithName:@"PingFang-SC-Medium" size:16.0*screenScale];
//    baseUIConfigure.clLoginBtnTextColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
//    baseUIConfigure.clLoginBtnBgColor = [UIColor colorWithRed:1 green:204/255.0 blue:0 alpha:1];
//    baseUIConfigure.clLoginBtnCornerRadius = @(5*screenScale);
//
//    //Privacy
//    NSString *url = [NSHomeDirectory() stringByAppendingString:@"/Documents/html/agreement.html"];
//    url = [[NSBundle mainBundle] pathForResource:@"agreement" ofType:@"html"];
//    baseUIConfigure.clAppPrivacyFirst = @[@"用户注册与隐私保护协议", [NSURL fileURLWithPath:url]];
//
//    baseUIConfigure.clAppPrivacyColor = @[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1],[UIColor colorWithRed:102/255.0 green:153/255.0 blue:255/255.0 alpha:1]];
//    baseUIConfigure.clAppPrivacyTextAlignment = @(NSTextAlignmentCenter);
//    baseUIConfigure.clAppPrivacyTextFont = [UIFont systemFontOfSize:11*screenScale];
//    baseUIConfigure.clAppPrivacyPunctuationMarks = @(YES);
//
//    // 隐私协议设置
//    baseUIConfigure.clAppPrivacyPunctuationMarks = @(NO);
//    baseUIConfigure.clAppPrivacyNormalDesTextFirst = @"登录即同意";
//    baseUIConfigure.clAppPrivacyNormalDesTextSecond = @"、";
//    baseUIConfigure.clAppPrivacyNormalDesTextFourth = @"并使用本机号码登录";
//
//
//    //隐私协议页
//    baseUIConfigure.clAppPrivacyWebBackBtnImage = [UIImage imageNamed:@"title_back"];
//    NSMutableAttributedString * att0 = [[NSMutableAttributedString alloc]initWithString:@"隐私" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],NSForegroundColorAttributeName:[UIColor blueColor]}];
//    NSMutableAttributedString * att1 = [[NSMutableAttributedString alloc]initWithString:@"条款" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor orangeColor]}];
//    [att0 appendAttributedString:att1];
//
//
//    //CheckBox
//    baseUIConfigure.clCheckBoxHidden = @(YES);
//    baseUIConfigure.clCheckBoxValue = @(YES);
//    baseUIConfigure.clCheckBoxVerticalAlignmentToAppPrivacyCenterY = @(YES);
//
//    //Slogan
//    baseUIConfigure.clSloganTextColor = UIColor.lightGrayColor;
//    baseUIConfigure.clSloganTextFont = [UIFont fontWithName:@"PingFang-SC-Medium" size:11.0*screenScale];
//    baseUIConfigure.clSlogaTextAlignment = @(NSTextAlignmentCenter);
//    baseUIConfigure.clNavigationBackBtnImage = [UIImage imageNamed:@"onekeyClose"];
//
////    baseUIConfigure.loadingView = ^(UIView * _Nonnull containerView) {
////        ;
////    };
//
//    baseUIConfigure.clLoadingSize = [NSValue valueWithCGSize:CGSizeMake(60, 60)];
////    /**Loading 圆角 float eg.@(5) */
//    baseUIConfigure.clLoadingCornerRadius = @(8);
////    /**Loading 背景色 UIColor eg.[UIColor colorWithRed:0.8 green:0.5 blue:0.8 alpha:0.8]; */
//    baseUIConfigure.clLoadingBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];;
////    /**UIActivityIndicatorViewStyle eg.@(UIActivityIndicatorViewStyleWhiteLarge)*/
////    @property (nonatomic,strong) NSNumber *clLoadingIndicatorStyle;
////    /**Loading Indicator渲染色 UIColor eg.[UIColor greenColor]; */
////    @property (nonatomic,strong) UIColor *clLoadingTintColor;
//    baseUIConfigure.clLoadingTintColor = [UIColor whiteColor];
//
//
//
//    //layout 布局
//    //布局-竖屏
//    CLOrientationLayOut * clOrientationLayOutPortrait = [CLOrientationLayOut new];
//
//    clOrientationLayOutPortrait.clLayoutLogoWidth = @(70*screenScale);
//    clOrientationLayOutPortrait.clLayoutLogoHeight = @(70*screenScale);
//    clOrientationLayOutPortrait.clLayoutLogoCenterX = @(0);
//    clOrientationLayOutPortrait.clLayoutLogoTop = @(64 + 45);
//
//    clOrientationLayOutPortrait.clLayoutPhoneTop = @(clOrientationLayOutPortrait.clLayoutLogoTop.floatValue + clOrientationLayOutPortrait.clLayoutLogoHeight.floatValue + 15);
//    clOrientationLayOutPortrait.clLayoutPhoneLeft = @(50*screenScale);
//    clOrientationLayOutPortrait.clLayoutPhoneRight = @(-50*screenScale);
//    clOrientationLayOutPortrait.clLayoutPhoneHeight = @(20*screenScale);
//
//    clOrientationLayOutPortrait.clLayoutLoginBtnTop = @(64 + 242);
//    clOrientationLayOutPortrait.clLayoutLoginBtnHeight = @(40*screenScale);
//    clOrientationLayOutPortrait.clLayoutLoginBtnLeft = @(40*screenScale);
//    clOrientationLayOutPortrait.clLayoutLoginBtnRight = @(-40*screenScale);
//
//    clOrientationLayOutPortrait.clLayoutAppPrivacyLeft = @(40*screenScale);
//    clOrientationLayOutPortrait.clLayoutAppPrivacyRight = @(-40*screenScale);
//    clOrientationLayOutPortrait.clLayoutAppPrivacyTop = @(clOrientationLayOutPortrait.clLayoutLoginBtnTop.floatValue + clOrientationLayOutPortrait.clLayoutLoginBtnHeight.floatValue + 12*screenScale);
//    clOrientationLayOutPortrait.clLayoutAppPrivacyHeight = @(45*screenScale);
//
//    clOrientationLayOutPortrait.clLayoutSloganLeft = @(0);
//    clOrientationLayOutPortrait.clLayoutSloganRight = @(0);
//    clOrientationLayOutPortrait.clLayoutSloganHeight = @(15*screenScale);
//    clOrientationLayOutPortrait.clLayoutSloganTop = @(clOrientationLayOutPortrait.clLayoutPhoneTop.floatValue + clOrientationLayOutPortrait.clLayoutPhoneHeight.floatValue + 4);
//    baseUIConfigure.clOrientationLayOutPortrait = clOrientationLayOutPortrait;
//
//    return baseUIConfigure;
//}

@end
