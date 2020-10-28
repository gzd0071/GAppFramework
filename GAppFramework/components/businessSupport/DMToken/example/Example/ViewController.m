//
//  ViewController.m
//  Example
//
//  Created by wushengzhong on 2019/8/15.
//  Copyright © 2019 ShiChengYouPin. All rights reserved.
//

#import "ViewController.h"
#import <DMSToken.h>
#import <Bolts/Bolts.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[DMSToken getAccessToken] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
       
        return nil;
    }];
}


@end
