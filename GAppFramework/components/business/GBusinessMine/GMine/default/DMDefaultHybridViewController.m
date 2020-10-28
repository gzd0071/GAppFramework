//
//  DMDefaultHybridViewController.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/5/10.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMDefaultHybridViewController.h"
#import <GLogger/Logger.h>
#import <YYKit/NSString+YYAdd.h>
#import <GConst/URDConst.h>
#import <GConst/HTMLConst.h>

@interface DMDefaultHybridViewController ()
///>  
@property (nonatomic, strong) NSString *urd;
@end

@implementation DMDefaultHybridViewController

ROUTER_REGISTER(RouterDefaultHandler, RouterDefaultHandler);

#pragma mark - RouterDelegate
///=============================================================================
/// @name RouterDelegate
///=============================================================================

+ (id)beforeInterceptors:(GRouterDigester *)data {
    DMDefaultHybridViewController *vc = [DMDefaultHybridViewController new];
    if ([data.url.host isEqualToString:@"browser"] && data.url.path.length) {
        vc.urlString = [[data.url.path substringFromIndex:1] stringByURLDecode];
    } else if ([data.url.path hasPrefix:@"//"]) {
        vc.urlString = HTML_FILE_C([data.url.path substringFromIndex:2]);
        if (vc.urlString && data.data) vc.urlString = URL_ADD_PARAMS(vc.urlString, data.data);
    } else if (data.url.host.length || data.url.absoluteString) {
        NSString *key = data.url.host.length ? data.url.host : data.url.absoluteString;
        key = key.lowercaseString;
        vc.urlString = [HTMLConst urdHTMLMap:data.url.scheme?:CSCHEME][key];
        vc.urd = key;
        if (vc.urlString && data.data) vc.urlString = URL_ADD_PARAMS(vc.urlString, data.data);
    }
    if (vc.urlString) {
        [[GRouter navi] pushViewController:vc animated:YES];
    } else {
        LOGE(@"[Hybrid URD] => Error. %@", data.url.absoluteString);
    }
    return [GTaskResult taskResultWithSuc:NO data:[vc delegateTask]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dmBarColor = HEX(@"ffffff", @"1c1c1e");
    self.dmHairlineHidden = YES;
    self.scrollView.backgroundColor = HEX(@"f7f7f7", @"000000");
    if ([self noScroll]) self.scrollView.scrollEnabled = NO;
}

///> 配置文件: 无需滚动 
- (BOOL)noScroll {
    return NO;
}

- (void)updateTitle:(NSString *)title {
    self.navigationItem.title = title;
}

@end
