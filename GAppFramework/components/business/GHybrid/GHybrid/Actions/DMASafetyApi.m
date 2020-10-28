//
//  DMASafetyApi.m
//  GHybrid
//
//  Created by iOS_Developer_G on 2019/10/25.
//

#import "DMASafetyApi.h"
#import <DMEncrypt/DMEncrypt.h>

@implementation DMASafetyApi
+ (id)dekDecrypt:(NSDictionary *)args {
    NSString *data = args[@"data"];
    return data.length ? [DMEncrypt decryptString:data] : data;
}
+ (id)dekEncrypt:(NSDictionary *)args {
    NSString *data = args[@"data"];
    return data.length ? [DMEncrypt encryptString:data] : data;
}
@end
