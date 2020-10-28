//
//  GMainTab.m
//  GMainTabExample
//
//  Created by iOS_Developer_G on 2019/7/13.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "GMainTab.h"
#import <GBaseLib/GConvenient.h>
#import <CYLTabBarController/CYLTabBarController.h>

static NSString * const kGMainTabConfig = @"GMainTabConfig";

#ifndef LOG_LEVEL
    #define LOG_LEVEL LogLevelEnvironment
#endif
#import <GLogger/Logger.h>


#pragma mark - GMainTabBarDelegate
///=============================================================================
/// @name GMainTabBarDelegate
///=============================================================================

@interface GMainTabBarDelegate:NSObject<UITabBarControllerDelegate>
@end
@implementation GMainTabBarDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UIViewController *vc = viewController;
    if ([viewController isKindOfClass:UINavigationController.class]) {
        vc = [(UINavigationController *)viewController visibleViewController];
    }
    if ([vc respondsToSelector:@selector(shouldSelectTabItem)] &&
        ![(id<GMainTabDelegate>)vc shouldSelectTabItem]) {
        LOGD(@"[TAB] => %@ responder the func 'shouldSelectTabItem' to prevent select.", NSStringFromClass(vc.class));
        return NO;
    }
    if (tabBarController.selectedViewController == viewController &&
        [vc conformsToProtocol:@protocol(GMainTabDelegate)] &&
        [vc respondsToSelector:@selector(tapSelectedTapItem)]) {
        LOGD(@"[TAB] => VC:%@ confirm GMainTabDelegate and responder to selector(tapSelectedTapItem)", NSStringFromClass(vc.class));
        [(id<GMainTabDelegate>)vc tapSelectedTapItem];
    }
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    UIViewController *vc = viewController;
    if ([viewController isKindOfClass:UINavigationController.class]) {
        vc = [(UINavigationController *)viewController visibleViewController];
    }
    LOGV(@"[TAB] => VC:%@ did select", NSStringFromClass(vc.class));
    if ([vc conformsToProtocol:@protocol(GMainTabDelegate)] &&
        [vc respondsToSelector:@selector(didSelectTabItem)]) {
        LOGD(@"[TAB] => VC:%@ had confirm GMainTabDelegate and responder to selector(didSelectTabItem)", NSStringFromClass(vc.class));
        [(id<GMainTabDelegate>)vc didSelectTabItem];
    }
}
@end

@interface GNavi : UINavigationController
@end
@implementation GNavi
- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([self.topViewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
        return [self.topViewController preferredStatusBarStyle];
    }
    return [super preferredStatusBarStyle];
}
@end

@interface GPlusButton : CYLPlusButton<CYLPlusButtonSubclassing>
@end

#pragma mark - GMainTab
///=============================================================================
/// @name GMainTab
///=============================================================================

@interface GMainTab()
///> 
@property (nonatomic, strong) GMainTabBarDelegate *delegate;
///> 
@property (nonatomic, strong) id<GMainTabDataSource> dataSource;
@end

@implementation GMainTab

+ (instancetype)manager {
    static GMainTab *tab;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LOGI(@"[TAB] => Start.");
        tab = [GMainTab new];
        tab.delegate = [[GMainTabBarDelegate alloc] init];
        Class cls = NSClassFromString(kGMainTabConfig);
        if (!cls) LOGW(@"[TAB] => 配置文件%@缺少", kGMainTabConfig);
        else LOGI(@"[TAB] => Config: %@", kGMainTabConfig);
        tab.dataSource = [cls new];
    });
    return tab;
}

+ (GTask *)task {
    [GPlusButton registerPlusButton];
    [[GMainTab manager] setupLocal];
    return nil;
}

#pragma mark - Logic
///=============================================================================
/// @name Logic
///=============================================================================

- (void)setupLocal {
    id<UIApplicationDelegate> appD = [[UIApplication sharedApplication] delegate];
    appD.window = [UIApplication sharedApplication].keyWindow;
    __block BOOL initial = YES;
    appD.window.backgroundColor = HEX(^id{
        if (!initial) [self updateTabBarStyle:appD.window];
        initial = NO;
        return HEX(@"ffffff");
    }, ^id{
        if (!initial) [self updateTabBarStyle:appD.window];
        initial = NO;
        return HEX(@"1c1c1e");
    });
    UITabBarController *tab = [self tabBar];
    appD.window.rootViewController = tab;
    [appD.window makeKeyAndVisible];
    LOGI(@"[TAB] => End.");
}

- (void)updateTabBarStyle:(UIWindow *)win {
    CYLTabBarController *tab = (CYLTabBarController *)win.rootViewController;
    if (![tab isKindOfClass:CYLTabBarController.class]) return;
    tab = [self customTabBarVC:tab.viewControllers];
    if ([self.dataSource respondsToSelector:@selector(customTabBar:)]) {
        [self.dataSource customTabBar:tab.tabBar];
    }
    win.rootViewController = tab;
}

- (UITabBarController *)tabBar {
    CYLTabBarController *tabBarVC = [self customTabBarVC:[self tabBarViewControllers]];
    if ([self.dataSource respondsToSelector:@selector(customTabBar:)]) {
        [self.dataSource customTabBar:tabBarVC.tabBar];
    }
    tabBarVC.delegate = self.delegate;
    return tabBarVC;
}

- (CYLTabBarController *)customTabBarVC:(NSArray<UIViewController *> *)vcs {
    CYLTabBarController *tabBarVC = [[CYLTabBarController alloc] initWithViewControllers:vcs tabBarItemsAttributes:[self tabBarItemsAttributes] imageInsets:UIEdgeInsetsZero titlePositionAdjustment:UIOffsetMake(0, -3.5) context:@"center"];
    return tabBarVC;
}

- (NSArray<NSDictionary *> *)tabBarItemsAttributes {
    NSArray *clasArray = [self.dataSource tabItemViewControllers];
    NSMutableArray *mut = @[].mutableCopy;
    [clasArray enumerateObjectsUsingBlock:^(NSString *vcString, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[CYLTabBarItemTitle] = [self.dataSource tabItemTitles][idx];
        dict[CYLTabBarItemImage] = [self.dataSource tabItemNormalImages][idx];
        dict[CYLTabBarItemSelectedImage] = [self.dataSource tabItemSelectedImages][idx];
        [mut addObject:dict];
    }];
    return mut;
}

- (NSArray *)tabBarViewControllers {
    NSArray *clasArray = [self.dataSource tabItemViewControllers];
    NSMutableArray *mutArr = [NSMutableArray array];
    [clasArray enumerateObjectsUsingBlock:^(NSString *vcString, NSUInteger index, BOOL *stop) {
        UINavigationController *navi = [self naviWithVCClass:NSClassFromString(vcString) index:index];
        if (navi) [mutArr addObject:navi];
        else LOGW(@"[TAB] => %@不存在", vcString);
    }];
    return mutArr;
}

- (UINavigationController *)naviWithVCClass:(Class)class index:(NSInteger)idx {
    UIViewController *vc = (UIViewController *)[class new];
    if ([vc conformsToProtocol:@protocol(GMainTabDelegate)] &&
        [vc respondsToSelector:@selector(tabItemViewControllerDidInitial:)]) {
        [(id<GMainTabDelegate>)vc tabItemViewControllerDidInitial:idx];
    }
    GNavi *navi = [[GNavi alloc] initWithRootViewController:vc];
    return navi;
}

@end

@implementation GPlusButton
+ (id)plusButton {
    GPlusButton *button = [[GPlusButton alloc] init];
    if ([[GMainTab manager].dataSource respondsToSelector:@selector(customPlusButton:)]) {
        [[GMainTab manager].dataSource customPlusButton:button];
    }
    return button;
}
+ (CGFloat)multiplierOfTabBarHeight:(CGFloat)tabBarHeight {
    return  0.5;
}
+ (CGFloat)constantOfPlusButtonCenterYOffsetForTabBarHeight:(CGFloat)tabBarHeight {
    if ([[GMainTab manager].dataSource respondsToSelector:@selector(constantOffsetYPlusButton)]) {
        return [[GMainTab manager].dataSource constantOffsetYPlusButton];
    }
    return 0;
}
+ (NSUInteger)indexOfPlusButtonInTabBar {
    if ([[GMainTab manager].dataSource respondsToSelector:@selector(indexOfPlusButton)]) {
        return [[GMainTab manager].dataSource indexOfPlusButton];
    }
    return -1;
}
+ (NSString *)tabBarContext {
    if ([self indexOfPlusButtonInTabBar] == -1) return @"";
    return @"center";
}
@end
