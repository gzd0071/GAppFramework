//
//  DMDebugEnterViewController.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDebugEnterViewController.h"
#import "DMDEnterModel.h"
#import <GRouter/GRouter.h>
#import <GBaseLib/GConvenient.h>
#import <GLogger/Logger.h>
#import <GBaseLib/UINavigationBar+DMExtend.h>

@interface DMDebugEnterViewController ()
///> 
@property (nonatomic, strong) NSArray<DMDEnterModel *> *sections;
@end

@implementation DMDebugEnterViewController

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"工具列表";
    self.view.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
    self.navigationController.navigationBar.dmBarColor = HEX(@"ffffff", @"1c1c1e");
    
    self.sections = [self getData];
    [self vdAddViews];
}

#pragma mark - GSViewDelegate
///=============================================================================
/// @name GSViewDelegate
///=============================================================================

- (NSArray *)vdViewsArray {
    NSMutableArray *mut = @[].mutableCopy;
    for (NSInteger i=0; i<self.sections.count; i++) {
        [mut addObject:@"DMDSectionView"];
    }
    [mut addObject:@"DMDCopyRightFooterView"];
    return mut;
}

- (id)vdModel:(NSInteger)idx {
    if (idx < self.sections.count) return self.sections[idx];
    return @{};
}

- (void)vdTapAction:(Class<DebuggerPluginDelegate>)cls {
    if (![cls respondsToSelector:@selector(pluginTapAction:)]) {
        LOGE(@"[DEBUGGER] => %@ no responder selector: pluginTapAction", NSStringFromClass(cls));
        return;
    }
    [cls pluginTapAction:self.navigationController];
}

#pragma mark - Data
///=============================================================================
/// @name Data
///=============================================================================

- (NSArray<DMDEnterModel *> *)getData {
    NSMutableArray<DMDEnterModel *> *mut = @[].mutableCopy;
    [self.plugins.allKeys enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        DMDEnterModel *model = [DMDEnterModel new];
        model.title = [self getPluginTypeName:obj.intValue];
        model.plugins = self.plugins[obj];
        [mut addObject:model];
    }];
    return mut;
}

- (NSString *)getPluginTypeName:(DebugPluginType)type {
    switch (type) {
        case DebugPluginTypeCommon:
            return @"常用工具";
        case DebugPluginTypeThird:
            return @"三方工具";
        case DebugPluginTypeVision:
            return @"视觉工具";
        case DebugPluginTypePerformance:
            return @"性能工具";
        default:
            return @"其他工具";
            break;
    }
}

@end
