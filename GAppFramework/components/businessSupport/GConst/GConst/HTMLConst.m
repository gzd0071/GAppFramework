//
//  HTMLConst.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/9/9.
//

#import "HTMLConst.h"
#import "URDConst.h"

@implementation HTMLConst
+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)urdHTMLMap:(NSString *)scheme {
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{CSCHEME : @{
                 URD_COMPANY      : HTML_COMPANY,    ///> 公司详情
                 URD_JOB_ADDRESS  : HTML_JOB_ADDRESS,
                 URD_CITY_SELECT  : HTML_CITY,
                 URD_SEARCH       : HTML_SEARCH,
                 URD_RESUME       : HTML_RESUME,     ///> 我的简历
                 URD_RESUME_INFO  : HTML_RESUME_INFO,
                 URD_RESUME_PREF  : HTML_RESUME_PREF,
                 URD_RESUME_EDU   : HTML_RESUME_EDU,
                 URD_RESUME_WORK  : HTML_RESUME_WORK,
                 URD_RESUME_ADDI  : HTML_RESUME_ADDI,
                 URD_WALLET       : HTML_WALLET,
                 URD_CASH_RECORD  : HTML_CASH_RECORD,
                 URD_CASH_APPLY   : HTML_CASH_APPLY,
                 URD_BIND_WECHAT  : HTML_BIND_WECHAT,
                 URD_BIND_ALIPAY  : HTML_BIND_ALIPAY,
                 URD_BIND_UNION   : HTML_BIND_UNION,
                 URD_APPLY_LIST   : HTML_APPLY_LIST,
                 URD_EVALUATE     : HTML_EVALUATE,
                 URD_FAVORITE     : HTML_FAVORITE,   ///> 我的收藏
                 URD_FEEDBACK     : HTML_FEEDBACK,   ///> 投诉反馈
                 URD_SWITCH       : HTML_SWITCH,     ///> 身份切换
                 URD_SETTING      : HTML_SETTING,
                 URD_CHANGE_MOBILE: HTML_CHANGE_MOBILE,
                 URD_BIND_LIST    : HTML_BIND_LIST,
                 URD_PREFECTURE   : HTML_PREFECTURE,
                 URD_COM_FEEDBACK : HTML_COM_FEEDBACK,
                 URD_CASH_SUC     : HTML_CASH_SUC,
                 URD_APPLY_DETAIL : HTML_APPLY_DETAIL,
                 URD_PUBLISHER    : HTML_JOB_PUBLISHER, ///> 职位发布者
                 URD_OFFLINE_SHARE: HTML_OFFLINE_SHARE,
                 URD_INVITE_LIST  : HTML_INVITE_LIST,
                 URD_INVITE_BONUS : HTML_INVITE_BONUS,
                 URD_APPLY_SUC    : HTML_APPLY_SUC,
                 URD_SCORE_DETAIL : HTML_SCORE_DETAIL,
                 URD_EARN_SCORE   : HTML_EARN_SCORE,
                 URD_JOB_LIST     : HTML_JOB_LIST},
                 };
    });
    return dict[scheme];
}
@end
