//
//  DMWechat.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/18.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GTask;

NS_ASSUME_NONNULL_BEGIN

@interface DMWechat : NSObject

#pragma mark - INIT
///=============================================================================
/// @name INIT
///=============================================================================

+ (void)initSDK;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (GTask *)login;

@end

NS_ASSUME_NONNULL_END
