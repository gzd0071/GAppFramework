//
//  HttpConfig.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/8/9.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "HttpConfig.h"
#import "GRequestUtil.h"
#import <DMEncrypt/DMEncrypt.h>

@implementation HttpConfig
///> 配置: 请求域名
- (NSString *)requestBaseUrl {
    return @"https://jz-c.doumi.com";
}
///> 配置: 全局请求头 
- (GTask<GTaskResult<NSDictionary *> *> *)requestHeadersTask {
    return [GRequestUtil requestDefaultHeader];
}
///> 配置:  
- (NSDictionary *)prettyHeadersPrint:(NSDictionary *)pre {
    NSMutableDictionary *mut = pre.mutableCopy;
    if (mut[@"info"]) {
        mut[@"info"] = [DMEncrypt decryptString:mut[@"info"]];
    }
    return mut;
}

@end
