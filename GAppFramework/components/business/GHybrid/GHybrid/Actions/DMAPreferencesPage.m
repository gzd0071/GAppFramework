//
//  DMAPreferencesPage.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/9/24.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMAPreferencesPage.h"
#import <DMUILib/DMPickerModel.h>

@implementation DMAPreferencesPage

+ (GTask *)showProvinceAndCityPicker:(NSDictionary *)args {
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
