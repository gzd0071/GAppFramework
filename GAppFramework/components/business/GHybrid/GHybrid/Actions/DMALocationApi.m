//
//  DMALocationApi.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/10/17.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMALocationApi.h"
#import <GLocation/GLocation.h>
#import <YYKit/NSObject+YYModel.h>

@implementation DMALocationApi

+ (id)getCachedLocation:(NSDictionary *)args {
    NSTimeInterval cur = [[NSDate date] timeIntervalSince1970] * 1000;
    if (cur - [[GLocation location].timestamp floatValue] >= 30 * 1000) {
        [GLocation requestLocation].then(^id(GTaskResult<GLLocationModel *> *t) {
            if (t.suc) return [self dataFromModel:t.data];
            return @{@"status":@"1", @"lat":t.data.lat?:@"", @"lng":t.data.lng?:@""};
        });
    }
    return [self dataFromModel:[GLocation location].model];
}

/// [JS ACTION]: 设置本地缓存
/// @param args {NSDictianry *}
/// @return {NSDictionary *}
///    @key data {NSDictinary *}
///       @key lon
///       @key lat
/// @since  2.7.5
+ (id)requestLocation:(NSDictionary *)args {
    return [GLocation requestLocation].then(^id(GTaskResult<GLLocationModel *> *t) {
        if (t.suc) return [self dataFromModel:t.data];
        return @{@"status":@"1", @"lat":t.data.lat?:@"", @"lng":t.data.lng?:@""};
    });
}

+ (NSDictionary *)dataFromModel:(GLLocationModel *)model {
    NSMutableDictionary *mut = [[model modelToJSONObject] mutableCopy];
    mut[@"status"] = @"1";
    mut[@"lon"] = model.lng;
    return mut.copy;
}
@end
