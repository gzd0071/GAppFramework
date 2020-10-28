//
//  NSArray+Extend.h
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/10/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<T> (Extend)
- (nullable NSString *)jsonString;
- (NSArray *)map:(id(^)(T each))block;
- (T)detect:(BOOL (^)(id each))block;
@end

NS_ASSUME_NONNULL_END
