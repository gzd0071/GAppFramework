//
//  URDConst.h
//  GConst
//
//  Created by iOS_Developer_G on 2019/9/9.
//

#ifndef URDConst_h
#define URDConst_h

#import "SCHEMEConst.h"
#import <GBaseLib/GConvenient.h>

#define URD(A)           FORMAT(@"%@://%@", CSCHEME, A)
#define URDS(A, B)       (FORMAT(@"%@://%@", A, B))
#define URL(A)           [A hasPrefix:@"http"] ? FORMAT(@"%@://browser/%@", CSCHEME, A) : A
#define URLS(A, B)       [B hasPrefix:@"http"] ? FORMAT(@"%@://browser/%@", A, B) : B

#pragma mark - C_URDS
///=============================================================================
/// @name  C_URDS
///=============================================================================

#define URD_TAB                 @"jianzhimain"                                  ///> TAB页面
#define URD_DETAIL              @"jobdetail"                                    ///> 职位详情
#define URD_JOB_ADDRESS         @"jobaddress"                                   ///> 地址列表
#define URD_CITY_SELECT         @"cityselect"                                   ///> 选择城市
#define URD_SEARCH              @"search"                                       ///> 搜索页面
#define URD_JOB_MAP             @"job-address-map"                              ///> 工作地点
#define URD_RESUME              @"resume-index"                                 ///> 我的简历
#define URD_RESUME_INFO         @"resume-info"                                  ///> 基本信息
#define URD_RESUME_PREF         @"resume-preference"                            ///> 求职意向
#define URD_RESUME_EDU          @"resume-education"                             ///> 教育经历
#define URD_RESUME_WORK         @"resume-work"                                  ///> 工作经历(个人中心)
#define URD_RESUME_ADDI         @"resume-addition"                              ///> 详细信息
#define URD_SIGN                @"duiba"                                        ///> 签到页面
#define URD_WALLET              @"userwallet"                                   ///> 我的钱包
#define URD_CASH_RECORD         @"apply-cash-record"                            ///> 收支记录
#define URD_CASH_APPLY          @"applycash"                                    ///> 提现申请
#define URD_BIND_WECHAT         @"bindweixinwallet"                             ///> 绑定微信
#define URD_BIND_ALIPAY         @"bindalipay"                                   ///> 绑定支付宝
#define URD_BIND_UNION          @"bindunionpay"                                 ///> 绑定银联
#define URD_APPLY_LIST          @"applylist"                                    ///> 我的报名
#define URD_EVALUATE            @"evaluate"                                     ///> 待评价页
#define URD_FAVORITE            @"favorite"                                     ///> 我的收藏
#define URD_COUNSELOR           @"jobcounselor"                                 ///> 求职顾问
#define URD_COM_FEEDBACK        @"complain-and-feedback"                        ///> 投诉反馈
#define URD_SWITCH              @"bc-switch"                                    ///> 身份切换
#define URD_SETTING             @"settings"                                     ///> 设置页面
#define URD_CHANGE_MOBILE       @"change-mobile-number"                         ///> 更换手机
#define URD_BIND_LIST           @"account-bind-list"                            ///> 账号绑定
#define URD_PREFECTURE          @"prefecture"                                   ///> 专区页面
#define URD_SAFARI              @"link"                                         ///> 浏览器页
#define URD_FEEDBACK            @"feedback"                                     ///> 产品反馈
#define URD_RECOMMENT           @"invite-recommend-list"                        ///> 推荐职位
#define URD_APPLY_DETAIL        @"apply-detail"                                 ///> 报名详情
#define URD_CASH_SUC            @"apply-cash-success"                           ///> 提现成功
#define URD_PUBLISHER           @"job-publisher"                                ///> 职位发布者
#define URD_OFFLINE_SHARE       @"offlineshare"                                 ///> 邀友赚钱
#define URD_INVITE_LIST         @"offlineinvitelist"                            ///> 我的邀约
#define URD_INVITE_BONUS        @"offlineinvitebonus"                           ///> 我的分红
#define URD_APPLY_SUC           @"applysuccess"                                 ///> 报名成功
#define URD_COMPANY             @"company-detail"                               ///> 公司详情
#define URD_SCORE_DETAIL        @"integraldetail"                               ///> 积分明细
#define URD_EARN_SCORE          @"earnscore"                                    ///> 赚取积分
#define URD_JOB_LIST            @"joblist"                                      ///> 职位列表
#define URD_CONVERSATION        @"conversation"                                 ///> 聊天页面
#define URD_ROLE                @"role"                                         ///> 身份选择
#define URD_APPLY_ACTION        @"applyaction"                                  ///> 报名事件
#define URD_FRAUD               @"anti-fraud-guide"                             ///> 防骗指南
#define URD_RESIDENCE           @"residence"                                    ///> 设置居住地址
#define URD_ADDR_SEARCH         @"search-address"                               ///> 搜索地址

#endif /* URDConst_h */
