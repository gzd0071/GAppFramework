//
//  DMPickerModel.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/10/21.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMPickerModel.h"

@implementation DMPickerModel
- (NSArray<NSArray<id> *> *)pickerData {
    NSMutableArray *arr = @[].mutableCopy;
    if (self.data[@"data1"]) [arr addObject:self.data[@"data1"]];
    if (self.data[@"data2"]) [arr addObject:self.data[@"data2"]];
    return arr;
}
- (NSArray<NSNumber *> *)pickerSelect {
    return self.select;
}
- (NSString *)pickerTitle {
    return self.title;
}
- (NSString *)titleKeyWithComponent:(NSInteger)idx {
    return self.key;
}
@end

@implementation DMCityPickerModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"showDefault" : @"show_default"};
}
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL suc = [super modelSetWithDictionary:dic];
    if (_level > 3 || _level < 1) self.level = 3;
    [self initProvinces];
    return suc;
}
- (void)initProvinces {
    id url = [[NSBundle mainBundle] pathForResource:@"province" ofType:@"plist"];
    NSDictionary *localP = [NSDictionary dictionaryWithContentsOfFile:url];
    NSArray *oriPro = localP[@"province"];
    self.provinces = oriPro;
}

- (NSInteger)numberOfComponents {
    return self.level;
}
- (NSArray<NSString *> *)pickerSelect {
    NSArray *arr = [self.select componentsSeparatedByString:@"-"];
    NSMutableArray *mut = @[].mutableCopy;
    [arr enumerateObjectsUsingBlock:^(NSString *idS, NSUInteger idx, BOOL *stop) {
        NSArray *temp = [self dataWithSelect:mut.copy];
        [temp enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger sidx, BOOL *sstop) {
            if (![obj[@"id"] isEqualToString:idS]) return;
            [mut addObject:@(sidx)];
            *sstop = YES;
        }];
    }];
    return mut.copy;
}
- (NSString *)pickerTitle {
    return self.title;
}
- (NSString *)titleKeyWithComponent:(NSInteger)idx {
    return @"name";
}
- (NSArray<id> *)dataWithSelect:(NSArray<NSNumber *> *)select {
    if (select.count == 0) return self.provinces;
    NSDictionary *spro = self.provinces[select[0].integerValue];
    if (select.count == 1) return spro[@"citys"];
    NSDictionary *sd = spro[@"citys"][select[1].integerValue];
    return sd[@"districts"];
}
@end
