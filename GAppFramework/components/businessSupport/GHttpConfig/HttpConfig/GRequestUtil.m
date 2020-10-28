//
//  GRequestUtil.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/12.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "GRequestUtil.h"
#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <DMEncrypt/DMEncrypt.h>
#import <DMToken/DMSToken.h>
#import <GTask/GTaskResult.h>
#import <GTask/GTask+Fwd.h>

#import <WebKit/WebKit.h>
#if __has_include(<YYReachability.h>)
#import <YYReachability.h>
#endif

@implementation GRequestUtil

#pragma mark - RequestInfo
///=============================================================================
/// @name RequestInfo
///=============================================================================

+ (NSString *)accessToken {
    return [DMSToken accessToken];
}

static NSString *ua;
/// 无法保证UA必定有
+ (NSString *)ua {
    if (ua) return ua;
    dispatch_task_on(dispatch_get_main_queue(), ^{
        WKWebView *web = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[WKWebViewConfiguration new]];
        web.translatesAutoresizingMaskIntoConstraints = NO;
        [web evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            ua = result?:nil;
            [web removeFromSuperview];
        }];
    });
    return ua?:@"Mozilla/5.0";
}

+ (NSString *)userAgent {
    // TODO: FIX SAFE
    NSMutableString *mut = [[self ua] mutableCopy];
    // app版本号
    [mut appendFormat:@" DouMi/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    // 编译版本号
    [mut appendFormat:@" BuildCode/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    // scheme
    [mut appendString:@" Platform/iOS"];
    // 渠道
    [mut appendString:@" ChannelID/AppStore"];
    // DeviceToken
    [mut appendFormat:@" dmdt/%@", [DMSToken deviceToken]];
    // info
    [mut appendFormat:@" info/%@", [self info]];
    return mut;
}

+ (NSString *)info {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // app版本号
    [dict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"v"];
    // 编译版本号
    [dict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"bc"];
    // scheme
    [dict setObject:@"DouMi" forKey:@"scheme"];
    // 渠道
    [dict setObject:@"AppStore" forKey:@"ch"];
    // Appid
    [dict setObject:@"61" forKey:@"appid"];
    // 城市id
    [dict setObject:@"12" forKey:@"cityId"];
    // 选中城市id
    [dict setObject:@"12" forKey:@"selectCityId"];
    // IMSI
    [dict setObject:[self IMSI] forKey:@"IMSI"];
    // 运营商
    [dict setObject:[self carrier] forKey:@"carrier"];
    // 手机号
    [dict setObject:@"-" forKey:@"phone"];
    // 网络类型
    [dict setObject:[self networkStatus] forKey:@"nettype"];
    // IDFA
    [dict setObject:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forKey:@"idfa"];
    // 设备型号
    [dict setObject:[self deviceName] forKey:@"device_model"];
    // token创建时间
    [dict setObject:@"" forKey:@"create_at"];
    
    return [DMEncrypt encryptString:[self transDicToString:dict]];
}

+ (NSDictionary *)commentHeader {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // info
    [dict setObject:[self info] forKey:@"info"];
    // accessToken
    [dict setObject:[self accessToken] forKey:@"accessToken"];
    // 协议头
    [dict setObject:@"https" forKey:@"doumi-protocol"];
    return dict;
}

+ (GTask<GTaskResult<NSDictionary *> *> *)requestDefaultHeader {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 赶集ID
    [dict setObject:@"779" forKey:@"X-Ganji-CustomerId"];
    // Content-Type
    [dict setObject:@"application/json" forKey:@"Content-Type"];
    // 代理商
    [dict setObject:@"appstore" forKey:@"agency"];
    // 设备和屏宽
    CGSize size = [UIScreen mainScreen].bounds.size;
    NSString *ca = [NSString stringWithFormat:@"%@#%0.f*%0.f", [UIDevice currentDevice].model, size.width, size.height];
    [dict setObject:ca forKey:@"clientAgent"];
    // info
    [dict setObject:[self info] forKey:@"info"];
    // User-Agent
    [dict setObject:[self userAgent] forKey:@"User-Agent"];
    // Accept-Encoding
    [dict setObject:@"gzip" forKey:@"Accept-Encoding"];
    // 协议头
    [dict setObject:@"https" forKey:@"doumi-protocol"];
    // User-Agent
    [dict setObject:@"json2" forKey:@"contentformat"];
    // 可能异步获取Token
    return [DMSToken getAccessToken].then(^id(NSString *t) {
        [dict setObject:t?:@"" forKey:@"accessToken"];
        return [GTask taskWithValue:[GTaskResult taskResultWithSuc:t.length data:dict]];
    });
}

#pragma mark - Funcs
///=============================================================================
/// @name Funcs
///=============================================================================

+ (NSString *)transDicToString:(NSDictionary *)dict {
    if (!dict) return @"";
    NSMutableString *mut = @"".mutableCopy;
    [dict.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [mut appendFormat:@";%@=%@", obj, dict[obj] ?: @""];
    }];
    return mut;
}

+ (NSString *)IMSI {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    return  [NSString stringWithFormat:@"%@%@", [carrier mobileCountryCode], [carrier mobileNetworkCode]];
}

+ (NSString *)carrier {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *carrier = [[info subscriberCellularProvider] carrierName];
    if ([carrier isEqualToString:@"中国移动"]) {
        return @"ChinaMobile";
    } else if ([carrier isEqualToString:@"中国联通"]) {
        return @"ChinaUnicom";
    } else if ([carrier isEqualToString:@"中国电信"]) {
        return @"ChinaTelecom";
    }
    return @"unknown";
}

+ (NSString *)networkStatus {
#if __has_include(<YYReachability.h>)
    YYReachability *reach = [YYReachability reachability];
    switch (reach.status) {
        case YYReachabilityStatusNone:
            return @"notReachable";
        case YYReachabilityStatusWiFi:
            return @"wifi";
        case YYReachabilityStatusWWAN:
            return [self transWWAN:reach];
        default:
            return @"unknown";
    }
#else
    return @"unknown";
#endif
}

#if __has_include(<YYReachability.h>)
+ (NSString *)transWWAN:(YYReachability *)reach {
    switch (reach.wwanStatus) {
        case YYReachabilityWWANStatus2G:
            return @"2G";
        case YYReachabilityWWANStatus3G:
            return @"3G";
        case YYReachabilityWWANStatus4G:
            return @"4G";
        case YYReachabilityWWANStatusNone:
            return @"notReachable";
        default:
            return @"unknown";
    }
}
#endif

/*!
 * @see http://theiphonewiki.com/wiki/Models
 */
+ (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone_X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone_X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone_XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone_XS";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone_XS_MAX";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone_XS_MAX";
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    if ([deviceModel isEqualToString:@""])      return [UIDevice currentDevice].model;
    return deviceModel;
}

@end
