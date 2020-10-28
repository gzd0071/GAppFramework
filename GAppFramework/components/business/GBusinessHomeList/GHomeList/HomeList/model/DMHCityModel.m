//
//  DMHCityModel.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/21.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHCityModel.h"

@implementation DMHCityModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"streets" : [DMHCityModel class]};
}
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL isSuc = [super modelSetWithDictionary:dic];
    if (self.streets.count || dic[@"add"]) return isSuc;
    
    DMHCityModel *model = [DMHCityModel modelWithJSON:@{@"id":@0, @"name":@"不限", @"add":@"1"}];
    self.streets = @[model];
    return isSuc;
}
@end
