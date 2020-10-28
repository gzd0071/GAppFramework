//
//  ViewController.m
//  Example
//
//  Created by wushengzhong on 2019/8/15.
//  Copyright © 2019 ShiChengYouPin. All rights reserved.
//

#import "ViewController.h"
#import <HttpRequest/HttpRequest.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    HttpRequest *req = [HttpRequest jsonRequest].urlString(@"/api/v3/client/filter/list")
    .params(@{@"filter_ver": @"1", @"is_show_cate": @"1", @"is_full_job": @"1"});
    [req.task continueWithBlock:^id(BFTask<HttpResult *> *t) {
        
        return nil;
    }];
}


@end
