//
//  LoginCoreVC.h
//  DMLogin
//
//  Created by Loyal on 2019/6/18.
//

#import <UIKit/UIKit.h>
#import "DMLoginDefine.h"
typedef enum : NSUInteger {
    DMLoginType_Phone,
    DMLoginType_WeChat,
    DMLoginType_WeChat_From_Unbind,//微信登录成功后，提示未绑定的情况
    DMLoginType_WeChat_HaveBinded,
    DMLoginType_OneKey,
} DMLoginType;

@protocol ModuleLoginDelegate <NSObject>

@required

//进入登录的入口， 首页？我的？强退登录？  验证码界面要用到
- (void)loginEnterport;

@optional

- (void)loginViewDidLoad;
- (void)loginViewWillAppear:(BOOL)animated;

- (void)loginSuccessWithType:(DMLoginType)loginType userInfo:(NSDictionary *)userInfo;
- (void)loginFail;

/* 要实现的东西
 1、标记登录界面 是否要在后台杀掉
 2、简历补充引导页面，点击返回后，需要再切换成新登录界面
 3、验证码 一键登录 微信登录 完成之后就会获取到用户的相关信息，实际的登录已经完成。这时候需要 获取用户角色  (老板还是求职者)
 4、AfterGuide Tool Delegate
 4-1、intoSelecteBorCViewCotroller
 4-2、intoB_Client
 4-3、intoC_Client
 5、B or C VC delegate
 5-1、bcSelectionPageDidSelectC
 6、获取简历的全部信息 getRusumeHasAllField
 7、进入填写基本信息 vc
 8、填写完成基本信息后，  继续填写 求职类型
 9、填写完成 求职类型相关的信息后， 上传信息 到服务端
 10、 上传求职类型信息  同时 请求服务端是否需要 继续填写 工作经历
 11、工作经历填写代理 DMGuideWorkExperDelegate
 11-1、guideWorkExperSkipButtonClicked:
 11-2、guideWorkExperDoneButtonClicked:
 
 12、 postFinish 登录过程完成
 13、获取省市信息
 14、登录完成上传简历
 
 */


@end

@interface LoginCoreVCConfig : NSObject

@property (nonatomic, copy) void(^ fromUserCenterFinishInputSMSCode)(void);

//界面跳转
@property (nonatomic, copy) void(^ pushToSMSVC)(UIViewController *SMSVC);
@property (nonatomic, copy) void(^ pushToWeChatBindVC)(UIViewController *weChatBindVC);
@property (nonatomic, copy) void(^ WeChatBindVCToMainVC)(UIViewController *mainVC, UINavigationController *navi);
@property (nonatomic, copy) void(^ SMSVCToMainVC)(UIViewController *mainVC, UINavigationController *navi);

//登录相关的请求方法//登录关键节点处理
@property (nonatomic, copy) void(^ reqVerifyCode)(NSString *phone, NSString *type, NSString *smsType, successBlock sBlock, failBlock fBlock);
@property (nonatomic, copy) void(^ loginWithPhone)(NSString *phone, NSString *verifyCode, successBlock sBlock, failBlock fBlock);
@property (nonatomic, copy) void(^ loginWithWeChat)(blankBlock getCodeS, blankBlock getCodeF, void(^getTokenS)(id sender), blankBlock getTokenF, successBlock sBlock, failBlock fBlock);
@property (nonatomic, copy) void(^ loginWithChinaMobile)(UIViewController *from, blankBlock getPhoneNumS, void(^getPhoneNumF)(id sender), blankBlock getAuthS, void(^getAuthF)(id sender), successBlock sBlock, failBlock fBlock);

@property (nonatomic, copy) void(^ chinaMobileGetPhoneNum)(blankBlock getPhoneNumS, void(^getPhoneNumF)(id sender));
@property (nonatomic, copy) void(^ chinaMobileLogin)(UIViewController *from, blankBlock getAuthS, void(^getAuthF)(id sender), successBlock sBlock, failBlock fBlock);

@property (nonatomic, copy) void(^ flashVerifyGetPhoneNum)(blankBlock getPhoneNumS, void(^getPhoneNumF)(id sender));
@property (nonatomic, copy) void(^ flashVerifyLogin)(UIViewController *from, blankBlock getAuthS, void(^getAuthF)(id sender), successBlock sBlock, failBlock fBlock);

@property (nonatomic, copy) void(^ loginWithThirdInfo)(NSDictionary *info, successBlock sBlock, failBlock fBlock);

//CoreVC 的某些生命周期
@property (nonatomic, copy) void(^ loginCoreVCViewDidLoad)(void);
@end

@interface LoginCoreVC : UIViewController

@property (nonatomic, strong) id<ModuleLoginDelegate> delegate;

@property (nonatomic, copy) void(^customedAddsmsVC)(void);
@property (nonatomic, copy) void(^customedAddWeChatBindVC)(NSDictionary *lastThirdBindSender);


- (instancetype)initWithConfig:(LoginCoreVCConfig *)config;

//集合类，用于存储需要和本 VC 生命周期同步的量
- (void)bindToLoginVCWithVar:(id)var;

- (NSDictionary *)userInfo;

@end
