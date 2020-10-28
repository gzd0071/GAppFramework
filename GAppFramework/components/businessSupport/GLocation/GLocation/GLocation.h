//
//  GLocation.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/15.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GBaseLib/GConvenient.h>

NS_ASSUME_NONNULL_BEGIN

////////////////////////////////////////////////////////////////////////////////
// @class GLLocationModel
////////////////////////////////////////////////////////////////////////////////

@interface GLLocationModel : NSObject
#pragma mark - FIRST PART
///=============================================================================
/// @name FIRST PART: 定位获取
///=============================================================================
///> 地址: 纬度
@property (nonatomic, strong) NSString *lat;
///> 地址: 经度
@property (nonatomic, strong) NSString *lng;

#pragma mark - SECOND PART
///=============================================================================
/// @name SECOND PART: 服务端获取
///=============================================================================
///> 地址: 城市ID
@property (nonatomic, strong) NSString *cityID;
///> 地址: 城市简拼
@property (nonatomic, strong) NSString *domain;
///> 地址: 城市全拼
@property (nonatomic, strong) NSString *pinyin;
///> 地址: 城市规模(1开始; 对应一二三四五线城市)
@property (nonatomic, assign) NSInteger level;
///> 地址: 城市父ID
@property (nonatomic, strong) NSString *parentID;

#pragma mark - THIRD PART
///=============================================================================
/// @name THIRD PART: 百度地图搜索获取
///=============================================================================
///> 地址: 国家
@property (nonatomic, strong) NSString *country;
///> 地址: 省份
@property (nonatomic, strong) NSString *province;
///> 地址: 城市
@property (nonatomic, strong) NSString *city;
///> 地址: 区县名称
@property (nonatomic, strong) NSString *district;
///> 地址: 乡镇
@property (nonatomic, strong) NSString *town;
///> 地址: 街道名
@property (nonatomic, strong) NSString *streetName;
///> 地址: 街道号
@property (nonatomic, strong) NSString *streetNumber;
///> 地址: 行政区域编码
@property (nonatomic, strong) NSString *adCode;
///> 地址: 国家代码
@property (nonatomic, strong) NSString *countryCode;
///> 地址: 方向
@property (nonatomic, strong) NSString *direction;
///> 地址: 距离
@property (nonatomic, strong) NSString *distance;

///> 地址: 地址信息
@property (nonatomic, strong) NSString *address;
///> 地址: 商圈
@property (nonatomic, strong) NSString *business;

#pragma mark - FOURTH PART
///=============================================================================
/// @name FOURTH PART: 结束
///=============================================================================
///> 地址: 获取结束, 用于监听变化
@property (nonatomic, assign) BOOL done;
@end

////////////////////////////////////////////////////////////////////////////////
// @class GLocation
////////////////////////////////////////////////////////////////////////////////

@interface GLocation : NSObject

#pragma mark - Property
///=============================================================================
/// @name Property
///=============================================================================

///> 定位: 变化
@property (nonatomic, assign) BOOL changed;
///> 定位: 更新时间
@property (nonatomic, strong) NSString *timestamp;
///> 定位: 定位数据
@property (nonatomic, strong) GLLocationModel *model;
///> 定位: 选择定位
@property (nonatomic, strong) GLLocationModel *smodel;

#pragma mark - Functions
///=============================================================================
/// @name Functions
///=============================================================================

///> 定位: 单例
+ (instancetype)location;
///> 定位: 初始化
+ (void)startWithKey:(NSString *)key;
///> 定位: 单次获取定位权限(斗米一整套定位流程)
+ (GTask<GTaskResult<GLLocationModel *> *> *)requestLocation;
/// 定位: 单次获取定位权限
/// @return {BOOL suc, NSNumber *lat, NSNumber *lng}
+ (GTask *)requestLatLng;
///> 数据: 更新选择城市smodel数据 
+ (void)updateSelectModel:(NSDictionary *)args;

@end

NS_ASSUME_NONNULL_END
