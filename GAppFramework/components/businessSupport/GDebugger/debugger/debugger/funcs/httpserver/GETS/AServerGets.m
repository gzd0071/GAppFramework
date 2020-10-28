//
//  AServerGets.m
//  Debugger
//
//  Created by iOS_Developer_G on 2019/11/18.
//

#import "AServerGets.h"
#import "DHttpServer.h"
#import <GRouter/GRouter.h>
#import <GBaseLib/GConvenient.h>
#import <YYKit/NSString+YYAdd.h>

@protocol DispatcherProtocol <NSObject>
+ (void)dispatcher:(NSString *)urd;
@end

@implementation AServerGets

+ (void)load {
    [DHttpServer addGetRequest:@"/urd" result:^NSDictionary *(NSString *path) {
        return [self handleUrd:path];
    }];
}

+ (NSDictionary *)handleUrd:(NSString *)path {
    NSURL *url = [NSURL URLWithString:path];
    NSDictionary *dict = [self paraDict:url.query];
    NSString *type = dict[@"type"];
    __block NSString *urd = dict[@"urd"];
    if (!type) return @{@"code":@203, @"message": @"类型不能为空"};
    if (!type) return @{@"code":@204, @"message": @"URD不能为空"};
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([urd hasPrefix:@"http"]) {
            urd = [NSString stringWithFormat:@"doumi://browser/%@", [urd stringByURLEncode]];
        }
        [GRouter router:urd];
    });
    return @{};
}

+ (NSDictionary *)paraDict:(NSString *)para {
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

@end
