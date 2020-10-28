//
//  DMChinaMobileTool.h
//  GAppFramework
//
//  Created by linjiesen on 22/11/2017.
//  Copyright © 2017 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMLChinaMobileTool : NSObject
+ (void)initSDK;
+ (void)checkUsability;
+ (BOOL)usable;

//timeOut 超时设置，单位：毫秒
+ (void)getPhoneNumS:(void(^)(void))getPhoneS getPhoneNumF:(void (^)(id sender))getPhoneF timeOut:(int)timeout;
+ (void)getAuthS:(void (^)(id sender))getAuthS getAuthF:(void (^)(NSString *resultStr))getAuthF superVC:(UIViewController *)vc;


+ (void)loginFrom:(UIViewController *)vc getPhoneNumS:(void(^)(void))getTokenS getPhoneNumF:(void (^)(id sender))getTokenF getAuthS:(void (^)(id sender))successBlock getAuthF:(void (^)(NSString *resultStr))failureBlock;
+ (void)loginFrom:(UIViewController *)vc title:(NSString *)title logo:(UIImage *)image getPhoneNumS:(void(^)(void))getTokenS getPhoneNumF:(void (^)(id sender))getTokenF complete:(void (^)(id sender))complete;
@end
