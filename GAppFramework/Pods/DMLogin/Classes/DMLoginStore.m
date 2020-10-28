//
//  DMLoginStore.m
//  DMLogin
//
//  Created by zhangjiexin on 2019/6/17.
//

#import "DMLoginStore.h"

@implementation DMLoginStore

+ (instancetype)shareInstance {
    static DMLoginStore *login = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        login = DMLoginStore.new;
    });
    return login;
}

@end
