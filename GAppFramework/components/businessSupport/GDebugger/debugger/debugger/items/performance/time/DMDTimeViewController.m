//
//  DMDTimeViewController.m
//  Debugger
//
//  Created by iOS_Developer_G on 2019/10/16.
//

#import "DMDTimeViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GRouter/GRouter.h>
#import <GProtocol/ViewProtocol.h>
#import <GLogger/Logger.h>
#import "DMCallTraceListViewController.h"
#import <GBaseLib/GConvenient.h>

////////////////////////////////////////////////////////////////////////////////
/// @@class
////////////////////////////////////////////////////////////////////////////////

@interface DMDTimeMananger : NSObject
///>
@property (nonatomic, strong) NSMutableArray *times;
@end
@implementation DMDTimeMananger
+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:[DMDTimeMananger manager] selector:@selector(timePost:) name:ALoggerTimeLogNotification object:nil];
}
+ (instancetype)manager {
    static DMDTimeMananger *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DMDTimeMananger new];
        manager.times = @[].mutableCopy;
    });
    return manager;
}
- (void)timePost:(NSNotification *)noti {
    NSDictionary *dict = noti.object;
    [self.times addObject:dict];
}
@end

@interface UIViewController (DMDTime)
@end
@implementation  UIViewController (DMDTime)
+ (void)load {
    LOGT(@"Start1");
    __block id observer =
    [[NSNotificationCenter defaultCenter]
     addObserverForName: @"UIApplicationDidFinishLaunchingNotification"
     object:nil
     queue:nil
     usingBlock:^(NSNotification *note) {
         LOGT(@"Start1", @"冷启动1[dylib-launch]");
         LOGT(@"Start2");
         [[NSNotificationCenter defaultCenter] removeObserver:observer];
     }];
    dm_swizzleSelector([UIViewController class], @selector(viewDidAppear:), @selector(dmd_viewDidAppear:));
}
- (void)dmd_viewDidAppear:(BOOL)animated {
    LOGTES(@"Start2", @"冷启动2[launch-appear]");
    [self dmd_viewDidAppear:animated];
}
@end


@interface DMDTimeViewController ()<UITableViewDelegate, UITableViewDataSource>
///> 视图
@property (nonatomic, strong) UITableView *tableView;
///>
@property (nonatomic, strong) NSArray *times;
@end

@implementation DMDTimeViewController

#pragma mark - DebuggerPluginDelegate
///=============================================================================
/// @name DebuggerPluginDelegate
///=============================================================================

+ (NSString *)pluginName {
    return @"时间分析";
}

+ (UIImage *)pluginIcon {
    return [UIImage imageNamed:@"doraemon_method_use_time@3x"];
}

+ (void)pluginTapAction:(UINavigationController *)navi {
    DMDTimeViewController *vc = [DMDTimeViewController new];
    [navi pushViewController:vc animated:YES];
}

#pragma mark - DebuggerPluginDelegate
///=============================================================================
/// @name DebuggerPluginDelegate
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [self.class pluginName];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    @weakify(self);
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

- (void)handleAction:(RACTuple *)data idx:(NSInteger)idx {
    
}

- (NSArray *)sectionFirst {
    return @[@{@"name":@"方法耗时列表"}];
}

- (NSArray *)sectionZero {
    if (self.times) return self.times;
    NSMutableArray *times = @[].mutableCopy;
    [[DMDTimeMananger manager].times enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [times addObject:@{@"name":obj[@"name"]?:@"", @"value": [self formatTime:[obj[@"time"] floatValue]]}];
    }];
    self.times = times;
    return self.times;
}
- (NSString *)formatTime:(NSTimeInterval)pad {
    NSTimeInterval old = pad;
    pad = pad / 1000.0;
    if (pad >= 3600 * 24) {
        return [NSString stringWithFormat:@"%ldd", (long)(pad/(3600 *24))];
    } else if (pad >= 3600) {
        return [NSString stringWithFormat:@"%ldh", (long)(pad/(3600))];
    } else if (pad >= 60) {
        return [NSString stringWithFormat:@"%ldmin", (long)(pad/(60))];
    } else if (pad >= 1) {
        return [NSString stringWithFormat:@"%.2fs", pad];
    } else if (pad >= 0.001) {
           return [NSString stringWithFormat:@"%ldms", (long)(pad * 1000)];
       } else {
           return [NSString stringWithFormat:@"%ldμs", (long)(pad * 1000000)];
       }
}

#pragma mark - Table Delegate
///=============================================================================
/// @name Table Delegate
///=============================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [self sectionZero].count;
    return [self sectionFirst].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id identi = indexPath.section == 0 ? @"DMDAppInfoCell" : @"DMDAppInfoCell";
    NSArray *models = indexPath.section == 1 ? [self sectionFirst] : [self sectionZero];
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:identi forIndexPath:indexPath];
    @weakify(self);
    BOOL isLast = indexPath.row == models.count - 1;
    [cell viewModel:RACTuplePack(models[indexPath.row], @(isLast)) action:^(id x){
        @strongify(self);
        [self handleAction:x idx:indexPath.row];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        id vc = [DMCallTraceListViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView<ViewDelegate> *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DMDAppInfoHeader"];
    [view viewModel:@[@{@"title":@"用时统计"},
                      @{@"title":@"方法耗时"}][section] action:^(id x){
                      }];
    return view;
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = HEX(@"f7f7f7", @"000000");
        [_tableView registerClass:NSClassFromString(@"DMDLogCell") forCellReuseIdentifier:@"DMDLogCell"];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoCell") forCellReuseIdentifier:@"DMDAppInfoCell"];
        [_tableView registerClass:NSClassFromString(@"DMDAppInfoHeader") forHeaderFooterViewReuseIdentifier:@"DMDAppInfoHeader"];
        _tableView.tableFooterView = [NSClassFromString(@"DMDCopyRightFooterView") new];
    }
    return _tableView;
}

@end
