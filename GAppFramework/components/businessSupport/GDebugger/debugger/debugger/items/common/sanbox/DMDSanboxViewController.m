//
//  DMDSanboxViewController.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/30.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDSanboxViewController.h"
#import "DMDSanboxModel.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GProtocol/ViewProtocol.h>
#import <GBaseLib/GConvenient.h>

@interface DMDSanboxViewController ()<UITableViewDelegate, UITableViewDataSource>
///> 
@property (nonatomic, strong) UITableView *tableView;
///> 
@property (nonatomic, strong) DMDSanboxModel *model;
///> 
@property (nonatomic, strong) NSArray<DMDSanboxModel *> *models;
@end

@implementation DMDSanboxViewController

#pragma mark - DebuggerPluginDelegate
///=============================================================================
/// @name DebuggerPluginDelegate
///=============================================================================

+ (NSString *)pluginName {
    return @"沙盒文件";
}
// 主题色 "#4D8F79"
+ (UIImage *)pluginIcon {
    return [UIImage imageNamed:@"doraemon_file@3x"];
}

+ (void)pluginTapAction:(UINavigationController *)navi {
    DMDSanboxViewController *vc = [DMDSanboxViewController new];
    [navi pushViewController:vc animated:YES];
}


- (void)routerPassParamters:(id)data {
    self.model = data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [self.class pluginName];
    self.view.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
    self.models = @[];
    
    [self.view addSubview:self.tableView];
    @weakify(self);
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self handleData];
}

- (void)handleData {
    NSFileManager *fm = [NSFileManager defaultManager];
    //该目录下面的内容信息
    NSMutableArray *files = @[].mutableCopy;
    NSError *error = nil;
    
    NSString *spath = self.model ? self.model.path : NSHomeDirectory();
    NSArray *paths = [fm contentsOfDirectoryAtPath:spath error:&error];
    for (NSString *path in paths) {
        BOOL isDir = false;
        NSString *fullPath = [spath stringByAppendingPathComponent:path];
        [fm fileExistsAtPath:fullPath isDirectory:&isDir];
        
        DMDSanboxModel *model = [[DMDSanboxModel alloc] init];
        model.path = fullPath;
        model.isFile = !isDir;
        model.name = path;
        [files addObject:model];
    }
    [files sortUsingComparator:^NSComparisonResult(DMDSanboxModel *obj1, DMDSanboxModel *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    self.models = files.copy;
    
    [self.tableView reloadData];
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

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
    return [self.models count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:@"DMDSanboxCell" forIndexPath:indexPath];
    @weakify(self);
    BOOL isLast = indexPath.row == self.models.count - 1;
    [cell viewModel:RACTuplePack(self.models[indexPath.row], @(isLast)) action:^(id x){
        @strongify(self);
        [self handleAction:x];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView<ViewDelegate> *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DMDAppInfoHeader"];
    @weakify(self);
    [view viewModel:@{@"title":self.model.name?:[self.class pluginName], @"color":HEX(@"C3E5DB", @"262628")} action:^(id x){
        @strongify(self);
        [self handleAction:x];
    }];
//    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
//    [tap addTarget:self action:@selector(headerTapAction)];
//    [view addGestureRecognizer:tap];
//    view.userInteractionEnabled = YES;
    return view;
}

- (void)headerTapAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.models[indexPath.row].isFile) return;
    UIViewController<GRouterTaskDelegate> *vc = [[self.class alloc] init];
    [vc routerPassParamters:self.models[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    DMDSanboxModel *model = _models[indexPath.row];
    NSMutableArray *mut = self.models.mutableCopy;
    [mut removeObjectAtIndex:indexPath.row];
    self.models = mut.copy;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:model.path error:nil];
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
        [_tableView registerClass:NSClassFromString(@"DMDSanboxCell") forCellReuseIdentifier:@"DMDSanboxCell"];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoHeader") forHeaderFooterViewReuseIdentifier:@"DMDAppInfoHeader"];
        _tableView.tableFooterView = [NSClassFromString(@"DMDCopyRightFooterView") new];
    }
    return _tableView;
}

@end
