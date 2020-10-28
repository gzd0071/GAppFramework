//
//  DMAUserCenter.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/10/18.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMAUserCenter.h"
#import <GStart/GStartManager.h>
#import <DMLogin/BLogin.h>
#import <GBaseLib/GConvenient.h>
#import <GHttpRequest/HttpRequest.h>
#import <DMUILib/GHud.h>

@implementation DMAUserCenter
+ (id)logOut:(NSDictionary *)args {
    if (![DMUserModel user].isLogin) {
        [[DMUserModel user] logout];
        [GStartManager startLogical:nil];
        return nil;
    }
    [GHud hud];
    id params = @{@"userId":[DMUserModel user].userId?:@"", @"mobile":[DMUserModel user].mobile};
    [HttpRequest request].urlString(@"/api/v2/client/logout")
    .method(HttpMethodPost).params(params).task
    .then(^id(HttpResult *t){
        [GHud hide];
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
