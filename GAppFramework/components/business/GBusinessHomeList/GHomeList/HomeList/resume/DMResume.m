//
//  DMResume.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/7/9.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMResume.h"
#import <YYKit/NSString+YYAdd.h>

#define kDMResumeDataKey @"kDMResumeDataKey"

@implementation DMResume

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"sex"      : @"gender",
             @"identity" : @"at_school"};
}

+ (instancetype)share {
    static DMResume *resume;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resume = [DMResume new];
        NSMutableDictionary *cache = [[resume getCache] mutableCopy];
        cache[@"noNeed"] = @"1";
        if (cache) [resume modelSetWithJSON:cache];
        resume.sex = resume.sex?: @"0";
        resume.identity = resume.identity?:@"0";
    });
    return resume;
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL suc = [super modelSetWithDictionary:dic];
    // 映射简历数据到筛选条件
    [self save];
    if ([self.identity isEqualToString:@"0"]) {
        self.identity = @"3";
    } else if ([self.identity isEqualToString:@"1"]) {
        self.identity = @"1";
    } else {
        self.identity = @"0";
    }
    self.done = @"1";
    return suc;
}

- (void)update {
    NSInteger identity = 1;
    if (identity == 3) {
        identity = 0;
    } else if (identity == 1) {
        identity = 1;
    } else {
        identity = 2;
    }
    NSInteger gender = 2;
    if (gender<0) gender = 0;
    [self modelSetWithJSON:@{@"gender":@(gender), @"at_school":@(identity)}];
}


- (void)save {
    [[NSUserDefaults standardUserDefaults] setValue:[self modelToJSONString] forKey:kDMResumeDataKey];
}

- (NSDictionary *)getCache {
    NSString *resume = [[NSUserDefaults standardUserDefaults] valueForKey:kDMResumeDataKey];
    return resume ? [resume jsonValueDecoded] : nil;
}

@end
