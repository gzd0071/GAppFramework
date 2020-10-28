//
//  GLocation.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/15.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "GLocation.h"
#import <GLogger/Logger.h>
#import <YYKit/NSObject+YYModel.h>
#import <GPermission/GPermission.h>
#import <GHttpRequest/HttpRequest.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <YYKit/NSString+YYAdd.h>
#import <GTask/GTaskResult.h>

@implementation GLLocationModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"cityID"  : @"id",
             @"city"    : @"name",
             @"parentID": @"parent_id"
             };
}
@end

@interface DMLocationSearch : NSObject<BMKGeoCodeSearchDelegate>
///> 
@property (nonatomic, strong) BMKGeoCodeSearch *search;
///> 
@property (nonatomic, strong) GTaskSource *tcs;
///>  
@property (nonatomic, strong) NSMutableArray *arr;
@end
@implementation DMLocationSearch

+ (instancetype)search {
    static DMLocationSearch *search = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        search = [DMLocationSearch new];
        search.arr = @[].mutableCopy;
    });
    return search;
}

#pragma mark - Public
///=============================================================================
/// @name Public
///=============================================================================

/// 搜索: 根据地理坐标获取地址信息
- (GTask<GTaskResult<BMKReverseGeoCodeSearchResult *> *> *)reverseGeocode:(CLLocationCoordinate2D)coor {
    [[DMLocationSearch search].arr addObject:self];
    BMKReverseGeoCodeSearchOption *opt = [[BMKReverseGeoCodeSearchOption alloc]init];
    opt.location = coor;
    self.search.delegate = self;
    [self.search reverseGeoCode:opt];
    return _tcs.task;
}
/// 搜索: 根据地址名称获取地理信息
- (GTask<GTaskResult<BMKGeoCodeSearchResult *> *> *)geocode:(NSString *)city addr:(NSString *)addr {
    [[DMLocationSearch search].arr addObject:self];
    BMKGeoCodeSearchOption *opt = [[BMKGeoCodeSearchOption alloc]init];
    opt.city    = city;
    opt.address = addr;
    self.search.delegate = self;
    [self.search geoCode:opt];
    return _tcs.task;
}

#pragma mark - BMKGeoCodeSearchDelegate
///=============================================================================
/// @name BMKGeoCodeSearchDelegate
///=============================================================================

///> 返回地址信息搜索结果 
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    [[DMLocationSearch search].arr removeObject:self];
    GTaskResult *tr = GTaskResult(error==BMK_SEARCH_NO_ERROR, result);
    [_tcs setResult:tr];
    self.search.delegate = nil;
}
///> 返回反地理编码搜索结果 
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    [[DMLocationSearch search].arr removeObject:self];
    GTaskResult *tr = GTaskResult(error==BMK_SEARCH_NO_ERROR, result);
    [_tcs setResult:tr];
    self.search.delegate = nil;
}

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)init {
    if (self = [super init]) {
        _tcs    = [GTaskSource source];
        _search = [BMKGeoCodeSearch new];
    }
    return self;
}
@end

#define kLocationKey @"kLocationKey"

@interface GLocation ()<BMKGeneralDelegate, BMKLocationManagerDelegate, BMKLocationAuthDelegate>
///> 地图: 管理 
@property (nonatomic, strong) BMKMapManager *manager;
///> 定位: 定位管理 
@property (nonatomic, strong) BMKLocationManager *locManager;
@end

@implementation GLocation

+ (instancetype)location {
    static GLocation *location;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        location = [GLocation new];
        NSString *json = [[NSUserDefaults standardUserDefaults] valueForKey:kLocationKey];
        if (json) {
            LOGI(@"[LOGIN] => Local Location data:%@", [json jsonValueDecoded]);
            [location modelSetWithJSON:[json jsonValueDecoded]];
        }
        if (!location.model) location.model = [GLLocationModel new];
    });
    return location;
}

- (GLLocationModel *)smodel {
    if (!_smodel) return _model;
    return _smodel;
}

- (void)updateSelectModel:(NSDictionary *)args {
    GLLocationModel *sm = _smodel;
    if (!sm) sm = [GLLocationModel new];
    sm.city   = args[@"cityname"];
    sm.domain = args[@"citydomain"];
    sm.cityID = args[@"cityid"];
    sm.done   = YES;
    [GLocation location].smodel = sm;
}

- (void)save {
    NSString *model  = [self.model modelToJSONObject];
    NSString *smodel = [self.smodel modelToJSONObject];
    NSMutableDictionary *mut = @{}.mutableCopy;
    mut[@"model"]  = model;
    mut[@"smodel"] = smodel;
    mut[@"changed"] = @(self.changed);
    mut[@"timestamp"] = self.timestamp;
    [[NSUserDefaults standardUserDefaults] setValue:[mut jsonString] forKey:kLocationKey];
}

///> 数据: 更新选择城市smodel数据 
+ (void)updateSelectModel:(NSDictionary *)args {
    [[GLocation location] updateSelectModel:args];
    [[GLocation location] save];
}

#pragma mark - AUTH
///=============================================================================
/// @name AUTH
///=============================================================================

+ (void)startWithKey:(NSString *)key {
    [[GLocation location] startWithKey:key];
}

- (void)startWithKey:(NSString *)key {
    if (_manager) return;
    [GPermission locationPreAuth:LocationAuthTypeWhenInUse];
    self.manager    = [BMKMapManager new];
    self.locManager = [[BMKLocationManager alloc] init];
    self.locManager.delegate = self;
    [self.manager start:key generalDelegate:self];
}

///> 返回网络错误 
- (void)onGetNetworkState:(int)iError {
    // TODO: 监听网络状态变化重新授权
}

///> 返回授权验证错误 
- (void)onGetPermissionState:(int)iError {
    if (iError == 0) LOGI(@"[Location] => 百度地图 授权成功");
}

#pragma mark - BMKLocationManagerDelegate
///=============================================================================
/// @name BMKLocationManagerDelegate
///=============================================================================

///> 定位: 权限状态改变时回调函数 
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([GPermission location] == AuthStatusAuthorized) {
        [self requestLocation];
    }
}

#pragma mark - EXPORTS
///=============================================================================
/// @name EXPORTS
///=============================================================================

+ (GTask<GTaskResult<GLLocationModel *> *> *)requestLocation {
    return [[GLocation location] requestLocation];
}
/// 定位: 单次获取定位
- (GTask<GTaskResult<GLLocationModel *> *> *)requestLocation {
    if ([GPermission location] != AuthStatusAuthorized) return nil;
    __block CLLocationCoordinate2D coor;
    // a. 从百度定位获取latlng
    return [self requestLocationKit].then(^id(GTaskResult<BMKLocation *> *t){
        if (t.suc) {
            coor = t.data.location.coordinate;
            //TODO: 是否等三个步骤完成后才保存应该延迟保存
            [GLocation location].model.lat = FORMAT(@"%.6f", coor.latitude);
            [GLocation location].model.lng = FORMAT(@"%.6f", coor.longitude);
            return [self requestServer:coor];
        }
        return t;
    })
    // b. 从服务端获取数据
    .then(^id(HttpResult *t) {
        if ([t isKindOfClass:GTaskResult.class]) return t;
        if (t.code == 200) {
            [[GLocation location].model modelSetWithJSON:t.extra];
            return [[DMLocationSearch new] reverseGeocode:coor];
        }
        return [GTaskResult taskResultWithSuc:NO data:[GLocation location].model];
    })
    // c. 从百度Search服务获取地址详细数据
    .then(^id (GTaskResult<BMKReverseGeoCodeSearchResult *> *t) {
        if ([t.data isKindOfClass:GLLocationModel.class]) {
            return t;
        }
        if (!t.suc) return [GTaskResult taskResultWithSuc:NO data:[GLocation location].model];
        id data = [t.data.addressDetail modelToJSONObject];
        [[GLocation location].model modelSetWithJSON:data];
        [GLocation location].model.address  = t.data.address;
        [GLocation location].model.business = t.data.businessCircle;
        [GLocation location].model.done = YES;
        [GLocation location].timestamp = [GConvenient timestamp];
        [[GLocation location] save];
        return [GTaskResult taskResultWithSuc:YES data:[GLocation location].model];
    });
}

- (GTask *)requestLocationKit {
    GTaskSource *tcs = [GTaskSource source];
    [self.locManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation *location, BMKLocationNetworkState state, NSError *error) {
        if (error && error.code != 7) LOGE(@"[Location] => locError:{%ld - %@};", (long)error.code, error.localizedDescription);
        if (location) {
            [tcs setResult:GTaskResult(YES, location)];
        } else {
            [tcs setResult:GTaskResult(NO, [GLocation location].model)];
        }
    }];
    return tcs.task;
}

- (GTask *)requestServer:(CLLocationCoordinate2D)coor {
    id url = FORMAT(@"/api/v2/client/latlng/%f,%f", coor.latitude, coor.longitude) ;
    return [HttpRequest jsonRequest].urlString(url).task;
}

+ (GTask *)requestLatLng {
    return [[GLocation location] requestLocationKit].then(^id(GTaskResult<BMKLocation *> *result) {
        if (!result.suc) return @NO;
        CLLocationCoordinate2D coor = result.data.location.coordinate;
        return ATuple(@YES, @(coor.latitude), @(coor.longitude));
    });
}

@end
