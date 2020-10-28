//
//  UIViewController+DMExtend.m
//  PartTimeWork
//
//  Created by iOS_Developer_G on 2016/10/31.
//  Copyright © 2016年 iOS_Developer_G. All rights reserved.
//

#import "UIViewController+DMExtend.h"
#import <objc/runtime.h>
#import "UINavigationBar+DMExtend.h"
#import "UIViewController+BackButtonHandler.h"
#import <GProtocol/ViewProtocol.h>

#define DMNaviBarBgColor HEX(@"ffffff", @"1c1c1e")
#define DMNaviBarTintColor HEX(@"4c5b61", @"dddddd")

@class DMNavigationRecognizerDelegate;

typedef void (^dmzInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (FDFullscreenPopGesturePrivate)
@property (nonatomic, copy) dmzInjectBlock dmzInjectBlock;
@property (nonatomic, strong) UINavigationBar *dmTransitionNavigationBar;
@property (nonatomic, assign) BOOL dmPrefersNavigationBarBackgroundViewHidden;
@end

@implementation UIViewController (DMExtend)

- (void)dm_viewWillAppear:(BOOL)animated {
    if (self.dmzInjectBlock) {
        self.dmzInjectBlock(self, animated);
    }
    [self refreshLeftBarItem:self];
    [self refreshRightBarItem:self];
    [self dm_viewWillAppear:animated];
}

+ (void)load {
    dm_swizzleSelector([UIViewController class], @selector(viewWillAppear:), @selector(dm_viewWillAppear:));
    [self addNavigationBarSwitchStyle];
}

#pragma mark - NaviBarItem
///=============================================================================
/// @name NaviBarItem
///=============================================================================

- (void)refreshRightBarItem:(UIViewController *)vc {
    if ([vc conformsToProtocol:@protocol(NaviDelegate)] &&
        [vc respondsToSelector:@selector(naviRightBarItem)]) {
        vc.navigationItem.rightBarButtonItem = [(id<NaviDelegate>)vc naviRightBarItem];
    }
}

- (void)refreshLeftBarItem:(UIViewController *)vc {
    if (vc.dmLeftBarItemHidden) {
        vc.navigationItem.leftBarButtonItem = [UIBarButtonItem new];
    } else if (vc.navigationItem.leftBarButtonItem) {
        return;
    } else if ([vc conformsToProtocol:@protocol(NaviDelegate)] &&
        [vc respondsToSelector:@selector(naviLeftBarItem)]) {
        vc.navigationItem.leftBarButtonItem = [(id<NaviDelegate>)vc naviLeftBarItem];
    } else if (vc.navigationController.viewControllers.count <= 1 || vc.navigationItem.leftBarButtonItem) {
        return;
    } else {
        UIImage *img = IMAGE(@"btn_back_normal", @"btn_back_normal_w");
        img = [[UIImage alloc] initWithData:UIImagePNGRepresentation(img) scale:IMAGE(@"btn_back_normal").scale];
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftTap:)];
        vc.navigationItem.leftBarButtonItem = leftBarItem;
    }
}

- (void)leftTap:(UIBarButtonItem *)item {
    UIViewController *vc = self.navigationController.topViewController;
    if ([vc conformsToProtocol:@protocol(NaviDelegate)] &&
        [vc respondsToSelector:@selector(naviLeftBarItemAction)]) {
        [(id<NaviDelegate>)vc naviLeftBarItemAction];
        return;
    }
    BOOL isBool = YES;
    if([vc conformsToProtocol:@protocol(BackButtonHandlerProtocol)] &&
       [vc respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
        isBool = [vc navigationShouldPopOnBackButton];
    }
    if([vc conformsToProtocol:@protocol(BackButtonHandlerProtocol)] &&
       [vc respondsToSelector:@selector(navigationPopActiveForType:)]) {
        isBool = [vc navigationPopActiveForType:UFQBackTypeButton];
    }
    if (isBool) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

+ (UINavigationController *)topNavi {
    UIViewController *topVC = [[UIApplication sharedApplication].windows.firstObject rootViewController];
    while ([topVC presentedViewController]) {
        topVC = [topVC presentedViewController];
    }
    if ([topVC isKindOfClass:[UITabBarController class]]) {
        topVC = [(UITabBarController *)topVC selectedViewController];
    }
    return (UINavigationController *)topVC;
}

- (dmzInjectBlock)dmzInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDmzInjectBlock:(dmzInjectBlock)dmzInjectBlock {
    objc_setAssociatedObject(self, @selector(dmzInjectBlock), dmzInjectBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Navigation Bar
///=============================================================================
/// @name Navigation Bar
///=============================================================================

- (BOOL)dmBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDmBarHidden:(BOOL)dmBarHidden {
    objc_setAssociatedObject(self, @selector(dmBarHidden), @(dmBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dmLeftBarItemHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDmLeftBarItemHidden:(BOOL)dmLeftBarItemHidden {
    objc_setAssociatedObject(self, @selector(dmLeftBarItemHidden), @(dmLeftBarItemHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dmHairlineHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}



- (void)setDmHairlineHidden:(BOOL)dmHairlineHidden {
    objc_setAssociatedObject(self, @selector(dmHairlineHidden), @(dmHairlineHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.navigationController.navigationBar.dmHairlineHidden = dmHairlineHidden;
}

- (UIColor *)dmBarColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDmBarColor:(UIColor *)dmBarColor {
    objc_setAssociatedObject(self, @selector(dmBarColor), dmBarColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.navigationController.navigationBar.dmBarColor = dmBarColor;
}

- (UIColor *)dmBarTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDmBarTintColor:(UIColor *)dmBarTintColor {
    objc_setAssociatedObject(self, @selector(dmBarTintColor), dmBarTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!dmBarTintColor) return;
    self.navigationController.navigationBar.barTintColor = dmBarTintColor;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:dmBarTintColor}];
}

- (UIImage *)dmNaviImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDmNaviImage:(UIImage *)dmNaviImage {
    objc_setAssociatedObject(self, @selector(dmNaviImage), dmNaviImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationController.navigationBar setBackgroundImage:dmNaviImage forBarMetrics:UIBarMetricsDefault];
}

- (UIColor *)dmLeftBarItemColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDmLeftBarItemColor:(UIColor *)dmLeftBarItemColor {
    objc_setAssociatedObject(self, @selector(dmLeftBarItemColor), dmLeftBarItemColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Gesture
///=============================================================================
/// @name Gesture
///=============================================================================

- (BOOL)dmPopGestureEnbled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDmPopGestureEnbled:(BOOL)dmPopGestureEnbled {
    objc_setAssociatedObject(self, @selector(dmPopGestureEnbled), @(dmPopGestureEnbled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)dmDistanceToLeftEdge {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setDmDistanceToLeftEdge:(CGFloat)dmDistanceToLeftEdge {
    objc_setAssociatedObject(self, @selector(dmPopGestureEnbled), @(dmDistanceToLeftEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -
///=============================================================================
/// @name
///=============================================================================

- (void)dm_viewDidAppear:(BOOL)animated {
    if (self.dmzInjectBlock) {
        self.dmzInjectBlock(self, animated);
    }
    [self.class hookViewDidAppear:self];
    [self dm_viewDidAppear:animated];
}

- (void)dm_viewWillLayoutSubviews {
    [self.class hookViewWillLayoutSubviews:self];
    [self dm_viewWillLayoutSubviews];
}

+ (void)addNavigationBarSwitchStyle {
    dm_swizzleSelector([UIViewController class], @selector(viewDidAppear:), @selector(dm_viewDidAppear:));
    dm_swizzleSelector([UIViewController class], @selector(viewWillLayoutSubviews), @selector(dm_viewWillLayoutSubviews));
}

+ (void)hookViewDidAppear:(UIViewController *)vc {
    if (vc.dmTransitionNavigationBar) {
        vc.dmBarTintColor = vc.dmBarTintColor?:DMNaviBarTintColor;
        [vc.navigationController.navigationBar setBackgroundImage:vc.dmNaviImage forBarMetrics:UIBarMetricsDefault];
        vc.navigationController.navigationBar.dmHairlineHidden = vc.dmHairlineHidden;
        vc.navigationController.navigationBar.dmBarColor = vc.dmBarColor?:DMNaviBarBgColor;
        [vc.dmTransitionNavigationBar removeFromSuperview];
        vc.dmTransitionNavigationBar = nil;
    } else {
        if (vc.dmNaviImage) {
            [vc.navigationController.navigationBar setBackgroundImage:vc.dmNaviImage forBarMetrics:UIBarMetricsDefault];
        }
    }
    vc.dmPrefersNavigationBarBackgroundViewHidden = vc.dmBarHidden;
}

+ (BOOL)isEqualVC:(UIViewController *)vc toVC:(UIViewController *)toVC {
    return [self compareA:vc.dmNaviImage B:toVC.dmNaviImage]
    && [self compareA:vc.dmBarColor B:toVC.dmBarColor]
    && [self compareA:@(vc.dmHairlineHidden) B:@(toVC.dmHairlineHidden)]
    && [self compareA:@(vc.dmBarHidden) B:@(toVC.dmBarHidden)]
    && [self compareA:vc.dmBarTintColor B:toVC.dmBarTintColor];
}
+ (BOOL)compareA:(id)A B:(id)B {
    if (!A && !B) return YES;
    if ([A isKindOfClass:UIImage.class]) {
        return [A isEqual:B];
    } else if ([A isKindOfClass:UIColor.class]) {
        return CGColorEqualToColor([(UIColor *)A CGColor], [(UIColor *)B CGColor]);
    } else if([A isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)A boolValue] == [(NSNumber *)B boolValue];
    }
    return NO;
}

+ (void)hookViewWillLayoutSubviews:(UIViewController *)vc {
    if (![vc isKindOfClass:UINavigationController.class]) return;
    id<UIViewControllerTransitionCoordinator> tc = vc.transitionCoordinator;
    if (!tc) return;
    UIViewController *fromVC = [tc viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [tc viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if ([self isEqualVC:fromVC toVC:toVC]) return;
    
    if (!fromVC.dmTransitionNavigationBar) {
        fromVC.view.clipsToBounds = toVC.view.clipsToBounds = NO;
        [fromVC dmAddTransitionNavigationBarIfNeeded];
        [toVC dmAddTransitionNavigationBarIfNeeded];
        toVC.dmPrefersNavigationBarBackgroundViewHidden = YES;
        fromVC.navigationController.navigationBar.dmHairlineHidden = YES;
    }
    
}

- (void)dmAddTransitionNavigationBarIfNeeded {
    if (self.dmBarHidden) return;
    CGFloat topHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + 44;
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, topHeight);
    CGFloat padding = self.navigationController.navigationBar.translucent ? (self.edgesForExtendedLayout == UIRectEdgeNone ? - topHeight:0) : -topHeight;
    self.automaticallyAdjustsScrollViewInsets = YES;
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, padding, rect.size.width, rect.size.height)];
    self.dmHairlineHidden = bar.shadowImage = self.dmHairlineHidden ?  [UIImage new] : self.navigationController.navigationBar.shadowImage;
    
    UIImage *image = self.dmNaviImage = self.dmNaviImage ?: [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [bar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

    bar.dmBarColor = self.dmBarColor?:DMNaviBarBgColor;
    bar.dmHairlineHidden = self.dmHairlineHidden;

    self.dmBarTintColor = bar.barTintColor = self.dmBarTintColor ?: DMNaviBarTintColor;
    if (self.dmTransitionNavigationBar) [self.dmTransitionNavigationBar removeFromSuperview];
    
    self.dmTransitionNavigationBar = bar;
    
    if (!bar.subviews.count) {
        UIView *view = [[UIView alloc] initWithFrame:bar.bounds];
        view.backgroundColor = bar.dmBarColor;
        [bar addSubview:view];
        
        if (!self.dmHairlineHidden) {
            UIImageView *barImageView = [self.navigationController.navigationBar findHairlineImageViewUnder:self.navigationController.navigationBar];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:barImageView.image];
            imageView.frame = CGRectMake(0, bar.bounds.size.height-0.5, bar.size.width, 0.5);
            imageView.backgroundColor = barImageView.backgroundColor;
            [view addSubview:imageView];
        }
    }
    [self.view addSubview:self.dmTransitionNavigationBar];
    
}

- (UINavigationBar *)dmTransitionNavigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDmTransitionNavigationBar:(UINavigationBar *)navigationBar {
    objc_setAssociatedObject(self, @selector(dmTransitionNavigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)dmPrefersNavigationBarBackgroundViewHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDmPrefersNavigationBarBackgroundViewHidden:(BOOL)hidden {
    [[self.navigationController.navigationBar valueForKey:@"_backgroundView"]
     setHidden:hidden];
    [self.navigationController.navigationBar setOverlayerHidden:hidden];
    objc_setAssociatedObject(self, @selector(dmPrefersNavigationBarBackgroundViewHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -
///=============================================================================
/// @name Keyboard
///=============================================================================

- (void)autoDismissKeyboard {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    
    __weak UIViewController *weakSelf = self;
    
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [weakSelf.view addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [weakSelf.view removeGestureRecognizer:singleTapGR];
                }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}
@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - For NavigationController
////////////////////////////////////////////////////////////////////////////////

@interface DMNavigationRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>
///> 
@property (nonatomic, weak) UINavigationController *navigationController;
@end

@implementation DMNavigationRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        UIViewController *vc = self.navigationController.topViewController;
        if ([vc respondsToSelector:@selector(navigationPopActiveForType:)]) {
            [vc navigationPopActiveForType:UFQBackTypeGesture];
        }
    }
    
    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.dmPopGestureEnbled) {
        return NO;
    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.dmDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }
    
    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    // 侧滑手势触发位置
    if ([self.navigationController.topViewController respondsToSelector:@selector(navigationPopActiveForType:)]) {
        return [self.navigationController.topViewController navigationPopActiveForType:UFQBackTypeGesture];
    }
    
    return YES;
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - For viewController
////////////////////////////////////////////////////////////////////////////////

@interface UINavigationController (DMNavigation)
///> 
@property (nonatomic, strong) UIPanGestureRecognizer *dmPopGestureRecognaizer;
///> 
@property (nonatomic, strong) DMNavigationRecognizerDelegate *dmPopDelegate;
@end

@implementation UINavigationController (DMViewController)
- (void)dm_pushViewController:(UIViewController *)vc animated:(BOOL)animated {
    [self.class dmPushViewController:vc animated:animated navi:self];
    [self dm_pushViewController:vc animated:animated];
}

- (void)dm_setViewControllers:(NSArray *)vcs animated:(BOOL)animated {
    [self.class dmPushViewController:vcs.lastObject animated:animated navi:self];
    [self dm_setViewControllers:vcs animated:animated];
}

+ (void)load {
    dm_swizzleSelector([UINavigationController class], @selector(pushViewController:animated:), @selector(dm_pushViewController:animated:));
    dm_swizzleSelector([UINavigationController class], @selector(setViewControllers:animated:), @selector(dm_setViewControllers:animated:));
}

+ (void)dmPushViewController:(UIViewController *)toVC animated:(BOOL)animated
                        navi:(UINavigationController *)navi {
    if (navi.viewControllers.count>=1) {
        toVC.hidesBottomBarWhenPushed = YES;
    }
    /* Add gesture */
    if (![navi.interactivePopGestureRecognizer.view.gestureRecognizers
          containsObject:navi.dmPopGestureRecognaizer]) {
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [navi.interactivePopGestureRecognizer.view addGestureRecognizer:navi.dmPopGestureRecognaizer];
        
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [navi.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        navi.dmPopGestureRecognaizer.delegate = navi.dmPopDelegate;
        [navi.dmPopGestureRecognaizer addTarget:internalTarget action:internalAction];
        
        // Disable the onboard gesture recognizer.
        navi.interactivePopGestureRecognizer.enabled = NO;
    }
    
    /* Judge the NavigationBar Appearance changed */
    [self isNavigationBarChanged:toVC navi:navi];
}

+ (void)isNavigationBarChanged:(UIViewController *)toVC
                          navi:(UINavigationController *)navi {
    @weakify(navi);
    dmzInjectBlock block = ^(UIViewController *vc, BOOL animated) {
        // 防止内存泄漏
        @strongify(navi);
        if ([NSStringFromClass(vc.class)  isEqualToString:@"MGFaceIDIDCardDetectViewController"]) {
            [navi setNavigationBarHidden:navi.navigationBarHidden animated:animated];
        } else if (navi.navigationBarHidden != vc.dmBarHidden) {
            [navi setNavigationBarHidden:vc.dmBarHidden animated:animated];
        }
    };
    toVC.dmzInjectBlock = block;
    UIViewController *vc = navi.viewControllers.lastObject;
    if (vc && !vc.dmzInjectBlock) {
        vc.dmzInjectBlock = block;
    }
}

- (UIPanGestureRecognizer *)dmPopGestureRecognaizer {
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

- (DMNavigationRecognizerDelegate *)dmPopDelegate {
    DMNavigationRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [[DMNavigationRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}
@end




