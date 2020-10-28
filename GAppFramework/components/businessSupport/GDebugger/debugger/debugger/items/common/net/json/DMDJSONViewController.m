//
//  DMDJSONViewController.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/5/5.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDJSONViewController.h"
#import <WebKit/WebKit.h>
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GProtocol/ViewProtocol.h>
#import <GBaseLib/GConvenient.h>

@interface DMDJSONViewController ()<WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate>
///> 
@property (nonatomic, strong) UIWebView *webview;
///> 
@property (nonatomic, strong) NSString *jsonString;
@end

@implementation DMDJSONViewController

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
    self.view.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
    self.webview = [self getUIWebView];
    [self.view addSubview:self.webview];
    self.webview.backgroundColor = self.view.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    @weakify(self);
    [_webview mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    NSString *base = FORMAT(@"%@", [[NSBundle mainBundle] bundlePath]);
    NSURL *baseUrl = [NSURL fileURLWithPath:base isDirectory:YES];
    NSString *htmlPath = FORMAT(@"%@/jsonviewer.html", base);
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString:htmlString baseURL:baseUrl];
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

#pragma mark - Initializes
///=============================================================================
/// @name 初始化
///=============================================================================

- (UIWebView *)getUIWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.delegate = self;
    webView.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
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
