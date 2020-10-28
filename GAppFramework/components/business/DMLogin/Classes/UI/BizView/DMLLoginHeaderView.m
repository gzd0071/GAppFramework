//
//  DMNewLoginHeaderView.m
//  c_doumi
//
//  Created by ltl on 2019/3/19.
//  Copyright © 2019 doumijianzhi. All rights reserved.
//

#import "DMLLoginHeaderView.h"
#import "UIView+LoginUIViewPosition.h"

@implementation DMLLoginHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addViews];
    }
    return self;
}

- (void )addViews {
    [self addImageView];
    [self addTextView];
}

- (void)addImageView {
    //TODO:图片设置
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"登录页点缀"]];
    [self addSubview:imageView];
    
    //TODO:界面约束
    imageView.DL_size = CGSizeMake(78, 74);
    imageView.DL_top = self.bounds.origin.y;
    imageView.DL_left = self.bounds.origin.x;
}

- (void)addTextView {
    UILabel *label = [[UILabel alloc] init];
    label.text = @"注册/登录";
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
    //防止 Xcode10 编译报错
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        label.textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1/1.0];
            } else {
                return UIColor.blackColor;
            }
        }];
    }
#endif
    
    [self addSubview:label];
    
    //TODO:界面约束
    label.DL_size = CGSizeMake(108, 32);
    label.DL_left = self.DL_bounds_left + 15;
    label.DL_bottom = self.DL_bounds_bottom;
}


@end
