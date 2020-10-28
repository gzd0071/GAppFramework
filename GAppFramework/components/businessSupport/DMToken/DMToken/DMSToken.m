//
//  DMSToken.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMSToken.h"
#import "DMSUniqueDataManager.h"
#import <DMEncrypt/DMEncrypt.h>
#import <GHttpRequest/HttpRequest.h>
#import <GTask/GTask.h>
#import <GLogger/Logger.h>

#define kDMSTokenKey @"DMSTokenKey"
#define kDMSSeparator @"{^!^}"
#define kDMSEndSeparator @"{%end%}"

#define URL_DEVICE_TOKEN @"/api/v2/client/devicetoken"     // 获取deviceToken

@interface DMSTokenModel : NSObject
@property (nonatomic, strong) NSString *token;
@end
@implementation DMSTokenModel
@end

@interface DMSToken()<HttpRequestConfigDelegate>
@end
@implementation DMSToken

+ (NSString *)accessToken {
    NSString *dt = [DMSUniqueDataManager getObjectForKey:kDMSTokenKey];
    if (dt && dt.length > 0) return [self accessTokenRule:dt];
    return @"";
}

+ (NSString *)deviceToken {
    NSString *dt = [DMSUniqueDataManager getObjectForKey:kDMSTokenKey];
    if (dt && dt.length > 0) return dt;
    return @"-";
}

+ (GTask *)getDeviceToken {
    NSString *at = [DMSUniqueDataManager getObjectForKey:kDMSTokenKey];
    if (at) return [GTask taskWithValue:at];
    return [self getDeviceTokenTime:3];
}

+ (GTask *)getAccessToken {
    return [self getDeviceToken].then(^(NSString *dt) {
        if (dt.length) dt = [self accessTokenRule:dt];
        return [GTask taskWithValue:dt];
    });
}

+ (GTask *)getDeviceTokenTime:(NSInteger)times {
    if (times <= 0) return [GTask taskWithValue:@""];
    
    id param = @{@"key": [self createToken]};
    GTask *task = [HttpRequest request].urlString(URL_DEVICE_TOKEN).params(param)
    .config([DMSToken new]).extraDataTransform(DMSTokenModel.class).method(HttpMethodPost).task;
    return task.then(^(HttpResult<id, DMSTokenModel *> *result){
        if (result.suc) {
            id token = result.extra.token;
            [DMSUniqueDataManager setObject:token forKey:kDMSTokenKey];
            return token;
        } else {
            return (id)[self getDeviceTokenTime:(times-1)];
        }
    });
}

+ (NSString *)accessTokenRule:(NSString *)token {
    NSString *time = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    if (!token || token.length < time.length) return nil;
    
    NSMutableString *result = @"".mutableCopy;
    for (NSInteger i=0; i<time.length; i++) {
        [result appendString:[token substringWithRange:NSMakeRange(i, 1)]];
        [result appendString:[time substringWithRange:NSMakeRange(i, 1)]];
    }
    [result appendString:[token substringFromIndex:time.length]];
    [result appendString:kDMSEndSeparator];
    return [DMEncrypt encryptString:result];
}

+ (NSString *)createToken {
    NSString *format = [NSString stringWithFormat:@"uuid=%@%@imei=%@%@", [self createUUID], kDMSSeparator, [self createUUID], kDMSEndSeparator];
    return [DMEncrypt encryptString:format];
}

+ (NSString*)createUUID {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

#pragma mark - HttpRequestConfigDelegate
///=============================================================================
/// @name HttpRequestConfigDelegate
///=============================================================================

///> 配置: 请求域名 
- (NSString *)requestBaseUrl {
    Class cls = NSClassFromString(@"HttpConfig");
    if (!cls) {
        LOGI(@"%@", @"未设置接口域名");
        return @"未设置接口域名";
    }
    id<HttpRequestConfigDelegate> cfg = [cls new];
    return [cfg requestBaseUrl];
}
///> 配置: 全局请求头 
- (NSDictionary *)requestHeaders {
    return @{};
}

@end
