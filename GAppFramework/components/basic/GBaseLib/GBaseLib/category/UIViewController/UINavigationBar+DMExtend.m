//
//  UINavigationBar+DMExtend.m
//  PartTimeWork
//
//  Created by iOS_Developer_G on 2016/11/1.
//  Copyright © 2016年 iOS_Developer_G. All rights reserved.
//

#import "UINavigationBar+DMExtend.h"
#import <objc/runtime.h>

@implementation UINavigationBar (DMExtend)

#pragma mark - Property
///=============================================================================
/// @name Property
///=============================================================================

- (UIView *)overlay {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOverlay:(UIView *)overlay {
    objc_setAssociatedObject(self, @selector(overlay), overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)dmBarColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDmBarColor:(UIColor *)dmBarColor {
    objc_setAssociatedObject(self, @selector(dmBarColor), dmBarColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self dmSetBackgroundColor:dmBarColor];
}

- (CGFloat)dmTranslationY {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setDmTranslationY:(CGFloat)dmTranslationY {
    objc_setAssociatedObject(self, @selector(dmTranslationY), @(dmTranslationY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self dmSetTranslationY:dmTranslationY];
}

- (CGFloat)dmAlpha {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setDmAlpha:(CGFloat)dmAlpha {
    objc_setAssociatedObject(self, @selector(dmAlpha), @(dmAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self dmSetElementsAlpha:dmAlpha];
}

- (BOOL)dmHairlineHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDmHairlineHidden:(BOOL)dmHairlineHidden {
    objc_setAssociatedObject(self, @selector(dmHairlineHidden), @(dmHairlineHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self dmSetView:self hairlineHidden:dmHairlineHidden];
}

#pragma mark - Function
///=============================================================================
/// @name Function
///=============================================================================

- (void)setOverlayerHidden:(BOOL)hidden {
    self.overlay.hidden = hidden;
}

- (void)dmSetView:(UIView *)view hairlineHidden:(BOOL)dmHairlineHidden {
    UIImageView *hairlineView = [self findHairlineImageViewUnder:view];
    if (hairlineView) hairlineView.hidden = dmHairlineHidden;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)dmSetElementsAlpha:(CGFloat)alpha {
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    UIView *titleView = [self valueForKey:@"_titleView"];
    titleView.alpha = alpha;
    //    when viewController first load, the titleView maybe nil
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            obj.alpha = alpha;
            *stop = YES;
        }
    }];
}

- (void)dmSetTranslationY:(CGFloat)y {
    self.transform =  CGAffineTransformMakeTranslation(0, y);
}

- (void)dmSetBackgroundColor:(UIColor *)color {
    if (!color) {
        [self dmResetBar];
        return;
    }
    
    if (!self.overlay && self.subviews.count > 0) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        CGFloat height = CGRectGetHeight(self.bounds);
        
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), height > 44?height:height+[[UIApplication sharedApplication] statusBarFrame].size.height)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [[self.subviews firstObject] insertSubview:self.overlay atIndex:0];
    }
    if (self.overlay){
        self.overlay.backgroundColor = color;
    }
}

- (void)dmResetBar {
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}


@end
