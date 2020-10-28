//
//  GCityViewController.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/14.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "GCityViewController.h"
#import <GBaseLib/GConvenient.h>
#import <GBaseLib/UINavigationBar+DMExtend.h>
#import <GProtocol/ViewProtocol.h>
#import <GLocation/GLocation.h>
#import <YYKit/UIBarButtonItem+YYAdd.h>
#import <GConst/URDConst.h>
#import <GConst/HTMLConst.h>

@interface GCityViewController ()<NaviDelegate>
@end

@implementation GCityViewController

ROUTER_REGISTER(CSCHEME, URD_CITY_SELECT);

#pragma mark - DMRouterDataDelegate
///=============================================================================
/// @name DMRouterDataDelegate
///=============================================================================

- (id)afterInterceptors:(id)data vc:(UIViewController *)vc navi:(UINavigationController *)navi {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [navi.visibleViewController presentViewController:nav animated:YES completion:^{}];
    return @NO;
}

#pragma mark - NaviDelegate
///=============================================================================
/// @name NaviDelegate
///=============================================================================

- (UIBarButtonItem *)naviLeftBarItem {
    UIBarButtonItem *item = [UIBarButtonItem new];
    item.image = IMAGE_ND(@"btn_back_normal", @"btn_back_normal_w");
    [item setActionBlock:^(id x) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.tcs setResult:[GTaskResult taskResultWithSuc:NO]];
        }];
    }];
    return item;
}

#pragma mark - Hybrid Actions
///=============================================================================
/// @name Hybrid Actions
///=============================================================================

- (id)handleAction:(NSString *)func args:(NSDictionary *)args {
    if ([func isEqualToString:@"changeCity"]) {
        [self changeCity:args];
    } else if ([func isEqualToString:@"getOptions"]) {
        return [self getOptions];
    } else if ([func isEqualToString:@"getCity"]) {
        return [self getCity];
    }
    return [super handleAction:func args:args];
}

- (id)changeCity:(NSDictionary *)args {
    [self.tcs setResult:[GTaskResult taskResultWithSuc:YES data:args]];
    [self dismissViewControllerAnimated:YES completion:^{}];
    return nil;
}

- (GTaskResult *)getCity {
    id task = [GLocation requestLocation]
    .then(^id (GTaskResult<GLLocationModel *> *t) {
        if (!t.suc) return nil;
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"cityid"]       = t.data.cityID;
        dict[@"city"]         = t.data.city;
        dict[@"citydomain"]   = t.data.domain;
        dict[@"parentid"]     = t.data.parentID;
        return dict;
    });
    return [GTaskResult taskResultWithSuc:NO data:task];
}

- (GTaskResult *)getOptions {
    GTask *task = [GLocation location].model.done ?
        [GTask taskWithValue:[GTaskResult taskResultWithSuc:YES data:[GLocation location].model]] :
        [GLocation requestLocation];
    task = task.then(^id (GTaskResult<GLLocationModel *> *t) {
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"s_city"]       = [GLocation location].smodel.city;
        dict[@"s_citydomain"] = [GLocation location].smodel.domain;
        if (!t.suc) return dict;
        dict[@"cityid"]       = t.data.cityID;
        dict[@"city"]         = t.data.city;
        dict[@"citydomain"]   = t.data.domain;
        return dict;
    });
    return [GTaskResult taskResultWithSuc:NO data:task];
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    self.urlString = HTML_CITY;
    self.navigationItem.title = @"选择城市";
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dmBarColor = HEX(@"ffffff", @"1c1c1e");
    self.dmHairlineHidden = YES;
}

@end
