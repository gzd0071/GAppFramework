//
//  UIView+LoginUIViewPosition.m
//  DMLogin
//
//  Created by zhangjiexin on 2019/6/3.
//

#import "UIView+LoginUIViewPosition.h"

@implementation UIView (LoginUIViewPosition)
@dynamic DL_x, DL_y, DL_width, DL_height, DL_origin, DL_size;

//- (CGFloat)left {
//    return self.frame.origin.x;
//}
//
//- (CGFloat)top {
//    return self.frame.origin.y;
//}
//
//- (CGFloat)right {
//    return self.frame.origin.x;
//}
//
//- (CGFloat)left {
//    return self.frame.origin.x;
//}
//
//- (CGFloat)left {
//    return self.frame.origin.x;
//}

- (void)setDL_x:(CGFloat)x {
    self.frame      = CGRectMake(x, self.DL_y, self.DL_width, self.DL_height);
}

- (void)setDL_y:(CGFloat)y {
    self.frame      = CGRectMake(self.DL_x, y, self.DL_width, self.DL_height);
}

- (void)setDL_left:(CGFloat)left {
    self.DL_x          = left;
}

- (void)setDL_right:(CGFloat)right {
    self.DL_x          = right - self.DL_width;
}

- (void)setDL_top:(CGFloat)top {
    self.DL_y          = top;
}

- (void)setDL_bottom:(CGFloat)bottom {
    self.DL_y          = bottom - self.DL_height;
}

- (void)setDL_width:(CGFloat)width {
    self.frame      = CGRectMake(self.DL_x, self.DL_y, width, self.DL_height);
}

- (void)setDL_height:(CGFloat)height {
    self.frame      = CGRectMake(self.DL_x, self.DL_y, self.DL_width, height);
}

- (void)setDL_origin:(CGPoint)origin {
    self.DL_x          = origin.x;
    self.DL_y          = origin.y;
}

- (void)setDL_size:(CGSize)size {
    self.DL_width      = size.width;
    self.DL_height     = size.height;
}

// Getters
- (CGFloat)DL_x {
    return self.frame.origin.x;
}

- (CGFloat)DL_y {
    return self.frame.origin.y;
}

- (CGFloat)DL_left {
    return self.DL_x;
}

- (CGFloat)DL_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)DL_top {
    return self.DL_y;
}

- (CGFloat)DL_bottom {
    return self.frame.origin.y + self.frame.size.height;
}


- (CGFloat)DL_bounds_left {
    return self.bounds.origin.x;
}

- (CGFloat)DL_bounds_right {
    return self.bounds.origin.x + self.bounds.size.width;
}

- (CGFloat)DL_bounds_top {
    return self.bounds.origin.y;
}

- (CGFloat)DL_bounds_bottom {
    return self.bounds.origin.y + self.bounds.size.height;
}


- (CGFloat)DL_width {
    return self.frame.size.width;
}

- (CGFloat)DL_height {
    return self.frame.size.height;
}

- (CGPoint)DL_origin {
    return CGPointMake(self.DL_x, self.DL_y);
}

- (CGSize)DL_size {
    return CGSizeMake(self.DL_width, self.DL_height);
}

@end
