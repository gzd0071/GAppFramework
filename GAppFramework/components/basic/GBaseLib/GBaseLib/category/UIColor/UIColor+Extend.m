//
//  UIColor+Extend.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/10/22.
//

#import "UIColor+Extend.h"
#import <YYKit/UIColor+YYAdd.h>

@implementation UIColor (Extend)
+ (UIColor *)hexString:(NSString *)hex {
    return [UIColor colorWithHexString:hex];
}
@end
