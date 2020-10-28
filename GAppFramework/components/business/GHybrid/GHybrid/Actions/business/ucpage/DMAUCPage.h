//
//  DMAUCPage.h
//  GHybrid
//
//  Created by iOS_Developer_G on 2019/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GTask<T>;

/*!
 * [EXPROT]: 暴露接口给HTML
 * JS页面相关
 */
@interface DMAUCPage : NSObject

/// [JS ACTION]: HTML选择职位
/// @param args {NSDictionary *}
///    @key jobs:               {JSON String} 已经展示职位
///    @key type:               {NSString *} 职位/标签
///    @key dmch:               {NSString *} 埋点使用
///    @key isHot:              {NSNumber *} 是否显示热门
///    @key showType:           {NSString *} 是否以弹框形式显示: '' or 'dialog'
///    @key maxSelect:          {NSNumber *} 最多职位可选择数
///    @key applyType:          {NSNumber *} 求职类型
///    @key isHideOther:        {NSNumber *} 是否隐藏其他
///    @key isRecommendation:   {NSNumber *} 是否显示推荐
///    @key isShowAllInHotType: {NSNumber *} 有热门的情况下，其他职位中是否显示完全职位，只有显示热门时生效
/// @return {NSDictinary *}
///    @key isOpenJSLog: 日志开关
/// @since 5.2.4
+ (GTask *)showSubscribeJobs:(NSDictionary *)args;

@end

NS_ASSUME_NONNULL_END
