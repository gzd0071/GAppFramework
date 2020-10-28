//
//  GALocation.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/11/22.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "GALocation.h"
#import <YYKit/NSObject+YYModel.h>
#import <GBaseLib/NSArray+Extend.h>
#import <GLogger/Logger.h>
#import <GTask/GTask.h>
#import <GTask/GTaskResult.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "GLocation.h"

@implementation GAPoiModel
@end

// MARK: DMGeoSearch
////////////////////////////////////////////////////////////////////////////////
/// @@class DMGeoSearch
////////////////////////////////////////////////////////////////////////////////

@interface DMGeoSearch : NSObject<BMKGeoCodeSearchDelegate>
///>
@property (nonatomic, strong) BMKGeoCodeSearch *search;
///>
@property (nonatomic, strong) GTaskSource *tcs;
///>
@property (nonatomic, strong) NSMutableArray *arr;
@end
@implementation DMGeoSearch

+ (instancetype)search {
    static DMGeoSearch *search = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        search = [DMGeoSearch new];
        search.search = nil;
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
    [[DMGeoSearch search].arr addObject:self];
    BMKReverseGeoCodeSearchOption *opt = [[BMKReverseGeoCodeSearchOption alloc]init];
    opt.location = coor;
    self.search.delegate = self;
    [self.search reverseGeoCode:opt];
    return _tcs.task;
}
/// 搜索: 根据地址名称获取地理信息
- (GTask<GTaskResult<BMKGeoCodeSearchResult *> *> *)geocode:(NSString *)city addr:(NSString *)addr {
    [[DMGeoSearch search].arr addObject:self];
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

/*! 返回地址信息搜索结果 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    [[DMGeoSearch search].arr removeObject:self];
    GTaskResult *tr = GTaskResult(error==BMK_SEARCH_NO_ERROR, result);
    [_tcs setResult:tr];
    self.search.delegate = nil;
}
/*! 返回反地理编码搜索结果 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    [[DMGeoSearch search].arr removeObject:self];
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

// MARK: BMKPOICitySearchOption
////////////////////////////////////////////////////////////////////////////////
/// @@class BMKPOICitySearchOption
////////////////////////////////////////////////////////////////////////////////

@interface DMPoiSearch : NSObject<BMKPoiSearchDelegate>
/// 提示检索器
@property (nonatomic, strong) BMKPoiSearch *search;
/// 任务管理
@property (nonatomic, strong) GTaskSource *tcs;
///
@property (nonatomic, strong) NSMutableArray *arr;
@end
@implementation DMPoiSearch
#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================
+ (instancetype)search {
    static DMPoiSearch *search = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        search = [DMPoiSearch new];
        search.search = nil;
        search.arr = @[].mutableCopy;
    });
    return search;
}
- (instancetype)init {
    if (self = [super init]) {
        _tcs    = [GTaskSource source];
        _search = [BMKPoiSearch new];
    }
    return self;
}

- (GTask<GTaskResult *> *)poiCity:(NSString *)city keyword:(NSString *)keyword {
    if (!keyword || keyword.length == 0) return [GTask taskWithValue:GTaskResult(NO)];
    [[DMPoiSearch search].arr addObject:self];
    BMKPOICitySearchOption *option = [BMKPOICitySearchOption new];
    option.city = city;
    option.isCityLimit = YES;
    option.keyword  = keyword;
    self.search.delegate = self;
    [self.search poiSearchInCity:option];
    return _tcs.task;
}

- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPOISearchResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    [[DMPoiSearch search].arr removeObject:self];
    self.search.delegate = nil;
    GTaskResult *tr = GTaskResult(errorCode==BMK_SEARCH_NO_ERROR, poiResult);
    [_tcs setResult:tr];
    self.search.delegate = nil;
}
@end

// MARK: GALocation
////////////////////////////////////////////////////////////////////////////////
/// @@class GALocation
////////////////////////////////////////////////////////////////////////////////

@interface GALocation ()
///>
@property (nonatomic, strong) BMKMapManager *manager;
@end

@implementation GALocation

+ (GTask<GTaskResult *> *)reverseGeo:(CLLocationCoordinate2D)coor {
    return [[DMGeoSearch new] reverseGeocode:coor]
    .then(^id(GTaskResult<BMKReverseGeoCodeSearchResult *> *t) {
        if (!t.suc) return GTaskResult(NO);
        GAPoiModel *model = [GAPoiModel new];
        model.name = t.data.sematicDescription;
        model.address = t.data.address;
        model.city = t.data.addressDetail.city;
        model.area = t.data.addressDetail.district;
        id list = [t.data.poiList map:^id(BMKPoiInfo *each) {
            GAPoiModel *model = [GAPoiModel modelWithJSON:[each modelToJSONObject]];
            model.pt = each.pt;
            return model;
        }];
        NSMutableArray *newList = @[model].mutableCopy;
        [newList addObjectsFromArray:list];
        return GTaskResult(YES, newList.copy);
    });
}

+ (GTask<GTaskResult *> *)poiCity:(NSString *)city keyword:(NSString *)keyword {
    return [[DMPoiSearch new] poiCity:city keyword:keyword]
    .then(^id(GTaskResult<BMKPOISearchResult *> *t) {
        if (!t.suc) return GTaskResult(NO);
        id list = [t.data.poiInfoList map:^id(BMKPoiInfo *each) {
            GAPoiModel *model = [GAPoiModel modelWithJSON:[each modelToJSONObject]];
            model.pt = each.pt;
            model.key = keyword;
            return model;
        }];
        return GTaskResult(YES, list);
    });
}

@end
