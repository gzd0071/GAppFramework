//
//  DMAUCPage.m
//  GHybrid
//
//  Created by iOS_Developer_G on 2019/11/23.
//

#import "DMAUCPage.h"
#import <YYKit/NSObject+YYModel.h>
#import <GRouter/GRouter.h>
#import <GBaseLib/GConvenient.h>

@implementation DMAUCPage

/// [JS ACTION]: HTML选择职位
+ (GTask *)showSubscribeJobs:(NSDictionary *)args {
    return [GRouter router:@"DMJobTagViewController" params:args]
    .then(^id(GTaskResult *t) {
        if (t.suc) {
            id result = [t.data modelToJSONString];
            return @{@"status":@"1", @"jobs":result?:@""};
        }
        return @{@"status":@"0"};
    });
}

@end
