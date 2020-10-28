//
//  NSString+Extend.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/10/22.
//

#import "NSString+Extend.h"
#import <YYKit/NSString+YYAdd.h>

@implementation NSString (Extend)
- (id)jsonDecoded {
    return [self jsonValueDecoded];
}
- (NSString *)URLEncode {
    return [self stringByURLEncode];
}
- (NSString *)URLDecode {
    return [self stringByURLDecode];
}
- (NSString *)MD5 {
    return [self md5String];
}

@end
