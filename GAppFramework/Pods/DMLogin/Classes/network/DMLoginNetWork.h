//
//  DMLoginNetWork.h
//  DMLogin
//
//  Created by NonMac on 2019/6/20.
//

#import <Foundation/Foundation.h>

typedef void(^ successBlock)(id _Nullable responseObj , NSDictionary * _Nullable userInfo);
typedef void(^ failBlock)(NSError * _Nullable error , NSDictionary * _Nullable userInfo);

NS_ASSUME_NONNULL_BEGIN

@interface DMLoginNetWork : NSObject
+ (void)postJsonRequestWithUrl:(NSString *)urlStr headers:(NSDictionary *)headers body:(NSDictionary *)body success:(successBlock)sBlock fail:(failBlock)fBlock;
+ (void)getJsonRequestWithUrl:(NSString *)urlStr headers:(NSDictionary *)headers body:(nullable NSDictionary *)body success:(successBlock)sBlock fail:(failBlock)fBlock;

+ (BOOL)checkNetCanUse;
@end

NS_ASSUME_NONNULL_END
