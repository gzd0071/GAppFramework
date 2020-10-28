//
//  DMHFilterModel.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/13.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMHListModel.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const FMV_TUIJIE;
extern NSString * const FMV_DINGYUE;
extern NSString * const FMV_FEATURE;

extern NSString * const FMV_CITY;
extern NSString * const FMV_ZIYING;
extern NSString * const FMV_FILTER;
extern NSString * const FMV_JOB_TYPE;

@interface FilterSelectItem : NSObject<YYModel>
///> 
@property (nonatomic, strong) NSString *sex;
///> 
@property (nonatomic, strong) NSString *identity;
///> 
@property (nonatomic, strong) NSString *ziying;
///> 
@property (nonatomic, strong) NSString *jobType;
@end

/*!
 * 首页: filter项模型
 */
@interface FilterItem : NSObject<YYModel>
///> 名称 
@property (nonatomic, strong) NSString *name;
///> 类型 
@property (nonatomic, assign) NSInteger type;
///> 值 
@property (nonatomic, strong) NSString *value;
///> 
@property (nonatomic, strong) NSString *key;
///>  
@property (nonatomic, assign) BOOL multi;
///> 子项 
@property (nonatomic, strong) NSArray<FilterItem *> *filterItems;

///> 是否选中 
@property (nonatomic, assign) BOOL select;
///> filterItems选中项 
@property (nonatomic, assign) NSInteger selIdx;
///> 选中文案名称 
@property (nonatomic, strong) NSString *sname;
@end

/*!
 * 首页: filter数据模型
 */
@interface DMHFilterModel : NSObject<YYModel>
///> 性别 
@property (nonatomic, copy) NSString *sex;
///> identity 
@property (nonatomic, copy) NSString *identify;
///> 是否全职 
@property (nonatomic, assign) BOOL isFull;
/// 是否显示精选
@property (nonatomic, assign) BOOL showJinxuan;
///> tab项 
@property (nonatomic, strong) NSArray<FilterItem *> *filterTabs;
///> menu项 
@property (nonatomic, strong) NSArray<FilterItem *> *filterMenus;
///> hot词 
@property (nonatomic, strong) NSArray<DMHHot *> *hots;

///> 更新more默认选中数据 
- (void)updateDefaultMore:(DMHDefaultMore *)more;

///> 重置筛选条件 
- (void)resetFilterMenus;
///> 是否为默认筛选条件 
- (BOOL)isDefaultFilter;
///> 曝光: item 
- (NSString *)filterItem:(NSString *)city;
- (NSString *)filterMoreItem;
@end

NS_ASSUME_NONNULL_END
