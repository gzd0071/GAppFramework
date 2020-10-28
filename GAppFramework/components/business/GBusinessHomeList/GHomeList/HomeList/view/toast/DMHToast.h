//
//  DMHToast.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/20.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMHToast : UIView

+ (void)toast:(NSString *)msg view:(UIView *)view y:(CGFloat)y;

@end

NS_ASSUME_NONNULL_END
