//
//  DMLFlashVerifyTool.h
//  DMLogin
//
//  Created by Non on 2019/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMLFlashVerifyTool : NSObject

+ (void)initSDK;
+ (void)getPhoneNumS:(void(^)(void))getPhoneS getPhoneNumF:(void (^)(id sender))getPhoneF timeOut:(int)timeout;
+ (void)getAuthS:(void (^)(id sender))getAuthS getAuthF:(void (^)(NSString *resultStr))getAuthF superVC:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
