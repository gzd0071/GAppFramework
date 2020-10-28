//
//  DMDRequestInfoViewController.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/5/6.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDRequestInfoViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GProtocol/ViewProtocol.h>
#import <YYKit/YYKit.h>
#import <DMEncrypt/DMEncrypt.h>
#import <GBaseLib/GConvenient.h>
#import "URLInjectorRecorder.h"
#import "URLInjectorRequestPacket.h"
#import "DMDWebViewController.h"
#import "DHttpServer.h"

@interface DMDRequestInfoViewController ()<UITableViewDelegate, UITableViewDataSource>
///> 
@property (nonatomic, strong) UITableView *tableView;
///> 
@property (nonatomic, strong) NSArray *data;
///> 
@property (nonatomic, strong) URLInjectorRequestPacket *packet;
@end

@implementation DMDRequestInfoViewController

- (void)routerPassParamters:(id)data {
    self.packet = data;
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"请求信息";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.data = [self getData];
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

- (void)handleAction:(id)data {
    
}

#pragma mark - Table Delegate
///=============================================================================
/// @name Table Delegate
///=============================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data[section][@"infos"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *model = self.data[indexPath.section][@"infos"][indexPath.row];
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:@"DMDAppInfoCell" forIndexPath:indexPath];
    @weakify(self);
    BOOL isLast = indexPath.row == [self.data[indexPath.section][@"infos"] count] - 1;
    [cell viewModel:RACTuplePack(model, @(isLast))
             action:^(id x){
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
    [view viewModel:self.data[section] action:^(id x){
        @strongify(self);
        [self handleAction:x];
    }];
    view.contentView.backgroundColor = HEX(@"F5FFFC", @"262628");
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *model = self.data[indexPath.section][@"infos"][indexPath.row];
    BOOL canTap = [model[@"canTap"] boolValue];
    if (!canTap) return;
    
    UIViewController<GRouterDataDelegate> *vc = [[NSClassFromString(@"DMDJSONViewController") alloc] init];
    [vc routerPassParamters:@{@"data":model[@"data"], @"title":model[@"name"]}];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle  = UITableViewCellSelectionStyleNone;
        _tableView.backgroundColor = HEX(@"f7f7f7", @"000000");
        _tableView.dataSource      = self;
        _tableView.delegate        = self;
        _tableView.tableFooterView = [NSClassFromString(@"DMDCopyRightFooterView") new];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoCell") forCellReuseIdentifier:@"DMDAppInfoCell"];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoHeader") forHeaderFooterViewReuseIdentifier:@"DMDAppInfoHeader"];
    }
    return _tableView;
}

#pragma mark - Data
///=============================================================================
/// @name Data
///=============================================================================

- (NSDictionary *)handleRequestHeaders:(NSDictionary *)dict {
    NSMutableDictionary *mut = dict.mutableCopy;
    if (mut[@"Common"]) mut[@"Common"] = [self decodeParaString:mut[@"Common"]];
    if (mut[@"info"]) mut[@"info"] = [self decodeParaString:mut[@"info"]];
    if (mut[@"AccessToken"]) mut[@"AccessToken"] = [DMEncrypt decryptString:mut[@"AccessToken"]];
    if (mut[@"Cookie"]) mut[@"Cookie"] = [self paraString:mut[@"Cookie"]];
    return mut;
}

- (NSDictionary *)handleRequestBody:(NSString *)jsonString {
    NSDictionary *dict = jsonString.jsonValueDecoded;
    if (!dict) {
        return [self paraString:jsonString];
    };
    NSMutableDictionary *mut = dict.mutableCopy;
    if (mut[@"data"]) mut[@"data"] = [DMEncrypt decryptString:mut[@"data"]];
    return mut;
}

- (NSDictionary *)decodeParaString:(NSString *)str {
    str = [DMEncrypt decryptString:str];
    return [self paraString:str];
}

- (NSDictionary *)paraString:(NSString *)str {
    NSArray *arr = [str componentsSeparatedByString:@";"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    [arr enumerateObjectsUsingBlock:^(NSString *kv, NSUInteger idx, BOOL *stop) {
        NSArray *kva = [kv componentsSeparatedByString:@"="];
        NSString *key = kva.firstObject;
        key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *value = kva.count > 1 ? kva[1] : @"";
        value = [value stringByRemovingPercentEncoding];
        id jv = value.modelToJSONObject;
        if (jv) value = jv;
        dict[key] = value;
    }];
    return dict;
}

///> 解析 URI 参数 
- (NSDictionary *)paraDict:(NSString *)para {
    if (!para) return nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *arr = [para componentsSeparatedByString:@"&"];
    [arr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSArray *keyValue = [obj componentsSeparatedByString:@"="];
        NSString *value = [keyValue.lastObject?:@"" stringByRemovingPercentEncoding];
        [dict setValue:value forKey:keyValue.firstObject?:@""];
    }];
    return dict;
}

- (NSArray *)getData {
    NSMutableArray *mut = @[].mutableCopy;
    if (self.packet.requestHeaders) {
        [mut addObject:@{@"name": @"请求Headers",
                         @"data": [self handleRequestHeaders:self.packet.requestHeaders].modelToJSONString,
                         @"canTap": @(YES)
                         }];
    }
    if (self.packet.requestBody) {
        [mut addObject:@{@"name": @"请求Body",
                         @"data": [self handleRequestBody:self.packet.requestBody.utf8String],
                         @"canTap": @(YES)
                         }];
    } else if ([self.packet.requestMethod isEqualToString:@"GET"] && self.packet.url.query) {
        [mut addObject:@{@"name": @"请求Body",
                         @"data": [self paraDict:self.packet.url.query],
                         @"canTap": @(YES)
                         }];
    }
    if (self.packet.responseHeaders) {
        [mut addObject:@{@"name": @"响应Headers",
                         @"data": self.packet.responseHeaders.modelToJSONString,
                         @"canTap": @(YES)
                         }];
    }
    NSData *data = [URLInjectorRecorder cachedResponseBody:self.packet];
    if (data) {
        [mut addObject:@{@"name": @"响应Body",
                         @"data": data.utf8String?:@"",
                         @"canTap": @(YES)
                         }];
    }
    return @[[self urlInfo],@{@"title": @"通用信息",
               @"infos": @[@{@"name": @"请求类型(method)",
                             @"value": self.packet.requestMethod,
                             @"color": [self getMethodColor:self.packet.requestMethod],
                             },
                           @{@"name": @"状态码(Code)",
                             @"value": self.packet.statusCode,
                             @"color": [self getCodeColor:self.packet.statusCode.integerValue],
                             },
                           @{@"name": @"数据类型(MIMEType)",
                             @"value": self.packet.response.MIMEType?:@"",
                             },
                           @{@"name": @"开始时间(Start)",
                             @"value": [self timeFormat:self.packet.startDate],
                             },
                           @{@"name": @"请求时间(Duration)",
                             @"value": [self formatTime:self.packet.duration]
                             },
                           @{@"name": @"延迟时间(Latency)",
                             @"value": [self formatTime:self.packet.latency]
                             }]
               },
             @{@"title": @"更多信息",
               @"infos": mut
               }];
}

- (NSDictionary *)urlInfo {
    NSURL *url = self.packet.url;
    NSMutableArray *mut = @[].mutableCopy;
    if (url.scheme) [mut addObject:@{@"name": @"SCHEME", @"value": url.scheme}];
    if (url.host) [mut addObject:@{@"name": @"HOST", @"value": url.host}];
    if (url.port) [mut addObject:@{@"name": @"PORT", @"value": url.port}];
    if (url.path) [mut addObject:@{@"name": @"PATH", @"value": url.path}];
    if (url.fragment) [mut addObject:@{@"name": @"FRAGMENT", @"value": url.fragment}];
    return @{@"title": @"URL信息",
             @"infos": mut
    };
}

- (UIColor *)getCodeColor:(NSInteger)code {
    if (code >= 200 && code < 300) {
        return RGB(46,204,113);
    } else if (code >= 300 && code < 400) {
        return RGB(241,196,15);
    } else {
        return RGB(231,76,60);
    }
}

- (UIColor *)getMethodColor:(NSString *)method {
    method = [method uppercaseString];
    if ([method isEqualToString:@"GET"]) {
        return RGB(0,206,201);
    } else if ([method isEqualToString:@"POST"]) {
        return RGB(253,203,110);
    } else if ([method isEqualToString:@"DELETE"]) {
        return RGB(225,112,85);
    } else if ([method isEqualToString:@"PUT"]) {
        return RGB(9,132,227);
    }
    return RGB(153,153,153);
}

- (NSString *)timeFormat:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)duration:(NSDate *)start end:(NSDate *)end {
    NSTimeInterval pad = [end timeIntervalSince1970] - [start timeIntervalSince1970];
    return [self formatTime:pad];
}

- (NSString *)formatTime:(NSTimeInterval)pad {
    if (pad >= 3600 * 24) {
        return FORMAT(@"%ldd", (long)(pad/(3600 *24)));
    } else if (pad >= 3600) {
        return FORMAT(@"%ldh", (long)(pad/(3600)));
    } else if (pad >= 60) {
        return FORMAT(@"%ldmin", (long)(pad/(60)));
    } else if (pad >= 1) {
        return FORMAT(@"%.2fs", pad);
    } else {
        return FORMAT(@"%ldms", (long)(pad * 1000));
    }
}

@end

