//
//  UINavigationBar+DMExtend.h
//  PartTimeWork
//
//  Created by iOS_Developer_G on 2016/11/1.
//  Copyright © 2016年 iOS_Developer_G. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (DMExtend)

///> Bar background color 
@property (nonatomic, strong) UIColor *dmBarColor;
///> Bar content alpha 
@property (nonatomic, assign) CGFloat dmAlpha;
///> Bar translationY 
@property (nonatomic, assign) CGFloat dmTranslationY;
///> Bar hairline 
@property (nonatomic, assign) BOOL dmHairlineHidden;
///> Bar reset 
- (void)dmResetBar;

- (void)setOverlayerHidden:(BOOL)hidden;
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view;
@end
