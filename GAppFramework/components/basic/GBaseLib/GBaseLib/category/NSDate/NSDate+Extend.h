//
//  NSDate+Extend.h
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/12/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Extend)
- (NSString *)format:(NSString *)format;
+ (NSDate *)time:(NSString *)time;
- (NSTimeInterval)diff:(id)date;
- (NSInteger)diffDay:(id)date;
@end

NS_ASSUME_NONNULL_END
