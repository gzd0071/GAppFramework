//
//  GHomeListViewController.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/18.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "GHomeListViewController.h"
#import "DMHNavBar.h"
#import "DMHDropMenuView.h"
#import "DMHListModel.h"
#import "DMHCityModel.h"
#import "DMHCity.h"
#import "DMHAddr.h"
#import "DMHFilterList.h"
#import <GBaseLib/iCarousel.h>
#import "DMHListView.h"
#import "DMResume.h"
#import <GBaseLib/GConvenient.h>
#import <GProtocol/ViewProtocol.h>
#import <YYKit/NSString+YYAdd.h>
#import <GLogger/Logger.h>
#import <GRouter/GRouter.h>
#import <GMainTab/GMainTab.h>
#import <GHttpRequest/HttpRequest.h>
#import <GBaseLib/MBProgressHUD+MJ.h>
#import <GLocation/GLocation.h>
#import <DMUILib/DMEmpty.h>
#import <DMUILib/DMAlertActions.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>
#import <GConst/URDConst.h>
#import <GTask/GTask+Fwd.h>
#import <GBaseLib/NSDictionary+Extend.h>

@interface GHomeListViewController ()<iCarouselDataSource, iCarouselDelegate, DMHParamsListDelegate, GMainTabDelegate>
///> 数据: 筛选 
@property (nonatomic, strong) DMHFilterModel *filterModel;
///> 数据: jobType 
@property (nonatomic, strong) FilterItem *jobTypeModel;
///> 视图: 导航条 
@property (nonatomic, strong) DMHNavBar *navBar;
///> 视图: 筛选栏 
@property (nonatomic, strong) DMHDropMenuView *menu;
///> 视图: 可滑动列表 
@property (nonatomic, strong) iCarousel *ic;
///> 视图: 下拉视图 
@property (nonatomic, strong) UIView<DMHDropDelegate> *drop;

///> 城市: 区域ID 
@property (nonatomic, strong) NSString *districtId;
///> 城市: 街道ID 
@property (nonatomic, strong) NSString *streetId;
///> 城市: 字符串 
@property (nonatomic, strong) NSString *cityStr;
///> 数据: 筛选 
@property (nonatomic, strong) NSDictionary *more;
///> 数据: 是否为自营 
@property (nonatomic, assign) BOOL ziyin;
///>  
@property (nonatomic, assign) BOOL ding;

@end

@implementation GHomeListViewController

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dmBarHidden = YES;
    self.view.backgroundColor = HEX(@"f7f7f7", @"000000");
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.filterModel = [DMHFilterModel modelWithJSON:@{@"isFull": @YES}];
    self.more = @{@"sex_demand": [DMResume share].sex,
                  @"identity_demand": [DMResume share].identity};
    [self startLocation];
    [self requestDropMenuData];
    [self addNoti];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self handleExposure:self.ic.currentItemIndex];
}

///> tab双击事件 
- (void)tapSelectedTapItem {
    if (self.filterModel.filterTabs) {
        [self refreshVisiable];
    } else {
        [self requestDropMenuData];
    }
}

- (void)tabViewControllerVisible:(NSDictionary *)params {
    if (!params[@"tab"]) return;
    if ([params[@"tab"] isEqualToString:@"sub"] &&
        self.ic.currentItemIndex != 0 &&
        self.filterModel.filterTabs.count &&
        [self.filterModel.filterTabs[0].key isEqualToString:FMV_DINGYUE]) {
        [self.ic scrollToItemAtIndex:0 animated:YES];
    } else if (!self.ic && [params[@"tab"] isEqualToString:@"sub"]) {
        self.ding = YES;
    }
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

- (void)navActions:(RACTuple *)tuple {
    [self dropDismiss:NO com:nil];
    if ([tuple.first isEqualToString:@"location"]) {
        ///> 选择城市
        [GRouter router:URDS(CSCHEME, URD_CITY_SELECT) navi:self.navigationController];
    } else if ([tuple.first isEqualToString:@"sign"]) {
        ///> 签到
        [GRouter router:URDS(CSCHEME, URD_SIGN) navi:self.navigationController];
    } else if ([tuple.first isEqualToString:@"search"]) {
        ///> 搜索
        id urd = FORMAT(@"%@%@&workType=%@", URD(URD_SEARCH), tuple.second, self.workType);
        ROUTER(urd);
    } else if ([tuple.first isEqualToString:@"refresh"]) {
        ///> 选择了新城市
        [self updateList];
    }
}

- (void)icActions:(RACTuple *)tuple {
    if ([tuple.first isEqualToString:@"hot"]) {
    } else if ([tuple.first isEqualToString:@"more"]) {
        NSMutableDictionary *mut = self.more.mutableCopy;
        [mut addEntriesFromDictionary:tuple.second];
        self.more = mut.copy;
    }
}

- (void)filterActions:(RACTuple *)tuple {
    if ([tuple.first isEqualToString:@"tabTap"]) {
        [self tabTap:tuple];
    } else if ([tuple.first isEqualToString:@"menuTap"]) {
        [self menuTap:tuple];
    } else if ([tuple.first isEqualToString:@"citySelect"]) {
        _districtId = [(DMHCityModel *)tuple.second id];
        _streetId   = [(DMHCityModel *)tuple.third id];
        [self refreshVisiable];
    } else if ([tuple.first isEqualToString:@"nearSelect"]) {
        /// 附近选择
        self.cityStr = tuple.second;
        id str = FORMAT(@"%@%@", [GLocation location].smodel.city, tuple.second);
        self.cityStr = str;
        [self refreshVisiable];
    } else if ([tuple.first isEqualToString:@"edit"]) {
        [self dropDismiss:NO com:^(BOOL finish) {
            ROUTER(URD_RESUME_PREF);
        }];
    } else if ([tuple.first isEqualToString:@"more"]) {
        self.more = tuple.second;
        [self refreshVisiable];
    }
}

- (void)resetFilter {
    [self.filterModel resetFilterMenus];
    self.ziyin = NO;
    self.more = @{@"sex_demand":[DMResume share].sex,
                  @"identity_demand":[DMResume share].identity
                  };
    self.streetId = nil;
    self.districtId = nil;
}

- (void)refreshVisiable {
    [self.navBar changeHot];
    [(DMHListView *)self.ic.currentItemView viewAction:RACTuplePack(@"refresh", @([self.filterModel isDefaultFilter]))];
}

- (void)updateList {
    [self.navBar changeHot];
    [self resetFilter];
    @weakify(self);
    [self.ic.visibleItemViews enumerateObjectsUsingBlock:^(DMHListView *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        if ([self.filterModel.filterTabs[idx].key isEqualToString:FMV_DINGYUE]) {
            return;
        }
        NSString *action = obj == self.ic.currentItemView ? @"refresh" : @"needRefresh";
        [obj viewAction:RACTuplePack(action, @YES)];
    }];
}

- (void)menuTap:(RACTuple *)tuple {
    if ([(DMHListView *)self.ic.currentItemView isRefresh]) return;
    [self.navBar changeHot];
    BOOL hasDrop = [(FilterItem *)tuple.second filterItems].count;
    if (hasDrop) {
        [(DMHListView *)self.ic.currentItemView viewAction:RACTuplePack(@"stickieTop")];
        if (self.navBar.height != STATUSBAR_HEIGHT) [self scrollAnimate:-44];
    }
    [self handleTagTap:tuple.second];
}

- (void)tabTap:(RACTuple *)tuple {
    if ([self.filterModel isDefaultFilter]) [self resetFilter];
    [self dropDismiss:YES com:nil];
    if ([tuple.third integerValue] == _ic.currentItemIndex) {
        [self refreshVisiable];
    } else {
        [(UIView<ViewDelegate> *)self.ic.currentItemView viewAction:RACTuplePack(@"stopScroll", @YES)];
        [(UIView<ViewDelegate> *)_ic.visibleItemViews[[tuple.third integerValue]] viewAction:RACTuplePack(@"needRefresh", @YES)];
        [self.ic scrollToItemAtIndex:[tuple.third integerValue] animated:NO];
    }
}

- (void)handleTagTap:(FilterItem *)model {
    if (self.drop && [[self.drop dropType] isEqualToString:model.key]) {
        [self dropDismiss:YES com:nil];
        return;
    }
    if (self.drop) [self dropDismiss:model.filterItems.count==0 com:nil];
    self.drop = nil;
    model.select = !model.select;
    @weakify(self);
    if ([model.key isEqualToString:FMV_CITY]) {
        self.drop = [DMHAddr show:RACTuplePack(model, _districtId, _streetId) block:^(id x){
            @strongify(self);
            [self filterActions:x];
            self.drop = nil;
        } view:self.menu];
    } else if ([model.key isEqualToString:FMV_FILTER]) {
        self.drop = [DMHFilterList show:model block:^(id x){
            @strongify(self);
            [self filterActions:x];
            self.drop = nil;
        }];
    } else if ([model.key isEqualToString:FMV_ZIYING]) {
        self.ziyin = model.select;
        [self refreshVisiable];
    }
}

- (void)dropDismiss:(BOOL)animted com:(void(^)(BOOL))comp {
    if (!self.drop) {
        if (comp) comp(YES);
        return;
    }
    [self.drop dismiss:animted com:^(BOOL finish) {
        if (comp) comp(YES);
    }];
    self.drop = nil;
}

#pragma mark - NavBar
///=============================================================================
/// @name NavBar
///=============================================================================

- (void)addViews {
    @weakify(self);
    self.navBar = [DMHNavBar viewWithModel:self.filterModel action:^(RACTuple *tuple){
        @strongify(self);
        [self navActions:tuple];
    }];
    CGRect frame = CGRectMake(0, self.navBar.size.height, SCREEN_WIDTH, 0);
    self.menu  = [DMHDropMenuView viewWithFrame:frame model:self.filterModel action:^(RACTuple *tuple){
        @strongify(self);
        [self filterActions:tuple];
    }];
    [self addICarousel];
    [self.view addSubview:_menu];
    [self.view addSubview:_navBar];
}

- (void)addICarousel {
    iCarousel *ic = [[iCarousel alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT+44+48, SCREEN_WIDTH, SCREEN_HEIGHT-44-48-STATUSBAR_HEIGHT-TABBAR_HEIGHT-INDICATOR_HEIGHT)];
    ic.delegate = self;
    ic.dataSource = self;
    ic.backgroundColor = self.view.backgroundColor;
    ic.type = iCarouselTypeLinear;
    ic.bounceDistance = 0.0001;
    ic.pagingEnabled = YES;
    ic.currentItemIndex = [self.filterModel.filterTabs indexOfObject:self.jobTypeModel];
    ic.centerItemWhenSelected = YES;
    self.ic = ic;
    [self.view insertSubview:self.ic belowSubview:_menu];
}

#pragma mark - Request
///=============================================================================
/// @name Request
///=============================================================================

- (void)requestDropMenuData {
    [MBProgressHUD showWebViewMessage:@"加载中" toView:self.view];
    GTask<HttpResult *> *tagTask = [HttpRequest jsonRequest].urlString(@"/api/v3/client/prefer/userjobtype").task;
    GTask<HttpResult *> *filterTask = [HttpRequest jsonRequest].urlString(@"/api/v3/client/filter/list")
    .params(@{@"filter_ver": @"1", @"is_show_cate": @"1", @"is_full_job": @"1"}).task;
    @weakify(self);
    ATJoin(@[tagTask, filterTask]).then(^id(NSArray<HttpResult *> *results) {
        @strongify(self);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"tagTask.value: %@", tagTask.value);
        NSLog(@"filterTask.value: %@", filterTask.value);
        //加载测试数据
        tagTask.value.code = 1000;
        tagTask.value.data = [self readJsonObjectFromFile:@"tagTaskValueDataJsonFile"];
        filterTask.value.code = 1000;
        filterTask.value.data = [self readJsonObjectFromFile:@"filterTaskValueDataJsonFile"];
        
        if (tagTask.value.code == 1000 && filterTask.value.code == 1000) {
            [self.filterModel modelSetWithJSON:filterTask.value.data];
            [self.filterModel modelSetWithJSON:tagTask.value.data];
            NSInteger idx = [self.filterModel.filterTabs[0].key isEqualToString:FMV_DINGYUE] ? (self.ding?0:1) : 0;
            self.jobTypeModel = self.filterModel.filterTabs[idx];
            if (self.ic) {
                [self.ic reloadData];
            } else {
                [self addViews];
            }
        } else {
            [self.view showEmpty:DMEmptyTypeNetworkWithButton action:^{
                [self requestDropMenuData];
            }];
        }
        self.ding = NO;
        return nil;
    });
}

- (id)readJsonObjectFromFile:(NSString *)fileName {
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData *data=[NSData dataWithContentsOfFile:jsonPath];

    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                      error:nil];
    
    return jsonObject;
}

- (void)requestHotKeyData {
    id params = @{@"citydomain": [GLocation location].smodel.domain ?: @"",
                  @"workType" : self.workType};
    @weakify(self);
    [HttpRequest jsonRequest].urlString(@"/api/v3/client/search/words").params(params).task
    .then(^id(HttpResult *t) {
        @strongify(self);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (t.code == 1000) {
            [self.filterModel modelSetWithJSON:@{@"hots":t.data?:@[]}];
        } else {
            
        }
        return nil;
    });
}

#pragma mark - DMHParamsListDelegate
///=============================================================================
/// @name DMHParamsListDelegate
///=============================================================================
/// listmore请求参数
- (NSDictionary *)listParams {
    NSMutableDictionary *mut = self.more.mutableCopy;
    mut[@"lat"]          = [GLocation location].model.lat;
    mut[@"lng"]          = [GLocation location].model.lng;
    mut[@"citydomain"]   = [GLocation location].smodel.domain;
    mut[@"job_type"]     = self.jobTypeModel.value;
    mut[@"work_type"]    = self.workType;
    mut[@"street_id"]    = self.streetId;
    mut[@"district_id"]  = self.districtId;
    mut[@"operate_self"] = @(self.ziyin);
    mut[@"is_show_quick_entry"]  = @1;
    return mut;
}
/// 运营请求参数
- (NSDictionary *)panelParams {
    NSMutableDictionary *mut = @{}.mutableCopy;
    mut[@"lat"]        = [GLocation location].model.lat;
    mut[@"lng"]        = [GLocation location].model.lng;
    mut[@"citydomain"] = [GLocation location].smodel.domain;
    mut[@"job_type"]   = self.jobTypeModel.value ?: @0;
    mut[@"recommend"]  = self.jobTypeModel.value ? @0 : @1;
    mut[@"work_type"]  = self.workType;
    return mut;
}
/// 全职or兼职
- (id)workType {
    return @2;
}

///> 更新more默认选中数据 
- (void)updateMoreData:(DMHDefaultMore *)more {
    [self.filterModel updateDefaultMore:more];
}

- (void)evlog:(NSString *)ev params:(NSDictionary *)params {
//    [self addEVLog:ev param:params];
}

- (NSString *)evTag {
    return self.jobTypeModel.name;
}

- (NSString *)evMore {
    if (self.cityStr) [self.filterModel filterItem:self.cityStr];
    id city = FORMAT(@"%@%@不限", [GLocation location].smodel.city, [GLocation location].smodel.city);
    return [self.filterModel filterItem:city];
}

#pragma mark - DMHParamsListDelegate Animate
///=============================================================================
/// @name DMHParamsListDelegate Animate
///=============================================================================

- (void)scrollAnimate:(CGFloat)distance {
    CGFloat navH = STATUSBAR_HEIGHT+44;
    CGRect menuF = self.menu.frame;
    if (menuF.origin.y == navH+distance) return;
    menuF.origin.y = navH + distance;
    self.menu.frame = menuF;
    [self.navBar viewAction:RACTuplePack(@"scroll", @(distance))];
    [self.ic.visibleItemViews enumerateObjectsUsingBlock:^(DMHListView *obj, NSUInteger idx, BOOL *stop) {
        if (obj == self.ic.currentItemView) return;
        [obj viewAction:RACTuplePack(@"updateFrame", @(distance))];
    }];
}

- (void)scrollViewNaviAnimate:(BOOL)isFull {
    [self.navBar viewAction:RACTuplePack(@"searchAnimate", @(isFull))];
}

#pragma mark - iCarouselDelegate
///=============================================================================
/// @name iCarouselDelegate
///=============================================================================

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.filterModel.filterTabs.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view {
    @weakify(self);
    FilterItem *item = self.filterModel.filterTabs[index];
    Class<ViewDelegate> cls = DMHListView.class;
    UIView<ViewDelegate> *rview = [cls viewWithFrame:carousel.bounds model:item action:^(id  _Nullable x) {
        @strongify(self);
        [self icActions:x];
    }];
    ((DMHListView *)rview).vc = self;
    if (index == carousel.currentItemIndex) [rview viewAction:RACTuplePack(@"firstVisible")];
    return rview;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionVisibleItems) {
        return self.filterModel.filterTabs.count;
    }
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [self handleExposure:[self.filterModel.filterTabs indexOfObject:self.jobTypeModel]];
    _jobTypeModel = self.filterModel.filterTabs[carousel.currentItemIndex];
    [_menu viewAction:RACTuplePack(@"scrollChange", @(carousel.currentItemIndex))];
    [self resetFilter];
    [(UIView<ViewDelegate> *)carousel.currentItemView viewAction:RACTuplePack(@"visible")];
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    [self.menu viewAction:RACTuplePack(@"scroll", @(carousel.scrollOffset))];
}

#pragma mark - THIRD
///=============================================================================
/// @name THIRD
///=============================================================================

//MARK: - 定位
- (void)startLocation {
// 城市变更后更新filterMenus数据
    @weakify(self);
    [RACObserve([GLocation location], smodel.done) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        NSString *city = [GLocation location].smodel.city;
        if (city && city.length) {
            [self requestHotKeyData];
            [DMHCity loadCityData:[GLocation location].smodel.cityID];
        }
        if (!self.filterModel.filterMenus.count) return;
        if (!city || city.length == 0 || [city isEqualToString:self.filterModel.filterMenus[0].name]) return;
        self.filterModel.filterMenus[0].name = FORMAT(@"全%@", city);
        self.filterModel.filterMenus[0].sname = @"";
        self.filterModel.filterMenus[0].select = NO;
        self.streetId = nil;
        self.districtId = nil;
        self.cityStr = nil;
    }];
}

#pragma mark - 上报逻辑
///=============================================================================
/// @name NOTI
///=============================================================================

- (void)willResignActive {
    [self dropDismiss:YES com:nil];
    [self handleExposure:self.ic.currentItemIndex];
}

- (void)handleExposure:(NSInteger)idx {
    if (!self.ic || idx >= self.ic.visibleItemViews.count) return;
    DMHListView *view = self.ic.visibleItemViews[idx];
    if (!view) return;
    [view viewAction:RACTuplePack(@"disVisiable")];
}

#pragma mark - NOTI
///=============================================================================
/// @name NOTI
///=============================================================================

- (void)addNoti {
    // 添加退出App的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    @weakify(self);
    [RACObserve([DMResume share], done) subscribeNext:^(id x) {
        if ([[DMResume share].sex isEqualToString:self.more[@"sex_demand"]] &&
            [[DMResume share].identity isEqualToString:self.more[@"identity_demand"]]) return;
        @strongify(self);
        [self updateList];
    }];
}

- (void)jopApplySuccess:(NSNotification *)noti {
    NSString *jobID = noti.object;
    [self.ic.visibleItemViews enumerateObjectsUsingBlock:^(DMHListView *obj, NSUInteger idx, BOOL *stop) {
        [obj viewAction:RACTuplePack(@"updateJobStatus", @{jobID:@0})];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//NSString *path=[paths objectAtIndex:0];
//NSString *Json_path=[path stringByAppendingPathComponent:@"JsonFile.json"];
////==写入文件
//NSData *jsonData = [NSJSONSerialization dataWithJSONObject:panel.value.data options:NSJSONWritingPrettyPrinted error:nil];
//[JsonData writeToFile:Json_path atomically:YES];

@end
