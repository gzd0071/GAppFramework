//
//  DMHybridViewController.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/10.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMHybridViewController.h"
#import <GBaseLib/GRefreshHeader.h>
#import <GHttpConfig/GRequestUtil.h>
#import <GBaseLib/MBProgressHUD+MJ.h>
#import <GBaseLib/UIViewController+DMExtend.h>
#import <DMUILib/DMEmpty.h>
#import <GRouter/GRouter.h>
#import <GLogger/Logger.h>
#import <DMEncrypt/DMEncrypt.h>
#import "GHybrid.h"
#import <WebKit/WebKit.h>
#import <GConst/HTMLConst.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GBaseLib/UIViewController+BackButtonHandler.h>
#import <DMUILib/GHud.h>

@interface DMHybridViewController (HAAction)
- (void)handleGobackData:(NSDictionary *)args;
- (GTaskResult *)shouldHandleAction:(NSString *)func args:(NSDictionary *)args;
@end

@interface DMHybridViewController ()<WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate, GHybridDelegate, BackButtonHandlerProtocol>

///> 标识: [JS 设置]是否需要传递滚动事件到H5
@property (nonatomic, assign) BOOL needScrollAction;
///> 标识: [JS 设置]用于通知H5触底计算
@property (nonatomic, assign) CGFloat threshold;
///> 标识: [JS 配合]用于标识是否告知H5触底
@property (nonatomic, assign) BOOL ignoreScroll;
@end

@implementation DMHybridViewController

- (BOOL)navigationPopActiveForType:(UFQBackType)type {
    if (![self.webView canGoBack]) return YES;
    [self.webView goBack];
    return NO;
}

- (CGRect)webframe {
    return self.webView.frame;
}

- (void)setWebframe:(CGRect)webframe {
    self.webView.frame = webframe;
}

- (UIScrollView *)scrollView {
    return self.webView.scrollView;
}

- (void)addRefreshHeader {
    if (self.scrollView.mj_header) return;
    @weakify(self);
    self.scrollView.mj_header = [GRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self headerRefreshingAction];
    }];
}
/// rewritable
- (void)headerRefreshingAction {
    [self evaluateJS:@"window.loadData(0)"];
}

#pragma mark - DekUpdateDelegate
///=============================================================================
/// @name DekUpdateDelegate
///=============================================================================

- (void)updateDek {
    
}

#pragma mark - DMWebViewDelegate
///=============================================================================
/// @name DMWebViewDelegate
///=============================================================================

///> [JS交互] 
- (GTask<NSString *> *)evaluateJavaScript:(NSString *)str {
    GTaskSource *tcs = [GTaskSource source];
    [self.webView evaluateJavaScript:str completionHandler:^(id result, NSError * error) {
        [tcs setResult:result];
    }];
    return tcs.task;
}
///> [JS交互]: 是否拦截事件 
- (GTaskResult *)handleAction:(NSString *)name args:(NSDictionary *)args {
    return [self shouldHandleAction:name args:args];
}

- (BOOL)shouldHandleUrd:(NSString *)urd {
    return YES;
}

- (void)updateTitle:(NSString *)title {
   
}

- (void)reloadUrl:(NSString *)urlString {
    [self loadUrl:urlString];
}

- (void)loadUrl:(NSString *)url {
    if (!_webView) [self.view addSubview:self.webView];
    if (!url || url.length == 0) return;
    
    NSURLRequest *urlR = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    if ([url isEqualToString:_urlString]) {
        [MBProgressHUD showWebViewMessage:@"加载中" toView:self.view];
    }
    if (@available(iOS 11.0, *)) {
        // 兼容WKWebView cookies问题
    } else {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:urlR.URL];
        NSDictionary<NSString *, NSString *> *cookieHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        NSMutableURLRequest *mutableRequest = [urlR mutableCopy];
        [mutableRequest setAllHTTPHeaderFields:cookieHeader];
        urlR = mutableRequest;
    }
    [self loadWKWebViewRequest:urlR];
}

- (void)loadWKWebViewRequest:(NSURLRequest *)request {
    if([request.URL isFileURL]) {
        [self.webView loadFileURL:request.URL allowingReadAccessToURL:[NSURL URLWithString:HTML_FILE_ROOT]];
    } else {
        [self.webView loadRequest:request];
    }
}

#pragma mark - VCLife
///=============================================================================
/// @name 生命周期
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUrl:self.urlString];
    if (self.headerRefresh) [self addRefreshHeader];
    if (self.comBlock) self.comBlock();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self evaluateJS:[NSString stringWithFormat:@"window.viewWillAppear(%d)",animated]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self evaluateJS:[NSString stringWithFormat:@"window.viewDidAppear(%d)",animated]];
}

#pragma mark - WebView Function
///=============================================================================
/// @name WebView Function
///=============================================================================

- (void)reload {
    if (_webView) [_webView reload];
}

- (void)evaluateJS:(NSString *)jsString {
    [self evaluateJavaScript:jsString];
}

- (void)evaluateJS:(NSString *)jsString completionHandler:(void (^)(id, NSError *error))completion {
    [self evaluateJavaScript:jsString].then(^id(NSString *t){
        if (completion) completion(t, nil);
        return nil;
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGSize  size   = self.webView.size;
    
    [self actionScroll:offset size:size];
    [self actionHitBottom:offset contentSize:scrollView.contentSize];
}

// [TOJS] 滚动事件
- (void)actionScroll:(CGPoint)offset size:(CGSize)size {
    if (!self.needScrollAction) return;
    [self evaluateJS:FORMAT(@"if(jsBridgeClient && jsBridgeClient.onPageScroll) jsBridgeClient.onPageScroll(%f,%f,%f,%f)", offset.x, offset.y, size.width, size.height)];
}
// [TOJS] 触底位置
- (void)actionHitBottom:(CGPoint)offset contentSize:(CGSize)size {
    CGFloat bot = offset.y + self.webframe.size.height;
    CGFloat ch  = size.height;
    if (offset.y > 0 && self.webframe.size.height < ch && bot >= ch-self.threshold && !self.ignoreScroll) {
        [self evaluateJS:FORMAT(@"if(jsBridgeClient && jsBridgeClient.onHitPageBottom) jsBridgeClient.onHitPageBottom(%f)", offset.y)];
        self.ignoreScroll = YES;
    } else {
        self.ignoreScroll = NO;
    }
}

#pragma mark - WKWebView Delegate
///=============================================================================
/// @name WKWebView Delegate
///=============================================================================

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self shouldStartLoadRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (BOOL)shouldStartLoadRequest:(NSURLRequest *)request {
    if ([GHybrid handleHybridAction:request.URL model:self]) {
        return NO;
    } else if ([GRouter hadRegister:request.URL.scheme] && [self shouldHandleUrd:request.URL.absoluteString]) {
        LOGD(@"[JS Action] => URD: %@", request.URL.absoluteString);
        [GRouter router:request.URL.absoluteString].then(^id(id result) {
            LOGD(@"[JS Action] => Receive vc task result: %@", result);
            [self handleGobackData:result];
            return nil;
        });
        return NO;
    } else if (![request.URL.scheme hasPrefix:@"http"] && ![request.URL.scheme hasPrefix:@"file"]) {
        LOGD(@"[JS Action] => Unhandle URD: %@", request.URL.absoluteString);
        return NO;
    }
    return YES;
}

#pragma mark - Initializes
///=============================================================================
/// @name 初始化
///=============================================================================

- (WKWebView *)webView {
    if (!_webView) {
        BOOL isClear = self.dmBarHidden || CGColorEqualToColor(self.dmBarColor.CGColor, [UIColor clearColor].CGColor);
        _webView = [self getWKWebView:isClear];
    }
    return _webView;
}

- (WKWebView *)getWKWebView:(BOOL)naviTrans {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    [self shareCookie:configuration];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    webView.opaque = NO;
    webView.scrollView.delegate = self;
    if (naviTrans) {
        if (@available(iOS 11.0, *)) {
            webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    if (@available(iOS 9.0, *)) {
        webView.customUserAgent = self.userAgent?:[GRequestUtil userAgent];
    } else {
        
    }
    @weakify(self);
    [RACObserve(webView, title) subscribeNext:^(NSString *x) {
        @strongify(self);
        [self updateTitle:x];
    }];
    return webView;
}

- (void)shareCookie:(WKWebViewConfiguration *)cfg {
    if (@available(iOS 11.0, *)) {
        cfg.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [cfg.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:nil];
        }
    } else {
        NSMutableString *script = [NSMutableString string];
        [script appendString:@"(function () {\n"];
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [script appendFormat:@"document.cookie = %@ + '=' + %@", cookie.name, cookie.value];
            if (cookie.path) [script appendFormat:@" + '; Path=' + %@", cookie.path];
            if (cookie.expiresDate) {
                [script appendFormat:@" + '; Expires=' + new Date(%f).toUTCString()", cookie.expiresDate.timeIntervalSince1970 * 1000];
            }
            [script appendString:@";\n"];
        }
        [script appendString:@"})();\n"];
        WKUserScript* cookieInScript = [[WKUserScript alloc] initWithSource:script
                                                              injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                           forMainFrameOnly:YES];
        [cfg.userContentController addUserScript:cookieInScript];
    }
}

@end

@implementation DMHybridViewController (HAAction)
/// 拦截JS Action事件
- (GTaskResult *)shouldHandleAction:(NSString *)func args:(NSDictionary *)args {
    if ([func isEqualToString:@"refreshPage"]) {
        [self refreshPage:args];
        return GTaskResult(NO);
    } else if ([func isEqualToString:@"canPullWebView"]) {
        [self canPull:args];
        return GTaskResult(NO);
    } else if ([func isEqualToString:@"goBack"] || [func isEqualToString:@"finishPage"]) {
        [self goBack:args];
        return GTaskResult(NO);
    } else if ([func isEqualToString:@"loadPageStatus"]) {
        [self loadPageStatus:args];
        return GTaskResult(NO);
    } else if ([func isEqualToString:@"updateTitleBar"]) {
        [self rightBarButton:args];
        [self leftBarButton:args];
        return GTaskResult(NO);
    } else if ([func isEqualToString:@"isScrollOn"]) {
        self.needScrollAction = [args[@"isScrollOn"] boolValue];
        return GTaskResult(NO);
    } else if ([func isEqualToString:@"dataDownloadFinished"]) {
        [self dataDownloadFinished];
        return GTaskResult(NO);
    } else if ([func isEqualToString:@"setHitPageBottomThreshold"]) {
        NSString *th = args[@"threshold"];
        if (th) self.threshold = th.floatValue;
        return GTaskResult(NO);
    }
    return GTaskResult(YES);
}
/// [JS ACTION]: 添加下拉刷新组件
- (void)canPull:(NSDictionary *)args {
    BOOL can = [args[@"canRefreshable"] boolValue];
    if (!can) return;
    [self addRefreshHeader];
}
/// [JS ACTION]: 页面返回
- (void)goBack:(NSDictionary *)args {
    BOOL animated = args[@"animated"] ? [args[@"animated"] boolValue] : YES;
    if ([args[@"isLoad"] boolValue]) {
        [self.tcs setResult:args];
    }
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}
- (void)handleGobackData:(NSDictionary *)args {
    if (![args isKindOfClass:NSDictionary.class]) return;
    if (![args[@"isLoad"] boolValue]) return;
    id data = args[@"data"];
    if (data && [NSJSONSerialization isValidJSONObject:data]) {
        [self evaluateJS:FORMAT(@"window.loadData(%@)", [data jsonString])];
    } else if (data) {
        [self evaluateJS:FORMAT(@"window.loadData(\'%@\')", data)];
    } else {
        [self evaluateJS:@"window.loadData(0)"];
    }
}
/// [JS ACTION]: 页面刷新
- (void)refreshPage:(NSDictionary *)args {
    if (self.scrollView.mj_header) {
        [self.scrollView.mj_header beginRefreshing];
    } else {
        [self evaluateJS:@"window.loadData(0)"];
    }
}
/// [JS ACTION]: 加载页面状态
- (void)loadPageStatus:(NSDictionary *)args {
    NSString *status = args[@"loadPageStatus"];
    NSString *msg    = args[@"msg"];
    if ([status isEqualToString:@"loading"]) {
        [GHud toast:msg];
    } else if ([status isEqualToString:@"loadSuccess"]) {
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    } else {
        DMEmptyType type;
        if ([status isEqualToString:@"loadFailed"])         type = DMEmptyTypeServerErrorWithButton;
        else if ([status isEqualToString:@"noData"])        type = DMEmptyTypeNoData;
        else if ([status isEqualToString:@"noFound"])       type = DMEmptyTypeNoFound;
        else if ([status isEqualToString:@"netWorkFailed"]) type = DMEmptyTypeNetwork;
        else type = DMEmptyTypeNoData;
        if ([self.scrollView.mj_header isRefreshing]) {
            [self.scrollView.mj_header endRefreshing];
        }
        [self.view showEmpty:type msg:args[@"msg"]];
    }
}
/// [JS ACTION]: 右按钮
- (void)rightBarButton:(NSDictionary *)args {
    BOOL show = [args[@"rightDisplay"] boolValue];
    if (!show || self.navigationItem.rightBarButtonItem) return;
    UILabel *label = [UILabel new];
    label.text = args[@"rightText"];
    label.textColor = HEX(@"404040", @"dddddd");
    label.font = FONT(16);
    @weakify(self);
    [label addTapGesture:^{
        @strongify(self);
        [self evaluateJS:FORMAT(@"window.%@()", args[@"rightAction"])];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
}
/// [JS ACTION]: 左按钮
- (void)leftBarButton:(NSDictionary *)args {
    BOOL show = [args[@"leftDisplay"] boolValue];
    if (!show) return;
    UIImageView *img = [[UIImageView alloc] initWithImage:IMAGE(@"btn_back_normal")];
    @weakify(self);
    [img addTapGesture:^{
        @strongify(self);
        [self evaluateJS:FORMAT(@"window.%@()", args[@"leftAction"])];
    }];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:img];
}
/// [JS ACTION]:
- (void)dataDownloadFinished {
    if (!self.scrollView.mj_header.isRefreshing) return;
    [self.scrollView.mj_header endRefreshing];
    
    CGSize size    = self.scrollView.contentSize;
    CGPoint offset = self.scrollView.contentOffset;
    CGFloat bot = offset.y + self.webframe.size.height;
    CGFloat ch  = size.height;
    if (offset.y > 0 && self.webframe.size.height < ch && bot >= ch-50) {
        [self evaluateJS:FORMAT(@"if(jsBridgeClient && jsBridgeClient.onHitPageBottom) jsBridgeClient.onHitPageBottom(%f)", offset.y)];
    }
}
@end
