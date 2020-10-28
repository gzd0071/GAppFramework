//
//  DMDAppInfoViewController.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDAppInfoViewController.h"
#import <sys/utsname.h>
// 下面是获取ip需要的头文件
#include <ifaddrs.h>
#include <sys/socket.h> // Per msqr
#import <sys/ioctl.h>
#include <net/if.h>
#import <arpa/inet.h>
#import <Masonry/Masonry.h>
#import <GPermission/GPermission.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GProtocol/ViewProtocol.h>
#import <GBaseLib/GConvenient.h>

@interface DMDAppInfoViewController ()<UITableViewDelegate, UITableViewDataSource>
///> 
@property (nonatomic, strong) UITableView *tableView;
///> 
@property (nonatomic, strong) NSArray *data;
@end

@implementation DMDAppInfoViewController

#pragma mark - DebuggerPluginDelegate
///=============================================================================
/// @name DebuggerPluginDelegate
///=============================================================================

+ (NSString *)pluginName {
    return @"App信息";
}

+ (UIImage *)pluginIcon {
    return [UIImage imageNamed:@"debugger_app_info"];
}

+ (void)pluginTapAction:(UINavigationController *)navi {
    DMDAppInfoViewController *vc = [DMDAppInfoViewController new];
    [navi pushViewController:vc animated:YES];
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [self.class pluginName];
    self.view.backgroundColor = HEX(@"f7f7f7", @"000000");
    [self.view addSubview:self.tableView];
    [self autoDismissKeyboard];
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
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:@"DMDAppInfoCell" forIndexPath:indexPath];
    @weakify(self);
    BOOL isLast = indexPath.row == [self.data[indexPath.section][@"infos"] count] - 1;
    [cell viewModel:RACTuplePack(self.data[indexPath.section][@"infos"][indexPath.row], @(isLast))
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
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoCell") forCellReuseIdentifier:@"DMDAppInfoCell"];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoHeader") forHeaderFooterViewReuseIdentifier:@"DMDAppInfoHeader"];
        _tableView.tableFooterView = [NSClassFromString(@"DMDCopyRightFooterView") new];
    }
    return _tableView;
}

#pragma mark - Data
///=============================================================================
/// @name Data
///=============================================================================

- (NSArray *)getData {
    return @[@{@"title": @"手机信息",
               @"infos": @[@{@"name": @"设备名称",
                             @"value": [UIDevice currentDevice].name
                             },
                           @{@"name": @"手机型号",
                             @"value": [self getDeviceName]
                             },
                           @{@"name": @"系统版本",
                             @"value": [UIDevice currentDevice].systemVersion
                             }]
               },
             @{@"title": @"App信息",
               @"infos": @[@{@"name": @"应用名称",
                             @"value": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
                             },
                           @{@"name": @"BundleID",
                             @"value": [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey]
                             },
                           @{@"name": @"App版本",
                             @"value": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey]
                             },
                           @{@"name": @"编译版本",
                             @"value": [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey]
                             }]
               },
             @{@"title": @"权限信息",
               @"infos": @[@{@"name": @"推送权限",
                             @"value": [self getStringFrom:[GPermission push]],
                             @"color": [self getColorFrom:[GPermission push]]
                             },
                           @{@"name": @"相册权限",
                             @"value": [self getStringFrom:[GPermission photo]],
                             @"color": [self getColorFrom:[GPermission photo]]
                             },
                           @{@"name": @"相机权限",
                             @"value": [self getStringFrom:[GPermission camera]],
                             @"color": [self getColorFrom:[GPermission camera]]
                             },
                           @{@"name": @"联系人权限",
                             @"value": [self getStringFrom:[GPermission contacts]],
                             @"color": [self getColorFrom:[GPermission contacts]]
                             },
                           @{@"name": @"麦克风权限",
                             @"value": [self getStringFrom:[GPermission microphone]],
                             @"color": [self getColorFrom:[GPermission microphone]]
                             },
                           @{@"name": @"位置权限",
                             @"value": [self getStringFrom:[GPermission location]],
                             @"color": [self getColorFrom:[GPermission location]]
                             },
                           @{@"name": @"日历权限",
                             @"value": [self getStringFrom:[GPermission event]],
                             @"color": [self getColorFrom:[GPermission event]]
                             },
                           @{@"name": @"提醒权限",
                             @"value": [self getStringFrom:[GPermission reminder]],
                             @"color": [self getColorFrom:[GPermission reminder]]
                             }],
               },@{@"title": @"UserInfo信息",
                   @"infos": @[@{@"name": @"详情页自营弹框次数",
                                 @"value": [[NSUserDefaults standardUserDefaults] valueForKey:@"DMJobAlertKey-ziying"]?:@"",
                                 @"block":^(NSString *x) {
                                     [[NSUserDefaults standardUserDefaults] setValue:x forKey:@"DMJobAlertKey-ziying"];
                                 }
                                },
                               @{@"name": @"详情页约面弹框次数",
                                 @"value": [[NSUserDefaults standardUserDefaults] valueForKey:@"DMJobAlertKey-interview"]?:@"",
                                 @"block":^(NSString *x) {
                                     [[NSUserDefaults standardUserDefaults] setValue:x forKey:@"DMJobAlertKey-interview"];
                                 }
                                 }]}];
}

- (NSString *)getStringFrom:(AuthStatus)status {
    switch (status) {
        case AuthStatusUnDetermined:
            return @"未授权";
        case AuthStatusAuthorized:
            return @"已授权";
        case AuthStatusDenied:
            return @"授权被拒";
        case AuthStatusRestricted:
            return @"权限受限";
    }
}

- (UIColor *)getColorFrom:(AuthStatus)status {
    switch (status) {
        case AuthStatusUnDetermined:
            return RGB(76,91,97);
        case AuthStatusAuthorized:
            return RGB(46,204,113);
        case AuthStatusDenied:
            return RGB(231,76,60);
        case AuthStatusRestricted:
            return RGB(241,196,15);
    }
}

// 获取设备型号然后手动转化为对应名称
- (NSString *)getDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])    return @"iPad 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad6,12"])    return @"iPad 5 (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,1"])     return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])     return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])     return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])     return @"iPad Pro 10.5 inch (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,5"])     return @"iPad 6th generation";
    if ([deviceString isEqualToString:@"iPad7,6"])     return @"iPad 6th generation";
    if ([deviceString isEqualToString:@"iPad8,1"])     return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,2"])     return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,3"])     return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,4"])     return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,5"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,6"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,7"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,8"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}

- (NSString *)getDeviceIPAddresses {
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    NSMutableArray *ips = [NSMutableArray array];
    int BUFFERSIZE = 4096;
    struct ifconf ifc;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifreq *ifr, ifrcopy;
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) >= 0){
        
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            int len = sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) continue;
            
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags & IFF_UP) == 0) continue;
            
            NSString *ip = [NSString  stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    
    close(sockfd);
    NSString *deviceIP = @"";
    
    for (int i=0; i < ips.count; i++) {
        if (ips.count > 0) {
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    return deviceIP;
}

@end
