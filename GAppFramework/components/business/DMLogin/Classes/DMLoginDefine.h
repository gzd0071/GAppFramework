//
//  DMLoginDefine.h
//  DMLogin
//
//  Created by zhangjiexin on 2019/6/10.
//

#ifndef DMLoginDefine_h
#define DMLoginDefine_h

typedef void(^ blankBlock)(void);
typedef void(^ successBlock)(id _Nullable responseObj , NSDictionary * _Nullable userInfo);
typedef void(^ failBlock)(NSError * _Nullable error , NSDictionary * _Nullable userInfo);

typedef enum : NSUInteger {
    ToastType_Show_Normal,
    ToastType_Show_Normal_NoDim,
    ToastType_Show_Success,
    ToastType_Show_Error,
    ToastType_Hide_Single,
    ToastType_Hide_All_Animated,
    ToastType_Hide_All_NoAni,
} ToastType;

typedef enum : NSUInteger {
    //set Key
    DMCK_C_BC_Back_Kill,        //BC选择页是否后台杀掉标记
    DMCK_C_Login_Back_Kill,     //登录页是否后台杀掉标记
    DMCK_C_Click_Boss,          //点选雇佣者标记
    DMCK_C_SwitchTo_B,          //C 端切换到 B端标记
    DMCK_LastLoginType_Phone,   //登录类型标记 手机号
    DMCK_LastLoginType_WeChat,  //登录类型标记 微信
    DMCK_LastLoginType_OneKey,  //登录类型标记 一键登录
    DMCK_ShouldToUserGuide,     //是否进入新手引导
    
    //get Key
    DMCK_LoginFromMe,           //从 '我的' 登录
    //DMCK_C_Login_Back_Kill
} DMCombineKey;

NS_ASSUME_NONNULL_BEGIN

@protocol DMLoginInfoModel <NSObject>
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger genderID;
@property (nonatomic, strong) NSString *birthYear;
@property (nonatomic, assign) NSInteger identifyID;
@property (nonatomic, assign) NSInteger educationID;
@property (nonatomic, strong) NSString *verifyCode;
@property (nonatomic, strong) NSArray *expJobs;
@property (nonatomic, assign) NSInteger provinceID; // 省
@property (nonatomic, assign) NSInteger cityID; // 市
@property (nonatomic, assign) NSInteger districtID; // 区
@property (nonatomic, assign) NSInteger jobDataTypeAllID; //1:我想找短期灵活工作 2:我想找长期稳定工作 0:我找什么工作都行
@end

@interface DMLAlertConfig : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *attrTitle;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, strong) NSArray *attrSubTitle;
@property (nonatomic, copy) NSString *confirmBtnTxt;
@property (nonatomic, copy) NSString *cancelBtnTxt;
@property (nonatomic, copy) void(^ confirmBlock)(id);
@property (nonatomic, copy) void(^ cancelBlock)(void);
@end

@interface DMLCaptchaAlertConfig : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *smsType;
@property (nonatomic, copy) NSString *confirmBtnTxt;
@property (nonatomic, copy) NSString *cancelBtnTxt;
@property (nonatomic, copy) void(^ confirmBlock)(NSString *captcha);
@property (nonatomic, copy) void(^ cancelBlock)(void);
@end

@interface DMLBaseInfoVCConfig : NSObject
@property (nonatomic, assign) BOOL isShowBackBtn;
@property (nonatomic, copy) void(^ goBack)(void);
@property (nonatomic, copy) void(^ continueFunc)(void);
@end

@interface DMLJobSelectVCConfig : NSObject
@property (nonatomic, strong) id preset;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL hideHot;
@property (nonatomic, assign) BOOL hideOther;
@property (nonatomic, assign) BOOL showAllInHotType;
@property (nonatomic, assign) CGFloat tHeight;
@property (nonatomic, assign) NSInteger max;
@property (nonatomic, strong) UIViewController *from;
@property (nonatomic, copy) NSString *dmch;
@property (nonatomic, copy) NSString *keyText;
@property (nonatomic, copy) void(^ completeBlock)(id result);
@end


NS_ASSUME_NONNULL_END

#endif /* DMLoginDefine_h */
