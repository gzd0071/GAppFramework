//
//  DMHZoneCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/21.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHZoneCell.h"
#import "DMHListModel.h"
#import <GBaseLib/GConvenient.h>
#import <GProtocol/ViewProtocol.h>

#define kZONE_WIDTH 146
#define kZONE_PAD   12

@interface ZoneCell : UITableViewCell
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHZone *model;
///>  
@property (nonatomic, strong) NSIndexPath *path;

///> 视图: 标题 
@property (nonatomic, strong) UIImageView *contain;
///> 视图: 滚动视图 
@property (nonatomic, strong) UILabel *title;
///> 视图: 底线 
@property (nonatomic, strong) UILabel *sub;
@end

@implementation ZoneCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    DMHZone *model = x.first;
    _title.text = model.title;
    _model = model;
    _actionBlock = action;
    [_contain setImageWithURL:[NSURL URLWithString:model.image]];
    _sub.text = model.subtitle;
}

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        self.clipsToBounds = YES;
        self.contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self addViews];
    }
    return self;
}

- (void)addViews {
    [self initView];
    [self.contentView addSubview:self.contain];
    [self.contain addSubview:self.title];
    [self.contain addSubview:self.sub];
    
    _title.frame = CGRectMake(10, 22, kZONE_WIDTH-20, 16);
    _sub.frame   = CGRectMake(10, 48, kZONE_WIDTH-20, 12);
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UIImageView *)contain {
    if (!_contain) {
        _contain = [UIImageView new];
        _contain.contentMode = UIViewContentModeScaleToFill;
        _contain.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        _contain.frame = CGRectMake(6, 0, kZONE_WIDTH, 90);
        
        @weakify(self);
        [_contain addTapGesture:^{
            @strongify(self);
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"zone", self.model, self.path));
        }];
    }
    return _contain;
}

- (UILabel *)createLabel {
    UILabel *label = [UILabel new];
    label.font = FONT(16);
    label.textColor = HEX(@"404040");
    return label;
}

- (void)initView {
    UILabel *title = [self createLabel];
    title.font = FONT_BOLD(16);
    self.title = title;
    
    UILabel *sub = [UILabel new];
    sub.font = FONT(12);
    sub.textColor = HEX(@"404040");
    self.sub = sub;
}
@end

@interface DMHZoneCell()<UITableViewDelegate, UITableViewDataSource>
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHPanelModel *model;
///>  
@property (nonatomic, strong) NSIndexPath *path;

///> 视图: 标题 
@property (nonatomic, strong) UILabel *title;
///> 视图: 关闭 
@property (nonatomic, strong) UIImageView *close;
///> 视图: 滚动视图 
@property (nonatomic, strong) UITableView *scroll;
///> 视图: 底线 
@property (nonatomic, strong) UIView *line;
@end

@implementation DMHZoneCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    DMHPanelModel *model = x.first;
    _model = model;
    _path = x.second;
    _actionBlock = action;
    
    _line.frame = CGRectMake(16, model.cellHeight-0.5, SCREEN_WIDTH-32, HALFPixal);
    _line.hidden = (_path.row == REFRESH_POSITION);
    [self.scroll reloadData];
}

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        self.clipsToBounds = YES;
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.title = [self createLabel];
    self.title.text = @"职位专区";
    self.line  = [self createLine:HEX(@"e5e5e5", @"303033")];
    self.close = [[UIImageView alloc] initWithImage:IMAGE(@"home_close")];
    @weakify(self);
    [self.close addTapGesture:^(id x) {
        @strongify(self);
        if (self.actionBlock) self.actionBlock(RACTuplePack(@"interest", self.path, @42, self.model));
    }];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.close];
    [self.contentView addSubview:self.scroll];
    [self.contentView addSubview:self.line];
    
    _title.frame = CGRectMake(16, 20, SCREEN_WIDTH-68, 18);
    _close.frame = CGRectMake(SCREEN_WIDTH-36, 22, 20, 14);
}

#pragma mark - DataSource
///=============================================================================
/// @name DataSource
///=============================================================================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.model.list[indexPath.row];
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:@"ZoneCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    @weakify(self);
    [cell viewModel:RACTuplePack(item, indexPath) action:^(RACTuple *x){
        @strongify(self);
        if (self.actionBlock) self.actionBlock([x tupleByAddingObject:self.model]);
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kZONE_WIDTH+12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionBlock) self.actionBlock(RACTuplePack(@"exposure", self.model, self.path, self.model.list[indexPath.row], @(indexPath.row)));
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UITableView *)scroll {
    if (!_scroll) {
        _scroll = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, 101-SCREEN_WIDTH/2, 90, SCREEN_WIDTH) style:UITableViewStyleGrouped];
        _scroll.showsVerticalScrollIndicator = NO;
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        _scroll.clipsToBounds = NO;
        _scroll.delegate = self;
        _scroll.dataSource = self;
        _scroll.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        _scroll.separatorStyle = UITableViewCellSeparatorStyleNone;
        _scroll.transform = CGAffineTransformMakeRotation(-M_PI/2);
        [_scroll registerClass:NSClassFromString(@"ZoneCell") forCellReuseIdentifier:@"ZoneCell"];
    }
    return _scroll;
}

- (UILabel *)createLabel {
    UILabel *label = [UILabel new];
    label.font = FONT_BOLD(16);
    label.textColor = HEX(@"404040", @"dddddd");
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (UIView *)createLine:(UIColor *)color {
    UIView *view = [UIView new];
    view.backgroundColor = color;
    return view;
}

@end

