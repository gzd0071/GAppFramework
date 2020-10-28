//
//  GMapView.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/11/22.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GProtocol/ViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GMAction) {
    /// Anno位置变更
    GMActionAnno,
};

typedef NS_OPTIONS(NSUInteger, GMConfig) {
    /// 手势是否可用
    GMConfigGestureDisabled = (1 << 0),
    /// 定位图层是否显示
    GMConfigUserLocation    = (1 << 1),
    /// poi标注是否显示底图, 默认显示
    GMConfigMapPoiDisabled  = (1 << 2)
};

@interface GMapPModel : NSObject
///> 地图: 地图比例尺级别，在手机上当前可使用的级别为4-21级
@property (nonatomic) float zoomLevel;
///> 地图: 配置选项
@property (nonatomic, assign) GMConfig config;
///> 地图: 经纬度
@property (nonatomic, assign) CLLocationCoordinate2D coor;
@end

///> 视图: 地图视图
@interface GMapView : UIView<ViewDelegate>
@end

NS_ASSUME_NONNULL_END
