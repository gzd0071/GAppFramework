//
//  DMDNetHistoryViewController.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/30.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDNetHistoryViewController.h"
#import "URLInjectorRecorder.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GProtocol/ViewProtocol.h>
#import <GRouter/GRouter.h>
#import <GBaseLib/GConvenient.h>

@interface DMDNetHistoryViewController ()<UITableViewDelegate, UITableViewDataSource>
///> 
@property (nonatomic, strong) UITableView *tableView;
///> 
@property (nonatomic, strong) NSArray<URLInjectorRequestPacket *> *data;
@end

@implementation DMDNetHistoryViewController

#pragma mark - DebuggerPluginDelegate
///=============================================================================
/// @name DebuggerPluginDelegate
///=============================================================================

+ (NSString *)pluginName {
    return @"历史请求";
}
// 主题色 "#4D8F79"
+ (UIImage *)pluginIcon {
    return [UIImage imageNamed:@"debugger_request"];
}

+ (void)pluginTapAction:(UINavigationController *)navi {
    DMDNetHistoryViewController *vc = [DMDNetHistoryViewController new];
    [navi pushViewController:vc animated:YES];
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"请求历史";
    self.view.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearListAction)];
    [self.view addSubview:self.tableView];
    self.data = [URLInjectorRecorder packets];
    @weakify(self);
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

/// 清空历史请求
- (void)clearListAction {
    [URLInjectorRecorder clearPackets];
    self.data = @[];
    [self.tableView reloadData];
}

- (void)handleAction:(id)data {
    
}

#pragma mark - Table Delegate
///=============================================================================
/// @name Table Delegate
///=============================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:@"DMDNetHistoryCell" forIndexPath:indexPath];
    @weakify(self);
    [cell viewModel:self.data[indexPath.row] action:^(id x){
        @strongify(self);
        [self handleAction:x];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 63;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView<ViewDelegate> *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DMDAppInfoHeader"];
    @weakify(self);
    [view viewModel:@{@"title":@"历史列表", @"color":HEX(@"F5FFFC",@"262628")} action:^(id x){
        @strongify(self);
        [self handleAction:x];
    }];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController<GRouterTaskDelegate> *vc = [[NSClassFromString(@"DMDRequestInfoViewController") alloc] init];
    [vc routerPassParamters:self.data[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = HEX(@"f7f7f7", @"000000");
        [_tableView registerClass:NSClassFromString(@"DMDNetHistoryCell") forCellReuseIdentifier:@"DMDNetHistoryCell"];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoHeader") forHeaderFooterViewReuseIdentifier:@"DMDAppInfoHeader"];
        _tableView.tableFooterView = [NSClassFromString(@"DMDCopyRightFooterView") new];
    }
    return _tableView;
}

@end
