//
//  DMACityApi.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/11.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMACityApi.h"
#import <GLocation/GLocation.h>
#import <DMUILib/DMPickerModel.h>

@implementation DMACityApi

+ (id)getValidCity:(NSDictionary *)args {
    GLLocationModel *smodel = [GLocation location].smodel;
    if (!smodel.done) return @{};
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"cityid"]       = smodel.cityID;
    dict[@"citydomain"]   = smodel.domain;
    return dict;
}

+ (id)changeCity:(NSDictionary *)args {
    [GLocation updateSelectModel:args];
    return nil;
}

+ (id)getCity:(NSDictionary *)args {
    id task = [GLocation requestLocation]
    .then(^id (GTaskResult<GLLocationModel *> *t) {
        if (!t.suc) return nil;
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"cityid"]       = t.data.cityID;
        dict[@"city"]         = t.data.city;
        dict[@"citydomain"]   = t.data.domain;
        dict[@"parentid"]     = t.data.parentID;
        return dict;
    });
    return task;
}

+ (id)getOptions:(NSDictionary *)args {
    GTask *task = [GLocation location].model.done ?
    [GTask taskWithValue:[GTaskResult taskResultWithSuc:YES data:[GLocation location].model]] :
    [GLocation requestLocation];
    task = task.then(^id (GTaskResult<GLLocationModel *> *t) {
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"s_city"]       = [GLocation location].smodel.city;
        dict[@"s_citydomain"] = [GLocation location].smodel.domain;
        if (!t.suc) return dict;
        dict[@"cityid"]       = t.data.cityID;
        dict[@"city"]         = t.data.city;
        dict[@"citydomain"]   = t.data.domain;
        return dict;
    });
    return task;
}

+ (id)showCityPicker:(NSDictionary *)args {
    DMCityPickerModel *model = [DMCityPickerModel modelWithJSON:args];
    return [DMPicker show:model type:PickerTypeLinkage]
    .then(^id(GTaskResult<NSArray *> *t) {
        if (!t.suc) return @{@"status":@"0"};
        NSMutableDictionary *mut = @{@"status":@"1"}.mutableCopy;
        NSMutableArray *temp = @[].mutableCopy;
        [t.data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *sel = @{}.mutableCopy;
            NSArray *arr = [model dataWithSelect:[t.data subarrayWithRange:NSMakeRange(0, idx)]];
            NSDictionary *dic = arr[obj.integerValue];
            sel[@"name"] = dic[@"name"];
            sel[@"id"] = dic[@"id"];
            [temp addObject:sel];
        }];
        mut[@"selected"] = temp.copy;
        return mut.copy;
    });
}
@end
