//
//  DMExtraModel.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/8/20.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMExtraModel.h"

@implementation DMCityInfoModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"parentID" : @"parent_id"
             };
}
@end

@implementation DMExtraModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"cityInfo" : @"city_info",
             @"token"    : @"token"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"cityInfo" : [DMCityInfoModel class]};
}
@end
