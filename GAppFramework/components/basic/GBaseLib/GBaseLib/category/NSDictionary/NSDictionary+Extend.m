//
//  NSDictionary+Extend.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/10/22.
//

#import "NSDictionary+Extend.h"
#import <YYKit/NSDictionary+YYAdd.h>

@implementation NSDictionary (Extend)
- (NSString *)jsonString {
    return [self jsonStringEncoded];
}
@end
