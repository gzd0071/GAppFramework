//
//  DMMineViewController.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/5/10.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMMineViewController.h"
#import <GConst/HTMLConst.h>

@interface DMMineViewController ()
@end

@implementation DMMineViewController

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    self.urlString = HTML_MINE;
    self.dmBarColor = [UIColor whiteColor];
    self.navigationItem.title = @"我的";
    self.dmHairlineHidden = YES;
    [super viewDidLoad];
    [self adaptation];
}

/// 适配iPhoneX
- (void)adaptation {
    self.webframe = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-TABBAR_HEIGHT-INDICATOR_HEIGHT);
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

- (void)updateTitle:(NSString *)title {
    
}

- (BOOL)shouldHandleUrd:(NSString *)urd {
    return YES;
}

@end
