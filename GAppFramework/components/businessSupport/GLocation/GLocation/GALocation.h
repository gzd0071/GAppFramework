//
//  GALocation.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/11/22.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GTask<T>;
@class GTaskResult<T>;
typedef struct CLLocationCoordinate2D CLLocationCoordinate2D;

// MARK: GAPoiModel
////////////////////////////////////////////////////////////////////////////////
/// @@class GAPoiModel
////////////////////////////////////////////////////////////////////////////////

@interface GAPoiModel : NSObject
///> POI名称
@property (nonatomic, strong) NSString *name;
///> POI坐标
@property (nonatomic, assign) CLLocationCoordinate2D pt;
///> POI地址信息
@property (nonatomic, strong) NSString *address;
///> POI所在城市
@property (nonatomic, strong) NSString *city;
///> POI所在行政区域
@property (nonatomic, strong) NSString *area;
///> POI检索key
@property (nonatomic, strong) NSString *key;
@end

// MARK: GAPoiModel
////////////////////////////////////////////////////////////////////////////////
/// @@class GAPoiModel
////////////////////////////////////////////////////////////////////////////////

@interface GALocation : UIView

/// 地理编码搜索结果
/// @param coor 地理编码位置
+ (GTask<GTaskResult *> *)reverseGeo:(CLLocationCoordinate2D)coor;

/// 地点输入POI提示检索
/// @param city {NSString *} 城市名称 e.g. "北京"
/// @param keyword {NSString *}
+ (GTask<GTaskResult *> *)poiCity:(NSString *)city keyword:(NSString *)keyword;
@end

NS_ASSUME_NONNULL_END
