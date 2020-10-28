//
//  DMCallTraceListViewController.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/26.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMCallTraceListViewController.h"
#import "DMCallTrace.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GRouter/GRouter.h>
#import <GProtocol/ViewProtocol.h>
#import <GBaseLib/GConvenient.h>

@interface DMCallTraceCell : UITableViewCell
///> 
@property (nonatomic, strong) UILabel *title;
///> 
@property (nonatomic, strong) UILabel *times;
///> 
@property (nonatomic, strong) UILabel *func;
///> 
@property (nonatomic, strong) UILabel *line;

///> 
@property (nonatomic, strong) UIView *leftLine;
@end

@implementation DMCallTraceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)buildUI {
    [self addSubview:self.title];
    [self addSubview:self.times];
    [self addSubview:self.func];
    [self addSubview:self.leftLine];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.times.mas_bottom).offset(10);
        make.right.equalTo(self).offset(-10);
        make.left.equalTo(self).offset(10);
    }];
    [self.times mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.left.equalTo(self.title);
        make.height.equalTo(@(20));
        make.width.equalTo(@(60));
    }];
    [self.func mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.times.mas_bottom).offset(10);
        make.left.equalTo(self.title);
        make.right.equalTo(self).offset(-20);
    }];
    [self.leftLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top).offset(10);
        make.width.equalTo(@5);
        make.height.equalTo(@30);
    }];
}

- (void)updateWithModel:(DMCallTraceModel *)model {
    self.title.text = [NSString stringWithFormat:@"[%@ %@]", model.className, model.methodName];
    self.times.text = [NSString stringWithFormat:@"%.2fms", model.timeCost * 1000];
    UIColor *color = RGB(36,147,110);
    if (model.timeCost * 1000 >= 200) {
        color = RGB(203,27,69);
    } else if (model.timeCost * 1000 >= 100) {
        color = RGB(247,217,76);
    }
    self.times.backgroundColor = color;
    self.leftLine.backgroundColor = color;
    self.func.text = model.path;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.func.preferredMaxLayoutWidth = self.func.frame.size.width;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont boldSystemFontOfSize:13];
        _title.textColor = [UIColor grayColor];
    }
    return _title;
}
- (UILabel *)times {
    if (!_times) {
        _times = [[UILabel alloc] init];
        _times.font = [UIFont systemFontOfSize:12];
        _times.textColor = [UIColor whiteColor];
        _times.layer.cornerRadius = 5;
        _times.clipsToBounds = YES;
        _times.textAlignment = NSTextAlignmentCenter;
        UIFont *font = [UIFont fontWithName:@"Menlo" size:11];
        _times.font = font ?: [UIFont fontWithName:@"Courier" size:4];
    }
    return _times;
}
- (UILabel *)func {
    if (!_func) {
        _func = [[UILabel alloc] init];
        _func.numberOfLines = 0;
        _func.font = [UIFont systemFontOfSize:12];
        _func.textColor = [UIColor lightGrayColor];
    }
    return _func;
}

- (UIView *)leftLine {
    if (!_leftLine) {
        _leftLine = [[UIView alloc] init];
    }
    return _leftLine;
}
@end


@interface DMCallTraceListViewController ()<UITableViewDelegate, UITableViewDataSource, GRouterDataDelegate>
///> 
@property (nonatomic, strong) UITableView *tableView;
///> 
@property (nonatomic, strong) NSArray<DMCallTraceModel *> *list;
@end

@implementation DMCallTraceListViewController

#pragma mark - DebuggerPluginDelegate
///=============================================================================
/// @name DebuggerPluginDelegate
///=============================================================================

+ (NSString *)pluginName {
    return @"方法耗时";
}

+ (UIImage *)pluginIcon {
    return [UIImage imageNamed:@"doraemon_method_use_time@3x"];
}

+ (void)pluginTapAction:(UINavigationController *)navi {
    DMCallTraceListViewController *vc = [DMCallTraceListViewController new];
    [navi pushViewController:vc animated:YES];
}

#pragma mark - DataRouter
///=============================================================================
/// @name DataRouter
///=============================================================================

- (void)routerPassParamters:(id)data {
    self.list = data;
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"耗时列表";
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.list) {
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            self.list = [DMCallTrace loadRecords];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
    
    [self addViews];
}

- (void)addViews {
    [self.view addSubview:self.tableView];
    @weakify(self);
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - UITableView Delegate
///=============================================================================
/// @name UITableView Delegate
///=============================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DMCallTraceModel *model = self.list[indexPath.row];
    CGRect frame = [model.path boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20*2, 999) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return 80 + frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DMCallTraceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
    [cell updateWithModel:self.list[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DMCallTraceModel *model = self.list[indexPath.row];
    if (model.subCosts) {
        UIViewController<GRouterDataDelegate> *vc = [[self.class alloc] init];
        [vc routerPassParamters:model.subCosts];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = HEX(@"e2e6e9", @"3030333");
        _tableView.backgroundColor = HEX(@"f7f7f7", @"000000");
        [_tableView registerClass:[DMCallTraceCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
        _tableView.tableFooterView = [NSClassFromString(@"DMDCopyRightFooterView") new];
    }
    return _tableView;
}

@end
