//
//  HttpDefaultConfig.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/8/6.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "HttpDefaultConfig.h"

@implementation HttpDefaultConfig

///> 配置: 请求域名 
- (NSString *)requestBaseUrl {
    return @"";
}
///> 配置: 全局请求头 
- (NSDictionary *)requestHeaders {
    return @{};
}
///> 配置: 超时时间(默认为60) 
- (NSTimeInterval)requestTimeout {
    return 60;
}
///> 配置: 可接受的ContentType 
- (NSSet<NSString *> *)requestAcceptableContentTypes {
    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"application/x-zip-compressed",@"application/zip", nil];
}
///> 配置: 最大并发量, 默认为6 
- (NSInteger)requestMaxConcurrent {
    return 6;
}

@end
