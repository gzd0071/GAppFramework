//
//  GButton.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/9/7.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "GButton.h"
#import <objc/runtime.h>

@interface GButton ()
@end

@implementation GButton

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateType];
}

- (void)updateType {
    switch (self.type) {
        case GButtonTypeVerticalImageText:
            [self layoutTypeVerticalImageText];
            break;
        case GButtonTypeVerticalTextImage:
            [self layoutTypeVerticalTextImage];
            break;
        case GButtonTypeHorizontalImageText:
            [self layoutTypeHorizontalImageText];
            break;
        case GButtonTypeHorizontalTextImage:
            [self layoutTypeHorizontalTextImage];
            break;
        default:
            break;
    }
}

- (void)layoutTypeHorizontalImageText {
    CGFloat bh = self.frame.size.height;
    CGFloat bw = self.frame.size.width;
    CGFloat iw = self.imgSize.width?:self.imageView.frame.size.width;
    CGFloat ih = self.imgSize.height?:self.imageView.frame.size.height;
    CGFloat tw = self.titleLabel.frame.size.width;
    CGFloat x = (bw - tw - iw - self.spacing) / 2;
    CGFloat y = (bh - ih) / 2;
    self.imageView.frame  = CGRectMake(x, y, iw, ih);
    self.titleLabel.frame = CGRectMake(x + iw + self.spacing, 0, tw, bh);
}

- (void)layoutTypeHorizontalTextImage {
    CGFloat bh = self.frame.size.height;
    CGFloat bw = self.frame.size.width;
    CGFloat iw = self.imgSize.width?:self.imageView.frame.size.width;
    CGFloat ih = self.imgSize.height?:self.imageView.frame.size.height;
    CGFloat tw = self.titleLabel.frame.size.width;
    CGFloat x = (bw - tw - iw - self.spacing) / 2;
    CGFloat y = (bh - ih) / 2;
    self.titleLabel.frame = CGRectMake(x, 0, tw, bh);
    self.imageView.frame  = CGRectMake(x + tw + self.spacing, y, iw, ih);
}

- (void)layoutTypeVerticalImageText {
    CGFloat bh = self.frame.size.height;
    CGFloat bw = self.frame.size.width;
    CGFloat iw = self.imgSize.width?:self.imageView.frame.size.width;
    CGFloat ih = self.imgSize.height?:self.imageView.frame.size.height;
    CGFloat th = self.titleLabel.frame.size.height;
    CGFloat x = (bw - iw) / 2;
    CGFloat y = (bh - ih - self.spacing - th) / 2;
    self.imageView.frame  = CGRectMake(x, y, iw, ih);
    self.titleLabel.frame = CGRectMake(0, bh - y - th, bw, th);
}

- (void)layoutTypeVerticalTextImage {
    CGFloat bh = self.frame.size.height;
    CGFloat bw = self.frame.size.width;
    CGFloat iw = self.imgSize.width?:self.imageView.frame.size.width;
    CGFloat ih = self.imgSize.height?:self.imageView.frame.size.height;
    CGFloat th = self.titleLabel.frame.size.height;
    CGFloat x = (bh - ih - self.spacing - th) / 2;
    CGFloat y = (bw - iw) / 2;
    self.titleLabel.frame = CGRectMake(0, y, bw, th);
    self.imageView.frame  = CGRectMake(x, bh - y - ih, iw, ih);
}

@end
