//
//  GButton.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/9/7.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GButtonType) {
    ///> 系统默认
    GButtonTypeSystemDefault        = 0,
    ///> 左右结构，左：图片，右：文字。
    GButtonTypeHorizontalImageText,
    ///> 左右结构，左：文字，右：图片。
    GButtonTypeHorizontalTextImage,
    ///> 上下结构，上：图片，下：文字。
    GButtonTypeVerticalImageText,
    ///> 上下结构，上：文字，下：图片。
    GButtonTypeVerticalTextImage,
};

@interface GButton : UIButton
///> 图文混排样式 
@property (nonatomic, assign) GButtonType type;
///> 图文混排间距 
@property (nonatomic, assign) CGFloat spacing;
///> 图片大小 
@property (nonatomic, assign) CGSize imgSize;
@end

NS_ASSUME_NONNULL_END
