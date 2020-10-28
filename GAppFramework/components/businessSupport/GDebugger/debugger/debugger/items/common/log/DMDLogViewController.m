//
//  DMDLogViewController.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/8/12.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMDLogViewController.h"
#import "DMDSanboxModel.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GProtocol/ViewProtocol.h>
#import <GLogger/Logger.h>
#import <GRouter/GRouter.h>
#import "DHttpServer.h"
#import <DMUILib/GHud.h>
#import <WebKit/WebKit.h>
#import <YYKit/YYKit.h>
#import <GBaseLib/GConvenient.h>

@interface DMDLogWebViewController : UIViewController<WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate>
///> 
@property (nonatomic, strong) UIWebView *webview;
///> 
@property (nonatomic, strong) NSString *jsonString;
@end

@implementation DMDLogWebViewController

#pragma mark - RouterData
///=============================================================================
/// @name RouterData
///=============================================================================

- (void)routerPassParamters:(id)data {
    if ([data isKindOfClass:NSString.class]) {
        self.jsonString = data ?: [@{} jsonStringEncoded];
    } else if ([data isKindOfClass:NSDictionary.class]) {
        self.jsonString = data[@"data"] ?: [@{} jsonStringEncoded];
        self.navigationItem.title = data[@"title"];
    }
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webview = [self getWKWebView];
    self.webview.backgroundColor = HEX(@"23241f");
    [self.view addSubview:self.webview];
    self.webview.backgroundColor = self.view.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    [_webview mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    id url = FORMAT(@"%@/#/logHistory", [DHttpServer getIPPort]);
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

#pragma mark - JS
///=============================================================================
/// @name JS
///=============================================================================

- (void)evaluateJS:(NSString *)jsString {
    [self evaluateJavaScript:jsString completionHandler:nil];
}

- (void)evaluateJavaScript:(NSString *)jsString completionHandler:(void (^)(id, NSError *error))completion {
    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:jsString];
    if (completion) completion(result, nil);
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self evaluateJS:FORMAT(@"renderJSONString(%@)", self.jsonString)];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

#pragma mark - Initializes
///=============================================================================
/// @name 初始化
///=============================================================================

- (UIWebView *)getUIWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.delegate = self;
    return webView;
}

- (WKWebView *)getWKWebView {
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];

    WKPreferences* preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;

    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;

    return webView;
}

@end


@interface DMDLogViewController ()<UITableViewDelegate, UITableViewDataSource>
///> 
@property (nonatomic, strong) UITableView *tableView;
///> 
@property (nonatomic, strong) DMDSanboxModel *model;
///> 
@property (nonatomic, strong) NSArray<DMDSanboxModel *> *models;
@end

@implementation DMDLogViewController

#pragma mark - DebuggerPluginDelegate
///=============================================================================
/// @name DebuggerPluginDelegate
///=============================================================================

+ (NSString *)pluginName {
    return @"开发日志";
}

+ (UIImage *)pluginIcon {
    return [UIImage imageNamed:@"doraemon_log@3x"];
}

+ (void)pluginTapAction:(UINavigationController *)navi {
    DMDLogViewController *vc = [DMDLogViewController new];
    [navi pushViewController:vc animated:YES];
}

#pragma mark - DebuggerPluginDelegate
///=============================================================================
/// @name DebuggerPluginDelegate
///=============================================================================

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
    
    NSString *spath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/Logs"];
    NSArray *paths = [fm contentsOfDirectoryAtPath:spath error:&error];
    for (NSString *path in paths) {
        BOOL isDir = false;
        NSString *fullPath = [spath stringByAppendingPathComponent:path];
        [fm fileExistsAtPath:fullPath isDirectory:&isDir];
        
        DMDSanboxModel *model = [[DMDSanboxModel alloc] init];
        model.path = fullPath;
        model.isFile = !isDir;
        model.name = [path componentsSeparatedByString:@" "].lastObject;
        [files addObject:model];
    }
    self.models = files.copy;
    
    [self.tableView reloadData];
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

- (void)handleAction:(RACTuple *)data idx:(NSInteger)idx {
    if ([data.first isEqualToString:@"Switch"]) {
        LogLevel cur = [[self sectionFirst][idx][@"level"] integerValue];
        if ([Logger currentLogLevel] >= cur) {
            if (idx == 0) cur = LogLevelOff;
            else cur = [[self sectionFirst][idx-1][@"level"] integerValue];
        }
        [Logger updateLevel:cur];
        [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(UITableViewCell<ViewDelegate> *obj, NSUInteger sid, BOOL *stop) {
            if ([obj isKindOfClass:NSClassFromString(@"DMDLogCell")]) {
                [obj viewAction:[self sectionFirst][idx][@"level"]];
            }
        }];
    }
}

- (NSArray *)sectionFirst {
    return @[@{@"title":@"LogLevelError",   @"level":@(LogLevelError)},
             @{@"title":@"LogLevelWarn",    @"level":@(LogLevelWarning)},
             @{@"title":@"LogLevelInfo",    @"level":@(LogLevelInfo)},
             @{@"title":@"LogLevelDebug",   @"level":@(LogLevelDebug)},
             @{@"title":@"LogLevelVerbose", @"level":@(LogLevelVerbose)}];
}

- (NSArray *)sectionZero {
    return @[@{@"name":@"服务器地址", @"value": [DHttpServer getIPPort]}];
}

#pragma mark - Table Delegate
///=============================================================================
/// @name Table Delegate
///=============================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [self sectionZero].count;
    else if (section == 1) return [self sectionFirst].count;
    return [self.models count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id identi = indexPath.section == 1 ? @"DMDLogCell" : indexPath.section == 0 ? @"DMDAppInfoCell" : @"DMDSanboxCell";
    NSArray *models = indexPath.section == 1 ? [self sectionFirst] : indexPath.section == 0 ? [self sectionZero]:self.models;
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:identi forIndexPath:indexPath];
    @weakify(self);
    BOOL isLast = indexPath.row == models.count - 1;
    [cell viewModel:RACTuplePack(models[indexPath.row], @(isLast)) action:^(id x){
        @strongify(self);
        [self handleAction:x idx:indexPath.row];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIPasteboard *ps = [UIPasteboard generalPasteboard];
        NSString *value = [self sectionZero][0][@"value"];
        [ps setString:value];
        [GHud toast:@"地址已复制到剪切板" view:self.view];
        return;
    }
    if (self.models[indexPath.row].isFile) {
        DMDLogWebViewController *vc = [DMDLogWebViewController new];
        NSMutableDictionary *mut = @{}.mutableCopy;
        mut[@"data"] = [NSString stringWithContentsOfFile:self.models[indexPath.row].path encoding:NSUTF8StringEncoding error:nil];
        [DHttpServer addGetRequest:@"/logHistory" result:^NSDictionary *(NSString *path) {
            return mut;
        }];
        [vc routerPassParamters:mut];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    UIViewController<GRouterDataDelegate> *vc = [NSClassFromString(@"DMDSanboxViewController") new];
    [vc routerPassParamters:self.models[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) return YES;
    return NO;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView<ViewDelegate> *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DMDAppInfoHeader"];
    [view viewModel:@[@{@"title":@"日志服务器"},
                      @{@"title":@"日志等级"},
                      @{@"title":@"日志文件"}][section] action:^(id x){
                      }];
    return view;
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
        [_tableView registerClass:NSClassFromString(@"DMDLogCell") forCellReuseIdentifier:@"DMDLogCell"];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoCell") forCellReuseIdentifier:@"DMDAppInfoCell"];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoHeader") forHeaderFooterViewReuseIdentifier:@"DMDAppInfoHeader"];
        _tableView.tableFooterView = [NSClassFromString(@"DMDCopyRightFooterView") new];
    }
    return _tableView;
}

@end
