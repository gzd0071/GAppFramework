//
//  DMDWebViewController.m
//  Debugger
//
//  Created by iOS_Developer_G on 2019/11/18.
//

#import "DMDWebViewController.h"
#import <WebKit/WebKit.h>
#import <YYKit/YYKit.h>
#import <GBaseLib/GConvenient.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DMDWebViewController ()<WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate>
///> 
@property (nonatomic, strong) WKWebView *webview;
///> 
@property (nonatomic, strong) NSString *jsonString;
///>
@property (nonatomic, strong) NSString *url;
@end

@implementation DMDWebViewController

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
        self.url = data[@"url"];
    }
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HEX(@"f7f7f7", @"000000");
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
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

#pragma mark - Initializes
///=============================================================================
/// @name 初始化
///=============================================================================

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
