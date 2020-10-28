//
//  GTextField.m
//  GUILib
//
//  Created by iOS_Developer_G on 2019/11/21.
//

#import "GTextField.h"

@implementation GTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _lvx = 8;
        _tx  = 6;
    }
    return self;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super leftViewRectForBounds:bounds];
    rect.origin.x += self.lvx;
    return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super rightViewRectForBounds:bounds];
    rect.origin.x += self.rvx;
    return rect;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGFloat x = self.leftView ? (self.lvx + self.leftView.frame.size.width + self.tx) : self.tx;
    return CGRectInset(bounds, x, 0.75);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGFloat x = self.leftView ? (self.lvx + self.leftView.frame.size.width + self.tx) : self.tx;
    return CGRectInset(bounds, x, 0.75);
}

@end
