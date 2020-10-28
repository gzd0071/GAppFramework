//
//  CarrierTool.m
//  DMLogin
//
//  Created by Non on 2019/9/25.
//

#import "CarrierTool.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation CarrierTool

+ (CarrierType)getOperatorsType {
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    
    NSString *currentCountryCode = [carrier mobileCountryCode];
    NSString *mobileNetWorkCode = [carrier mobileNetworkCode];
    if (@available(iOS 12.0, *)) {
        NSDictionary *dic = [telephonyInfo serviceSubscriberCellularProviders];
        NSDictionary *dicw = [telephonyInfo serviceCurrentRadioAccessTechnology];
        NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
        //如果是 iOS 12 双卡的设备
        if ([[dic allKeys] count] == 2 && [sysVersion containsString:@"12."]) {
            return CarrierType_dualSim_iOS12;
        }
    }
    
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        NSString *netCode = [telephonyInfo dataServiceIdentifier];
        if ([netCode length] > 2) {
            [netCode substringFromIndex:netCode.length-2];
        }
        mobileNetWorkCode = netCode;
    }
#endif
    
    if (![currentCountryCode isEqualToString:@"460"]) {
        return CarrierType_Unkown;
    }
    
    // 参考 https://en.wikipedia.org/wiki/Mobile_country_code
    
    if ([mobileNetWorkCode isEqualToString:@"00"] ||
        [mobileNetWorkCode isEqualToString:@"02"] ||
        [mobileNetWorkCode isEqualToString:@"07"]) {
        
        // 中国移动
        return CarrierType_ChinaMobile;
    }
    
    if ([mobileNetWorkCode isEqualToString:@"01"] ||
        [mobileNetWorkCode isEqualToString:@"06"] ||
        [mobileNetWorkCode isEqualToString:@"09"]) {
        
        // 中国联通
        return CarrierType_ChinaUnicom;
    }
    
    if ([mobileNetWorkCode isEqualToString:@"03"] ||
        [mobileNetWorkCode isEqualToString:@"05"] ||
        [mobileNetWorkCode isEqualToString:@"11"]) {
        
        // 中国电信
        return CarrierType_ChinaTelecom;
    }
    
    if ([mobileNetWorkCode isEqualToString:@"20"]) {
        
        // 中国铁通
        return CarrierType_ChinaTietong;
    }
    
    return CarrierType_Unkown;
}

@end
