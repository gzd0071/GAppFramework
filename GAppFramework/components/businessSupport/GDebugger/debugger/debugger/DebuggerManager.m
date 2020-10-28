//
//  DebuggerManager.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DebuggerManager.h"
#import "DMDebugEnterViewController.h"
#import "DHttpServer.h"
#import <GLogger/GSocket.h>
#import <GBaseLib/GConvenient.h>

@interface DebuggerViewController : UIViewController
///>
@property (nonatomic, strong) AActionBlock block;
@end
@implementation DebuggerViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.block) self.block();
}
@end

@interface DebuggerManager ()
///> 
@property (nonatomic, strong) UIWindow *keyWindow;
///> 
@property (nonatomic, strong) UIWindow *enterWindow;
///>
@property (nonatomic, weak) UIWindow *oriKeyWindow;
///> 
@property (nonatomic, strong) NSMutableDictionary<id, NSMutableArray<Class<DebuggerPluginDelegate>> *> *plugins;
@end

@implementation DebuggerManager

+ (instancetype)manager {
    static DebuggerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DebuggerManager new];
        manager.plugins = @{}.mutableCopy;
    });
    return manager;
}

#pragma mark - logical
///=============================================================================
/// @name logical
///=============================================================================

+ (void)load {
    __block id observer =
    [[NSNotificationCenter defaultCenter]
     addObserverForName: @"UIApplicationDidFinishLaunchingNotification"
     object:nil
     queue:nil
     usingBlock:^(NSNotification *note) {
         [self start];
         [[NSNotificationCenter defaultCenter] removeObserver:observer];
     }];
}

+ (void)start {
    UIView<DMDEnterUIProtocol> * pro = [NSClassFromString(@"DMFPSLabel") new];
    [self registerCommon];
    if (![pro respondsToSelector:@selector(originRect)]) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIWindow alloc] initWithFrame:[pro originRect]];
        window.windowLevel = UIWindowLevelStatusBar + 1;
        window.backgroundColor = [UIColor clearColor];
        DebuggerViewController *vc = [DebuggerViewController new];
        window.rootViewController = vc;
        
        window.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [window addGestureRecognizer:tap];
        vc.block = ^{
            [pro becomeFirstResponder];
        };
        [vc.view addSubview:pro];
        window.hidden = NO;
        [DebuggerManager manager].keyWindow = window;
    });
    
    [GSocket startConnect];
    [DHttpServer startServer];
}

+ (void)dismiss {
    if ([DebuggerManager manager].enterWindow) {
        if ([DebuggerManager manager].oriKeyWindow != [UIApplication sharedApplication].keyWindow) {
            [[DebuggerManager manager].oriKeyWindow makeKeyAndVisible];
        }
        UINavigationController *nav = (UINavigationController *)[DebuggerManager manager].enterWindow.rootViewController;
        if (nav.viewControllers.count > 1) [nav popToRootViewControllerAnimated:NO];
        [DebuggerManager manager].enterWindow.hidden = ![DebuggerManager manager].enterWindow.hidden;
    }
}

+ (void)tapAction {
    if (![DebuggerManager manager].enterWindow) {
        [self showEnterVC];
    } else {
        if ([DebuggerManager manager].oriKeyWindow != [UIApplication sharedApplication].keyWindow) {
            [[DebuggerManager manager].oriKeyWindow makeKeyAndVisible];
        }
        UINavigationController *nav = (UINavigationController *)[DebuggerManager manager].enterWindow.rootViewController;
        if (nav.viewControllers.count > 1) [nav popToRootViewControllerAnimated:NO];
        [DebuggerManager manager].enterWindow.hidden = ![DebuggerManager manager].enterWindow.hidden;
    }
}

+ (void)showEnterVC {
    [DebuggerManager manager].oriKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    DMDebugEnterViewController *vc = [NSClassFromString(@"DMDebugEnterViewController") new];
    vc.plugins = [DebuggerManager manager].plugins;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav.navigationBar setShadowImage:[UIImage new]];
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelStatusBar - 1;
    window.backgroundColor = [UIColor clearColor];
    window.rootViewController = nav;
    window.hidden = NO;
    [DebuggerManager manager].enterWindow = window;
}


+ (void)registerCommon {
    [DebuggerManager addPlugin:NSClassFromString(@"DMDAppInfoViewController")];
    [DebuggerManager addPlugin:NSClassFromString(@"DMDSanboxViewController")];
    [DebuggerManager addPlugin:NSClassFromString(@"DMDLogViewController")];
    [DebuggerManager addPlugin:NSClassFromString(@"DMDNetHistoryViewController")];
    
    [DebuggerManager addPlugin:NSClassFromString(@"DMDTimeViewController") type:DebugPluginTypePerformance];
}

+ (UINavigationController *)navi {
    if (![DebuggerManager manager].enterWindow || [DebuggerManager manager].enterWindow.hidden) {
        return nil;
    }
    return (UINavigationController *)[DebuggerManager manager].enterWindow.rootViewController;
}

#pragma mark - ADD Plugins
///=============================================================================
/// @name 添加插件方法
///=============================================================================

+ (void)addPlugin:(Class<DebuggerPluginDelegate>)plugin {
    [self addPlugin:plugin type:DebugPluginTypeCommon];
}

+ (void)addPlugin:(Class<DebuggerPluginDelegate>)plugin type:(DebugPluginType)type {
    NSMutableArray *mut = [DebuggerManager manager].plugins[@(type)] ?: @[].mutableCopy;
    [mut addObject:plugin];
    [DebuggerManager manager].plugins[@(type)] = mut;
}

+ (void)addPlugins:(NSArray<Class<DebuggerPluginDelegate>> *)plugins {
    [self addPlugins:plugins type:DebugPluginTypeCommon];
}

+ (void)addPlugins:(NSArray<Class<DebuggerPluginDelegate>> *)plugins type:(DebugPluginType)type {
    NSMutableArray *mut = [DebuggerManager manager].plugins[@(type)] ?: @[].mutableCopy;
    [mut addObjectsFromArray:plugins];
    [DebuggerManager manager].plugins[@(type)] = mut;
}

@end
