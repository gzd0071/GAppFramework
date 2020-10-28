//
//  DMLogin.m
//  DMLogin
//
//  Created by NonMac on 2019/6/3.
//

#import "DMLogin.h"

@implementation DMLogin

+ (instancetype)shareInstance {
    static DMLogin *login;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        login = DMLogin.new;
    });
    return login;
}

+ (BOOL)isUseNewLogin {
    return YES;
    return NO;
}

@end
