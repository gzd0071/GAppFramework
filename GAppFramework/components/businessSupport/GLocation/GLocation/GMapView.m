//
//  GMapView.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/11/22.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "GMapView.h"
#import <GTask/GInvokeBlock.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@implementation GMapPModel
@end

@interface GMapView ()<BMKMapViewDelegate>
///> 事件:
@property (nonatomic, strong) id action;
///> 数据:
@property (nonatomic, strong) GMapPModel *model;
///> 视图: 地图
@property (nonatomic, strong) BMKMapView *map;
///> 当前定位
@property (nonatomic, assign) CLLocationCoordinate2D location;
///>
@property (nonatomic, strong) BMKPointAnnotation *anno;
@end

@implementation GMapView

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (nonnull id)viewWithFrame:(CGRect)frame model:(nullable id)model baction:(nullable BActionBlock)action {
    return [[self alloc] initWithFrame:frame model:model action:action];
}

- (instancetype)initWithFrame:(CGRect)frame model:(id)model action:(BActionBlock)action {
    if (self = [super initWithFrame:frame]) {
        self.action = action;
        self.model = model;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        [self addViews];
        [self updateLoc:self.model.coor];
    }
    return self;
}

- (void)addViews {
    [self addSubview:self.map];
    [self addSubview:self.loc];
}

#pragma mark - BMKMapViewDelegate
///=============================================================================
/// @name BMKMapViewDelegate
///=============================================================================

- (void)updateLoc:(CLLocationCoordinate2D)loc {
    _map.delegate = self;
    _location = loc;
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = loc;
    annotation.isLockedToScreen = YES;
    self.anno = annotation;
    self.anno.screenPointToLock = CGPointMake(SCREEN_WIDTH/2, _map.height/2);
    [_map addAnnotation:annotation];
    [_map setCenterCoordinate:loc animated:NO];
    [_map setMapCenterToScreenPt:CGPointMake(SCREEN_WIDTH/2, _map.height/2)];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView
             viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (!annotationView) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.pinColor = BMKPinAnnotationColorRed;
        annotationView.image = [UIImage imageNamed:@"detail_map_pin"];
        return annotationView;
    }
    return nil;
}

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    self.anno.screenPointToLock = CGPointMake(SCREEN_WIDTH/2, _map.height/2);
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    id tuple = ATuple(@(GMActionAnno), @(self.anno.coordinate.latitude), @(self.anno.coordinate.longitude));
    if (self.action) ACallBlock(self.action, tuple);
}

#pragma mark - Views
///=============================================================================
/// @name Views
///=============================================================================

- (BMKMapView *)map {
    if (!_map) {
        _map = [BMKMapView new];
        _map.mapType = BMKMapTypeStandard;
        _map.zoomLevel = self.model.zoomLevel ?: 16;
        _map.gesturesEnabled = !(self.model.config & GMConfigGestureDisabled);
        _map.frame = self.bounds;
        if (self.model.config & GMConfigUserLocation) _map.showsUserLocation = YES;
        if (self.model.config & GMConfigMapPoiDisabled) _map.showMapPoi = NO;
    }
    return _map;
}

- (UIImageView *)loc {
    UIImageView *img = [UIImageView new];
    img.frame = CGRectMake(self.width-54, self.height-54, 48, 48);
    img.image = IMAGE(@"loc_action");
    [img addTapGesture:^{
        [self.map setCenterCoordinate:self.location animated:YES];
    }];
    return img;
}

@end
