//
//  NSString+Extend.h
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/10/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extend)
- (id)jsonDecoded;
- (NSString *)URLEncode;
- (NSString *)URLDecode;
- (NSString *)MD5;
@end

NS_ASSUME_NONNULL_END
