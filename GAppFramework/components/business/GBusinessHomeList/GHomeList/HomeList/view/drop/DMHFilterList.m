//
//  DMFilterList.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/21.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHFilterList.h"
#import "DMHFilterModel.h"
#import "DMHCityModel.h"
#import <GProtocol/ViewProtocol.h>
#import <YYKit/UIImage+YYAdd.h>
#import <ReactiveObjc/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>

#define kBOTTOM_HEIGHT 64

#pragma mark - DMHAreaCell
///=============================================================================
/// @name DMHAreaCell
///=============================================================================

@interface DMHFilterCell: UITableViewCell
///>  
@property (nonatomic, strong) UILabel *title;
///>  
@property (nonatomic, strong) NSMutableArray<UIButton *> *btns;
@end

@implementation DMHFilterCell
#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(FilterItem *)model action:(nullable AActionBlock)action {
    self.title.text = model.name;
    [self addItems:model.filterItems isMulti:model.multi];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        self.btns = @[].mutableCopy;
        self.title = [self createTitle];
        [self.contentView addSubview:_title];
    }
    return self;
}

#pragma mark - GETTERS
///=============================================================================
/// @name GETTER
///=============================================================================

- (UILabel *)createTitle {
    UILabel *title = [UILabel new];
    title.font = FONT(14);
    title.textColor = HEX(@"404040", @"dddddd");
    title.frame = CGRectMake(12, 14, SCREEN_WIDTH-24, 20);
    return title;
}

- (void)addItems:(NSArray<FilterItem *> *)array isMulti:(BOOL)isMulti  {
    @weakify(self);
    [array enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        UIButton *btn;
        if (idx < self.btns.count) {
            btn = self.btns[idx];
            [btn setTitle:obj.name forState:UIControlStateNormal];
        } else {
            btn = [self btn:obj.name];
            CGFloat p = 12;
            CGFloat h = 33;
            CGFloat w = (SCREEN_WIDTH-p*5)/4;
            btn.frame = CGRectMake(idx%4*(w+p)+p, idx/4*(p+h)+43, w, h);
            [self.contentView addSubview:btn];
            [self.btns addObject:btn];
        }
        [RACObserve(obj, select) subscribeNext:^(id x) {
            btn.selected = [x boolValue];
            btn.layer.borderColor = btn.selected ? HEX(@"ffaa00").CGColor : HEX(@"e5e5e5", @"303033").CGColor;
            btn.backgroundColor   = btn.selected ? HEX(@"fffcf5", @"262628") : [UIColor clearColor];
        }];
        [btn addEvents:UIControlEventTouchUpInside action:^{
            if (!isMulti || idx == 0) {
                [array enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger sidx, BOOL *sstop) {
                    sobj.select = sobj == obj;
                }];
            } else {
                obj.select = !obj.select;
                __block BOOL hasSel = NO;
                [array enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger sidx, BOOL *sstop) {
                    if (sobj.select) hasSel = YES;
                }];
                array[0].select = !hasSel;
            }
        }];
    }];
    NSArray *mut = self.btns.copy;
    for (NSInteger i=array.count; i<mut.count; i++) {
        UIButton *btn = mut[i];
        [btn removeFromSuperview];
        [self.btns removeObject:btn];
    }
}

- (UIButton *)btn:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 2;
    btn.layer.borderColor = HEX(@"e5e5e5", @"303033").CGColor;
    btn.layer.borderWidth = 0.5;
    btn.clipsToBounds = NO;
    btn.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    btn.titleLabel.font = FONT(14);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:HEX(@"808080", @"AFAFB0") forState:UIControlStateNormal];
    [btn setTitleColor:HEX(@"404040", @"dddddd") forState:UIControlStateSelected];
    return btn;
}
@end

#pragma mark - DMHFilterList
///=============================================================================
/// @name DMHFilterList
///=============================================================================

@interface DMHFilterList ()<UITableViewDelegate, UITableViewDataSource>
#pragma mark - inherent
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///>  
@property (nonatomic, strong) UITableView *table;
///>  
@property (nonatomic, strong) FilterItem *data;
///>  
@property (nonatomic, strong) UIView *botView;
///> 黑色背景 
@property (nonatomic, strong) UIView *back;
@end

@implementation DMHFilterList

+ (id)show:(id)model block:(AActionBlock)block {
    DMHFilterList *sub = [self viewWithFrame:CGRectZero model:model action:block];
    [[UIApplication sharedApplication].keyWindow addSubview:sub];
    [sub show];
    return sub;
}

#pragma mark - Animate
///=============================================================================
/// @name Animate
///=============================================================================

- (void)show {
    CGRect frame = self.table.frame;
    frame.size.height = kMENUHEIGHT;
    CGRect bframe = self.botView.frame;
    bframe.origin.y = kMENUHEIGHT-kBOTTOM_HEIGHT;
    [UIView animateWithDuration:0.2 animations:^{
        self.table.frame = frame;
        self.botView.frame = bframe;
        self.backgroundColor = [HEX(@"000000") colorWithAlphaComponent:0.5];
    }];
}

///> DMHDropDelegate
- (void)dismiss:(BOOL)animated com:(nullable void (^)(BOOL))comp {
    _data.select = !_data.select;
    if (!animated) {
        [self removeFromSuperview];
        if (comp) comp(YES);
        return;
    }
    
    CGRect frame = self.table.frame;
    frame.size.height = 0;
    CGRect bframe = self.botView.frame;
    bframe.origin.y = -kBOTTOM_HEIGHT;
    [UIView animateWithDuration:0.2 animations:^{
        self.table.frame = frame;
        self.botView.frame = bframe;
        self.backgroundColor = [HEX(@"000000") colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (comp) comp(YES);
    }];
}

- (NSString *)dropType {
    return FMV_FILTER;
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

- (void)resetAction {
    self.data.sname = @"筛选";
    self.data.select = YES;
    [self.data.filterItems enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
        [obj.filterItems enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger sidx, BOOL *sstop) {
            sobj.select = sidx == 0;
        }];
    }];
}

- (void)confirmAction {
    NSMutableDictionary *mut = @{}.mutableCopy;
    __block NSInteger isFirst = 1;
    [self.data.filterItems enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
        [obj.filterItems enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger sidx, BOOL *sstop) {
            if (sobj.select == NO) return;
            obj.selIdx = sidx;
            isFirst = isFirst & (sidx==0);
            mut[obj.key] = sobj.value;
            *stop = NO;
        }];
    }];
    self.data.sname = isFirst ? @"" : @"筛选";
    [self dismiss:YES com:nil];
    if (_actionBlock) _actionBlock(RACTuplePack(@"more", mut));
}

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (id)viewWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    return [[self alloc] initWithFrame:frame model:model action:action];
}

#pragma mark - Delegate
///=============================================================================
/// @name Delegate
///=============================================================================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.filterItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.data.filterItems[indexPath.row];
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell viewModel:item action:nil];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 43 + ((self.data.filterItems[indexPath.row].filterItems.count-1) / 4 + 1) * 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    CGFloat y = STATUSBAR_HEIGHT+93;
    CGRect rect = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT-y);
    if (self = [super initWithFrame:rect]) {
        self.actionBlock = action;
        self.clipsToBounds = YES;
        self.data = model;
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        [self.data.filterItems enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
            [obj.filterItems enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger sidx, BOOL *sstop) {
                sobj.select = obj.selIdx == sidx;
            }];
        }];
        [self addViews];
    }
    return self;
}

- (void)addTap {
    @weakify(self);
    [_back addTapGesture:^{
        @strongify(self);
        [self dismiss:YES com:nil];
        if (self.actionBlock) self.actionBlock(RACTuplePack(@"cancel"));
    }];
}

- (void)addViews {
    self.table = [self createTableView];
    self.table.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    _back = [[UIView alloc] initWithFrame:self.bounds];
    _back.backgroundColor = [HEX(@"000000") colorWithAlphaComponent:0.0];
    [self addTap];
    
    [self addSubview:_back];
    [self addSubview:self.table];
    self.botView = [self bottomView];
    [self addSubview:self.botView];
}

- (UITableView *)createTableView {
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    table.showsHorizontalScrollIndicator = NO;
    [table registerClass:NSClassFromString(@"DMHFilterCell") forCellReuseIdentifier:@"FilterCell"];
    return table;
}

- (UIView *)bottomView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -kBOTTOM_HEIGHT, SCREEN_WIDTH, kBOTTOM_HEIGHT)];
    view.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    line.backgroundColor = HEX(@"e5e5e5", @"303033");
    [view addSubview:line];
    [view addSubview:[self resetButton]];
    [view addSubview:[self doneBtn]];
    return view;
}

- (UIButton *)resetButton {
    UIButton *resetBtn = [[UIButton alloc]init];
    [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    [resetBtn setTitleColor:HEX(@"404040") forState:UIControlStateNormal];
    resetBtn.titleLabel.font = FONT(14);
    [resetBtn setBackgroundImage:[UIImage imageWithColor:HEX(@"F5C839", @"ffbb00")] forState:UIControlStateNormal];
    [resetBtn setBackgroundImage:[UIImage imageWithColor:HEX(@"F3BB36")] forState:UIControlStateHighlighted];
    [resetBtn addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
    resetBtn.frame = CGRectMake(SCREEN_WIDTH-2*88, 16, 72, 32);
    resetBtn.clipsToBounds = YES;
    resetBtn.layer.cornerRadius = 4;
    return resetBtn;
}

- (UIButton *)doneBtn {
    UIButton *confirmBtn = [[UIButton alloc] init];
    [confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:HEX(@"404040") forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = FONT(14);
    [confirmBtn setBackgroundImage:[UIImage imageWithColor:HEX(@"F5C839", @"ffbb00")] forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[UIImage imageWithColor:HEX(@"F3BB36")] forState:UIControlStateHighlighted];
    [confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.frame = CGRectMake(SCREEN_WIDTH-88, 16, 72, 32);
    confirmBtn.clipsToBounds = YES;
    confirmBtn.layer.cornerRadius = 4;
    return confirmBtn;
}

@end

