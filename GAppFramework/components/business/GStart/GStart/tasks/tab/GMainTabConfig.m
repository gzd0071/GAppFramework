//
//  GMainTabConfig.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/10.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "GMainTabConfig.h"
#import <GBaseLib/GConvenient.h>
#import <GConst/URDConst.h>
#import <GMainTab/GMainTab.h>
#import <YYKit/UIImage+YYAdd.h>
#import <GRouter/GRouter.h>

@interface GMainTabConfig()<GMainTabDataSource>
@end

@implementation GMainTabConfig

- (BOOL)isC {
    return YES;
}

#pragma mark - Custom
///=============================================================================
/// @name Custom
///=============================================================================

- (NSArray<NSString *> *)tabItemViewControllers {
    if ([self isC]) {
        return @[@"GHomeListViewController",
                 @"DMMineViewController"
                 ];
    }
    return @[@"ViewController1",
             @"ViewController2",
             @"ViewController3"
            ];
}

- (NSArray<NSString *> *)tabItemTitles {
    if ([self isC]) return @[@"列表", @"个人中心"];
    return @[@"简历", @"职位", @"我的"];
}

- (NSArray<NSString *> *)tabItemNormalImages {
    if ([self isC]) return @[@"tab_home_normal", @"tab_mine_normal"];
    return @[@"tab_resume_normal", @"tab_job_normal", @"tab_mine_b_normal"];
}

- (NSArray<id> *)tabItemSelectedImages {
    if ([self isC]) return @[IMAGE_ND(@"tab_home_selected", @"tab_home_dark"),
                             IMAGE_ND(@"tab_mine_selected", @"tab_mine_dark")];
    return @[@"tab_resume_selected", @"tab_job_selected", @"tab_mine_b_selected"];
}

- (NSInteger)indexOfPlusButton {
    return [self isC] ? -1 : 2;
}

- (void)customTabBar:(UITabBar *)tabBar {
    if ([self isC]) {
        id normal = @{ NSForegroundColorAttributeName : HEX(@"999999", @"989899") };
        id select = @{ NSForegroundColorAttributeName : HEX(@"999999", @"ffaa00") };
#if A_IOS13_SDK
        if (@available(iOS 13.0, *)) {
            UITabBarAppearance *app  = [UITabBarAppearance new];
            app.stackedLayoutAppearance.normal.titleTextAttributes = normal;
            app.stackedLayoutAppearance.selected.titleTextAttributes = select;
            tabBar.standardAppearance = app;
        } else {
            [[UITabBarItem appearance] setTitleTextAttributes:normal forState:UIControlStateNormal];
            [[UITabBarItem appearance] setTitleTextAttributes:select forState:UIControlStateSelected];
        }
#elif
        [[UITabBarItem appearance] setTitleTextAttributes:normal forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:select forState:UIControlStateSelected];
        tabBar.backgroundImage = [UIImage imageWithColor:HEX(@"1c1c1e")];
#endif
        tabBar.backgroundColor = HEX(@"fefefe", @"000000");
        tabBar.shadowImage     = [UIImage imageWithColor:HEX(@"e5e5e5")];
    } else {
        tabBar.shadowImage     = [[UIImage imageNamed:@"tab_topline"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0.1, 0, 0.1) resizingMode:UIImageResizingModeStretch];
        tabBar.backgroundColor = HEX(@"ffffff", @"000000");
        tabBar.backgroundImage = [UIImage imageWithColor:HEX(@"ffffff", @"1c1c1e")];
        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : HEX(@"D9D9D9") }
                                                 forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : HEX(@"6699ff") }
                                                 forState:UIControlStateSelected];
    }
}

- (CGFloat)constantOffsetYPlusButton {
    return -(INDICATOR_HEIGHT/2+21.5f);
}

- (void)customPlusButton:(UIButton *)button {
    UIImage *normalButtonImage = [UIImage imageNamed:@"tab_publish"];
    UIImage *hlightButtonImage = [UIImage imageNamed:@"tab_publish"];
    [button setImage:normalButtonImage forState:UIControlStateNormal];
    [button setImage:hlightButtonImage forState:UIControlStateHighlighted];
    [button setImage:hlightButtonImage forState:UIControlStateSelected];
    [button setTitle:@"发布" forState:UIControlStateNormal];
    [button setTitleColor:HEX(@"D9D9D9") forState:UIControlStateNormal];
    [button setTitleColor:HEX(@"D9D9D9") forState:UIControlStateSelected];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(65+7.5, -65, 0, 0);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    [button sizeToFit];
    button.frame = CGRectMake(0.0, 0.0, 65, 65);
    [button addTarget:self action:@selector(btnTap) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnTap {
    
}

@end
