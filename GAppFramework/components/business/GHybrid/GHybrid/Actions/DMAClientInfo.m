//
//  DMAClientInfo.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/16.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMAClientInfo.h"
#import <GHttpConfig/GRequestUtil.h>
#import <GHttpConfig/HttpConfig.h>
#import <GBaseLib/GConvenient.h>

@implementation DMAClientInfo

+ (id)getHost:(NSDictionary *)args {
    static HttpConfig *httpConfig = nil;
    if (!httpConfig) {
        httpConfig = [HttpConfig new];
    }
    id URL = [httpConfig requestBaseUrl];
    return @{@"info":URL};
}

+ (id)getNetworkType:(NSDictionary *)args {
//    id param = @{}.mutableCopy;
    return @{};
}

+ (id)getCommonHeaders:(NSDictionary *)args {
    return [GRequestUtil commentHeader];
}

+ (id)getCustomUserAgent:(NSDictionary *)args {
    NSMutableDictionary *mut = @{}.mutableCopy;
    NSString *ua = [GRequestUtil userAgent];
    mut[@"nativeUserAgent"] = ua?:@"";
    NSString *uaa = args[@"userAgent"];
    if (![uaa containsString:ua]) uaa = FORMAT(@"%@ %@", uaa, ua);
    mut[@"customUserAgent"] = uaa?:@"";
    return mut;
}

@end
