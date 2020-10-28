//
//  DMSUniqueDataManager.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMSUniqueDataManager.h"
#import <SAMKeychain/SAMKeychain.h>

#define DMSUniqueKeychainService @"!#@$DMSSKeychainService%&^*"

@interface DMSUniqueDataManager ()
///> 
@property (nonatomic, strong) NSMutableDictionary *dict;
@end

@implementation DMSUniqueDataManager

+ (instancetype)manager {
    static DMSUniqueDataManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DMSUniqueDataManager new];
        manager.dict = @{}.mutableCopy;
    });
    return manager;
}

+ (BOOL)setObject:(NSString *)value forKey:(NSString *)key {
    if (!value || !key) return NO;
    BOOL suc = [SAMKeychain setPassword:value forService:DMSUniqueKeychainService account:key];
    if (!suc) return NO;
    [DMSUniqueDataManager manager].dict[key] = value;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    return suc;
}

+ (NSString *)getObjectForKey:(NSString *)key {
    if (!key) return nil;
    // 内存
    id result = [DMSUniqueDataManager manager].dict[key];
    if (result) return result;
    // UserDefaults
    result = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (result) {
        [DMSUniqueDataManager manager].dict[key] = result;
        return result;
    }
    // SSKeychain
    NSInteger count = 3;
    while (count > 0 && !result) {
        result = [SAMKeychain passwordForService:DMSUniqueKeychainService account:key];
        count--;
    }
    if (result) {
        [DMSUniqueDataManager manager].dict[key] = result;
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:key];
        return result;
    }
    return result;
}

@end
