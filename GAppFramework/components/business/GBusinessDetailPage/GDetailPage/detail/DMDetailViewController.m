//
//  DMDetailViewController.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/12.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMDetailViewController.h"
#import <GBaseLib/GConvenient.h>
#import <GRouter/GRouter.h>
#import <GProtocol/ViewProtocol.h>
#import <GHttpRequest/HttpRequest.h>
#import "DMDetailModel.h"
#import "DMDActions.h"
#import <GConst/URDConst.h>
#import <GConst/HTMLConst.h>
#import <DMUILib/GHud.h>
#import <GTask/GTaskResult.h>
#import <GLocation/GLocation.h>
#import <GShareComponent/GShareComponent.h>

@interface DMDetailViewController ()
///> 数据: router
@property (nonatomic, strong) DMDetaiUrdParamsModel *urdModel;
///> 导航: 收藏
@property (nonatomic, strong) UIImageView *collect;
///> 数据: 分享
@property (nonatomic, strong) id shareData;
@end

@implementation DMDetailViewController


#pragma mark - Router Support
///=============================================================================
/// @name Router支持
///=============================================================================

ROUTER_REGISTER(CSCHEME, URD_DETAIL);

- (void)routerPassParamters:(NSDictionary *)data {
    DMDetaiUrdParamsModel *model = [DMDetaiUrdParamsModel modelWithJSON:data];
    model.detail = [DMDetailModel modelWithJSON:[GConvenient paraDict:model.urdData]];
    self.urlString = URL_ADD_PARAMS(HTML_DETAIL, data);
    self.urdModel = model;
    self.navigationItem.rightBarButtonItems = [self naviRightBarItem];
}

#pragma mark - DMWebViewDelegate
///=============================================================================
/// @name DMWebViewDelegate
///=============================================================================

- (NSArray<UIBarButtonItem *> *)naviRightBarItem {
    UIImageView *share = [[UIImageView alloc] initWithImage:IMAGE_ND(@"detail_share_b", @"detail_share_w")];
    share.frame = CGRectMake(0, 0, 36, 36);
    share.contentMode = UIViewContentModeCenter;
    @weakify(self);
    [share addTapGesture:^{
        @strongify(self);
        [self shareAction];
    }];
    self.collect = [[UIImageView alloc] initWithImage:[self collectImg:NO]];
    self.collect.contentMode = UIViewContentModeCenter;
    self.collect.frame = CGRectMake(0, 0, 36, 36);
    [self.collect addTapGesture:^{
        @strongify(self);
        [self collectAction];
    }];
    UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fix.width = -5;
    return @[fix,
             [[UIBarButtonItem alloc] initWithCustomView:share],
             [[UIBarButtonItem alloc] initWithCustomView:self.collect]];
}

- (UIImage *)collectImg:(BOOL)collected {
    if (collected) {
        return IMAGE_ND(@"detail_collect_y_b", @"detail_collect_y_w");
    }
    return IMAGE_ND(@"detail_collect_n_b", @"detail_collect_n_w");
}

#pragma mark - ACTIONS
///=============================================================================
/// @name ACTIONS
///=============================================================================

- (void)actions:(RACTuple *)tuple {
    DMDAction action = [tuple.first integerValue];
    if (action == DMDActionApply) {
        [self applyAction];
    }
}
/// 报名
- (void)applyAction {
    [GRouter router:URD(URD_APPLY_ACTION) params:self.urdModel.detail]
    .then(^id(GTaskResult *t) {
        if (t.suc) {
            self.urdModel.detail.canApplyCode = -104;
            self.urdModel.detail.canApplyTxt = @"取消报名";
            self.urdModel.detail.done = YES;
        }
        return t.data;
    });
}
/// 收藏
- (void)collectAction {
    id params = @{@"postId":self.urdModel.jobID?:@"", @"cityId": [GLocation location].smodel.cityID?:@""};
    id url = @"api/v2/client/collect";
    BOOL curC = self.urdModel.detail.collect;
    if (curC) url = FORMAT(@"%@/update", url);
    @weakify(self);
    [HttpRequest jsonRequest].method(HttpMethodPost).urlString(url).params(params).task
    .then(^id(HttpResult *t) {
        @strongify(self);
        [GHud hideAll:self.view];
        if (t.code == 200) {
            id msg = curC ? @"已取消收藏" : @"收藏成功";
            self.urdModel.detail.collect = !curC;
            self.collect.image = [self collectImg:!curC];
            [GHud toast:msg];
        } else {
            [GHud toast:t.message];
        }
        return nil;
    });
}
///
- (void)shareAction {
    [self shareTask].then(^(id shareData) {
        [GShareComponent share:^GSObject *(GShareScene scene) {
            GSMini *obj = [GSMini new];
            obj.title = shareData[0][@"title"];
            obj.url = shareData[0][@"url"];
            obj.desc = shareData[0][@"text"];
            obj.thumb = shareData[0][@"image"];
            obj.id = @"gh_0e6933df41f1";
            return obj;
        }];
    });
}
- (GTask *)shareTask {
    if (self.shareData) return ATTask(self.shareData);
    [GHud hud:@"" dim:NO view:self.view];
    id params = @{@"post_id":self.urdModel.jobID?:@""};
    @weakify(self);
    return [HttpRequest jsonRequest].method(HttpMethodPost)
    .urlString(@"api/v2/client/share").params(params).task
    .then(^id(HttpResult *t) {
        @strongify(self);
        [GHud hideAll:self.view];
        if (t.code == 200) return self.shareData = t.extra[@"share"];
        
        [GHud toast:t.message];
        return [NSError new];
    });
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    self.dmHairlineHidden = YES;
    self.dmBarColor = HEX(@"ffffff", @"1c1c1e");
    [super viewDidLoad];
    [self loadBottomData];
}

- (void)addBottom {
    Class<ViewDelegate> bot = NSClassFromString(@"DMDetailBottomView");
    @weakify(self);
    UIView *view = [bot viewWithModel:self.urdModel.detail action:^(id x){
        @strongify(self);
        [self actions:x];
    }];
    [self.view addSubview:view];
    self.webframe = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-view.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    CGFloat titleh = MAX(self.urdModel.detail.titleRelative - NAVIBAR_HEIGHT - STATUSBAR_HEIGHT, 0.1);
    self.navigationItem.title = (y > titleh)?self.urdModel.detail.title:@"";
}

#pragma mark - Hybrid Actions
///=============================================================================
/// @name Hybrid Actions
///=============================================================================

- (id)handleAction:(NSString *)func args:(NSDictionary *)args {
    if ([func isEqualToString:@"getStatusBarAndTitleBarHeight"]) {
        return GTaskResult(NO, @{@"height":@(STATUSBAR_HEIGHT+44)});
    } else if ([func isEqualToString:@"dataDownloadFinished"]) {
        [self loadDataFromJS];
        [self addBottom];
        return GTaskResult(NO);
    }
    return [super handleAction:func args:args];
}

- (void)loadDataFromJS {
    @weakify(self);
    [self evaluateJS:@"JSON.stringify(window.jobInfo())" completionHandler:^(id result, NSError *error) {
        @strongify(self);
        [self.urdModel.detail modelSetWithJSON:[result jsonDecoded]];
        self.collect.image = [self collectImg:self.urdModel.detail.collect];
    }];
}

#pragma mark - Request
///=============================================================================
/// @name Request
///=============================================================================

- (void)loadBottomData {
    @weakify(self);
    id url = FORMAT(@"api/v3/client/detail/applyinfo/%@", self.urdModel.jobID);
    [HttpRequest jsonRequest].urlString(url).headers(@{@"Ca-platform":@"5"}).task
    .then(^id(HttpResult *t) {
        @strongify(self);
        if (t.code == 200) {
            [self.urdModel.detail modelSetWithJSON:t.extra];
            self.urdModel.detail.done = YES;
        }
        return nil;
    });
}

@end
