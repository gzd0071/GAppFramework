//
//  DMHJobType.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/7/1.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHJobType.h"
#import "DMHFilterModel.h"
#import <GBaseLib/GConvenient.h>
#import <GProtocol/ViewProtocol.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>

#pragma mark - DMHJobTypeCell
///=============================================================================
/// @name DMHJobTypeCell
///=============================================================================

@interface DMHJobTypeCell: UITableViewCell
///>  
@property (nonatomic, strong) UILabel *title;
///>  
@property (nonatomic, copy) AActionBlock block;
///>  
@property (nonatomic, strong) NSMutableArray<UIButton *> *btns;
@end

@implementation DMHJobTypeCell
#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================
- (void)viewModel:(FilterItem *)model action:(nullable AActionBlock)action {
    self.title.text = model.name;
    self.block = action;
    [self addItems:model.filterItems];
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
    title.textColor = HEX(@"808080", @"AFAFB0");
    title.frame = CGRectMake(12, 14, SCREEN_WIDTH-24, 20);
    return title;
}

- (void)addItems:(NSArray<FilterItem *> *)array  {
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
            btn.backgroundColor   = btn.selected ? HEX(@"fffcf5") : [UIColor clearColor];
        }];
        [btn addEvents:UIControlEventTouchUpInside action:^{
            if (self.block) self.block(RACTuplePack(@"select", @(idx)));
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
    btn.titleLabel.font = SCREEN_WIDTH >= 320 ? FONT(14) : FONT(12);
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

@interface DMHJobType ()<UITableViewDelegate, UITableViewDataSource>
#pragma mark - inherent
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///>  
@property (nonatomic, strong) UITableView *table;
///>  
@property (nonatomic, strong) FilterItem *data;
///> 黑色背景 
@property (nonatomic, strong) UIView *back;

///>  
@property (nonatomic, assign) NSInteger fid;
///>  
@property (nonatomic, assign) NSInteger sid;
@end

@implementation DMHJobType

+ (id)show:(id)model block:(AActionBlock)block {
    DMHJobType *sub = [self viewWithFrame:CGRectZero model:model action:block];
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
    [UIView animateWithDuration:0.2 animations:^{
        self.table.frame = frame;
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
    [UIView animateWithDuration:0.2 animations:^{
        self.table.frame = frame;
        self.backgroundColor = [HEX(@"000000") colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (comp) comp(YES);
    }];
}

- (NSString *)dropType {
    return FMV_JOB_TYPE;
}

#pragma mark - Actions
///=============================================================================
/// @name Actions
///=============================================================================

- (void)actions:(RACTuple *)x fid:(NSInteger)fid {
    self.data.filterItems[self.fid].filterItems[self.sid].select = NO;
    self.fid = fid;
    self.sid = [x.second integerValue];
    self.data.filterItems[self.fid].filterItems[self.sid].select = YES;
    if (self.fid == 0 && self.sid == 0) {
        self.data.sname = @"";
    } else {
        self.data.sname = self.data.filterItems[self.fid].filterItems[self.sid].name;
    }
    [self dismiss:YES com:nil];
    NSString *jobType = self.data.filterItems[self.fid].filterItems[self.sid].value;
    NSString *name = self.data.filterItems[self.fid].filterItems[self.sid].name;
    if (_actionBlock) _actionBlock(RACTuplePack(@"jobType", jobType, name));
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
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:@"JobTypeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell viewModel:item action:^(RACTuple *x){
        [self actions:x fid:indexPath.row];
    }];
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
        @weakify(self);
        [self.data.filterItems enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            [obj.filterItems enumerateObjectsUsingBlock:^(FilterItem *sobj, NSUInteger sidx, BOOL *sstop) {
                if (sobj.select == NO) return;
                else if (self.data.sname.length) {
                    self.fid = idx;
                    self.sid = sidx;
                    *sstop = YES;
                } else {
                    self.fid = self.sid = 0;
                    sobj.select = NO;
                }
            }];
        }];
        if (self.fid == 0 && self.sid == 0 && self.data.filterItems[0].filterItems.count) {
            self.data.filterItems[0].filterItems[0].select = YES;
        }
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
}

- (UITableView *)createTableView {
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    table.showsHorizontalScrollIndicator = NO;
    [table registerClass:NSClassFromString(@"DMHJobTypeCell") forCellReuseIdentifier:@"JobTypeCell"];
    return table;
}

@end
