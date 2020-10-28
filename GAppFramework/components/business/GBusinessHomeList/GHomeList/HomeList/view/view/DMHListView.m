//
//  DMHListView.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/24.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHListView.h"
#import "DMHFilterModel.h"
#import "DMHToast.h"
#import <GBaseLib/iCarousel.h>
#import "DMExtraModel.h"
#import <GBaseLib/GConvenient.h>
#import <GBaseLib/GRefreshHeader.h>
#import <MJRefresh/MJRefresh.h>
#import <GHttpRequest/HttpRequest.h>
#import <GRouter/GRouter.h>
#import <DMUILib/DMEmpty.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>
#import <GConst/URDConst.h>
#import <DMUILib/GHud.h>
#import <GTask/GTask+Fwd.h>
#import <GBaseLib/NSArray+Extend.h>
#import <DMUILib/DMEmpty.h>

@interface DMHListView ()<UITableViewDelegate, UITableViewDataSource>
///> 事件: 回调 
@property (nonatomic, copy) AActionBlock actionBlock;
///> 视图: 列表栏 
@property (nonatomic, strong) UITableView *tableView;
///> 视图: 无数据 
@property (nonatomic, strong) UIView *empty;
///> 视图: 加载数据失败 
@property (nonatomic, strong) UIView *failEmpty;
///> 视图:  
@property (nonatomic, strong) FilterItem *item;
///> 数据: 列表 
@property (nonatomic, strong) DMHListModel *listModel;
///> 状态: 
@property (nonatomic, assign) CGFloat old;
///> 
@property (nonatomic, assign) CGFloat dis;
///> 状态: 刷新 
@property (nonatomic, assign) BOOL needRefresh;
///> 
@property (nonatomic, assign) BOOL isDefaultFilter;
///> 状态: 外部刷新动作(不影响位置) 
@property (nonatomic, assign) BOOL isLoad;

///> 
@property (nonatomic, assign) NSInteger refreshTimes;
///> 埋点: 过滤首屏曝光 
@property (nonatomic, assign) BOOL canBegin;

@property (nonatomic, assign) BOOL reqMore;
@end

@implementation DMHListView

- (BOOL)isRefresh {
    return _tableView.mj_header.isRefreshing;
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

- (void)refreshToTop:(RACTuple *)x {
    self.isLoad = YES;
    self.isDefaultFilter = [x.second boolValue];
    _old = _dis;
    if (self.listModel.data.count > 0) [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self beginRefreshing];
}

- (void)beginRefreshing {
    if (_tableView.mj_header.isRefreshing) {
        [self requestListData];
    } else {
        [_tableView.mj_header beginRefreshing];
    }
}

- (void)viewAction:(RACTuple *)x {
    if ([x.first isEqualToString:@"firstVisible"] ) {
        _tableView.contentInset = UIEdgeInsetsMake(44+_dis, 0, 0, 0);
        _needRefresh = YES;
        self.isDefaultFilter = YES;
        self.isLoad = YES;
        _old = _dis;
        [self beginRefreshing];
    } else if ([x.first isEqualToString:@"visible"]) {
        _tableView.contentInset = UIEdgeInsetsMake(44+_dis, 0, 0, 0);
        if ((_listModel.data.count>0 && !_needRefresh && _isDefaultFilter)) return;
        if (self.empty && self.empty.superview) {
            [self.empty removeFromSuperview];
        }
        self.isDefaultFilter = YES;
        self.isLoad = YES;
        _old = _dis;
        [self beginRefreshing];
    } else if ([x.first isEqualToString:@"refresh"]) {
        [self refreshToTop:x];
    } else if ([x.first isEqualToString:@"updateFrame"]) {
        _dis = [x.second floatValue];
    } else if ([x.first isEqualToString:@"needRefresh"]) {
        _needRefresh = [x.second boolValue];
    } else if ([x.first isEqualToString:@"stickieTop"]) {
        if (44+_dis == 0) return;
        CGPoint point = CGPointMake(0, [self offsetY]);
        if ([self isEqualTwo:self.tableView.contentOffset.y num2:point.y]) return;
        [self.tableView setContentOffset:point animated:NO];
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    } else if ([x.first isEqualToString:@"updateJobStatus"]) {
        [self updateJobStatus:x.second];
    } else if ([x.first isEqualToString:@"disVisiable"]) {
    } else if ([x.first isEqualToString:@"stopScroll"]) {
        [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    }
}

- (CGFloat)offsetY {
    if (self.listModel.data.count == 0) return 0;
    if (self.listModel.data.count == 2 &&
        [self.listModel.data[0].cellIndentifier isEqualToString:HCI_EMPTY] &&
        [self.listModel.data[1].cellIndentifier isEqualToString:HCI_CONUSELOR]) {
        return 0;
    }
    return self.tableView.contentOffset.y+(44+_dis);
}

- (void)actions:(RACTuple *)x {
    if ([x.first isEqualToString:@"interest"]) {
        // 模板删除
        [self handleInterest:x.fourth y:[x.third floatValue]];
    } else if ([x.first isEqualToString:@"listBtn"]) {
        // 聊天和投简历
        [self handleListBtn:x.second];
    } else if ([x.first isEqualToString:@"merchant"]) {
        // 商家模板 商家点击
        [self handleMerchantDetail:x.second panel:x.fourth];
    } else if ([x.first isEqualToString:@"merchantChat"]) {
        // 商家模板 聊天点击
        [self handleMerchantChat:x.second panel:x.fourth];
    } else if ([x.first isEqualToString:@"zone"]) {
        // 职位专区 点击
        DMHZone *zone = x.second;
        [GRouter router:URL(zone.url)];
    } else if ([x.first isEqualToString:@"banner"]) {
        // Banner专区 点击
        DMHBannerItem *banner = x.second;
        [GRouter router:URL(banner.url)];
    } else if ([x.first isEqualToString:@"conuselor"]) {
        // 顾问banner 点击
        [GRouter router:x.second];
    } else if ([x.first isEqualToString:@"hot"]) {
        // 热门推荐 点击
    } else if ([x.first isEqualToString:@"exposure"]) {
        // 曝光
    } else {
        if (self.actionBlock) self.actionBlock(x);
    }
}

///> 事件: 商家头像点击 
- (void)handleMerchantDetail:(DMHListMerchant *)mer panel:(DMHPanelModel *)panel {
}

///> 事件: 商家聊天点击 
- (void)handleMerchantChat:(DMHListMerchant *)mer panel:(DMHPanelModel *)panel {
}

///> 事件: 不感兴趣 
- (void)handleInterest:(DMHPanelModel *)model y:(CGFloat)y {
}

///> 事件: 聊天、投简历 
- (void)handleListBtn:(DMHListItem *)item {
    if (_tableView.mj_header.isRefreshing) return;
    if (item.canChat) {

    } else {
        [GRouter router:URD(URD_APPLY_ACTION)  params:item];
    }
}

- (void)updateJobStatus:(NSDictionary *)object {
    if (!object) return;
    @weakify(self);
    [object.allKeys enumerateObjectsUsingBlock:^(NSString *jobId, NSUInteger idx, BOOL *stop) {
        if (!self.listModel.hasApply && [object[jobId] boolValue]) self.listModel.hasApply = YES;
        @strongify(self);
        [self.listModel.data enumerateObjectsUsingBlock:^(id<DMHListDelegate> obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:DMHListItem.class] || ![[(DMHListItem *)obj jobID] isEqualToString:jobId]) return;
            DMHListItem *item = (DMHListItem *)obj;
            item.canApply = [object[jobId] boolValue];
        }];
    }];
}

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (id)viewWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    return [[self alloc] initWithFrame:frame model:model action:action];
}

- (instancetype)initWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    if (self = [super initWithFrame:frame]) {
        _actionBlock = action;
        _item = model;
        _listModel = [DMHListModel modelWithJSON:@{}];
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        self.clipsToBounds = NO;
        [self addTabView];
    }
    
    return self;
}

- (void)logout {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TabView Delegate
///=============================================================================
/// @name TabView Delegate
///=============================================================================

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.vc respondsToSelector:@selector(hscrollViewDidScroll:)]) {
        [self.vc hscrollViewDidScroll:scrollView];
    }
    if ([self.vc respondsToSelector:@selector(scrollViewNaviAnimate:)]) {
        BOOL isFull = scrollView.contentOffset.y < 0;
        if (self.tableView.indexPathsForVisibleRows.count > 0 || self.listModel.data.count == 0) {
            [self.vc scrollViewNaviAnimate:isFull];
        }
    }
    if (self.isLoad) return;
    CGFloat new = scrollView.contentOffset.y;
    CGFloat pad = MAX(scrollView.contentSize.height-self.tableView.height, 0);
    if ((new-_old>0 && new<=0-_tableView.contentInset.top) || new>=pad || new==_old) {
        _old = new;
        return;
    }
    _dis = MAX(MIN(0, _dis - (new-_old)), -44);
    _old = new;
    BOOL isEqual = [self isEqualTwo:_tableView.contentInset.top num2:(44+_dis)];
    if (_tableView.mj_header.state != MJRefreshStateRefreshing && !isEqual) {
        [_tableView setContentInset:UIEdgeInsetsMake(44+_dis, 0, 0, 0)];
    }
    [self.vc scrollAnimate:_dis];
}

- (BOOL)isEqualTwo:(CGFloat)num1 num2:(CGFloat)num2 {
    return (num1 - num2) < 0.0001 && (num1 - num2) > -0.0001;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.vc respondsToSelector:@selector(hscrollViewDidEndDecelerating:)]) {
        [self.vc hscrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate && [self.vc respondsToSelector:@selector(hscrollViewDidEndDecelerating:)]) {
        [self.vc hscrollViewDidEndDecelerating:scrollView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listModel.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<DMHListDelegate> item = self.listModel.data[indexPath.row];
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:[item cellIndentifier] forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row > self.listModel.data.count-2 && !self.tableView.mj_header.isRefreshing && !self.listModel.isLast && !self.reqMore) {
        [self requestMoreListData];
    }
    @weakify(self);
    id temp = item;
    [cell viewModel:RACTuplePack(temp, indexPath, @(self.listModel.data.count), @(self.listModel.isLast), self.item.key) action:^(RACTuple *x){
        @strongify(self);
        [self actions:x];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.listModel.data[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id temp = self.listModel.data[indexPath.row];
    if ([temp isKindOfClass:DMHPanelModel.class] && [[(DMHPanelModel *)temp type] isEqualToString:HCI_REFRESH]) {
        [self viewAction:RACTuplePack(@"refresh")];
        return;
    } else if ([temp isKindOfClass:DMDingYueModel.class]) {
        [self qzdyTap];
        return;
    }
    if (![temp isKindOfClass:DMHListItem.class]) return;
    DMHListItem *item = temp;
    item.hasTap = YES;
    NSMutableString *urd = @"".mutableCopy;
    [urd appendFormat:@"title=%@", item.title];
    [urd appendFormat:@"&payment_type_str=%@", item.paymentTypeStr];
    [urd appendFormat:@"&job_type_str=%@", item.jobTypeStr];
    [urd appendFormat:@"&salary=%@", item.salary];
    [urd appendFormat:@"&salary_type_str=%@", item.salaryType];
    [urd appendFormat:@"&ad_types=%@", item.adType];
    [urd appendFormat:@"&is_salary_nego=%@", @(item.isSalaryNego)];
    [urd appendFormat:@"&salary_unit_str=%@", item.salaryUnit];
    [urd appendFormat:@"&template_type=%@", item.templateType];
    [urd appendFormat:@"&work_type=%li", item.workType];
    [urd appendFormat:@"&welfare_tag=%@", [item.oriWelfareTags jsonString]];
    [urd appendFormat:@"&is_ziying=%@", item.isZiyin?@"true":@"false"];
    if (item.imagesNum) [urd appendFormat:@"&work_images_num=%@", item.imagesNum];
    NSString *urdS = FORMAT(@"%@?job_id=%@&template_type=%@&urdData=%@&readed_from=index", URD(URD_DETAIL), item.jobID, item.templateType, [urd URLEncode]);
    [GRouter router:urdS];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return _listModel.data.count ? (self.listModel.isLast?70:54) : 0.001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (!_listModel.data.count) return nil;
    UILabel *label = [self lightLabel];
    label.text = _listModel.isLast?@"已没有更多数据":@"正在加载更多的数据...";
    label.textColor = _listModel.isLast?HEX(@"808080", @"787880"):HEX(@"404040", @"dddddd");
    label.backgroundColor = HEX(@"f7f7f7", @"000000");
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - Request
///=============================================================================
/// @name Request
///=============================================================================

- (id)readJsonObjectFromFile:(NSString *)fileName {
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData *data=[NSData dataWithContentsOfFile:jsonPath];

    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                      error:nil];
    
    return jsonObject;
}

- (void)requestListData {
    if (self.failEmpty) [self.failEmpty removeFromSuperview];
    NSString *url = @"/api/v2/client/listmore";
    NSMutableDictionary *dict = [self.vc listParams].mutableCopy;
    dict[@"is_refresh"] = @1;
    dict[@"refresh_times"] = @(self.refreshTimes);
    self.refreshTimes += 1;
    HttpMethod method = HttpMethodPost;
    GTask<HttpResult<id, DMExtraModel *> *> *list = [HttpRequest jsonRequest].method(method)
    .urlString(url).extraDataTransform(DMExtraModel.class).params(dict).task;
    GTask<HttpResult *> *panel = [HttpRequest jsonRequest].urlString(@"/api/v3/client/listpanel").params([self.vc panelParams]).task;
    @weakify(self);
    ATJoin(@[list, panel]).then(^id(NSArray *results) {
        @strongify(self);
        //设置测试数据
        panel.value.code = 1000;
        panel.value.data = [self readJsonObjectFromFile:@"listPanelJsonFile"];
        
        if (list.value.code == 1000 && panel.value.code == 1000) {
            BOOL hasData = self.listModel.data.count;
            [self.listModel modelSetWithJSON:@{@"panel": panel.value.data?:@{}, @"workType": self.vc.workType?:@2,@"dingyue":@([self.item.key isEqualToString:FMV_DINGYUE]), @"nopanel": @([self.item.key isEqualToString:FMV_DINGYUE] || [self.item.key isEqualToString:FMV_FEATURE])}];
            [self.listModel modelSetWithJSON:list.value.data];
            [self.vc updateMoreData:self.listModel.defaultMore];
            id params = @{@"sex_demand":self.listModel.defaultMore.sex?:@"",
                          @"identity_demand":self.listModel.defaultMore.identity?:@""};
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"more", params));
            [self handleData:hasData isDing:NO];
        } else {
            [self.tableView.mj_header endRefreshing];
            if (self.listModel.data.count == 0) {
                self.failEmpty = [self.tableView showEmpty:DMEmptyTypeNoDataWithButton action:^{
                    [self.tableView.mj_header beginRefreshing];
                }];
            } else {
                [GHud toast:@"请求异常，请检查网络" view:self];
            }
        }
        self.isLoad = NO;
        return nil;
    });
}

- (void)requestMoreListData {
    self.reqMore = YES;
    NSMutableDictionary *dict = [self.vc listParams].mutableCopy;
    dict[@"page"] = @(self.listModel.curPage + 1);
    dict[@"refresh_times"] = @(self.refreshTimes);
    NSString *url = @"/api/v2/client/listmore";
    HttpMethod method = HttpMethodPost;
    GTask *list = [HttpRequest jsonRequest].method(method).urlString(url).params(dict).task;
    @weakify(self);
    list.then(^id(HttpResult *t) {
        @strongify(self);
        if (t.code == 1000) {
            NSArray<NSIndexPath *> *paths = [self.listModel addNextPage:t.data];
            [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            self.reqMore = NO;
        } else {
            [self.tableView.mj_footer endRefreshing];
            [GHud toast:@"请求异常，请检查网络" view:self];
        }
        return nil;
    });
}

- (void)handleData:(BOOL)hasData isDing:(BOOL)isDing {
    self.needRefresh = NO;
    if (self.listModel.data.count) {
        if (_empty.superview) [_empty removeFromSuperview];
        [DMHToast toast:FORMAT(@"为您更新了%@职位", _item.name) view:self y:65];
    } else if (!_empty || !_empty.superview) {
        _empty = [self createEmptyView];
        [self.tableView addSubview:_empty];
    } else if (_empty) {
        UIView *img = [_empty viewWithTag:334];
        if (img && ![DMHListModel needShowDingyueCell]) [img removeFromSuperview];
    }
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - GETTERS
///=============================================================================
/// @name GETTERS
///=============================================================================

- (void)addTabView {
    CGRect frame = self.bounds;
    frame.origin.y = [self.item.key isEqualToString:FMV_DINGYUE] ? -44:1;
    frame.size.height -= frame.origin.y;
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = HEX(@"f7f7f7", @"000000");
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.clipsToBounds = NO;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    [_tableView registerClass:NSClassFromString(@"DMHListCell") forCellReuseIdentifier:HCI_JOB];
    [_tableView registerClass:NSClassFromString(@"DMHHotCell") forCellReuseIdentifier:HCI_HOT];
    [_tableView registerClass:NSClassFromString(@"DMHZoneCell") forCellReuseIdentifier:HCI_ZONE];
    [_tableView registerClass:NSClassFromString(@"DMPListCell") forCellReuseIdentifier:HCI_JOB_PT];
    [_tableView registerClass:NSClassFromString(@"DMHBannerCell") forCellReuseIdentifier:HCI_BANNER];
    [_tableView registerClass:NSClassFromString(@"DMHMerchantCell") forCellReuseIdentifier:HCI_MERCHANT];
    [_tableView registerClass:NSClassFromString(@"DMHRefreshCell") forCellReuseIdentifier:HCI_REFRESH];
    [_tableView registerClass:NSClassFromString(@"DMHEmptyCell") forCellReuseIdentifier:HCI_EMPTY];
    [_tableView registerClass:NSClassFromString(@"DMHConuselorCell") forCellReuseIdentifier:HCI_CONUSELOR];
    [_tableView registerClass:NSClassFromString(@"DMDingyueCell") forCellReuseIdentifier:HCI_DINGYUE];
    
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self addSubview:_tableView];
    
    @weakify(self);
    _tableView.mj_header = [GRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self beginRefreshing];
    }];
}

- (UILabel *)lightLabel {
    UILabel *label = [UILabel new];
    label.font = FONT(14);
    label.textColor = HEX(@"808080", @"AFAFB0");
    return label;
}

- (UIView *)createEmptyView {
    UIView *view = [UIView new];
    CGRect frame = self.tableView.bounds;
    frame.origin.y = 0;
    view.frame = frame;
    view.backgroundColor = HEX(@"ffffff", @"1c1c1e");

    UIImageView *img = [[UIImageView alloc] initWithImage:IMAGE(@"notfound_load")];
    [view addSubview:img];
    
    UILabel *label = [self lightLabel];
    label.text = @"没找到匹配的职位哦~~";
    [view addSubview:label];
    
    [img mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(img.mas_centerY).offset(5);
        make.left.equalTo(img.mas_right).offset(10);
        make.left.equalTo(view.mas_centerX).offset(-30);
    }];
    
    return view;
}

- (void)qzdyTap {
}

@end
