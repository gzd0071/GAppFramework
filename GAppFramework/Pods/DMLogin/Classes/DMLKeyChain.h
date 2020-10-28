//
//  DMLKeyChain.h
//  DMLogin
//
//  Created by Non on 2019/9/23.
//

#import <Foundation/Foundation.h>

#define KeyChainLog(x) [[DMLKeyChain shareInstance] log:x]

NS_ASSUME_NONNULL_BEGIN

@interface DMLKeyChain : NSObject

+ (instancetype)shareInstance;
- (void)log:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
