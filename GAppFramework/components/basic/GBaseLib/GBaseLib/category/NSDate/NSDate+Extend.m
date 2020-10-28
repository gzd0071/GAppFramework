//
//  NSDate+Extend.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/12/10.
//

#import "NSDate+Extend.h"


// MARK: Const
////////////////////////////////////////////////////////////////////////////////
/// @@class Const
////////////////////////////////////////////////////////////////////////////////

///> 格式化: 默认字符串
static NSString * const kFORMAT_DEFAULT = @"YYYY-MM-DDTHH:mm:ssZ";
///> 每单位秒数
static NSUInteger const kSECONDS_A_MINUTE = 60;
static NSUInteger const kSECONDS_A_HOUR   = kSECONDS_A_MINUTE * 60;
static NSUInteger const kSECONDS_A_DAY    = kSECONDS_A_HOUR * 24;
static NSUInteger const kSECONDS_A_WEEK   = kSECONDS_A_DAY * 7;


@implementation NSDate (Extend)
- (NSString *)format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}
+ (NSDate *)time:(NSString *)time {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:kFORMAT_DEFAULT];
    return [formatter dateFromString:time];
}
- (NSTimeInterval)diff:(id)date {
    return [self timeIntervalSinceDate:[NSDate time:date]];
}
- (NSInteger)diffDay:(id)date {
    return (NSInteger)([self diff:date]/kSECONDS_A_DAY);
}
@end
