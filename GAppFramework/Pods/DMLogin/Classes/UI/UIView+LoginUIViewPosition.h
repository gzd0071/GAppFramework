//
//  UIView+LoginUIViewPosition.h
//  DMLogin
//
//  Created by zhangjiexin on 2019/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LoginUIViewPosition)

/** View's X Position */
@property (nonatomic, assign) CGFloat   DL_x;

/** View's Y Position */
@property (nonatomic, assign) CGFloat   DL_y;

/** X Value representing the top of the view (alias of x) **/
@property (nonatomic, assign) CGFloat   DL_left;

/** X Value representing the right side of the view **/
@property (nonatomic, assign) CGFloat   DL_right;

/** Y Value representing the top of the view (alias of y) **/
@property (nonatomic, assign) CGFloat   DL_top;

/** Y value representing the bottom of the view **/
@property (nonatomic, assign) CGFloat   DL_bottom;


@property (nonatomic, assign) CGFloat   DL_bounds_left;

@property (nonatomic, assign) CGFloat   DL_bounds_right;

@property (nonatomic, assign) CGFloat   DL_bounds_top;

@property (nonatomic, assign) CGFloat   DL_bounds_bottom;


/** View's width */
@property (nonatomic, assign) CGFloat   DL_width;

/** View's height */
@property (nonatomic, assign) CGFloat   DL_height;

/** View's origin - Sets X and Y Positions */
@property (nonatomic, assign) CGPoint   DL_origin;

/** View's size - Sets Width and Height */
@property (nonatomic, assign) CGSize    DL_size;

@end

NS_ASSUME_NONNULL_END
