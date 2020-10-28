//
//  ViewController.m
//  Example
//
//  Created by wushengzhong on 2019/8/15.
//  Copyright © 2019 ShiChengYouPin. All rights reserved.
//

#import "ViewController.h"
#import <DMEncrypt.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *expect = [DMEncrypt encryptString:@"woshiceshi"];
    NSLog(@"%@", expect);
    NSLog(@"%@", [DMEncrypt decryptString:expect]);
    // Do any additional setup after loading the view.
}


@end
