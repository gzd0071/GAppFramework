//
//  GRequestUtil.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/12.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GHttpRequest/HttpRequest.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GRequestUtilDelegate <NSObject>

#pragma mark - RequestInfo
///=============================================================================
/// @name RequestInfo
///=============================================================================

+ (NSString *)userAgent;

+ (NSString *)info;

+ (NSString *)accessToken;

+ (NSDictionary *)commentHeader;

+ (GTask<GTaskResult<NSDictionary *> *> *)requestDefaultHeader;

@end


@interface GRequestUtil : NSObject<GRequestUtilDelegate>

@end

NS_ASSUME_NONNULL_END
