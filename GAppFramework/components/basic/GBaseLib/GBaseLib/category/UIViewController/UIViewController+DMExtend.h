//
//  UIViewController+SZExtend.h
//  PartTimeWork
//
//  Created by iOS_Developer_G on 2016/10/31.
//  Copyright © 2016年 iOS_Developer_G. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>


static inline void dm_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@interface UIViewController (DMExtend)

#pragma mark - NavigationBar Custom
///=============================================================================
/// @name NavigationBar Custom
///=============================================================================

///> Hides the hairline view at the bottom of a navigation bar.  
@property (nonatomic, assign) BOOL dmHairlineHidden;

///> Navigtaion Bar Color. 
@property (nonatomic, strong) UIColor *dmBarColor;
///> 
@property (nonatomic, strong) UIColor *dmBarTintColor;
///> 
@property (nonatomic, strong) UIImage *dmNaviImage;

/*!
 Indicate this view controller prefers its navigation bar hidden or not,
 Default to NO.
 */
@property (nonatomic, assign) BOOL dmBarHidden;
///> 左上角按钮 
@property (nonatomic, assign) BOOL dmLeftBarItemHidden;
///> 左上角颜色 
@property (nonatomic, strong) UIColor *dmLeftBarItemColor;

#pragma mark - InteractivePop Custom
///=============================================================================
/// @name InteractivePop Custom
///=============================================================================

/*! 
 Whether the interactive pop gesture is disabled when contained
 in a navigation. 
 */
@property (nonatomic, assign) BOOL dmPopGestureEnbled;

/*!
 Max allowed initial distance to left edge when you begin the interactive pop
 gesture.
 */
@property (nonatomic, assign) CGFloat dmDistanceToLeftEdge;


#pragma mark -
///=============================================================================
/// @name Keyboard
///=============================================================================

- (void)autoDismissKeyboard;

@end
