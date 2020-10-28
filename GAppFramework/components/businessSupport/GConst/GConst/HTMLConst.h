//
//  HTMLConst.h
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/9/9.
//

#import <Foundation/Foundation.h>


#pragma mark - HTML Macro
///=============================================================================
/// @name HTML宏
///=============================================================================

/// html文件夹路径
#define HTML_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/html"]
/// HTML文件前缀
#define HTML_FILE_ROOT [@"file://" stringByAppendingPathComponent:HTML_PATH]
/// 方法: 初始化HTML路径
#if DEBUG
/// 为Debugger提供便利
#define HTML_ROOT_C_KEY @"kDEBUG_HTML_C_KEY"
#define HTML_ROOT_C_VALUE [[NSUserDefaults standardUserDefaults] valueForKey:HTML_ROOT_C_KEY]
#define HTML_ROOT_C_PATH ([HTML_ROOT_C_VALUE length] ? HTML_ROOT_C_VALUE : HTML_FILE_ROOT)
#define HTML_FILE_C(A) [HTML_ROOT_C_PATH stringByAppendingPathComponent:A]
#else
#define HTML_FILE_C(A) [HTML_FILE_ROOT stringByAppendingPathComponent:A]
#endif

#pragma mark - C_HTMLS
///=============================================================================
/// @name C_HTMLS
///=============================================================================

#define HTML_FEATURED      HTML_FILE_C(@"selected.html")                        ///> 精选页面
#define HTML_MINE          HTML_FILE_C(@"account.html")                         ///> 个人中心
#define HTML_JOB_ADDRESS   HTML_FILE_C(@"modules/jobaddress/jobaddress.html")   ///> 地址列表
#define HTML_CITY          HTML_FILE_C(@"city.html")                            ///> 城市选择
#define HTML_NEARBY        HTML_FILE_C(@"nearby-list.html")                     ///> 离我最近
#define HTML_DETAIL        HTML_FILE_C(@"job-detail.html")                      ///> 职位模板
#define HTML_SEARCH        HTML_FILE_C(@"search.html")                          ///> 搜索页面
#define HTML_RESUME        HTML_FILE_C(@"resume-index.html")                    ///> 我的简历
#define HTML_RESUME_INFO   HTML_FILE_C(@"resume-info.html")                     ///> 基本信息
#define HTML_RESUME_PREF   HTML_FILE_C(@"resume-preference.html")               ///> 求职意向
#define HTML_RESUME_EDU    HTML_FILE_C(@"resume-education.html")                ///> 教育经历
#define HTML_RESUME_WORK   HTML_FILE_C(@"resume-work.html")                     ///> 工作经历(个人中心)
#define HTML_RESUME_ADDI   HTML_FILE_C(@"resume-addition.html")                 ///> 详细信息(个人中心)
#define HTML_WALLET        HTML_FILE_C(@"wallet.html")                          ///> 我的钱包
#define HTML_CASH_RECORD   HTML_FILE_C(@"apply-cash-record.html")               ///> 收支记录
#define HTML_CASH_APPLY    HTML_FILE_C(@"apply-cash.html")                      ///> 提现申请
#define HTML_BIND_WECHAT   HTML_FILE_C(@"bind-weixinwallet.html")               ///> 绑定微信
#define HTML_BIND_ALIPAY   HTML_FILE_C(@"bind-alipay.html")                     ///> 绑定支付宝
#define HTML_BIND_UNION    HTML_FILE_C(@"bind-unionpay.html")                   ///> 绑定银联
#define HTML_APPLY_LIST    HTML_FILE_C(@"apply-list.html")                      ///> 我的报名
#define HTML_EVALUATE      HTML_FILE_C(@"evaluate.html")                        ///> 待评价页
#define HTML_FAVORITE      HTML_FILE_C(@"favorite.html")                        ///> 我的收藏
#define HTML_COM_FEEDBACK  HTML_FILE_C(@"complain-and-feedback.html")           ///> 投诉反馈
#define HTML_SWITCH        HTML_FILE_C(@"bc-switch.html")                       ///> 身份切换
#define HTML_SETTING       HTML_FILE_C(@"settings.html")                        ///> 设置页面
#define HTML_CHANGE_MOBILE HTML_FILE_C(@"change-mobile-number.html")            ///> 更换手机
#define HTML_BIND_LIST     HTML_FILE_C(@"account-bind-list.html")               ///> 账号绑定
#define HTML_PREFECTURE    HTML_FILE_C(@"prefecture.html")                      ///> 专区页面
#define HTML_SIGN_SUC      HTML_FILE_C(@"sign-in.html")                         ///> 签到成功
#define HTML_FEEDBACK      HTML_FILE_C(@"feedback.html")                        ///> 产品反馈
#define HTML_RECOMMEND     HTML_FILE_C(@"invite-recomment-list.html")           ///> 推荐职位
#define HTML_APPLY_DETAIL  HTML_FILE_C(@"apply-detail.html")                    ///> 报名详情
#define HTML_CASH_SUC      HTML_FILE_C(@"apply-cash-success.html")              ///> 提现成功
#define HTML_JOB_PUBLISHER HTML_FILE_C(@"job-publisher.html")                   ///> 职位发布者
#define HTML_OFFLINE_SHARE HTML_FILE_C(@"offlineshare.html")                    ///> 邀友赚钱
#define HTML_INVITE_LIST   HTML_FILE_C(@"offline-invite-list.html")             ///> 我的邀约
#define HTML_INVITE_BONUS  HTML_FILE_C(@"offline-invite-bonus.html")            ///> 我的分红
#define HTML_APPLY_SUC     HTML_FILE_C(@"apply-success.html")                   ///> 报名成功
#define HTML_SCORE_DETAIL  HTML_FILE_C(@"integral-detail.html")                 ///> 积分明细
#define HTML_EARN_SCORE    HTML_FILE_C(@"earn-score.html")                      ///> 赚取积分
#define HTML_JOB_LIST      HTML_FILE_C(@"recommend-list.html")                  ///> 职位列表
#define HTML_COMPANY       HTML_FILE_C(@"company-detail.html")                  ///> 公司详情
#define HTML_FRAUD         HTML_FILE_C(@"anti-fraud-guide.html")                ///> 防骗指南


NS_ASSUME_NONNULL_BEGIN
@interface HTMLConst : NSObject
+ (NSDictionary<NSString *, NSString *> *)urdHTMLMap:(NSString *)scheme;
@end
NS_ASSUME_NONNULL_END
