//
//  DMHFilterModel.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/13.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMHFilterModel.h"
#import "DMResume.h"
#import <GLocation/GLocation.h>

#pragma mark - EXPORTS
///=============================================================================
/// @name EXPORTS
///=============================================================================
///> 推荐
NSString * const FMV_TUIJIE  = @"FMV_TUIJIE";
///> 订阅
NSString * const FMV_DINGYUE = @"FMV_DINGYUE";
///> 斗米精选
NSString * const FMV_FEATURE = @"FMV_FEATURE";
///> 城市选项
NSString * const FMV_CITY   = @"FMV_CITY";
///> 自营选项
NSString * const FMV_ZIYING = @"operate_self";
///> 筛选选项
NSString * const FMV_FILTER = @"more";
///> 职位类型
NSString * const FMV_JOB_TYPE = @"job_type";

@implementation FilterSelectItem
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"sex" : @"sex_demand",
             @"identity"  : @"identity_demand",
             };
}

- (BOOL)isEqual:(FilterSelectItem *)object {
    if ([object isKindOfClass:FilterSelectItem.class]) {
        return [self.sex isEqualToString:object.sex] &&
               [self.identity isEqualToString:object.identity];
    }
    return [super isEqual:object];
}
@end

@implementation FilterItem
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"type" : @[@"type", @"choice_type"],
             @"key"  : @[@"key", @"field"],
             @"filterItems" : @[@"filter_items", @"child_items"]
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"filterItems" : [FilterItem class]};
}
@end

@implementation DMHFilterModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"offsetY"     : @"height",
             @"filterMenus" : @"filter_menu",
             @"filterTabs"  : @"data"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"filterMenus" : [FilterItem class],
             @"filterTabs" : [FilterItem class],
             @"hots"       : [DMHHot class],
             };
}
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL isSuc;
    if (dic[@"filter_menu"]) {
        FilterItem *cityItem = (self.filterMenus.count > 0) ? self.filterMenus[0] : [self cityItem];
        isSuc = [super modelSetWithDictionary:dic];
        NSMutableArray *temp = @[cityItem].mutableCopy;
        [temp addObjectsFromArray:self.filterMenus];
        self.filterMenus = temp;
    } else if (dic[@"data"]) {
        self.filterTabs = @[];
        isSuc = [super modelSetWithDictionary:dic];
        NSMutableArray *temp = @[].mutableCopy;
        //注释订阅逻辑
        //if (_isFull && [DMHListModel needShowDingyue]) [temp addObject:[self dingyueItem]];
        [temp addObject:[self tuijieItem]];
        if (_isFull && self.showJinxuan) [temp addObject:[self featureItem]];
        [temp addObjectsFromArray:self.filterTabs];
        self.filterTabs = temp.copy;
    } else {
        isSuc = [super modelSetWithDictionary:dic];
    }
    return isSuc;
}
- (FilterItem *)cityItem {
    FilterItem *item = [FilterItem new];
    item.name = FORMAT(@"全%@", [GLocation location].smodel.city);
    item.key = FMV_CITY;
    item.filterItems = @[@"", @""];
    return item;
}
- (FilterItem *)tuijieItem {
    FilterItem *item = [FilterItem new];
    item.name = _isFull?@"全职推荐":@"兼职推荐";
    item.key = FMV_TUIJIE;
    return item;
}
- (FilterItem *)dingyueItem {
    FilterItem *item = [FilterItem new];
    item.name = @"订阅";
    item.key = FMV_DINGYUE;
    return item;
}
- (FilterItem *)featureItem {
    FilterItem *item = [FilterItem new];
    item.name = @"优选";
    item.key = FMV_FEATURE;
    item.value = @"0";
    return item;
}

///> 更新more默认选中数据 
- (void)updateDefaultMore:(DMHDefaultMore *)more {
    [self updateDefaultMore:more reset:NO];
}
- (void)updateDefaultMore:(DMHDefaultMore *)more reset:(BOOL)reset {
    [self.filterMenus enumerateObjectsUsingBlock:^(FilterItem *fobj, NSUInteger idx, BOOL *fstop) {
        if (![fobj.key isEqualToString:FMV_FILTER]) return;
        __block NSInteger isD = 0;
        [fobj.filterItems enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
            [obj.filterItems enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger sidx, BOOL *sstop) {
                if ([obj.key isEqualToString:@"sex_demand"]) {
                    sobj.select = [sobj.value isEqualToString:more.sex];
                    if (sobj.select) {
                        obj.selIdx = sidx;
                        isD = isD | sidx;
                    }
                } else if ([obj.key isEqualToString:@"identity_demand"]) {
                    sobj.select = [sobj.value isEqualToString:more.identity];
                    if (sobj.select) {
                        obj.selIdx = sidx;
                        isD = isD | sidx;
                    }
                } else if (reset) {
                    sobj.select = sidx == 0;
                    if (sidx == 0) obj.selIdx = 0;
                }
            }];
        }];
        fobj.sname = isD == 0 ? nil : @"筛选";
        fobj.select = NO;
        *fstop = YES;
    }];
}

- (void)resetFilterMenus {
    [self.filterMenus enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.key isEqualToString:FMV_ZIYING]) obj.select = NO;
        else if ([obj.key isEqualToString:FMV_FILTER]) {
            DMHDefaultMore *more = [DMHDefaultMore modelWithJSON:@{@"sex":[DMResume share].sex,
                                                                      @"identity":[DMResume share].identity
                                                                      }];
            [self updateDefaultMore:more reset:YES];
        } else if ([obj.key isEqualToString:FMV_CITY]) {
            obj.sname = @"";
            obj.select = NO;
        } else if ([obj.key isEqualToString:FMV_JOB_TYPE]) {
            obj.sname = @"";
            obj.select = NO;
        }
    }];
}

- (BOOL)isDefaultFilter {
    __block NSInteger idx = 0;
    [self.filterMenus enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger idx, BOOL *stop) {
        if ([sobj.key isEqualToString:FMV_FILTER]) {
            [sobj.filterItems enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
                if (([obj.key isEqualToString:@"sex_demand"] && ![obj.filterItems[obj.selIdx].value isEqualToString:[DMResume share].sex]) ||
                    ([obj.key isEqualToString:@"identity_demand"] &&
                     ![obj.filterItems[obj.selIdx].value isEqualToString:[DMResume share].identity]) ||
                    (![obj.key isEqualToString:@"sex_demand"] && ![obj.key isEqualToString:@"identity_demand"] && obj.selIdx != 0)) {
                    idx = idx | 1;
                }
                if (idx == 1) *stop = 0;
            }];
        } else if (sobj.name.length || sobj.select) {
            idx = idx | 1;
        }
        if (idx == 1) *stop = 0;
    }];
    return idx == 1;
}

///> 曝光: item 
- (NSString *)filterItem:(NSString *)city {
    NSMutableArray *mut = @[city?:@""].mutableCopy;
    [self.filterMenus enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger idx, BOOL *stop) {
        if ([sobj.key isEqualToString:FMV_FILTER]) {
            [sobj.filterItems enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
                [obj.filterItems enumerateObjectsUsingBlock:^(FilterItem *ssobj, NSUInteger idx, BOOL *stop) {
                    if (ssobj.select) [mut addObject:ssobj.name];
                }];
            }];
        } else if ([sobj.key isEqualToString:FMV_JOB_TYPE]) {
            if (sobj.sname.length) [mut addObject:sobj.sname];
        }
    }];
    return [mut componentsJoinedByString:@";"];
}

- (NSString *)filterMoreItem {
    NSMutableArray *mut = @[].mutableCopy;
    [self.filterMenus enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger idx, BOOL *stop) {
        if ([sobj.key isEqualToString:FMV_FILTER]) {
            [sobj.filterItems enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
                [obj.filterItems enumerateObjectsUsingBlock:^(FilterItem *ssobj, NSUInteger idx, BOOL *stop) {
                    if (ssobj.select) [mut addObject:ssobj.name];
                }];
            }];
        }
    }];
    return [mut componentsJoinedByString:@","];
}

@end
