//
//  DMHListModel.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/19.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/NSObject+YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DMHListDelegate <NSObject>
@required
///> cell 复用标识 
- (NSString *)cellIndentifier;
///> cell 高度 
- (CGFloat)cellHeight;
@end

#pragma mark - EXPORTS
///=============================================================================
/// @name EXPORTS
///=============================================================================
///> 模板标识: 商家信息
extern NSString * const HCI_MERCHANT;
///> 模板标识: 运营模板
extern NSString * const HCI_ZONE;
///> 模板标识: 全职职位
extern NSString * const HCI_JOB;
///> 模板标识: 兼职职位
extern NSString * const HCI_JOB_PT;
///> 模板标识: 热门标签
extern NSString * const HCI_HOT;
///> 模板标识: 刷新模板
extern NSString * const HCI_REFRESH;
///> 模板标识: Banner模板
extern NSString * const HCI_BANNER;
///> 模板标识: 空白模板
extern NSString * const HCI_EMPTY;
///> 模板标识: 求职顾问模板
extern NSString * const HCI_CONUSELOR;
///> 模板标识: 订阅模板
extern NSString * const HCI_DINGYUE;


///> 刷新模板位置
extern NSInteger const REFRESH_POSITION;

#pragma mark - MERCHANT
///=============================================================================
/// @name MERCHANT
///=============================================================================

@interface DMHListMerchant : NSObject<YYModel>
///> 商家: logo 
@property (nonatomic, strong) NSString *logo;
///> 商家: 名称 
@property (nonatomic, strong) NSString *name;
///> 商家: 职称 
@property (nonatomic, strong) NSString *position;
///> 商家: VIP 
@property (nonatomic, strong) NSString *isAuth;
///> 商家: 职位名称 
@property (nonatomic, strong) NSString *jobName;
///> 商家: 类目 
@property (nonatomic, strong) NSString *jobTypeName;
///> 商家: 公司名称 
@property (nonatomic, strong) NSString *companyName;
///> 商家: 公司ID 
@property (nonatomic, strong) NSString *companyId;
///> 商家: 会话ID 
@property (nonatomic, strong) NSString *userId;
///> 商家: 活跃描述 
@property (nonatomic, strong) NSString *activeMsg;
@end

#pragma mark - LIST_ITEM
///=============================================================================
/// @name LIST_ITEM
///=============================================================================

///> 首页: List项模型 
@interface DMHListItem : NSObject<DMHListDelegate>
///> 职位: ID 
@property (nonatomic, strong) NSString *jobID;
///> 职位: 模板类型 
@property (nonatomic, strong) NSString *templateType;
///> 职位: 是否急聘 
@property (nonatomic, assign) BOOL isJipin;
///> 职位: 是否自营 
@property (nonatomic, assign) BOOL isZiyin;
///> 职位: 图片个数(详情页使用)
@property (nonatomic, strong) NSString *imagesNum;
///> 职位: 职位公司名称
@property (nonatomic, strong) NSString *companyName;
///> 职位: 是否 
@property (nonatomic, assign) BOOL isToutiao;
///> 职位: 是否可聊 
@property (nonatomic, assign) BOOL canChat;
///> 职位: 是否可投简历 
@property (nonatomic, assign) BOOL canApply;
///> 职位: 位置 
@property (nonatomic, strong) NSString *postArea;
///> 职位: 名称 
@property (nonatomic, strong) NSString *jobTypeStr;
///> 职位: 名称
@property (nonatomic, strong) NSString *jobType;
///> 职位: 距离 
@property (nonatomic, strong) NSString *distance;
///> 职位: 组装distance+postArea 
@property (nonatomic, strong) NSString *disArea;
///> 职位: 亮点 
@property (nonatomic, strong) NSString *postNote;
///> 职位: 标题 
@property (nonatomic, strong) NSString *title;
///> 职位: 工资 
@property (nonatomic, strong) NSString *salary;
///> 职位: 工资单位 
@property (nonatomic, strong) NSString *salaryUnit;
///> 职位: 工资每* 
@property (nonatomic, strong) NSString *salaryType;
///> 职位: 工资描述(组装) 
@property (nonatomic, strong) NSString *salaryUnitStr;
///> 职位: 薪资面议 
@property (nonatomic, assign) BOOL isSalaryNego;
///> 职位: 默认图片 
@property (nonatomic, strong) NSString *image;
///> 职位: 图片 
@property (nonatomic, strong) NSString *postImage;
///> 职位: 福利tags 
@property (nonatomic, strong) NSArray<NSString *> *welfareTags;
///> 职位: 福利tags 
@property (nonatomic, strong) NSArray<NSString *> *oriWelfareTags;
///> 职位: 商家 
@property (nonatomic, strong) DMHListMerchant *merchant;
///> 职位: 会话ID 
@property (nonatomic, strong) NSString *userId;
///> 职位: 是否显示图片 
@property (nonatomic, assign) BOOL showImg;
///> 职位: 类型 1兼职,2全职 
@property (nonatomic, assign) NSInteger workType;
///> 职位: 结算方式 
@property (nonatomic, strong) NSString *paymentTypeStr;
///> 职位: 埋点用 
@property (nonatomic, strong) NSString *adType;
///> 职位: 
@property (nonatomic, strong) NSString *auditAt;
///> 
@property (nonatomic, strong) NSAttributedString *postAttri;

@property (nonatomic, assign) BOOL hasTap;
///> 职位: 计算所得高度 
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat titleH;
@property (nonatomic, assign) CGFloat tagsH;
@property (nonatomic, assign) CGFloat noteH;
@end

#pragma mark - PANEL_ITEM
///=============================================================================
/// @name PANEL_ITEM
///=============================================================================

///> 热门职位 
@interface DMHHot : NSObject<YYModel>
///>  
@property (nonatomic, strong) NSString *id;
///>  
@property (nonatomic, strong) NSString *word;
///>  
@property (nonatomic, assign) BOOL isHot;
@end

///> 运营位 
@interface DMHZone : NSObject
///>  
@property (nonatomic, strong) NSString *id;
///>  
@property (nonatomic, strong) NSString *title;
///>  
@property (nonatomic, strong) NSString *subtitle;
///>  
@property (nonatomic, strong) NSString *url;
///>  
@property (nonatomic, strong) NSString *image;
///>  
@property (nonatomic, strong) NSString *dmalog;
@end

///> Banner位 
@interface DMHBannerItem : NSObject<YYModel>
///> 图片 
@property (nonatomic, copy) NSString *url;
///> 标题 
@property (nonatomic, copy) NSString *title;
///> id 
@property (nonatomic, copy) NSString *id;
///> 标题 
@property (nonatomic, copy) NSString *image;
///> 1:普通;2:广告 
@property (nonatomic, assign) NSInteger type;
///> 品牌名称 
@property (nonatomic, copy) NSString *brandName;
///>  
@property (nonatomic, strong) NSString *dmalog;
@end

@interface DMDingYueModel : NSObject<DMHListDelegate>
@end

#pragma mark - PANEL
///=============================================================================
/// @name PANEL
///=============================================================================

@interface DMHPanelModel<__covariant ObjectType> : NSObject<YYModel, DMHListDelegate>
///> 模板: 类型 
@property (nonatomic, strong) NSString *type;
///> 模板: 标题 
@property (nonatomic, strong) NSString *title;
///> 模板: 数据 
@property (nonatomic, strong) NSArray<ObjectType> *list;
///> 模板: 位置 
@property (nonatomic, assign) NSInteger position;
///> 模板: 相对位置 
@property (nonatomic, assign) NSInteger idx;

- (NSString *)panelId;
@end

@interface DMHPanel : NSObject<YYModel>
///> pannel: 运营位 
@property (nonatomic, strong) NSArray<DMHZone *> *zone;
///> pannel: 关键词 
@property (nonatomic, strong) NSArray<DMHHot *> *hot;
///> pannel: Banner位 
@property (nonatomic, strong) NSArray<DMHBannerItem *> *banner1;
///> pannel: 商家s 
@property (nonatomic, strong) DMHPanelModel<DMHListMerchant *> *merchant;
///>  
@property (nonatomic, strong) NSArray<DMHPanelModel *> *arr;
@end

@interface DMHPanelPosition : NSObject<YYModel>
///> pannel位置: 运营位 
@property (nonatomic, strong) NSString *zone;
///> pannel位置: 关键词 
@property (nonatomic, strong) NSString *hot;
///> pannel位置: 商家s 
@property (nonatomic, strong) NSString *merchant;
///> pannel位置: banner 
@property (nonatomic, strong) NSString *banner;
@end

@interface DMHDefaultMore : NSObject<YYModel>
///>  
@property (nonatomic, strong) NSString *sex;
///>  
@property (nonatomic, strong) NSString *identity;
@end

#pragma mark - HOME_DATA
///=============================================================================
/// @name HOME_DATA
///=============================================================================
/*!
 * 首页: 数据模型
 */
@interface DMHListModel : NSObject<YYModel>
///> 当前页码 
@property (nonatomic, assign) NSInteger curPage;
///> 最后页码 
@property (nonatomic, assign) NSInteger lastPage;
///> 订阅数 
@property (nonatomic, assign) NSInteger fetchNum;
///> 
@property (nonatomic, assign) BOOL isLast;
///> 
@property (nonatomic, assign) BOOL isDingyue;
///>
@property (nonatomic, assign) BOOL nopanel;
///> 
@property (nonatomic, assign) NSInteger workType;
///> 
@property (nonatomic, strong) NSMutableArray<id<DMHListDelegate>> *data;
///>  
@property (nonatomic, strong) DMHDefaultMore *defaultMore;
///> 
@property (nonatomic, strong) DMHPanelPosition *panelPosition;
///>  
@property (nonatomic, strong) DMHPanel *panel;
///> 是否报名成功过 
@property (nonatomic, assign) BOOL hasApply;

- (NSArray<NSIndexPath *> *)addNextPage:(NSDictionary *)dict;

#pragma mark - Dingyue
///=============================================================================
/// @name 订阅
///=============================================================================
+ (BOOL)needShowDingyue;
+ (BOOL)needShowDingyueCell;
+ (void)updateShowDingyueCell:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
