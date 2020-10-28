//
//  DMNewLoginBottomView.m
//  c_doumi
//
//  Created by ltl on 2019/3/19.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMLLoginBottomView.h"
#import "UIView+LoginUIViewPosition.h"
//#import "DMButton.h"
//#import "DMWeixinTool.h"
//#import "DMServiceFactory.h"

@implementation DMLLoginBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addViews];
    }
    return self;
}

- (void)addViews {
    [self addTopView];
}

- (void)addTopView {
    UIView *view = [[UIView alloc] init];
    [self addSubview:view];
    
    view.DL_top = self.bounds.origin.y;
    view.DL_left = self.bounds.origin.x;
    view.DL_width = self.DL_width;
    view.DL_height = 12;
    
    // 添加或字
    UILabel *label = [[UILabel alloc] init];
    label.text = @"或";
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];//✔️ 暗黑模式不变色
    [view addSubview:label];
    
    //TODO:界面约束
    label.DL_size = CGSizeMake(12, 12);
    label.center = view.center;
    
    // 添加左边的灰线
    UIView *leftLine = [[UIView alloc] init];
    [view addSubview:leftLine];
    
    UIColor *lineColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1/1.0];
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        lineColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:48/255.0 green:48/255.0 blue:51/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1/1.0];
            }
        }];
    }
#endif
    leftLine.backgroundColor = lineColor;
    
    leftLine.DL_width = 126;
    leftLine.DL_height = 0.5;
    leftLine.DL_right = label.DL_left - 16;
    leftLine.center = CGPointMake(leftLine.center.x, view.center.y);
    
    // 添加右边的灰线
    UIView *rightLine = [[UIView alloc] init];
    [view addSubview:rightLine];
    rightLine.backgroundColor = lineColor;
    
    rightLine.DL_width = 126;
    rightLine.DL_height = 0.5;
    rightLine.DL_left = label.DL_right + 16;
    rightLine.center = CGPointMake(rightLine.center.x, view.center.y);
    
    
    // 添加微信按钮
    
    
    self.wechatBtn = [self createWeChatButton];
    [self addSubview:self.wechatBtn];
    
    self.wechatBtn.DL_size = CGSizeMake(56, 70);
    self.wechatBtn.DL_top = view.DL_bottom + 32;
    self.wechatBtn.center = CGPointMake(view.center.x, self.wechatBtn.center.y);
}

- (UIButton *)createWeChatButton {
    UIButton *wechatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    wechatBtn.DL_size = CGSizeMake(56, 70);
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLoginWechat"]];
    imgView.contentMode = UIViewContentModeCenter;
    [wechatBtn addSubview:imgView];
    imgView.DL_top = 0;
    imgView.DL_left = (wechatBtn.DL_width - imgView.DL_width)/2;
    
    UILabel *title = UILabel.new;
    title.text = @"微信登录";
    title.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    
    UIColor *btnTitleColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        btnTitleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
            }
        }];
    }
#endif
    
    title.textColor = btnTitleColor;
    title.DL_left = wechatBtn.DL_bounds_left;
    title.DL_width = wechatBtn.DL_width;
    title.DL_height = title.font.lineHeight;
    title.DL_bottom = wechatBtn.DL_bounds_bottom;
    [wechatBtn addSubview: title];
    
    
//    [wechatBtn setTitle:@"微信登录" forState:UIControlStateNormal];
//    //TODO: 设置图片
//    [wechatBtn setImage:[UIImage imageNamed:@"newLoginWechat"] forState:UIControlStateNormal];
//    wechatBtn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//    [wechatBtn setTitleColor:[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0] forState:UIControlStateNormal];
//
//
//    wechatBtn.adjustsImageWhenHighlighted = NO;
//
//    CGFloat buttonHeight = wechatBtn.frame.size.height;
//    CGFloat buttonWidth  = wechatBtn.frame.size.width;
//
//    // imageView size
//    CGFloat imageWidth = wechatBtn.imageView.frame.size.width;
//    CGFloat imageHeight = wechatBtn.imageView.frame.size.height;
//
//    // text size
//    CGFloat textHeight = wechatBtn.titleLabel.frame.size.height;
//
//    CGFloat marginX = (buttonWidth - imageWidth) / 2;
//    CGFloat marginY = (buttonHeight - imageHeight - 12 - textHeight) / 2;
//
//    wechatBtn.imageView.frame = CGRectMake(marginX, marginY, imageWidth, imageHeight);
////    wechatBtn.titleLabel.frame = CGRectMake(0, 50,//buttonHeight - marginY - textHeight,
////                                            buttonWidth, textHeight);
//    wechatBtn.titleLabel.DL_left = 0;
//    wechatBtn.titleLabel.DL_width = buttonWidth - 10;
    
    return wechatBtn;
}



@end
