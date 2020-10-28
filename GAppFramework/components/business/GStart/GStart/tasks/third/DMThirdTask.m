//
//  DMThirdTask.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/15.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMThirdTask.h"
#import <GLocation/GLocation.h>
#import "DMWechat.h"

#define BAIDU_LOCATION_KEY @"RmalETLbAozqfrbnRbWEsc4I"

@implementation DMThirdTask

#pragma mark - Public
///=============================================================================
/// @name Public
///=============================================================================

+ (GTask *)task {
    [GLocation startWithKey:BAIDU_LOCATION_KEY];
    [DMWechat initSDK];
    return nil;
}

@end
