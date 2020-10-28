//
//  DMAUCApi.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/16.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMAUCApi.h"
#import <GStart/GStartManager.h>
#import <GBaseLib/GConvenient.h>
#import <DMLogin/BLogin.h>
#import <GHttpRequest/HttpRequest.h>
#import <GRouter/GRouter.h>
#import <DMUILib/GHud.h>

@implementation DMAUCApi

+ (GTask *)getUserInfo:(NSDictionary *)args {
    NSString *userID      = @"0";
    NSString *phoneNumber = @"0";
    NSString *score = @"0";
    if ([DMUserModel user].isLogin) {
        userID      = [DMUserModel user].userId?:@"0";
        phoneNumber = [DMUserModel user].mobile?:@"";
        score = FORMAT(@"%ld", (long)0);
    }
    id param = @{@"userId": userID,
                 @"phoneNumber": phoneNumber,
                 @"score": score
                 };
    return [GTask taskWithValue:param];
}

+ (GTask *)logOut:(NSDictionary *)args {
    if (![DMUserModel user].isLogin) {
        [[DMUserModel user] logout];
        [GStartManager startLogical:nil];
        return nil;
    }
    id params = @{@"userId":[DMUserModel user].userId?:@"", @"mobile":[DMUserModel user].mobile};
    [HttpRequest request].urlString(@"/api/v2/client/logout")
    .method(HttpMethodPost).params(params).task
    .then(^id(HttpResult *t){
        if (t.code == 200 || t.code == -200 || t.code == -100) {
            [[DMUserModel user] logout];
            [GStartManager startLogical:nil];
        } else {
            [GHud toast:@"退出登录失败"];
        }
        return nil;
    });
    return nil;
}

@end
